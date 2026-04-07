#!/usr/bin/env node

const assert = require("node:assert/strict");
const fs = require("node:fs");
const path = require("node:path");

const projectRoot = path.resolve(__dirname, "..");
const config = require(path.join(projectRoot, "apiease.config.js"));

function expectDirectoryExists(directoryPath, errorMessage) {
  assert.ok(fs.existsSync(directoryPath), errorMessage);
  assert.ok(fs.statSync(directoryPath).isDirectory(), errorMessage);
}

assert.ok(config.resources, "Expected apiease.config.js to export a resources object.");

assert.equal(
  config.resources.functionsDirectory,
  "functions",
  "Expected resources.functionsDirectory to be set to 'functions'.",
);

const resourceRootDirectory = path.join(projectRoot, config.resources.rootDirectory);
expectDirectoryExists(
  resourceRootDirectory,
  "Expected the configured resources root directory to exist.",
);

[
  config.resources.requestsDirectory,
  config.resources.widgetsDirectory,
  config.resources.variablesDirectory,
  config.resources.functionsDirectory,
].forEach((resourceDirectoryName) => {
  const resourceDirectoryPath = path.join(resourceRootDirectory, resourceDirectoryName);
  expectDirectoryExists(
    resourceDirectoryPath,
    `Expected resource directory '${resourceDirectoryName}' to exist.`,
  );
});

assert.ok(
  fs.existsSync(path.join(resourceRootDirectory, config.resources.functionsDirectory, ".gitkeep")),
  "Expected resources/functions to use the same .gitkeep starter pattern as the other resource directories.",
);

console.log("functions-resource-layout.test.js: passed");
