# Shared Ongoing AI Guidance

Use this file for shared implementation lessons that should apply across APIEase projects.

Add concise, reusable guidance here when real-world implementation work reveals behavior that agents should not re-learn project by project.

## APIEase Resource Identifier Guidance

Use these directives when creating or reviewing repository-managed APIEase resources, examples, Liquid, CLI commands, and docs.

- Treat requests, widgets, variables, and functions as first-class APIEase resources with a server-owned immutable `id`, a merchant-controlled `handle`, and a human-readable `name`.
- Prefer `handle` as the stable public identifier for resources. Do not store server-owned `id` values in template resource source files or examples. Use `name` only as display text.
- For request source files, `handle` is the stable repository identifier. Request handles should be lowercase slugs using letters, numbers, and hyphens, for example `product-details-proxy`.
- For request CLI read, update, and delete flows, `--request-id` remains the compatibility option name. Pass a request handle through that option unless explicitly addressing a legacy server-owned id.
- When a request source file has a valid `handle`, `apiease create request --file <path>` is idempotent: it creates the request when the handle does not exist and updates the existing request when it does.
- For older request source files that still contain `id` metadata or no `handle`, use `apiease create request --file <path> --auto-update-source-identifier` to migrate only the local identifier metadata.
- APIEase request invocation surfaces may still use the parameter name `requestId`. In Liquid `call` tags, storefront calls, remote calls, and Flow conditions, provide or compare the request handle as the `requestId` value whenever possible.
- For chained request references, prefer the request handle when the APIEase surface supports it. Use names only as compatibility fallback display identifiers.

## APIEase Liquid Runtime Constraints

Use these directives when generating or reviewing Liquid for APIEase.

These directives come from real runtime failures observed during client validation. Treat them as stricter-than-standard Liquid constraints for APIEase.

## Required Directives

- Do not place filtered expressions directly in `if` conditions in APIEase Liquid. Compute filtered values with `assign` first, then compare plain variables.
- Do not assume nested response properties are null-safe in APIEase Liquid. Check key presence before dereferencing paths like `response.data.errors` or `result.userErrors`.

## Known Failure Modes

### 1. Filters Inside `if` Conditions Can Fail To Parse

Observed error:

```text
Error during liquid call dispatch: expected ":" after filter name, line:55, col:51
```

Problem pattern:

```liquid
{% if header_columns[0] | remove: '"' | strip != 'EXPECTED_PRODUCT_CODE' %}
```

Safe pattern:

```liquid
{% assign first_header = header_columns[0] | remove: '"' | strip %}
{% if first_header != 'EXPECTED_PRODUCT_CODE' %}
```

### 2. Nested Property Access Is Not Null-Safe

Observed error:

```text
Error during liquid call dispatch: undefined variable: batch_response.data.errors, line:253, col:21
```

Problem pattern:

```liquid
{% assign errors = batch_response.data.errors %}
{% assign user_errors = mutation_result.userErrors %}
```

Safe pattern:

```liquid
{% assign batch_response_json = batch_response | json %}
{% if batch_response_json contains '"errors"' %}
  {% assign errors = batch_response.data.errors %}
{% endif %}
```

Apply the same pattern to any nested path. Confirm the parent payload contains the key before dereferencing the nested property.
