#!/usr/bin/env node

const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

const projectRoot = path.resolve(__dirname, "..");

function readProjectFile(relativePath) {
  return fs.readFileSync(path.join(projectRoot, relativePath), "utf8");
}

const agentsGuidance = readProjectFile("AGENTS.md");
const templateReadme = readProjectFile("README.md");

assert.match(
  agentsGuidance,
  /requests, widgets, variables, functions, and triggers/,
  "Expected AGENTS.md to include functions in the primary APIEase resource guidance sentence.",
);

assert.match(
  agentsGuidance,
  /`resources\/functions` contains function resources\./,
  "Expected AGENTS.md to describe the resources/functions directory alongside the other resource directories.",
);

assert.match(
  templateReadme,
  /- `resources\/functions`/,
  "Expected README.md to list resources/functions in the core template resource model.",
);

assert.match(
  templateReadme,
  /docs\/examples\/resources\/functions\/example-function\.json/,
  "Expected README.md to reference the bundled function example file.",
);

assert.match(
  templateReadme,
  /- `function`/,
  "Expected README.md to list function as a supported resource type.",
);

[
  "create function --file docs/examples/resources/functions/example-function.json",
  "read function --function-handle <function-handle>",
  "update function --function-handle <function-handle> --file docs/examples/resources/functions/example-function.json",
  "delete function --function-handle <function-handle>",
].forEach((commandExample) => {
  assert.match(
    templateReadme,
    new RegExp(commandExample.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")),
    `Expected README.md to include the command example '${commandExample}'.`,
  );
});

[
  "read widget --widget-handle <widget-handle>",
  "read variable --variable-handle <variable-handle>",
  "update widget --widget-handle <widget-handle> --file docs/examples/resources/widgets/example-widget.json",
  "update variable --variable-handle <variable-handle> --file docs/examples/resources/variables/example-variable.json",
  "delete widget --widget-handle <widget-handle>",
  "delete variable --variable-handle <variable-handle>",
].forEach((commandExample) => {
  assert.match(
    templateReadme,
    new RegExp(commandExample.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")),
    `Expected README.md to use a handle placeholder in the command example '${commandExample}'.`,
  );
});

[
  "<widget-id>",
  "<variable-name>",
  "<function-id>",
].forEach((legacyIdentifierPlaceholder) => {
  assert.doesNotMatch(
    templateReadme,
    new RegExp(legacyIdentifierPlaceholder.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")),
    `Expected README.md not to prefer the legacy identifier placeholder '${legacyIdentifierPlaceholder}'.`,
  );
});

assert.match(
  templateReadme,
  /Create commands read the resource handle from the JSON file\./,
  "Expected README.md to explain that create flows use handles from source JSON files.",
);

assert.match(
  templateReadme,
  /Requests, widgets, variables, and functions should use `handle` as the stable public identifier\./,
  "Expected README.md to describe handle as the preferred identifier for every supported resource type.",
);

assert.match(
  templateReadme,
  /Function source files include `handle` as the target stable identifier\./,
  "Expected README.md to describe Function source files as handle-first.",
);

assert.match(
  templateReadme,
  /Liquid Function tag supports `functionName` or `functionId`, but not a handle-named field yet\./,
  "Expected README.md to document the current Liquid Function handle invocation deferral.",
);

console.log("template-function-guidance.test.js: passed");
