# Tools, skill discovery and plugin operating guide

## Essential taxonomy

A **skill** is an agent instruction package; a **Codex plugin** may register hooks/tools; an **MCP server** exposes services; a **ChatGPT connector/plugin** may require separate installation/OAuth. A name alone does not guarantee one exists in this agent's runtime. Never fabricate `find_skills`, plugin installs or successful calls. Review publisher, repository, license, installed hooks and network/data access before trusting a package. Installation and cloud access require user approval.

## Requested names and intended tasks

| Requested name | Specific purpose at Loop | Guardrail |
|---|---|---|
| `find_skills` / skill discovery | Discover actual design/mobile/testing skills and read their full instructions | If unavailable, use actual environment equivalents |
| `plugin management` | Discover, verify and (with authorization) connect relevant plugins | Codex tools and ChatGPT connectors differ |
| `headless` | First identify exact provider/package; useful for browser E2E of future marketing website, external dashboards or HTML preview if it supports them | Ambiguous name; **not** proof of native app testing; Tray Headless workflows are unrelated without Tray use case |
| `graphify` | Map dependency paths / change impact and connected tests after repo graph is indexed | Remote Graphify plugin needs connection/indexed repo; local Codex skill is distinct |
| `ponytail` | Reduce redundant code, avoid abstraction bloat, review diffs and simplify | Simplification never removes accessibility, data safety or required validation |
| `ui-ux-pro-max` | Research mobile-native patterns, tokens, hierarchy, information density | Choose Flutter-native recommendations; verify source and adapt critically |
| `web-design-guidelines` | Audit marketing/docs/HTML prototypes and adapt general accessibility lessons | Web/CSS rules are not drop-in Flutter implementation |
| `shadcn` | Consistent Next.js marketing/website prototype components | No React dependencies in Flutter app |
| `hallmark` | Evaluate visual distinctiveness and anti-template tendencies, particularly future web | Don't let website patterns override native usability |
| `emil-design-eng` | Motion timing, perceived quality, spacing, tactile interactions and reduced-motion audit | Translate browser-specific tips to Flutter idioms |

## Suggested verified upstream references (check latest and approve before installing)

- `https://github.com/DietrichGebert/ponytail` — Ponytail Codex plugin, source reviewed.
- `https://graphify.com/mcp` and `https://graphify.com/blog/graphify-chatgpt-plugin` — Graphify MCP and plugin explanation.
- `https://github.com/nextlevelbuilder/ui-ux-pro-max-skill` — UI UX Pro Max.
- `https://github.com/vercel-labs/agent-skills` — Web design guidelines skill.
- `https://github.com/Nutlope/hallmark` — Hallmark.
- `https://github.com/emilkowalski/skills` — Emil Design Engineering skill.
- `https://ui.shadcn.com/` — shadcn for web designs.
- Headless: **unresolved exact identity**. Discover by marketplace and ask permission before choosing a similarly named product.

## Required discovery report (M00)

Record columns: exact requested name, discovery method, exact publisher/version or provider, category (skill/plugin/MCP), installed/available/unavailable, required permissions, scope, use case, actual invocation evidence, fallback. An unavailable plugin is a documented limitation, **not** grounds to stop core Flutter work.

## Suggested working sequence

1. Detect actual tool capabilities and local project state.
2. Find mobile architecture/testing skills plus named requested skills.
3. Prepare design research with `ui-ux-pro-max`, `emil-design-eng`; use `hallmark` for originality review. Use `web-design-guidelines` for web/prototype audit. If no suitable tools, apply `docs/DESIGN.md` directly and manually audit.
4. As modules are implemented, use `ponytail` review where installed and `graphify` (if repo indexed) to assess call graph and blast radius.
5. Use browser headless workflows for genuine web assets. Use Flutter integration tests + Android and iOS devices for mobile behavior.
6. Write what tools were **actually used** in each milestone report.

## Safe approvals policy

- May read current repo and publicly documented packages without additional confirmation.
- Must get owner approval before installing new code/hook, connecting OAuth services, indexing a private repo remotely, uploading files/data, purchasing services, signing certificates, publishing or changing security settings.
- No `curl | sh`, blind `npx` arbitrary packages or copying credentials into prompts without review.
