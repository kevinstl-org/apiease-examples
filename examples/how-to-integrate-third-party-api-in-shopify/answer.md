# StackOverflow Answer Draft

The goal is simple: send Shopify order data to a third-party API when an order is created.

To understand how to do that, it helps to understand what a Shopify webhook is and why you need an app.

### What is a Shopify webhook?

A webhook is a mechanism Shopify provides to notify another system when events happen in your store.

For example, if you register an endpoint for the `orders/create` webhook, Shopify will send a POST request with the order data to that endpoint whenever a new order is created.

### Why not just send the webhook directly to the third-party API?

In most cases, you cannot do this.

The third-party API will almost never expect the exact same data structure that Shopify sends. It may require:
- different field names
- a different JSON structure
- authentication headers
- additional computed values

Because of this mismatch, you need something in the middle to transform the data.

### Why do you need to create a Shopify app?

You need a backend (typically implemented as a Shopify app) for two reasons:

1. It provides an endpoint for Shopify to send webhook data to
2. It lets you process and transform that data before sending it to the third-party API

So the app acts as a bridge between Shopify and the external system.

### The actual flow

Shopify → webhook → your app/backend → third-party API


## Putting That Together

No matter how you implement it, the integration always looks like this:

1. Shopify creates an order
2. Shopify sends a webhook (`orders/create`)
3. Your backend receives the webhook
4. Your backend calls the third-party API with that data

The main work is building and hosting that backend, including receiving the webhook, validating it, and transforming the data before calling the third-party API.

---

## Minimal Alternative

If you want to avoid building and hosting your own backend, you can use an integration runtime that handles the webhook and API call for you.

For example, with APIEase:

- Configure a request triggered by `ORDERS_CREATE` (APIEase’s constant for Shopify’s `orders/create` webhook)
- Set the request address your third-party API endpoint
- Add your API credentials as a secure header
- Transform the request body as needed by the third-party API

That’s enough to forward every new order automatically.

Here is a minimal working example:

[github.com/kevinstl-org/apiease-examples/tree/main/examples/how-to-integrate-third-party-api-in-shopify](https://github.com/kevinstl-org/apiease-examples/tree/main/examples/how-to-integrate-third-party-api-in-shopify)
