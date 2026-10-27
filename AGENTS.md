# AGENTS.md — Codex discovery entrypoint

This is a **Flutter mobile** repository for **Loop**. The canonical instructions are `AGENT.md` and `CODEX.md`. Read both completely before editing files. Then read `docs/PRODUCT.md`, `docs/ARCHITECTURE.md`, `docs/DESIGN.md`, `docs/MILESTONES.md`, and `docs/TOOLS_AND_SKILLS.md`. A working app must not be inferred from this documentation-only kit.

**Execution order:** inspect repository and tools → discover relevant skills/plugins (including user-requested names) → record verified availability → implement the next incomplete milestone → test on feasible targets → document evidence and blockers → commit only a verified milestone → continue automatically. Work on one milestone at a time; do not combine unverified milestones. Do not skip release-critical checks or cross the approval boundaries below.

## Continuous Milestone Execution Policy

The owner authorized continuous execution of M01–M15 on 2026-10-27. This authorization persists across sessions until the owner changes it. Read `docs/verification/CONTINUATION.md` and `PROGRESS.md` after the canonical contract, inspect actual Git state, and resume the first incomplete milestone. Preserve M00's historical evidence.

For each milestone: read requirements/prerequisites → create or switch to its local `milestone/XX-short-name` branch → implement → run all applicable quality gates → diagnose/fix failures and rerun affected/regression checks → update verification, traceability and status → commit `milestone-XX: <verified outcome>` → confirm commit and clean worktree → immediately begin the next incomplete milestone. Do not wait for a new prompt or ask whether to continue. Routine files, refactors, documented features, local tests/screenshots, branches and commits are authorized.

Never fabricate results or mark PASS with unmet required criteria. Record a genuine blocker and prepare all safe independent work; continue other work only when its prerequisites remain satisfied. Optional tool absence is not a blocker by itself. Keep `docs/verification/PROGRESS.md` and `CONTINUATION.md` current with actual commits, tests, blockers and exact safe resume commands. Context limits are a checkpoint requirement, not grounds to restart or repeat completed work.

Explicit approval remains required for unapproved third-party agent plugins/services, OAuth/external accounts, exposing private code or user data, remote indexing, purchases/charges, destructive actions outside scope, remote pushes, store publishing, production credentials and accepting legal agreements. Prepare reviewable local work before requesting approval. Continuous execution never waives these boundaries, native-device evidence, or release gates. See `CODEX.md` and `docs/MILESTONES.md` for the full workflow.

**Non-negotiables:** local-first; no login; domain-appropriate progress measures; no fabricated improvement scores; accessible, respectful UI; data integrity; user ownership/export; staged feature flags; no hardcoded secrets; permission minimization; no production use of fake data; no unverified success claims.
