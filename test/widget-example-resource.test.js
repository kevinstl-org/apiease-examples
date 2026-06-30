#!/usr/bin/env node

const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

const projectRoot = path.resolve(__dirname, "..");
const exampleWidgetPath = path.join(
  projectRoot,
  "docs",
  "examples",
  "resources",
  "widgets",
  "example-widget.json",
);

assert.ok(
  fs.existsSync(exampleWidgetPath),
  "Expected a bundled widget example at docs/examples/resources/widgets/example-widget.json.",
);

const exampleWidget = JSON.parse(fs.readFileSync(exampleWidgetPath, "utf8"));
const templateReadme = fs.readFileSync(path.join(projectRoot, "README.md"), "utf8");

assert.deepEqual(
  Object.keys(exampleWidget),
  [
    "widgetHandle",
    "widgetName",
    "liquid",
    "javascript",
    "externalJavascriptUrls",
    "disableJavascript",
  ],
  "Expected the widget example to preserve the current public widget source fields.",
);

assert.doesNotMatch(
  JSON.stringify(exampleWidget),
  /"id"\s*:/,
  "Expected the widget example not to store server-owned id metadata.",
);

assert.equal(
  typeof exampleWidget.widgetHandle,
  "string",
  "Expected the widget example to include widgetHandle as the public handle field.",
);
assert.match(
  exampleWidget.widgetHandle,
  /^[a-z0-9]+(?:-[a-z0-9]+)*$/,
  "Expected widgetHandle to be a lowercase slug identifier.",
);
assert.equal(
  typeof exampleWidget.widgetName,
  "string",
  "Expected the widget example to include widgetName as display text.",
);
assert.notEqual(
  exampleWidget.widgetName,
  exampleWidget.widgetHandle,
  "Expected widgetName to remain display text instead of the stable identifier.",
);

assert.match(
  templateReadme,
  /Widget source files keep the current public `widgetHandle` and `widgetName` field names: `widgetHandle` is the widget handle, and `widgetName` is display text\./,
  "Expected README.md to align widget field language with the unified handle contract.",
);

console.log("widget-example-resource.test.js: passed");
