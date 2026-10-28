# Loop — Gated Development Plan (M00–M15)

**Run sequence:** One milestone at a time. Complete acceptance tests and evidence file before commit. The presence of documents is not evidence that a milestone has been executed. Initial state: **all PENDING**. M00 baseline starts from the kit; do not claim code, CI, builds, screenshots, native tests or publication already exist.

## Continuous Milestone Execution Policy

Effective 2026-10-27, the owner authorizes automatic M01–M15 progression and future-session resumption. M00 is already verified. Read [CONTINUATION.md](verification/CONTINUATION.md) and [PROGRESS.md](verification/PROGRESS.md), inspect the repository, and resume the first incomplete milestone. Keep one milestone in progress at a time and one verified local commit per successful milestone.

For each: read requirements/prerequisites → branch → implement → test → fix and rerun affected/regression checks → document actual evidence and update traceability/status → commit → confirm commit and clean worktree → immediately begin the next milestone. Do not ask the owner whether to continue. Preserve all quality gates and M00 historical results. Routine local engineering is authorized; external accounts, unapproved third-party tools/services, remote indexing/data exposure, costs, out-of-scope destruction, pushes, production credentials, legal agreements and store publishing still require explicit approval.

Required failing or blocked checks prevent PASS. Record BLOCKED/FAIL truthfully with reproduction/remediation and retain completed safe preparation; only proceed to independent work whose prerequisites are satisfied. Missing optional tools do not lower acceptance. Keep durable progress/checkpoint records after each milestone and before session interruption. At the end, execute the full available verification and report actual supported-platform readiness separately from hardware, signing, policy and publication blockers. See [CODEX.md](../CODEX.md) for the complete policy.

## Global milestone template

Each MXX requires (1) preconditions from earlier gates, (2) scoped plan and implementation, (3) test cases, (4) visual/permission/security review when relevant, (5) `docs/verification/MXX.md` with actual commands and outcomes, (6) Git commit after verified success, (7) follow-up owner decisions/blockers. Commit format `milestone-XX: concise verified outcome`. Use `docs/QUALITY.md` as universal overlay. No hidden 'skip tests to finish faster'. Do not push/deploy/publish without owner authorization. Evidence distinguishes emulator, physical device and mocked tests.

## Milestone table

| Milestone | Name | Primary output | Status |
|---|---|---|---|
| M00 | Discovery and repository baseline | tool matrix, git baseline, traceability | [PASS](verification/M00.md) |
| M01 | Product validation and scope lock | validated workflows, product decisions | [PASS](verification/M01.md) |
| M02 | Brand, UX and design system | token set, reviewable native mock screens, goldens | [PASS](verification/M02.md) |
| M03 | Flutter app foundation | working shell, routing, localization, CI | [PASS — local foundation](verification/M03.md) |
| M04 | Durable storage and security | drift schema, migrations, media/file boundary | PASS — local persistence; physical/release limits in M04 report |
| M05 | Skill, goal and exercise management | complete CRUD flows | PASS — local skill management; commit recorded in M05 checkpoint |
| M06 | Session state machine and timer | reliable lifecycle and resume logic | PASS — local timer/manual entry; physical Android lifecycle and restart verified |
| M07 | Reflection and session journal | complete end-to-end offline practice loop | PASS — offline journal, durable reflection and owner-directed expressive UI |
| M08 | Photos and audio evidence | permission-safe private evidence library | PENDING |
| M09 | Then vs Now | compare compatible image/audio evidence | PENDING |
| M10 | Progress analytics and search | honest goals, measurements and history | PENDING |
| M11 | Respectful reminders | local scheduler and settings | PENDING |
| M12 | Ownership: export, restore, delete | tested full lifecycle and portability | PENDING |
| M13 | Security, performance and accessibility hardening | audit, beta-quality app | PENDING |
| M14 | Beta distribution and policy compliance | release candidate, store docs, device evidence | PENDING |
| M15 | Production launch and operations | owner-approved store rollout and support runbook | PENDING |

---

## M00 — Discovery, project baseline and tool audit

**Goal:** Establish what exists and what the coding agent can actually do; create zero false implementation claims.

**Tasks**

