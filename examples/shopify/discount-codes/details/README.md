# Lookup Shopify Discount Code Details From A Theme Extension

This example shows how a Shopify storefront or theme extension can look up discount code details without calling the Shopify Admin API from browser-delivered code.

Theme extensions run in the storefront. Storefront JavaScript and Liquid are inspectable by customers, so they should not contain Shopify Admin API access tokens. This example sends only the discount code from the storefront to APIEase through Shopify App Proxy. APIEase runs the Shopify Admin GraphQL request server-side and returns safe display data.

The widget follows APIEase's documented runtime embedded Liquid parameter pattern and sends only the entered discount code to the Liquid request.

Architecture:

```text
Theme Extension -> Shopify App Proxy -> APIEase -> Shopify Admin GraphQL
```

## What this example does

- Adds a storefront widget with a discount code text input, lookup button, loading state, error state, not-found state, and successful result display.
- Creates a storefront-facing Liquid request that accepts only the discount code through `liquidParamsEmbedded`.
- Creates an internal HTTP request that calls Shopify Admin GraphQL `codeDiscountNodeByCode`.
- Uses APIEase automatic shop access token behavior for the Shopify Admin API request. No Shopify Admin API token, APIEase API key, or private credential appears in the widget code.
- Returns display-oriented JSON with common fields for basic code discounts and fallback details for other discount code types.

## Files

- `resources/requests/lookup-shopify-discount-code-admin-graphql.json`: the internal Shopify Admin GraphQL HTTP request.
- `resources/requests/lookup-shopify-discount-code-details.json`: the storefront-facing Liquid request that shapes the response. Add the Storefront App Proxy trigger to this request in the APIEase admin after creating it.
- `resources/widgets/lookup-shopify-discount-code-details.json`: the reusable storefront widget.
- `answer.md`: short community-answer copy that links to this example.

## Beginner-friendly steps

1. Replace `your-store.myshopify.com` in `lookup-shopify-discount-code-admin-graphql.json` with the shop domain where APIEase is installed.
2. Confirm APIEase has the Shopify Admin API `read_discounts` scope for that shop.
   This example also requests product and collection display fields when a discount targets them, so confirm the shop token has the related read access if Shopify enforces it for your selected fields.
3. Create the internal Admin GraphQL request:

```bash
apiease create request --file examples/shopify/discount-codes/details/resources/requests/lookup-shopify-discount-code-admin-graphql.json
```

4. Create the storefront-facing Liquid request:

```bash
apiease create request --file examples/shopify/discount-codes/details/resources/requests/lookup-shopify-discount-code-details.json
```

5. Create the widget:

```bash
apiease create widget --file examples/shopify/discount-codes/details/resources/widgets/lookup-shopify-discount-code-details.json
```

For a working install, prefer the script below. It passes `--auto-update-source-identifier` so `apiease-cli` can migrate source identifiers in the resource files it creates from.

```bash
APIEASE_SHOP_DOMAIN=your-store.myshopify.com examples/shopify/discount-codes/details/create-resources.sh
```

6. Add the Storefront App Proxy trigger to the Liquid request in the APIEase admin. The Liquid request handle is `lookup-shopify-discount-code-details`.
7. Add the APIEase app block to the desired theme template or page and set the widget handle to `lookup-shopify-discount-code-details`.
8. Test with an existing discount code.

The public resource API used by `apiease create request` may not support creating the Storefront App Proxy trigger directly. The runtime trigger type for storefront calls is `storefrontAppProxy`, but add it from the APIEase admin when the public API rejects that trigger field.

If you use the manual commands instead of the script, replace `your-store.myshopify.com` in the Admin GraphQL request file before creating it.

## Why this is safe

The browser only sends:

```json
{ "code": "SAVE10" }
```

The GraphQL query, Shopify Admin API endpoint, and shop access token behavior stay inside APIEase. The internal Admin GraphQL HTTP request does not have a storefront trigger, so the widget cannot directly execute arbitrary Admin API calls.

## Response shape

Successful lookup responses are shaped like:

```json
{
  "ok": true,
  "found": true,
  "code": "SAVE10",
  "title": "10% off Diamond Ring #1",
  "type": "DiscountCodeBasic",
  "status": "ACTIVE",
  "startsAt": "2026-01-01T00:00:00Z",
  "endsAt": null,
  "usageLimit": null,
  "usageCount": 3,
  "valueSummary": "10% off selected products",
  "minimumRequirement": "None",
  "eligibleProducts": [],
  "eligibleCollections": [],
  "rawType": "DiscountCodeBasic"
}
```

Not-found responses are shaped like:

```json
{
  "ok": true,
  "found": false,
  "code": "BADCODE",
  "message": "No discount code was found for BADCODE."
}
```

Error responses are shaped like:

```json
{
  "ok": false,
  "message": "Unable to lookup discount code."
}
```

## When to extend this example

Use this as the root pattern for related discount-code examples:

- Show eligible products for a discount code.
- Show eligible collections for a discount code.
- Validate whether a discount applies to the current product.
- Validate whether a discount applies to the current cart.
- Show active discount codes.
- Show discounts available to a logged-in customer.
- Show automatic discounts.
- Build promotion finder widgets.

## Important notes

- Use Shopify Admin GraphQL for discount definition lookup, not Storefront GraphQL.
- `codeDiscountNodeByCode(code: $code)` is the right lookup when the storefront input is a discount code string.
- The Shopify Admin API request requires the `read_discounts` access scope.
- Product and collection display fields may require the related Shopify Admin API read access in addition to `read_discounts`.
- Do not put `X-Shopify-Access-Token` in theme code, widget JavaScript, or any browser-delivered Liquid.
- If you use an explicit `X-Shopify-Access-Token` header for a local demo, store it as a sensitive APIEase request parameter. Do not place it in the widget.

## Official links

- [Shopify codeDiscountNodeByCode](https://shopify.dev/docs/api/admin-graphql/latest/queries/codeDiscountNodeByCode)
- [Shopify DiscountCodeNode](https://shopify.dev/docs/api/admin-graphql/latest/objects/DiscountCodeNode)
- [Shopify DiscountCodeBasic](https://shopify.dev/docs/api/admin-graphql/latest/objects/DiscountCodeBasic)
- [APIEase documentation](https://docs.apiease.com/)
