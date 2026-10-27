# Starting prompt — paste into Codex from the root of the Loop repository

You are building **Loop**, a premium Flutter iOS/Android product for deliberate practice and tangible skill progress. The product source of truth is `README.md`, `AGENTS.md`, `AGENT.md`, `CODEX.md`, and every file in `docs/`; read them **before** touching code. Treat documentation in this repository as the approved product and technical contract. This is a new independent app; do not modify PesoFlow.

**Mandatory tools and discovery:** Start with `find_skills` if exposed, otherwise discover and list available agent skills with the host's actual equivalent. Also use plugin management/discovery if accessible. Search for: `headless`, `graphify`, `ponytail`, `ui-ux-pro-max`, `web-design-guidelines`, `shadcn`, `hallmark`, `emil-design-eng`, plus useful Flutter testing, mobile security and design skills. Identify each package's exact type, publisher, trust and availability. Read the relevant skill docs. Use requested tools where applicable and genuinely available, **without inventing invocations**. Obtain my approval before installing code/plugins/hooks, remote repo indexing, authenticating integrations or sharing project data. No anonymous or unsafe plugin installs. The name `headless` is ambiguous; resolve it instead of guessing. Graphify's remote plugin cannot read an unindexed repository automatically. shadcn and web design guidance belong to web prototypes/marketing, not native Flutter widgets.

**First execution is M00 ONLY:**
1. Inspect the repository, git status, local Flutter/Xcode/Android SDKs, Android and iOS testing capabilities. Preserve existing user files.
2. Read all project specifications and create a traceability table mapping product requirements to milestones, tests and launch criteria; capture unknowns without delaying safe defaults.
3. Perform the skill/plugin inventory and log true availability in `docs/verification/M00.md`.
4. For an empty repository, establish clean structure, `.gitignore`, source-controlled docs, engineering workflows and any non-destructive setup needed for M00. Do not implement M01–M15 in the same pass or falsely create screenshots/build outputs.
5. Run genuinely possible validation, produce meaningful M00 evidence and a `docs/verification/INDEX.md` progress dashboard.
6. Commit **only if** the milestone's feasible checks pass, with message `milestone-00: discovery and repository baseline`. Never push/publish.
7. Report completed work, exact commands/results, tools actually invoked, blockers, next task, and whether M00 is PASS/PARTIAL/BLOCKED.

**Standing rule for later prompts:** Follow `docs/MILESTONES.md` in order; one milestone per task and one verified commit per milestone; hold product scope, app design and privacy boundaries constant. Never use a screenshot-only mock as a finished feature. Avoid fake data in production, dead buttons, skipped device tests presented as passes, fabricated app store approval or premature payment integration.
