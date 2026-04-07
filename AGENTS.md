# Agent Guidance

## Purpose
This repository is the starter template used by `apiease-cli` for new APIEase projects.

Agents working in this repository should optimize for clarity, minimalism, and template suitability. This is not an application repository with an established runtime, test suite, or framework stack.

## Instruction Order
Before making changes, read these files in this order:

1. `AGENTS.md`
2. `docs/shared-ongoing-ai-guidance.md`
3. `docs/knowledgebase/apiEaseDocsConsolidated.md`
4. `CUSTOM_AGENT_GUIDANCE.md`
5. `CUSTOM_README.md`
6. `README.md`

`AGENTS.md`, `README.md`, and `docs/shared-ongoing-ai-guidance.md` are template-owned defaults. `CUSTOM_AGENT_GUIDANCE.md` and `CUSTOM_README.md` are the intended places for project-specific customization.

If the custom files contain project-specific instructions, treat them as the user-editable guidance layer for this project. If they conflict with this file, follow the more specific instruction unless it would break the template's core structure.

## What To Do
- Help users create or modify APIEase resource files and configuration.
- Use `docs/knowledgebase/apiEaseDocsConsolidated.md` as the primary product reference for how APIEase works and how requests, widgets, variables, functions, and triggers should be configured.
- Treat `apiease.config.js` as the source of truth for resource directory names.
- Keep the repository minimal unless the user explicitly asks for more structure.
- Prefer examples that teach the APIEase resource model over abstract scaffolding.

## Project Structure
- `apiease.config.js` defines the resource root and subdirectories.
- `resources/requests` contains request resources.
- `resources/widgets` contains widget resources.
- `resources/variables` contains variable resources.
- `resources/functions` contains function resources.
- `docs/knowledgebase/apiEaseDocsConsolidated.md` contains the bundled APIEase knowledge base agents should use when implementing project-specific resources.
- `docs/shared-ongoing-ai-guidance.md` contains shared implementation lessons and agent guidance that apply across projects.

## Guardrails
- Do not add unrelated frameworks, build tooling, or app scaffolding by default.
- Do not assume a package manager, runtime entrypoint, or deployment target unless the user adds one.
- Do not guess at APIEase behavior when the knowledge base answers it; consult `docs/knowledgebase/apiEaseDocsConsolidated.md` first.
- Apply shared implementation constraints from `docs/shared-ongoing-ai-guidance.md` when they are relevant, especially for APIEase Liquid behavior not covered in the main knowledge base.
- Keep sample resources lightweight and easy to replace.
- Preserve compatibility between `apiease.config.js` and the directory structure.
- Prefer project-specific documentation updates in `CUSTOM_README.md`.
- Update `README.md` only when the template-wide defaults or usage guidance change.

## Definition Of Done
A good change in this repository:

- keeps the template simple for new users,
- leaves the directory layout and config consistent,
- makes the next agent or human more likely to understand what to do,
- and avoids introducing unnecessary project-specific assumptions.

## Commit & Pull Request Guidelines
- Write imperative commit subjects under about 72 characters (for example `Add upgrade conflict reporting`).
- Every implementation handoff must include a proposed commit message ending with a period, even if the user did not ask for one. Put it in the final completion summary as a dedicated line starting with "Commit message:".
