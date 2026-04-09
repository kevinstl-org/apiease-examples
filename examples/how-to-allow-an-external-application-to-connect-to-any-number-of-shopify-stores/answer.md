What you are describing is a standalone Shopify app authorization flow. Your external application would be treated as a standalone app rather than a Shopify embedded Admin app.

There is not a single universal Shopify URL that a standalone application can redirect to and then receive reusable credentials for arbitrary stores without first having a Shopify app involved. The app install and authorization flow is the mechanism that grants that access. [Shopify authorization code grant](https://shopify.dev/docs/apps/build/authentication-authorization/access-tokens/authorization-code-grant)

## Typical Shopify approach

If your external application needs to connect to any number of Shopify stores owned by your clients, the normal approach is to:

- create a Shopify app in the Dev Dashboard. [Create apps in the Dev Dashboard](https://shopify.dev/docs/apps/build/dev-dashboard/create-apps-using-dev-dashboard)
- have each client store authorize that app
- receive and store a separate access token for each shop
- subscribe each shop to webhooks if you want Shopify to push events such as orders to you
- use the stored shop token whenever your system needs to call Shopify later

For standalone apps, Shopify uses the authorization code grant flow. That flow is what allows a merchant to log in, select their store, and grant your application access. Once completed, your server receives a shop-specific access token, which you store and use for future API calls. [Shopify authorization code grant](https://shopify.dev/docs/apps/build/authentication-authorization/access-tokens/authorization-code-grant)

## If your goal is transaction or order syncing

If your goal is to listen for transactions, Shopify webhooks are the standard approach. After a shop installs your app, you register webhook subscriptions such as order events. Shopify then sends those events to your HTTPS endpoint. [Shopify HTTPS webhooks](https://shopify.dev/docs/apps/build/webhooks/subscribe/https)

Your application should verify the webhook HMAC before processing the request so you know it actually came from Shopify.

In practice, your external system becomes a multi-tenant system keyed by shop:

- each shop installs and authorizes your app
- you store an access token per shop
- you receive events via webhooks and/or call the Admin API using that token

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
