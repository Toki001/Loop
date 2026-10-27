# Loop

**Loop** is a local-first mobile practice companion for deliberate improvement across hobbies and skills. This repository contains the native design system, Android/iOS foundation, private relational persistence and verified owned skill/goal/exercise setup. It is **not a completed practice journal**; timing, journaling, evidence and release gates remain M06–M15.

Current evidence: [verification ledger](docs/verification/INDEX.md), [owned skill setup](docs/SKILL_MANAGEMENT.md), [native boot/identity/verification](docs/NATIVE_FOUNDATION.md), [private persistence and recovery](docs/PERSISTENCE.md), [native design preview](design_preview/README.md), [screen/state design contract](docs/SCREEN_DESIGN.md), and [continuous execution checkpoint](docs/verification/CONTINUATION.md). Design fixtures never become production data.

**North-star statement:** *Practice with intention. See your progress.*

## Read and run

1. Read `AGENTS.md` (auto-discovered by many coding agents), `AGENT.md`, and `CODEX.md`.
2. Read `docs/PRODUCT.md`, `docs/DESIGN.md`, `docs/ARCHITECTURE.md`, and `docs/MILESTONES.md` before making changes.
3. Inspect Git state and `docs/verification/CONTINUATION.md` to resume the first incomplete milestone. `prompts/START_CODEX.md` is the original empty-repository discovery prompt; do not restart completed M00 work or overwrite this application.
4. Continuous execution is authorized for M01–M15: complete each milestone's quality gate, create and verify its local Git commit, then immediately proceed to the next incomplete milestone without another prompt. Read the durable checkpoint in `docs/verification/CONTINUATION.md` when resuming.
5. Keep decision, evidence and blocker logs in `docs/verification/` in the application repository.

With the pinned preinstalled toolchain, use `flutter pub get --enforce-lockfile`, then `flutter run -d DEDICATED_DEVICE_ID` for the foundation. Run `python3 tool/ci.py --android --ios` on the provisioned Mac for core/design/native checks; the explicit dedicated-device option is documented in the native foundation guide. Remote CI, physical testing, release signing and publication are separate gates.

## Files and authorities

| File | Contract |
|---|---|
| `CODEX.md` | Master mission, workflow, phases, done definition |
| `AGENT.md` | Universal agent execution, coding and collaboration rules |
| `AGENTS.md` | Codex/agent discovery entrypoint |
| `docs/PRODUCT.md` | PRD, user journeys, scope, acceptance |
| `docs/DESIGN.md` | Design tokens, components, screen architecture, states, motion |
| `docs/ARCHITECTURE.md` | Stack, layers, repo layout, persistence, platform behavior |
| `docs/DATA_AND_METRICS.md` | Schema, calculations, comparisons, data integrity |
| `docs/SECURITY_PRIVACY.md` | Threat model, device storage, media, policy |
| `docs/QUALITY.md` | Testing matrix, performance, accessibility, release gates |
| `docs/RELEASE.md` | CI/CD, signing, stores, operations, staged rollout |
| `docs/MILESTONES.md` | Step-by-step milestone ledger, tasks and exit criteria |
| `docs/TOOLS_AND_SKILLS.md` | Skill/plugin discovery and Flutter-vs-web applicability |
| `docs/DECISIONS.md` | ADRs and unresolved product/business decisions |
| `docs/ANALYTICS.md` | Privacy-friendly product learning and success measures |
| `prompts/START_CODEX.md` | First Codex execution prompt |
| `prompts/DESIGN_PHASE.md` | Focused visual direction prompt |
| `prompts/NEXT_MILESTONE.md` | Repeatable controlled milestone prompt |

## Scope policy

* **Public v1:** Offline-first iOS/Android Flutter product, optional notifications, sessions, goals, evidence media, comparisons, progress and **portable export/restore**. No sign-in, cloud sync, social feeds or generative AI required.
* **Candidate v1.1+:** guided programs, advanced insights, optional paid tier, verified cloud sync, rich instrument-specific tools. Require separate architecture / business approval.
* A public release must have no placeholder buttons, simulated persistence, fake statistics, dangling navigation, insecure media or unfinished paywalls.

## Origin and design inspiration

Use the previously supplied **PesoFlow** design principles as inspiration only: quiet visual rhythm, spacious white cards, intentional blue accents, simple navigation, legible charts, careful states. Do not copy its financial information architecture or assets. If actual screenshots/source are not mounted, do **not** claim to have inspected them; treat this document as the authoritative Loop-specific design contract.

## Core principle

A timer is not progress. Progress exists when a practice session captures **what was attempted, what was observed and what changed**. Avoid shame, guilt and streak pressure. Prefer explicit evidence and user-entered measures to invented automated skill scoring.
