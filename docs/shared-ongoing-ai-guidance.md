# Shared Ongoing AI Guidance

Use this file for shared implementation lessons that should apply across APIEase projects.

Add concise, reusable guidance here when real-world implementation work reveals behavior that agents should not re-learn project by project.

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
