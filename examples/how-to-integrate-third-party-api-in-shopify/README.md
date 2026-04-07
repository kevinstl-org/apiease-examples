# How To Integrate A Third-Party API In Shopify

This example answers the Stack Overflow question by showing the smallest APIEase setup you need to send new Shopify orders to a third-party API without building a custom backend first.

## What this example does

- Listens for APIEase's `ORDERS_CREATE` webhook trigger, which maps to Shopify's `orders/create` topic.
- Sends the webhook payload to your third-party API with APIEase.
- Keeps the third-party API token on the server as a sensitive request header.

## Files

- `resources/requests/send-shopify-order-to-third-party.json`: the APIEase HTTP request resource.

## Beginner-friendly steps

1. Replace the example API URL in the request file with your real third-party order endpoint.
2. Replace the placeholder bearer token with the real token or credential format your third-party API expects.
3. Create the request in APIEase:

```bash
apiease create request --file examples/how-to-integrate-third-party-api-in-shopify/resources/requests/send-shopify-order-to-third-party.json
```

4. Confirm the webhook event is correct for your use case:
   `ORDERS_CREATE` sends the order as soon as Shopify creates it.
   If your third-party system should only receive paid orders, change the trigger to the APIEase constant for the matching Shopify paid-order topic.
5. Run a test order in Shopify and confirm the third-party API receives it.

## Why this is enough

For this use case you do not need to start by building a full custom Shopify app. The basic pattern is:

1. Shopify creates an order.
2. APIEase receives the webhook.
3. APIEase calls the third-party API from the server.

That covers the core integration path the question is asking about.

The request does not need a saved body parameter because the latest APIEase webhook documentation says the Shopify webhook payload is already passed as the request body.

## When to extend this example

Use a more advanced APIEase flow if your third-party API needs more than a single authenticated POST:

- Add more request headers if the API needs a custom auth scheme.
- Change the body if the API expects a different payload shape.
- Add a chained authentication request if you must fetch a temporary access token before sending the order.

## Important notes

- Do not put the third-party API secret in Shopify theme code or storefront JavaScript.
- Start with manual testing before relying on live orders.
- Match the body format to the exact contract from the third-party API documentation.
