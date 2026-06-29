#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

admin_request_file="$script_dir/resources/requests/lookup-shopify-discount-code-admin-graphql.json"
liquid_request_file="$script_dir/resources/requests/lookup-shopify-discount-code-details.json"
widget_file="$script_dir/resources/widgets/lookup-shopify-discount-code-details.json"
state_file="${APIEASE_RESOURCE_STATE_FILE:-$script_dir/.apiease-resource-ids.env}"

shop_domain="${1:-${APIEASE_SHOP_DOMAIN:-}}"
admin_request_id="${APIEASE_ADMIN_REQUEST_ID:-}"
liquid_request_id="${APIEASE_LIQUID_REQUEST_ID:-}"
widget_id="${APIEASE_WIDGET_ID:-}"
declare -a shop_args=()
declare -a temp_files=()

usage() {
  cat >&2 <<USAGE
Usage:
  APIEASE_SHOP_DOMAIN=your-store.myshopify.com ./create-resources.sh
  ./create-resources.sh your-store.myshopify.com

If a previous run already created the internal Admin GraphQL request, reuse it:
  APIEASE_ADMIN_REQUEST_ID=<request-id> ./create-resources.sh your-store.myshopify.com

To update a full existing install, pass or keep these ids in the generated state
file:
  APIEASE_ADMIN_REQUEST_ID=<request-id>
  APIEASE_LIQUID_REQUEST_ID=<request-id>
  APIEASE_WIDGET_ID=<widget-id>

The script reads APIEase API key and base URL configuration the same way the
apiease CLI does. The shop domain is used both for the CLI --shop-domain flag
and to replace the placeholder Shopify Admin GraphQL host in a temporary copy of
the internal Admin GraphQL request resource.

Generated ids are saved to:
  $state_file
USAGE
}

cleanup() {
  if [[ ${#temp_files[@]} -eq 0 ]]; then
    return
  fi

  for temp_file in "${temp_files[@]}"; do
    if [[ -n "$temp_file" && -f "$temp_file" ]]; then
      rm -f "$temp_file"
    fi
  done
}
trap cleanup EXIT

require_command() {
  local command_name="$1"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "$command_name is required but was not found on PATH." >&2
    return 1
  fi
}

load_state() {
  if [[ ! -f "$state_file" ]]; then
    return
  fi

  local key
  local value
  local state_shop_domain=""
  local state_admin_request_id=""
  local state_liquid_request_id=""
  local state_widget_id=""

  while IFS='=' read -r key value; do
    case "$key" in
      APIEASE_SHOP_DOMAIN)
        state_shop_domain="$value"
        ;;
      APIEASE_ADMIN_REQUEST_ID)
        state_admin_request_id="$value"
        ;;
      APIEASE_LIQUID_REQUEST_ID)
        state_liquid_request_id="$value"
        ;;
      APIEASE_WIDGET_ID)
        state_widget_id="$value"
        ;;
    esac
  done < "$state_file"

  if [[ -n "$state_shop_domain" && -n "$shop_domain" && "$state_shop_domain" != "$shop_domain" ]]; then
    echo "Ignoring resource state file for $state_shop_domain; current shop is $shop_domain." >&2
    return
  fi

  if [[ -z "$admin_request_id" ]]; then
    admin_request_id="$state_admin_request_id"
  fi
  if [[ -z "$liquid_request_id" ]]; then
    liquid_request_id="$state_liquid_request_id"
  fi
  if [[ -z "$widget_id" ]]; then
    widget_id="$state_widget_id"
  fi
}

save_state() {
  mkdir -p "$(dirname "$state_file")"

  {
    printf 'APIEASE_SHOP_DOMAIN=%s\n' "$shop_domain"
    printf 'APIEASE_ADMIN_REQUEST_ID=%s\n' "$admin_request_id"
    printf 'APIEASE_LIQUID_REQUEST_ID=%s\n' "$liquid_request_id"
    printf 'APIEASE_WIDGET_ID=%s\n' "$widget_id"
  } > "$state_file"
}

