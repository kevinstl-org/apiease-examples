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
  "read function --function-id <function-id>",
  "update function --function-id <function-id> --file docs/examples/resources/functions/example-function.json",
  "delete function --function-id <function-id>",
].forEach((commandExample) => {
  assert.match(
    templateReadme,
    new RegExp(commandExample.replace(/[.*+?^${}()|[\]\\]/g, "\\$&")),
    `Expected README.md to include the command example '${commandExample}'.`,
  );
});

console.log("template-function-guidance.test.js: passed");
