What you are describing is a standalone Shopify app authorization flow. Your external application would be treated as a standalone app rather than a Shopify embedded Admin app.

## Standalone App Admin API Access

There is not a single universal Shopify URL that an app can redirect to and then receive reusable credentials for arbitrary stores without first having a Shopify app involved. Instead, if your external application needs to connect to any number of Shopify stores owned by your clients, the normal approach is to use the [app install and authorization flow](https://shopify.dev/docs/apps/build/authentication-authorization/access-tokens/authorization-code-grant), which uses Shopify's authorization code grant flow:

- Create a Shopify app using the [Dev Dashboard](https://shopify.dev/docs/apps/build/dev-dashboard/create-apps-using-dev-dashboard)
- Have each client store authorize that app
- Receive and store a separate access token for each shop
- Use the stored shop token whenever your system needs to call Shopify later

## Data Synchronization

If your goal is to listen for transactions, [Shopify webhooks](https://shopify.dev/docs/apps/build/webhooks/subscribe/https) are the standard approach. After a shop authorizes your app, you register webhook subscriptions such as order events. Shopify then sends those events to your HTTPS endpoint.

Your application should verify the webhook HMAC before processing the request so you know it actually came from Shopify.

## APIEase Option

An alternative approach is to have each store install APIEase instead:

- APIEase handles the Shopify authorization and stores the shop access token per shop
- You configure webhook-triggered requests inside APIEase, for example for orders
- APIEase can push those events to your external application
- You can include a shared secret in those outbound calls so your external system can verify they are trusted
- Your external system can also call APIEase remotely using an APIEase API key and shop domain, and APIEase will execute requests on behalf of that shop

APIEase lets you define and run API integrations, workflows, and storefront logic without building or maintaining your own backend.

Working example of this approach:

https://github.com/kevinstl-org/apiease-examples/tree/main/examples/how-to-allow-an-external-application-to-connect-to-any-number-of-shopify-stores