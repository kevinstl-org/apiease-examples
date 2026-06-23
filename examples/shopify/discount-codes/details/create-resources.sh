#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

admin_request_file="$script_dir/resources/requests/lookup-shopify-discount-code-admin-graphql.json"
liquid_request_file="$script_dir/resources/requests/lookup-shopify-discount-code-details.json"
widget_file="$script_dir/resources/widgets/lookup-shopify-discount-code-details.json"

shop_domain="${1:-${APIEASE_SHOP_DOMAIN:-}}"
shop_args=()
admin_request_to_create="$admin_request_file"
temp_admin_request_file=""

usage() {
  cat >&2 <<'USAGE'
Usage:
  APIEASE_SHOP_DOMAIN=your-store.myshopify.com ./create-resources.sh
  ./create-resources.sh your-store.myshopify.com

This script reads APIEase API key and base URL configuration the same way the
apiease CLI does. The shop domain is used both for the CLI --shop-domain flag
and to replace the placeholder Shopify Admin GraphQL host in a temporary copy of
the internal Admin GraphQL request resource.
USAGE
}

cleanup() {
  if [[ -n "$temp_admin_request_file" && -f "$temp_admin_request_file" ]]; then
    rm -f "$temp_admin_request_file"
  fi
}
trap cleanup EXIT

if ! command -v apiease >/dev/null 2>&1; then
  echo "apiease CLI is required but was not found on PATH." >&2
  echo "Install it with: npm install -g apiease" >&2
  exit 1
fi

if [[ -n "$shop_domain" ]]; then
  if [[ "$shop_domain" == http://* || "$shop_domain" == https://* || "$shop_domain" == */* ]]; then
    echo "Shop domain must be a bare myshopify domain, for example your-store.myshopify.com." >&2
    exit 1
  fi

  temp_admin_request_file="$(mktemp "${TMPDIR:-/tmp}/apiease-discount-code-admin-graphql.XXXXXX.json")"
  sed "s#your-store.myshopify.com#$shop_domain#g" "$admin_request_file" > "$temp_admin_request_file"

  admin_request_to_create="$temp_admin_request_file"
  shop_args=(--shop-domain "$shop_domain")
else
  if grep -q "your-store.myshopify.com" "$admin_request_file"; then
    echo "Missing shop domain." >&2
    echo "" >&2
    usage
    exit 1
  fi
fi

#echo "Creating internal Shopify Admin GraphQL request..."
#apiease create request --file "$admin_request_to_create" "${shop_args[@]}"

echo "Creating storefront-facing Liquid request..."
apiease create request --file "$liquid_request_file" "${shop_args[@]}"

echo "Creating storefront widget..."
apiease create widget --file "$widget_file" "${shop_args[@]}"

echo "Done."
echo "Add the APIEase app block to your theme and use widget handle: lookup-shopify-discount-code-details"
