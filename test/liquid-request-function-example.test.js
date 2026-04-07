#!/usr/bin/env node

const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

const projectRoot = path.resolve(__dirname, "..");
const exampleFunctionPath = path.join(
  projectRoot,
  "docs",
  "examples",
  "resources",
  "functions",
  "example-function.json",
);
const exampleLiquidRequestPath = path.join(
  projectRoot,
  "docs",
  "examples",
  "resources",
  "requests",
  "example-liquid-request.json",
);

const exampleFunction = JSON.parse(fs.readFileSync(exampleFunctionPath, "utf8"));
const exampleLiquidRequest = JSON.parse(fs.readFileSync(exampleLiquidRequestPath, "utf8"));

assert.equal(
  exampleLiquidRequest.type,
  "liquid",
  "Expected the liquid request example to keep using the 'liquid' request type.",
);

assert.match(
  exampleLiquidRequest.liquid,
  new RegExp(String.raw`{%\s*function\s+${exampleFunction.name}\s*\(`),
  "Expected the liquid request example to call the saved function example by name with the documented inline function tag syntax.",
);

assert.match(
  exampleLiquidRequest.liquid,
  /{%\s*function\s+.+\s+as\s+\w+\s*%}/,
  "Expected the liquid request example to assign the function result with the required 'as <name>' syntax.",
);

assert.match(
  exampleLiquidRequest.liquid,
  /{{\s*\w+\.message\s*}}/,
  "Expected the liquid request example to use the returned function result in the response payload.",
);

console.log("liquid-request-function-example.test.js: passed");