- Inspect repository path, branch, existing source assets, package files, uncommitted changes; stop before overwriting existing application data.
- Inventory Flutter stable/Dart, Xcode, CocoaPods, Android SDK, JDK, emulators, Android/iOS physical devices, Node/npm if web/skills are considered, Git and CI availability.
- Discover skills via real `find_skills` **if exposed** and plugin management or equivalent. Search all named: headless, graphify, ponytail, ui-ux-pro-max, web-design-guidelines, shadcn, hallmark, emil-design-eng. Identify exact functionality and third-party privileges; do not confuse ChatGPT connectors with Codex local tools.
- Read source docs and produce a requirement-to-milestone and test traceability list; inventory owner approval questions D-01–D-10.
- Establish Git safety, branch conventions, ignore rules for media, keys, build outputs, iOS Pods, archives, test fixture content; record environment and future package baselines.
- Create `docs/verification/INDEX.md`, `M00.md`, ADR directory if needed, simple contributor and issue templates. Do not scaffold the full feature implementation yet.

**Acceptance / evidence:** no destructive writes, tool inventory with statuses and exact references, first verified Git commit only if repository checks green, complete next-milestone handoff. **Tests:** `git status`, `flutter doctor -v` where available, documentation path checker and secret/ignored-files review. **Dependencies:** none. **Exit:** repo and toolchain state documented; unavailable capabilities assigned fallback. **Commit:** `milestone-00: discovery and repository baseline`.

---

## M01 — Product discovery, user journeys, requirements lock

**Goal:** Make core behavior unambiguous and grounded in likely user needs.

**Tasks**

- Create interview protocol and usability script; recruit representative hobby learners if owner has volunteers. **Never fabricate completed interviews.** If participants unavailable, mark empirical validation pending and use product requirements as hypotheses.
- Refine 3 primary personas: occasional learner, cross-skill tinkerer, deliberate improver. Capture what evidence each can realistically add.
- Define onboarding first session, casual untimed session, recording session, repeat session, Then-vs-Now, data export/restore flows including failure outcomes.
- Review built-in skill templates and metric definitions. Define anti-gamification constraints, units and honest comparison policy; no unsourced AI scoring claims.
- Finalize v1 vs post-v1 backlog, acceptance flows US-01–US-18, product copy, open decisions in `docs/DECISIONS.md`.
- Create requirement traceability matrix (`docs/verification/TRACEABILITY.md`) connecting story → UI → domain model → tests → milestone; label research assumptions.

**Acceptance:** reviewed PRD and no contradictory scope; all mandatory flows have identifiable test paths; research status truthful; owner signoff on any material scope change. **Tests:** doc consistency, feature-priority walk-through, privacy flow review. **Exit:** product freeze for M02–M12 unless ADR. **Commit:** `milestone-01: product workflows and scope contract`.

---

## M02 — Brand direction and high-fidelity design system

**Goal:** A coherent Loop-native visual system before screen proliferation.

**Tasks**

- Use verified ui-ux-pro-max for mobile pattern research, emil-design-eng for motion/tactility and hallmark for originality critique; apply web-design-guidelines/shadcn to web preview only. Maintain tool call evidence. Compare brand to PesoFlow design principles but give Loop separate identity.
- Define typography licensing, logo/icon concept, light/dark color and contrast-tested semantic tokens, 4/8pt grid, radii, shadows, imagery handling, responsive max widths and component catalog.
- Create core user flows and detailed wireframes for all screen inventory items including recovery, permission denial, empty states and export/restore.
- Build Flutter component gallery/golden fixtures or well-specified design preview; never mistake HTML render for native pass. Design first-run, Today, Skills, session timer, Finish, Progress, Then-vs-Now, Library, Settings.
- Include 200% text test snapshots, screen-reader semantics plan, dark mode, small phone and iPad/adaptive layout strategy, reduced-motion and hand-off acceptance rubric.
- Reject AI-generic styling (over-gradients, noisy glass panels, fake dashboard metric, inconsistent card components). Record rationales and deliberate distinctions.

**Acceptance:** token system complete and contrast checked, components documented, multi-screen fidelity baseline, flows accepted, design issues tracked. **Tests:** visual snapshot review on named viewport sizes and manual accessibility design audit. **Exit:** no major unanswered visual rules when starting M03. **Commit:** `milestone-02: Loop design contract and component gallery`.

---

