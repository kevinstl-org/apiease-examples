Theme extensions run in the storefront, so they should not call the Shopify Admin API directly. Any Liquid or JavaScript delivered to the browser is inspectable by customers, which means an Admin API access token must not be placed there.

The usual architecture is:

```text
Theme Extension -> Shopify App Proxy -> Server-Side Backend App -> Shopify Admin API
```

APIEase uses the same server-side pattern without requiring you to build and host the backend yourself:

```text
Theme Extension -> Shopify App Proxy -> APIEase -> Shopify Admin GraphQL
```

For discount codes, use Shopify Admin GraphQL `codeDiscountNodeByCode(code: $code)`. The storefront sends only the customer-entered discount code through the Shopify App Proxy. APIEase runs the Admin GraphQL request server-side using the shop's Admin API authorization and returns safe display data to the storefront.

Working example:

[https://github.com/kevinstl-org/apiease-examples/tree/main/examples/shopify/discount-codes/details](https://github.com/kevinstl-org/apiease-examples/tree/main/examples/shopify/discount-codes/details)
