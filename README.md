# APIEase Template

This repository is the minimal starter template used by `apiease` for new APIEase projects.

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
- `docs/examples/resources/widgets/example-widget.json`: Widget example using canonical public widget field names.
- `docs/examples/resources/variables/example-variable.json`: Variable example including the `sensitive` field.
- `docs/examples/resources/functions/example-function.json`: Function example using the documented saved Function fields and reusable Liquid parameters.

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

apiease read request --request-id <request-id>
apiease read widget --widget-id <widget-id>
apiease read variable --variable-name <variable-name>
apiease read function --function-id <function-id>

apiease update request --request-id <request-id> --file docs/examples/resources/requests/example-request.json
apiease update widget --widget-id <widget-id> --file docs/examples/resources/widgets/example-widget.json
apiease update variable --variable-name <variable-name> --file docs/examples/resources/variables/example-variable.json
apiease update function --function-id <function-id> --file docs/examples/resources/functions/example-function.json

apiease delete request --request-id <request-id>
apiease delete widget --widget-id <widget-id>
apiease delete variable --variable-name <variable-name>
apiease delete function --function-id <function-id>
```

Use those example files as a starting point, then replace them with project-specific resources as your APIEase project grows.

The template also includes a bundled APIEase knowledge base at `docs/knowledgebase/apiEaseDocsConsolidated.md` so coding agents can understand the platform and configure project resources correctly.

It also includes shared agent guidance at `docs/shared-ongoing-ai-guidance.md` for implementation lessons that apply across APIEase projects, such as stricter runtime constraints discovered during real-world Liquid request work.

## Customization Files

This template keeps the default template guidance separate from project-specific customization.

- `README.md` and `AGENTS.md` are the template-owned defaults.
- `docs/shared-ongoing-ai-guidance.md` is template-owned shared implementation guidance for agents.
- `docs/knowledgebase/apiEaseDocsConsolidated.md` is the template-owned APIEase product reference.
- `CUSTOM_README.md` is the intended place for user-specific project documentation.
- `CUSTOM_AGENT_GUIDANCE.md` is the intended place for user-specific agent instructions.

## Agent Guidance

This template is designed to work well with coding agents such as Codex, Claude, and GitHub Copilot.

- `AGENTS.md` contains the template-owned default guidance for agents.
- `docs/shared-ongoing-ai-guidance.md` contains template-owned ongoing implementation guidance that applies across projects.
- `docs/knowledgebase/apiEaseDocsConsolidated.md` contains the APIEase product knowledge agents should use when configuring resources.
- `CUSTOM_README.md` contains project-specific documentation for humans and agents.
- `CUSTOM_AGENT_GUIDANCE.md` is the intended place for users to add project-specific agent instructions.
- `CLAUDE.md` and `.github/copilot-instructions.md` provide compatibility entry points for tools that look for those filenames.

When extending this template into a real project, keep project-specific documentation in `CUSTOM_README.md` and project-specific agent instructions in `CUSTOM_AGENT_GUIDANCE.md` so those customizations stay separate from the template defaults and shared guidance.