make_temp_file() {
  local label="$1"
  local temp_file

  temp_file="$(mktemp "${TMPDIR:-/tmp}/apiease-discount-code-${label}.XXXXXX.json")"
  temp_files+=("$temp_file")
  printf '%s\n' "$temp_file"
}

extract_request_id() {
  awk -F': ' '/Request ID:/ {print $2; exit}'
}

extract_widget_id() {
  awk -F': ' '/Widget ID:/ {print $2; exit}'
}

create_request() {
  local file="$1"
  local output
  local request_id

  output="$(apiease create request --file "$file" "${shop_args[@]}")"
  printf '%s\n' "$output" >&2

  request_id="$(printf '%s\n' "$output" | extract_request_id)"
  if [[ -z "$request_id" ]]; then
    echo "Could not read Request ID from apiease create output." >&2
    exit 1
  fi

  printf '%s\n' "$request_id"
}

update_request() {
  local request_id="$1"
  local file="$2"
  local output

  output="$(apiease update request --request-id "$request_id" --file "$file" "${shop_args[@]}")"
  printf '%s\n' "$output" >&2
}

create_widget() {
  local file="$1"
  local output
  local created_widget_id

  output="$(apiease create widget --file "$file" "${shop_args[@]}")"
  printf '%s\n' "$output" >&2

  created_widget_id="$(printf '%s\n' "$output" | extract_widget_id)"
  if [[ -z "$created_widget_id" ]]; then
    echo "Could not read Widget ID from apiease create output." >&2
    exit 1
  fi

  printf '%s\n' "$created_widget_id"
}

update_widget() {
  local current_widget_id="$1"
  local file="$2"
  local output

  output="$(apiease update widget --widget-id "$current_widget_id" --file "$file" "${shop_args[@]}")"
  printf '%s\n' "$output" >&2
}

resource_exists() {
  local resource_type="$1"
  local resource_id="$2"

  case "$resource_type" in
    request)
      apiease read request --request-id "$resource_id" "${shop_args[@]}" >/dev/null 2>&1
      ;;
    widget)
      apiease read widget --widget-id "$resource_id" "${shop_args[@]}" >/dev/null 2>&1
      ;;
    *)
      echo "Unsupported resource type: $resource_type" >&2
      return 1
      ;;
  esac
}

create_or_update_request() {
  local label="$1"
  local file="$2"
  local current_request_id="$3"

  if [[ -n "$current_request_id" ]]; then
    if resource_exists request "$current_request_id"; then
      echo "Updating $label request: $current_request_id" >&2
      update_request "$current_request_id" "$file"
      printf '%s\n' "$current_request_id"
      return
    fi

    echo "$label request ID was not found, creating a new request: $current_request_id" >&2
  fi

  echo "Creating $label request..." >&2
  create_request "$file"
}

create_or_update_widget() {
  local file="$1"
  local current_widget_id="$2"

  if [[ -n "$current_widget_id" ]]; then
    if resource_exists widget "$current_widget_id"; then
      echo "Updating storefront widget: $current_widget_id" >&2
      update_widget "$current_widget_id" "$file"
      printf '%s\n' "$current_widget_id"
      return
    fi

    echo "Widget ID was not found, creating a new widget: $current_widget_id" >&2
  fi

  echo "Creating storefront widget..." >&2
  create_widget "$file"
}

create_admin_request_file() {
  local output_file="$1"
  local current_request_id="${2:-}"

  SHOP_DOMAIN="$shop_domain" RESOURCE_ID="$current_request_id" INPUT_FILE="$admin_request_file" OUTPUT_FILE="$output_file" node <<'NODE'
const fs = require('fs');

const shopDomain = process.env.SHOP_DOMAIN;
const resourceId = process.env.RESOURCE_ID;
const inputFile = process.env.INPUT_FILE;
const outputFile = process.env.OUTPUT_FILE;

const resource = JSON.parse(fs.readFileSync(inputFile, 'utf8'));
if (resourceId) {
  resource.id = resourceId;
}
resource.address = resource.address.replace('your-store.myshopify.com', shopDomain);
fs.writeFileSync(outputFile, `${JSON.stringify(resource, null, 2)}\n`);
NODE
}

