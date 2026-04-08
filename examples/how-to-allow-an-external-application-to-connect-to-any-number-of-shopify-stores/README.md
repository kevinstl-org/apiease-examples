# How To Allow An External Application To Connect To Any Number Of Shopify Stores

This example answers the Shopify Community question by showing the smallest APIEase setup for a multi-store external application.

The key point is that there is not a generic Shopify URL that lets an arbitrary external app send a merchant to Shopify, have them pick any store, and return permanent credentials to that external app.

The supported pattern is still store-by-store app authorization. With APIEase, each merchant installs and authorizes APIEase for their own shop, APIEase stores that shop's OAuth token, and your external app can remotely execute the same saved request against whichever shop domain has already authorized the app.

## What this example does

- Creates one saved HTTP request per shop that calls the Shopify Admin GraphQL API.
- Uses APIEase automatic shop access token injection, so the request does not need an explicit `X-Shopify-Access-Token` header.
- Lets your external application call the same request ID remotely for different shops by changing the `x-shop-myshopify-domain` header.

## Files

- `resources/requests/read-shopify-order-transactions.json`: a minimal HTTP request that reads orders and their transactions from the current shop.

## Beginner-friendly steps

1. Replace `your-client-store.myshopify.com` in the request file with the actual client shop domain.
2. Create the request in APIEase for that specific shop:

```bash
apiease create request \
  --shop-domain your-client-store.myshopify.com \
  --file examples/how-to-allow-an-external-application-to-connect-to-any-number-of-shopify-stores/resources/requests/read-shopify-order-transactions.json
```

3. Confirm the stored shop token has the Shopify Admin API scopes you need.
   For order reads, that usually means `read_orders`.
   Shopify also limits order access to the last 60 days by default unless the app is approved for broader order access.
4. Generate an APIEase API key from the APIEase settings page if you do not already have one.
5. From your external application, call the saved request remotely:

```bash
curl -X POST 'https://app-admin.apiease.com/api/remote/caller/call?requestId=read-shopify-order-transactions' \
  -H 'x-apiease-api-key: replace-with-your-apiease-api-key' \
  -H 'x-shop-myshopify-domain: your-client-store.myshopify.com'
```

6. To call the same request for another client store, authorize APIEase in that store, save the same request there, and change only the `x-shop-myshopify-domain` header in the remote call.

## Why this is enough

This solves the main problem behind the question:

1. A merchant authorizes the app for one Shopify store.
2. APIEase stores that shop's OAuth token for that shop.
3. Your external application identifies the target shop with `x-shop-myshopify-domain`.
4. APIEase executes the saved request against that shop's Admin API using the stored token.

That gives you one repeatable integration pattern across many Shopify stores without making your external application handle Shopify Admin API tokens directly for each request.

## Important notes

- The request address must match the client shop domain for automatic Shopify token injection to apply.
- Do not put Shopify Admin API credentials in browser code, theme code, or widgets.
- If you need real-time push instead of polling, extend this example with a webhook-triggered request that forwards order or transaction data to your external application.
