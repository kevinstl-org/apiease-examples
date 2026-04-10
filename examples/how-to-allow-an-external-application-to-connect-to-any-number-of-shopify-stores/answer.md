What you are describing is a standalone Shopify app authorization flow. Your external application would be treated as a standalone app rather than a Shopify embedded Admin app.

## Standalone App Admin API Access

There is not a single universal Shopify URL that a standalone application can redirect to and then receive reusable credentials for arbitrary stores without first having a Shopify app involved. Instead, if your external application needs to connect to any number of Shopify stores owned by your clients, the normal approach is to use the [app install and authorization flow](https://shopify.dev/docs/apps/build/authentication-authorization/access-tokens/authorization-code-grant), which uses Shopify's authorization code grant flow:

- create a Shopify app using the [Dev Dashboard](https://shopify.dev/docs/apps/build/dev-dashboard/create-apps-using-dev-dashboard)
- have each client store authorize that app
- receive and store a separate access token for each shop
- use the stored shop token whenever your system needs to call Shopify later

## If your goal is transaction or order syncing

If your goal is to listen for transactions, [Shopify webhooks](https://shopify.dev/docs/apps/build/webhooks/subscribe/https) are the standard approach. After a shop authorizes your app, you register webhook subscriptions such as order events. Shopify then sends those events to your HTTPS endpoint.

Your application should verify the webhook HMAC before processing the request so you know it actually came from Shopify.

## APIEase alternative

An alternative approach is to have each store install APIEase instead.

In that model:

- APIEase handles the Shopify authorization and stores the shop access token per shop
- you configure webhook-triggered requests inside APIEase, for example for orders
- APIEase can push those events to your external application
- you can include a shared secret in those outbound calls so your external system can verify they are trusted
- your external system can also call APIEase remotely using an APIEase API key and shop domain, and APIEase will execute requests on behalf of that shop

APIEase essentially acts as the execution layer for API calls, webhooks, and workflows. It runs everything server-side and keeps credentials secure, so you do not have to build and host that infrastructure yourself.

## Working example

[View the example in this repository](https://github.com/kevinstl-org/apiease-examples/tree/main/examples/how-to-allow-an-external-application-to-connect-to-any-number-of-shopify-stores)
