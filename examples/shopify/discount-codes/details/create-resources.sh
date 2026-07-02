#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

admin_request_file="$script_dir/resources/requests/lookup-shopify-discount-code-admin-graphql.json"
liquid_request_file="$script_dir/resources/requests/lookup-shopify-discount-code-details.json"
widget_file="$script_dir/resources/widgets/lookup-shopify-discount-code-details.json"

shop_domain="${1:-${APIEASE_SHOP_DOMAIN:-}}"
shop_args=()

usage() {
  cat >&2 <<'USAGE'
Usage:
  APIEASE_SHOP_DOMAIN=your-store.myshopify.com ./create-resources.sh
  ./create-resources.sh your-store.myshopify.com

The script reads APIEase API key and base URL configuration the same way the
apiease CLI does. When provided, the shop domain is passed through to the CLI
with --shop-domain.
USAGE
}

require_command() {
  local command_name="$1"

  if ! command -v "$command_name" >/dev/null 2>&1; then
    echo "$command_name is required but was not found on PATH." >&2
    return 1
  fi
}

create_request() {
  local file="$1"

  apiease create request --file "$file" --auto-update-source-identifier "${shop_args[@]}"
}

create_widget() {
  local file="$1"

  apiease create widget --file "$file" --auto-update-source-identifier "${shop_args[@]}"
}

require_command apiease

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

echo "Creating internal Shopify Admin GraphQL request..."
create_request "$admin_request_file"
echo "Creating storefront-facing Liquid request..."
create_request "$liquid_request_file"
echo "Creating storefront widget..."
create_widget "$widget_file"

echo "Done."
echo "Internal Admin GraphQL request handle: lookup-shopify-discount-code-admin-graphql"
echo "Storefront-facing Liquid request handle: lookup-shopify-discount-code-details"
echo ""
echo "Add the APIEase app block to your theme and use widget handle: lookup-shopify-discount-code-details"