## M03 — Production Flutter foundation

**Goal:** A bootable maintainable native shell, not a page stack of mocks.

**Tasks**

- Create `flutter create` project for iOS/Android within clean repo, select bundle/package ID via owner decision, app display name Loop, icon placeholder only in debug until final brand reviewed.
- Pin SDK constraints and runtime versions; review package maintainer status; add Riverpod, go_router, localization, theme, testing/lints and minimal dependencies only. Commit lockfile, license checklist.
- Build shell navigation Today/Skills/Practice/Progress/Library + Settings, route guards for missing session, deep links no auth. Provide truthful empty states and pending-feature affordances hidden/disabled with explanation in **development only**.
- Implement design tokens, shared primitive widgets, theme persistence (preferences), locale scaffolding, errors/recovery screen, safe area and keyboard policy.
- Establish CI automated format/analyze/unit/widget smoke and Android debug build; Mac/iOS simulator smoke if tooling available. Add simple widget tests and golden foundations.
- Clear release startup from preview fixtures. Add initial documentation for boot lifecycle and app identifiers.

**Acceptance:** freshly installed shell boots offline, no login or fake skills; nav/back/empty states work; CI and local automated core checks pass. **Tests:** Android emulator (or documented unavailable), iOS simulator if available, `flutter analyze`, `flutter test`, build. **Exit:** solid shell ready for persistence. **Commit:** `milestone-03: native Flutter app foundation`.

---

## M04 — Persistence, migrations and security boundary

**Goal:** Data survives real-world app lifecycle and can migrate safely.

**Tasks**

- Define Drift tables/indexes/FKs from `docs/DATA_AND_METRICS.md`; initial migration and migration harness with seeded prior-version fixture. Implement repositories and transaction boundaries for skills, goals, exercises, sessions, metrics, media refs, reminders and settings.
- Implement app-private file storage abstraction and checksum validation; path traversal-resistant relative paths; lightweight file cleanup/reconcile service.
- Document and validate at-rest protection: OS file protection, Android/iOS backup policy, secure key needs. Do explicit SQL encryption spike if feasible and get ADR decision; avoid claiming media encrypted when only database is.
- Implement typed local failure mapping, database initialization/recovery, crash/reopen test, full-disk and unavailable-file tests.
- Use dependency graph analyzer/Graphify only if repository actually indexed. Review schema with deliberate migrations before further app features.

**Acceptance:** CRUD repository tests, constraints, migration fixture runs, restart persistence, no public file writes, no silent reset, key/backup story clear. **Tests:** database transactions, app process kill, corrupt DB recovery (non-destructive), schema version migration. **Exit:** implementation-ready domain APIs. **Commit:** `milestone-04: durable private persistence and migrations`.

---

## M05 — Skills, goals, exercises

**Goal:** User can shape practice for real hobbies without account.

**Tasks**

- Build skill category selection, custom category, create/edit/archive/reorder/search, active/archived views, empty states and confirmation semantics.
- Implement goal types and progress calculation eligibility, meaningful target selection, qualitative milestones, archiving/completion.
- Implement starter exercises per skill with stable IDs and editable templates; exercise sorting, duplication and manual user customization.
- Build Skills and Skill Detail screens to approved M02 design, navigation to Goal and Exercise editors; persist all changes.
- Preserve references and snapshot exercise titles when templates archived; long Unicode, duplicate names, no goals and no active skill cases.

**Acceptance:** US-01–04 implemented with no placeholders; reopen app retains entities; no orphaned sessions introduced; accessible CRUD. **Tests:** repository, widget, goldens, fresh/upgrade install smoke. **Exit:** usable skill setup. **Commit:** `milestone-05: skill goals and exercise management`.

---

## M06 — Accurate session clock and lifecycle

**Goal:** Timer that can't silently lie about time spent.

**Tasks**

- Implement serialized `draft/running/paused/completed/discarded` state machine and one active session invariant. `Stopwatch`-based foreground time segments; durable checkpoints and lifecycle pause; manual entry alternative.
- Build Practice setup and active timer screen (Start, Pause, Resume, Finish, Discard), exercise context, optional note draft, app lifecycle handling, screen reader timer summary.
- Handle accidental backgrounding, phone call, screen lock, quick app switch, process kill, battery saver, timezone change, double taps and finish races. Persist recovery draft; no background time accrual.
- Distinguish untimed practice from active timed sessions; mark manual duration and evidence-only zero-duration entries accurately.