create_liquid_request_file() {
  local output_file="$1"
  local current_request_id="${2:-}"

  ADMIN_REQUEST_ID="$admin_request_id" RESOURCE_ID="$current_request_id" INPUT_FILE="$liquid_request_file" OUTPUT_FILE="$output_file" node <<'NODE'
const fs = require('fs');

const adminRequestId = process.env.ADMIN_REQUEST_ID;
const resourceId = process.env.RESOURCE_ID;
const inputFile = process.env.INPUT_FILE;
const outputFile = process.env.OUTPUT_FILE;

const resource = JSON.parse(fs.readFileSync(inputFile, 'utf8'));
if (resourceId) {
  resource.id = resourceId;
}
resource.liquid = resource.liquid.replaceAll(
  'lookup-shopify-discount-code-admin-graphql',
  adminRequestId,
);
delete resource.triggers;
fs.writeFileSync(outputFile, `${JSON.stringify(resource, null, 2)}\n`);
NODE
}

create_widget_file() {
  local liquid_request_id="$1"
  local output_file="$2"

  LIQUID_REQUEST_ID="$liquid_request_id" INPUT_FILE="$widget_file" OUTPUT_FILE="$output_file" node <<'NODE'
const fs = require('fs');

const liquidRequestId = process.env.LIQUID_REQUEST_ID;
const inputFile = process.env.INPUT_FILE;
const outputFile = process.env.OUTPUT_FILE;

const widget = JSON.parse(fs.readFileSync(inputFile, 'utf8'));
widget.liquid = widget.liquid.replace(
  /data-request-id="[^"]+"/,
  `data-request-id="${liquidRequestId}"`,
);
widget.javascript = widget.javascript.replaceAll(
  'lookup-shopify-discount-code-details',
  liquidRequestId,
);
fs.writeFileSync(outputFile, `${JSON.stringify(widget, null, 2)}\n`);
NODE
}

require_command apiease
require_command node
load_state

if [[ -n "$shop_domain" ]]; then
  if [[ "$shop_domain" == http://* || "$shop_domain" == https://* || "$shop_domain" == */* ]]; then
    echo "Shop domain must be a bare myshopify domain, for example your-store.myshopify.com." >&2
    exit 1
  fi

  shop_args=(--shop-domain "$shop_domain")
else
  echo "Missing shop domain." >&2
  echo "" >&2
  usage
  exit 1
fi

echo "Resource state file: $state_file"

admin_request_to_sync="$(make_temp_file "admin-graphql")"
create_admin_request_file "$admin_request_to_sync" "$admin_request_id"
admin_request_id="$(create_or_update_request "internal Shopify Admin GraphQL" "$admin_request_to_sync" "$admin_request_id")"

liquid_request_to_sync="$(make_temp_file "liquid")"
create_liquid_request_file "$liquid_request_to_sync" "$liquid_request_id"
liquid_request_id="$(create_or_update_request "storefront-facing Liquid" "$liquid_request_to_sync" "$liquid_request_id")"

widget_to_sync="$(make_temp_file "widget")"
create_widget_file "$liquid_request_id" "$widget_to_sync"
widget_id="$(create_or_update_widget "$widget_to_sync" "$widget_id")"

save_state

echo "Done."
echo "Internal Admin GraphQL request ID: $admin_request_id"
echo "Storefront-facing Liquid request ID: $liquid_request_id"
echo "Storefront widget ID: $widget_id"
echo "Saved resource IDs to: $state_file"
echo ""
echo "Required final admin step:"
echo "Add the Storefront App Proxy trigger to request ID $liquid_request_id in APIEase."
echo "Then add the APIEase app block to your theme and use widget handle: lookup-shopify-discount-code-details"
