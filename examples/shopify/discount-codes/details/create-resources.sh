#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

admin_request_file="$script_dir/resources/requests/lookup-shopify-discount-code-admin-graphql.json"
liquid_request_file="$script_dir/resources/requests/lookup-shopify-discount-code-details.json"
widget_file="$script_dir/resources/widgets/lookup-shopify-discount-code-details.json"

shop_domain="${1:-${APIEASE_SHOP_DOMAIN:-}}"
admin_request_id="${APIEASE_ADMIN_REQUEST_ID:-}"
shop_args=()
temp_files=()

usage() {
  cat >&2 <<'USAGE'
Usage:
  APIEASE_SHOP_DOMAIN=your-store.myshopify.com ./create-resources.sh
  ./create-resources.sh your-store.myshopify.com

If a previous run already created the internal Admin GraphQL request, reuse it:
  APIEASE_ADMIN_REQUEST_ID=<request-id> ./create-resources.sh your-store.myshopify.com

The script reads APIEase API key and base URL configuration the same way the
apiease CLI does. The shop domain is used both for the CLI --shop-domain flag
and to replace the placeholder Shopify Admin GraphQL host in a temporary copy of
the internal Admin GraphQL request resource.
USAGE
}

cleanup() {
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

create_admin_request_file() {
  local output_file="$1"

  SHOP_DOMAIN="$shop_domain" INPUT_FILE="$admin_request_file" OUTPUT_FILE="$output_file" node <<'NODE'
const fs = require('fs');

const shopDomain = process.env.SHOP_DOMAIN;
const inputFile = process.env.INPUT_FILE;
const outputFile = process.env.OUTPUT_FILE;

const resource = JSON.parse(fs.readFileSync(inputFile, 'utf8'));
resource.address = resource.address.replace('your-store.myshopify.com', shopDomain);
fs.writeFileSync(outputFile, `${JSON.stringify(resource, null, 2)}\n`);
NODE
}

create_liquid_request_file() {
  local output_file="$1"

  ADMIN_REQUEST_ID="$admin_request_id" INPUT_FILE="$liquid_request_file" OUTPUT_FILE="$output_file" node <<'NODE'
const fs = require('fs');

const adminRequestId = process.env.ADMIN_REQUEST_ID;
const inputFile = process.env.INPUT_FILE;
const outputFile = process.env.OUTPUT_FILE;

const resource = JSON.parse(fs.readFileSync(inputFile, 'utf8'));
resource.liquid = resource.liquid.replaceAll(
  'lookup-shopify-discount-code-admin-graphql',
  adminRequestId,
);
resource.parameters = (resource.parameters || []).map((parameter) => {
  if (parameter.type === 'liquid' && parameter.name === 'code' && !parameter.value) {
    return { ...parameter, value: 'replace-at-runtime' };
  }
  return parameter;
});
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

if [[ -z "$admin_request_id" ]]; then
  admin_request_to_create="$(make_temp_file "admin-graphql")"
  create_admin_request_file "$admin_request_to_create"

  echo "Creating internal Shopify Admin GraphQL request..."
  admin_request_id="$(create_request "$admin_request_to_create")"
else
  echo "Using existing internal Shopify Admin GraphQL request: $admin_request_id"
fi

liquid_request_to_create="$(make_temp_file "liquid")"
create_liquid_request_file "$liquid_request_to_create"

echo "Creating storefront-facing Liquid request..."
liquid_request_id="$(create_request "$liquid_request_to_create")"

widget_to_create="$(make_temp_file "widget")"
create_widget_file "$liquid_request_id" "$widget_to_create"

echo "Creating storefront widget..."
apiease create widget --file "$widget_to_create" "${shop_args[@]}"

echo "Done."
echo "Internal Admin GraphQL request ID: $admin_request_id"
echo "Storefront-facing Liquid request ID: $liquid_request_id"
echo ""
echo "Required final admin step:"
echo "Add the Storefront App Proxy trigger to request ID $liquid_request_id in APIEase."
echo "Then add the APIEase app block to your theme and use widget handle: lookup-shopify-discount-code-details"