**Acceptance:** a 2-minute foreground practice interrupted by 10 minutes background displays ~2 minutes; restart shows paused draft, never automatic fabricated time; one completed record from rapid Finish taps. **Tests:** deterministic fake clock unit, lifecycle widget/integration and at least one physical Android test; iOS physical gate later M14. **Exit:** dependable session engine. **Commit:** `milestone-06: interruption-safe practice timer`.

---

## M07 — Finishing flow, reflection and journal

**Goal:** First complete practice loop with durable improvement context.

**Tasks**

- Build finish screen with optional notes, What got easier, next-step, effort rating and compatible metric readings; validation and clear save/discard outcomes.
- Atomic Finish operation stores session, snapshots selected exercises, readings and reflection without duplicating on retry. Update Today, Skill Detail and Session Detail directly from repository stream.
- Implement timeline sorted/filterable by skill/date/exercise, view/edit/delete session and undo strategy where feasible; preserve revision metadata and recompute local summaries.
- Build clear empty state and permission-independent capture flow; test `save` with disk-full and retry, large notes and keyboard.

**Acceptance:** all basic practice operations work offline end-to-end and after restart; views show real records, no seeded retail history, editable revisions preserve correctness. **Tests:** end-to-end fresh install → skill → session → save → relaunch → detail; unit/widget/error state checks. **Exit:** independently useful MVP core. **Commit:** `milestone-07: complete offline practice journaling`.

---

## M08 — Private photo and audio evidence

**Goal:** Record genuine artifacts without privacy or data loss surprises.

**Tasks**

- Integrate maintained photo picker/camera and audio recorder/player after compatibility, permissions and license audit; capture only on deliberate user action, handle interruptions/revocation and device resource cleanup.
- Copy imported files into private app-owned media directory; derive opaque IDs, verify metadata/type/hash, generate previews safely and attach to sessions atomically with DB metadata.
- Create media Library screen (filter by skill/type, browse/view/play/delete), memory-bounded thumbnails and storage usage review; graceful missing/corrupt handling.
- Set clear file size/duration caps, user controls, audio recording state and privacy explanations; no cloud processing. Strip sensitive EXIF location where safe; test image rotation/quality.

**Acceptance:** photo/audio attached to sessions survives relaunch; deleting sessions/media cleans up files; no media capture without permission/intention; audio A/B does not leak in background. **Tests:** real microphone/camera (physical Android at least), denial, no-space, corrupt import, process kill, E2E and file garbage collection. **Exit:** media pipeline robust. **Commit:** `milestone-08: private media evidence pipeline`.

---

## M09 — Signature Then vs Now comparison

**Goal:** Make improvement visible without manipulated evidence.

**Tasks**

- Build comparison eligibility query: same skill and artifact kind with chronology, readable assets; a two-step picker that always exposes selected dates and sessions.
- Implement image two-up comparison and optional scrub slider; handle different dimensions/aspect ratios, metadata, source thumbnails, accessibility fallback buttons and 200% text.
- Implement audio A/B player with one playback at a time, scrub/seek where supported, pause when app backgrounded and source notes. Normalize UI playback level only if valid and transparent; do not claim objective progress scoring.
- Metric compare uses compatible metric definition/version/unit; show absolute change, date and direction explanation; no percent if baseline zero or data missing.
- Allow navigation from progress/skill detail/library and return to source sessions. Include empty and one-asset CTA states.

**Acceptance:** genuine dated image comparison, audio A/B and compatible metric comparison work across app restart; inaccessible media degrades gracefully, incompatible types blocked with explanation. **Tests:** screenshot goldens, audio integration device, metric unit, delete asset during comparison, TalkBack/VoiceOver fallback. **Exit:** core product differentiation proven. **Commit:** `milestone-09: evidence-based Then vs Now comparison`.

---

## M10 — Progress insights, timeline search and history

**Goal:** Trustworthy patterns rather than gamified vanity.

**Tasks**

