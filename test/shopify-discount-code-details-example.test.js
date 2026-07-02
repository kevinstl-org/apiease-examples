#!/usr/bin/env node

const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

const projectRoot = path.resolve(__dirname, "..");
const exampleRoot = path.join(projectRoot, "examples", "shopify", "discount-codes", "details");

function readExampleJson(relativePath) {
  return JSON.parse(fs.readFileSync(path.join(exampleRoot, relativePath), "utf8"));
}

const lookupRequest = readExampleJson(
  "resources/requests/lookup-shopify-discount-code-details.json",
);
const lookupWidget = readExampleJson(
  "resources/widgets/lookup-shopify-discount-code-details.json",
);

assert.match(
  lookupWidget.javascript,
  /liquidParamsEmbedded:\s*JSON\.stringify\(\{\s*code:\s*code\s*\}\)/,
  "Expected the storefront widget to send the entered code via liquidParamsEmbedded.",
);

assert.deepEqual(
  lookupRequest.triggers,
  undefined,
  "Expected the storefront-facing Liquid request source not to include Storefront App Proxy triggers while the public create API rejects them.",
);

assert.match(
  lookupRequest.liquid,
  /apiEaseParameters\.liquidParams\.code/,
  "Expected the Liquid request to read liquidParamsEmbedded values from apiEaseParameters.liquidParams.",
);

assert.doesNotMatch(
  lookupRequest.liquid,
  /apiEaseParameters\.liquid\.code/,
  "Expected the Liquid request not to use the non-runtime apiEaseParameters.liquid path.",
);

assert.match(
  lookupRequest.liquid,
  /api_ease_parameters_json contains '"liquidParams"'/,
  "Expected the Liquid request to check for liquidParams before dereferencing it.",
);

assert.match(
  lookupRequest.liquid,
  /liquid_params_json = apiEaseParameters\.liquidParams \| json/,
  "Expected the Liquid request to inspect the liquidParams object before reading code.",
);

assert.match(
  lookupRequest.liquid,
  /liquid_params_json contains '"code":'/,
  "Expected the Liquid request to check for the code key inside liquidParams before dereferencing it.",
);

console.log("shopify-discount-code-details-example.test.js: passed");
