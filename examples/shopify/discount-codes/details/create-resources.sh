#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

admin_request_file="$script_dir/resources/requests/lookup-shopify-discount-code-admin-graphql.json"
liquid_request_file="$script_dir/resources/requests/lookup-shopify-discount-code-details.json"
widget_file="$script_dir/resources/widgets/lookup-shopify-discount-code-details.json"

shop_domain="${1:-${APIEASE_SHOP_DOMAIN:-}}"
shop_args=()
admin_request_to_create=""

usage() {
  cat >&2 <<'USAGE'
Usage:
  APIEASE_SHOP_DOMAIN=your-store.myshopify.com ./create-resources.sh
  ./create-resources.sh your-store.myshopify.com

The script reads APIEase API key and base URL configuration the same way the
apiease CLI does. The shop domain is used both for the CLI --shop-domain flag
and to replace the placeholder Shopify Admin GraphQL host in a temporary copy of
the internal Admin GraphQL request resource.
USAGE
}

cleanup() {
  if [[ -n "${admin_request_to_create:-}" && -f "$admin_request_to_create" ]]; then
    rm -f "$admin_request_to_create"
  fi
}
trap cleanup EXIT

require_command() {
  local command_name="$1"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "$command_name is required but was not found on PATH." >&2
    return 1
  fi
}

create_request() {
  local file="$1"

  apiease create request --file "$file" "${shop_args[@]}"
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

admin_request_to_create="$(mktemp "${TMPDIR:-/tmp}/apiease-discount-code-admin-graphql.XXXXXX.json")"
create_admin_request_file "$admin_request_to_create"

echo "Creating internal Shopify Admin GraphQL request..."
create_request "$admin_request_to_create"
echo "Creating storefront-facing Liquid request..."
create_request "$liquid_request_file"
echo "Creating storefront widget..."
apiease create widget --file "$widget_file" "${shop_args[@]}"

echo "Done."
echo "Internal Admin GraphQL request handle: lookup-shopify-discount-code-admin-graphql"
echo "Storefront-facing Liquid request handle: lookup-shopify-discount-code-details"
echo ""
echo "Required final admin step:"
echo "Add the Storefront App Proxy trigger to request handle lookup-shopify-discount-code-details in APIEase."
echo "Then add the APIEase app block to your theme and use widget handle: lookup-shopify-discount-code-details"