- Implement deterministic local aggregation for completed session count, active seconds, practiced dates/week, skill distributions, goal eligibility, comparable metric trends. Use `docs/DATA_AND_METRICS.md` exactly.
- Build Progress Overview, Skill Progress, accessible chart/table alternatives and range filters. Label units, time zones, data source and number of samples, avoid fake extrapolation/benchmarks.
- Implement offline keyword search across skill/exercise/notes with debouncing, filters and safe query semantics; cap result sizes and preserve responsiveness with large data.
- Recalculate on edits, deletions and restores; ensure no double counts, zero baseline safe, negative-direction improvements interpreted correctly.

**Acceptance:** numbers match known fixture and actual DB, no universal mastery %, charts accessible, data insufficiency clear and recalculation immediate. **Tests:** time boundary, DST, leap day, rounding, big dataset perf, 200% text/golden, filters and live updates. **Exit:** honest measurement platform. **Commit:** `milestone-10: local insights and searchable history`.

---

## M11 — Reminders and supportive habit loop

**Goal:** Encourage intentional re-practice without guilt or battery abuse.

**Tasks**

- Build local-only per-skill reminder scheduler, weekdays, exact local time, quiet hours, snooze/pause all and OS permission-gated setup. No remote push, no notification permission on first app launch.
- Handle permission revoked, restart, reboot if platform supports, timezone/DST, OS caps and rescheduling; describe best-effort delivery and no guarantee.
- Build gentle nonjudgmental copy, accessible settings, Test Reminder (only if platform supports truthful feedback) and cancellation after archive/delete.

**Acceptance:** reminders schedule/cancel correctly, denial doesn't affect practice, no spam outside configured quiet hours, changing zone does not multiply schedules. **Tests:** timezone logic, OS scheduling emulator, physical Android and iOS at beta. **Exit:** optional reminder flow reliable. **Commit:** `milestone-11: respectful on-device reminders`.

---

## M12 — User data ownership and recovery

**Goal:** Make local-only trust defensible by providing true portability.

**Tasks**

- Implement versioned data export (all entities + attached media + checksums) in a shared **user-initiated** archive; no fake success toast. Expose counts, archive size, backup caveat and privacy warning.
- Implement secure import: reject path traversal, malformed/unsupported version, malicious expansion, duplicate paths and checksum corruption; stage & validate, preview counts/collisions, atomic merge into existing or empty DB. Define clear duplicate handling and rollback.
- Implement Settings storage usage, purge stale temp, delete individual sessions/media, archive skill vs irreversible full-data deletion, reminder cancellation, privacy/legal links. Optional passphrase encryption only if reviewed/vetted and tested; never invent cryptography.
- Rehearse old→new device via OS Files/share import/export, restart, disk-full, merge and idempotency; user should understand uninstall risk.

**Acceptance:** 100% data + evidence restored from export with byte hashes matching, zero modification on malicious/corrupt import, all-data clear removes local content and OS schedules; accurate copy about encryption. **Tests:** full round-trip on Android physical and iOS Files flow when available; data integrity count/hash, fatal import rollback, 500MB corpus test or defensible bound. **Exit:** credible offline personal data ownership. **Commit:** `milestone-12: portable export restore and deletion`.

---

## M13 — System hardening and UX refinement

**Goal:** Close launch blockers with evidence.

**Tasks**

- Full functional and architectural audit: direct DB misuse, unreachable routes, abandoned placeholder code, third-party permissions, privacy claims, security of archive import, media garbage collection, app lifecycle issues, deterministic timer accuracy.
- Run Ponytail review (if installed) for redundant abstractions, Graphify dependency/change blast radius (if repo indexed), design skills for polish; no tool can substitute for actual testing.
- Profile startup, timer power, timeline scroll, image decode, archive import/export, audio player resource leaks using named real/emulated devices and realistic large fixtures.
- Test all screens in both themes, compact devices, 200% text, VoiceOver/TalkBack, landscape/tablets if supported, reduced motion, large notes, corrupt media and denied permissions.
- Run security scan, license/SBOM audit, release backup/recovery and P0/P1 triage; create prioritized issues for remaining noncritical gaps.

**Acceptance:** no P0/P1, automated suites green with documented counts/skips, launch UX accessible, measured perf with device details, all critical privacy controls verified. **Tests:** entire `docs/QUALITY.md` suite plus threat matrix. **Exit:** beta-ready candidate. **Commit:** `milestone-13: performance security and accessibility hardening`.

