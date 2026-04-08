The goal is simple: send Shopify order data to a third-party API when an order is created.

To understand how to do that, it helps to understand what a Shopify webhook is and why you usually need something server-side in the middle.

### What is a Shopify webhook?

A webhook is Shopify's way of notifying another system when an event happens in your store.

For example, if you subscribe an endpoint to the `orders/create` webhook topic, Shopify will POST the webhook payload with the order data to that endpoint whenever a new order is created.

### Why not just send the webhook directly to the third-party API?

In some cases you can, but in most real integrations it is not enough on its own.

The third-party API usually will not expect the exact same data structure that Shopify sends. It may require:
- different field names
- a different JSON structure
- authentication headers
- additional computed values

Because of that mismatch, you usually need something in the middle to validate, transform, and forward the data.

### Why do you usually need an app or backend?

You typically need a backend layer for two reasons:

1. It provides an endpoint for Shopify to POST webhook payloads to
2. It lets you process and transform that data before sending it to the third-party API


That backend is often part of a Shopify app, but it could also be another server-side integration layer. The important part is that it acts as a bridge between Shopify and the external system.

### In simple terms, the flow looks like this:

1. A customer places an order in Shopify.
2. Shopify POSTs the `orders/create` webhook payload to your subscribed endpoint.
3. Your app or backend verifies the Shopify webhook HMAC signature, then validates and processes the payload.
4. Your app or backend calls the third-party API with properly configured order data.

The main work is building and hosting that backend, including accepting the webhook payload, validating it, and transforming it before calling the third-party API.

---

If you want to avoid building and hosting your own backend, you can use an integration runtime that handles the server-side webhook flow and outbound API call for you.

With APIEase you can:

- Trigger a request on `ORDERS_CREATE` (APIEase’s constant for Shopify’s `orders/create` webhook topic)
- Point that request at your third-party API endpoint
- Store your API credentials in a sensitive header
- Transform the payload to match the third-party API contract

For a basic integration, that is enough to forward each new order automatically.

Working example:

[github.com/kevinstl-org/apiease-examples/tree/main/examples/how-to-integrate-third-party-api-in-shopify](https://github.com/kevinstl-org/apiease-examples/tree/main/examples/how-to-integrate-third-party-api-in-shopify)