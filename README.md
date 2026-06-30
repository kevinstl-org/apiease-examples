# APIEase Template

This repository is the minimal starter template used by general `apiease` users for new APIEase projects.

Most users should consume this template through the CLI with `apiease init` instead of cloning the repository directly.

Install the CLI globally with:

```bash
npm install -g apiease
```

The goal of this template is to provide a small, neutral starting point with a simple configuration file and a `resources/` directory that mirrors the core APIEase resource model:

- `resources/requests`
- `resources/widgets`
- `resources/variables`
- `resources/functions`

The included example files are intentionally lightweight, but they now use the strict public API field shapes so they can serve as valid starting points instead of loose placeholders.

Current examples:

- `docs/examples/resources/requests/example-request.json`: HTTP request example covering the common top-level fields, all HTTP parameter types, and all trigger types.
- `docs/examples/resources/requests/example-liquid-request.json`: Liquid request example showing the `liquid` field.
- `docs/examples/resources/requests/example-system-request.json`: System request example showing the required `system` parameters.
- `docs/examples/resources/widgets/example-widget.json`: Widget example using `widgetHandle` as the stable handle field and `widgetName` as display text.
- `docs/examples/resources/variables/example-variable.json`: Variable example including a stored value and the `sensitive` field.
- `docs/examples/resources/functions/example-function.json`: Function example using a handle-first saved Function shape and reusable Liquid parameters.

## Managing Resources With apiease

This template assumes you will manage APIEase resources through `apiease`.

Supported resource types:

- `request`
- `widget`
- `variable`
- `function`

Common commands:

```bash
apiease create request --file docs/examples/resources/requests/example-request.json
apiease create widget --file docs/examples/resources/widgets/example-widget.json
apiease create variable --file docs/examples/resources/variables/example-variable.json
apiease create function --file docs/examples/resources/functions/example-function.json

apiease read request --request-id <request-handle>
apiease read widget --widget-id <widget-handle>
apiease read variable --variable-name <variable-handle>
apiease read function --function-id <function-handle>

apiease update request --request-id <request-handle> --file docs/examples/resources/requests/example-request.json
apiease update widget --widget-id <widget-handle> --file docs/examples/resources/widgets/example-widget.json
apiease update variable --variable-name <variable-handle> --file docs/examples/resources/variables/example-variable.json
apiease update function --function-id <function-handle> --file docs/examples/resources/functions/example-function.json

apiease delete request --request-id <request-handle>
apiease delete widget --widget-id <widget-handle>
apiease delete variable --variable-name <variable-handle>
apiease delete function --function-id <function-handle>
```

Requests, widgets, variables, and functions should use `handle` as the stable public identifier. Use `name` only as display text. Server-owned `id` values are APIEase metadata and should not be stored in template resource source files or examples.

Create commands read the resource handle from the JSON file. Widget source files keep the current public `widgetHandle` and `widgetName` field names: `widgetHandle` is the widget handle, and `widgetName` is display text. Use `widgetHandle` as the widget handle until the public widget source shape exposes a plain `handle` field.

Function source files include `handle` as the target stable identifier. The current Liquid Function tag supports `functionName` or `functionId`, but not a handle-named field yet. Until that Liquid invocation contract lands, Liquid examples use `functionName` as the compatibility fallback and avoid server-owned `functionId` values.

The existing `--request-id`, `--widget-id`, `--variable-name`, and `--function-id` option names are compatibility names for read, update, and delete flows. Pass resource handles through those options unless the CLI exposes handle-named options for your installed version.

When a request source file has a valid `handle`, `apiease create request` is idempotent: it creates the request if the handle does not exist, or updates the existing request with that handle if it does. The same handle-first identity model applies to widgets, variables, and functions.

For older request files that still contain `id` or no `handle`, run `apiease create request --file <path> --auto-update-source-identifier` to migrate only the local identifier metadata.

Use those example files as a starting point, then replace them with project-specific resources as your APIEase project grows.

The template also includes a bundled snapshot of the public APIEase docs from `https://docs.apiease.com` at `docs/knowledgebase/apiEaseDocsConsolidated.md` so coding agents can understand the platform and configure project resources correctly.

It also includes shared agent guidance at `docs/shared-ongoing-ai-guidance.md` for implementation lessons that apply across APIEase projects, such as stricter runtime constraints discovered during real-world Liquid request work.

## Customization Files

This template keeps the default template guidance separate from project-specific customization.

- `README.md` and `AGENTS.md` are the template-owned defaults.
- `docs/shared-ongoing-ai-guidance.md` is template-owned shared implementation guidance for agents.
- `docs/knowledgebase/apiEaseDocsConsolidated.md` is the template-owned APIEase product reference generated from `https://docs.apiease.com`.
- `CUSTOM_README.md` is the intended place for user-specific project documentation.
- `CUSTOM_AGENT_GUIDANCE.md` is the intended place for user-specific agent instructions.

## Agent Guidance

This template is designed to work well with coding agents such as Codex, Claude, and GitHub Copilot.

- `AGENTS.md` contains the template-owned default guidance for agents.
- `docs/shared-ongoing-ai-guidance.md` contains template-owned ongoing implementation guidance that applies across projects.
- `docs/knowledgebase/apiEaseDocsConsolidated.md` contains the APIEase product knowledge from `https://docs.apiease.com` that agents should use when configuring resources.
- `CUSTOM_README.md` contains project-specific documentation for humans and agents.
- `CUSTOM_AGENT_GUIDANCE.md` is the intended place for users to add project-specific agent instructions.
- `CLAUDE.md` and `.github/copilot-instructions.md` provide compatibility entry points for tools that look for those filenames.

When extending this template into a real project, keep project-specific documentation in `CUSTOM_README.md` and project-specific agent instructions in `CUSTOM_AGENT_GUIDANCE.md` so those customizations stay separate from the template defaults and shared guidance.