---

## M14 — Beta candidate, store metadata and distribution preparation

**Goal:** Put a real signed candidate in real testers' hands with appropriate legal disclosures.

**Tasks**

- Confirm official app identity, icon, package names, supported OS targets, versioning, store/legal URLs and beta tester program. Brand collision review for common name Loop.
- Obtain owner-authorized signing, store developer account permissions and compliant bundle configuration; NEVER store secrets in Git or logs.
- Full Android device test, iOS simulator + physical iPhone test where possible; real camera/mic, local notifications, app upgrade, Files import/export, airplane mode and data delete.
- Generate Android signed AAB and iOS signed IPA/TestFlight **only when authorized**; verify build metadata/hash, screenshots and review flows. App Store privacy manifests, Play data safety and current policy reviewed against actual packaged SDKs.
- Run beta user experience walkthroughs, accessibility and crash/feedback capture with consent, close P0/P1, document all P2 exceptions.

**Acceptance:** functional beta binary with approved disclosures and store assets, device matrix evidence, tester feedback/issues. If iOS signing/hardware/store accounts unavailable mark platform-specific gate BLOCKED and do not say 'iOS ready'. **Exit:** release candidate approved pending store rollout. **Commit:** `milestone-14: verified beta release candidate`.

---

## M15 — Production release and steady-state operations

**Goal:** Ship a defensible product, with an owner-controlled rollout.

**Tasks**

- Confirm explicit owner approval for store submission and budget/payment-related actions. Final preflight all release gates, listing, screenshots, privacy policy, support email, pricing/free status and release notes.
- Publish iOS and/or Android **only when approvals, accounts and signing exist**. Record actual submission/approval/rejection and live listing links; do not use fictitious URLs. If owner isn't ready, prepare a ship package and label release awaiting approval.
- Stage rollout per store controls, monitor opt-in diagnostics and support complaints, capture known issues, release notes, and incident management responsibilities. Confirm crash/perf cannot be measured without approved telemetry.
- Document data migration/backup upgrade path, on-call/support inbox process, release rollback limitations, next version roadmap hypotheses and post-launch interview plan.
- Maintain user content safe across future upgrades; archive format stays backwards-readable or migration-managed.

**Acceptance:** 0 P0/P1, explicit owner publication consent, store status exactly documented, v1 release artifacts and handoff runbook present; if not published, status PENDING/APPROVAL-BLOCKED. **Tests:** clean retail install, update and restore, review all URLs/metadata, signed artifact checks. **Commit:** `milestone-15: production release and operations handoff` after conditions genuinely met.

---

## Dependency and acceptance matrix

| Scenario | Milestone owner(s) | Launch critical? |
|---|---|---|
| Start in under 60s, offline/no login | M01, M03, M05–07 | YES |
| Add a goal and contextual exercise | M05 | YES |
| Timer/interruptions never fabricate time | M06, M13, M14 | YES |
| Reflection attached and durable | M07 | YES |
| Photos/voice recording private by default | M08, M13, M14 | YES |
| Then-vs-Now photos/audio | M09 | YES |
| Compatible honest metrics | M04, M07, M10 | YES |
| Reminders optional/denial safe | M11 | YES |
| Full export/restore, delete all | M12, M13, M14 | YES |
| Accessibility, native devices and policy | M02, M13–15 | YES |
| AI feedback, cloud sync, paywall | Later ADR | NO |

## Milestone evidence file template

```markdown
# MXX verification — <date> / commit <sha>
**Status:** PASS | PARTIAL | BLOCKED | FAIL
**Environment:** OS, flutter/dart, devices, app flavor, schema version
**Prerequisites:** list + links
**Scope changed:** actual source files, screenshots, new deps and decisions
**Acceptance:** check IDs with pass/fail + reasoning
**Tests:** command, exit code, passed/skipped, environment and timestamps
**On-device:** make/model, OS, run steps, screenshots, limitations
**Privacy/security:** permission/data transfer/backup impact
**Tool evidence:** tool/skill/plugin exact invocation + outcomes, or 'not available'
**Blockers/P0/P1:** severity, reproduction and next remediation
**Commit:** actual git hash or 'not committed, blocked'
**Next:** next milestone ID and prerequisites
```
