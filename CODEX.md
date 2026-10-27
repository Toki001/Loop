# CODEX.md — LOOP: COMPLETE PRODUCT ENGINEERING MISSION

## Product charter

**Product:** Loop  
**Category:** personal growth, deliberate practice, hobbies, learning  
**Targets:** Android and iOS; Flutter native widgets  
**Launch posture:** local-first, no account, privacy-respecting  
**Tagline:** *Practice with intention. See your progress.*  
**Experience promise:** within 30 seconds the user can begin practicing; within 60 seconds of finishing they can record what improved; after several sessions they can compare real evidence and see patterns.

Loop is **not** a habit tracker disguised as a calendar. Loop connects an intention → session → artifact / metric → reflection → next step. Users can make progress even when they practice irregularly; we show consistency as context, never as a shame mechanism.

## Deliverable quality standard

Build a product people can trust with their personal recordings and long-term progress history. Every feature must be real, persisted, reversible when reasonable, comprehensible, tested and accessible. Shipping means an actual signed app build and a store-ready submission package, **not** a screenshot or green unit tests alone.

## What users do

1. Choose from Guitar/Music, Drawing, Language, Programming, Singing/Voice, Typing, Fitness/Movement (manual only; not a health app) or Custom.
2. Define a meaningful skill goal: outcome, unit, target or milestone, frequency suggestion and motivation; optional baseline evidence.
3. Start a focused practice session with a plan or exercises; timer runs reliably and can pause/resume/cancel.
4. Save a reflection (effort, what worked, what to repeat) and at least one form of **evidence** (optional metrics, notes, image or audio).
5. Explore skill-specific charts/timelines and compare eligible photos/audio/quantitative values from two sessions.
6. Decide the next repeatable action; optionally set a respectful reminder; export or delete their data anytime.

## MVP and post-launch separation

**Core v1 must ship:** quick onboarding with skip, skill CRUD, goals, exercise templates, reliable sessions, logs, image/audio import/capture if permission granted, private media library, then-vs-now, timeline/calendar, meaningful metrics, reminders opt-in, search/filter, empty/loading/error states, onboarding/help, user export and tested restore, privacy/delete, accessibility, CI and store submissions.

**Do not block v1 on:** AI feedback; speech recognition; automated scoring; chord detection; real-time microphone analysis; coding interpreter; social leaderboard; coach marketplace; cloud sync; collaborative groups; sign-in; remote push; paid subscription. These are documented roadmap candidates and require separately approved ADRs plus security/cost review.

## Architecture decisions (binding until ADR)

- Flutter stable (pin after verification), Dart; Android/iOS first, no WebView shell.
- Feature-first structure, repository-owned writes and a testable domain layer.
- State management: **Riverpod** (select current compatible version after inspection); deterministic injection in tests.
- Routing: **go_router** with shell navigation, typed/named routes where practical; deep link strategy documented.
- Persistence: **Drift + SQLite**; SQLite foreign keys/transactions; migrations tracked and tested. Use well-supported encrypted database option only after documented plugin/device validation, otherwise platform data protection + protected file storage and accurate user-facing claims (never misleading 'end-to-end encryption').
- Device credentials/secrets: `flutter_secure_storage` only if a key or token is needed. No account/auth backend in v1.
- Evidence storage: app-private document directory, random opaque file identifiers, image resize/EXIF scrubbing policy, local audio codec validation, integrity manifest, delete/export/restore lifecycle.
- Recording/media: evaluate maintained `record`, `just_audio`, `image_picker`, `camera`, `path_provider` equivalents at implementation time; permissions are requested *when needed*.
- Notifications: local device scheduling only (timezones, daylight-saving and OS permission/frequency constraints tested); never block practice if notifications denied.
- Charts: performant Flutter chart library assessed for accessibility; also present equivalent text/table statistics.
- Product telemetry: OFF by default for v1; use aggregated opt-in, privacy-reviewed instrumentation only if approved. Do not sneak in analytics or crash SDKs.
- Open-ended plugins: discover, verify and document; no mandatory third-party plugin is permitted to compromise the product.

## Navigation

Bottom tabs: **Today**, **Skills**, **Practice** (visually prominent launch action), **Progress**, **Library**. A single global **Settings** route via top app bar or menu; profile/account tab intentionally omitted. The practice tab opens skill selection or resumes draft, rather than a dead tab. Maintain back-button, unsaved changes, state restoration and deep-link rules. Avoid more than five top-level destinations.

## Definition of Done, per feature

An item is done only when: accepted UX spec and tests exist; data survives process kill/relaunch; invalid input and permission denial recover gracefully; screen reader/focus and 200% text work; light/dark/compact screens do not overflow; load/empty/error/permission/partial states exist; telemetry/privacy impact checked; golden/widget/unit tests pass; documented on-device behavior; no fake backend or placeholder click; lint + format + build succeed; verification log is updated.

## Complete development sequence

Read `docs/MILESTONES.md` for **16 gated milestones M00–M15**. Complete them in order, with one local commit per successful milestone; no combining unverified phases and no external deployment without approval.

## Continuous Milestone Execution Policy

**Owner authorization dated 2026-10-27:** continue M01 → M02 → M03 → M04 → M05 → M06 → M07 → M08 → M09 → M10 → M11 → M12 → M13 → M14 → M15 automatically within the active session and resume this policy in future sessions. After a successful milestone, do not stop to request another prompt. M00 is already PASS; preserve its historical verification.

Read the next milestone's full requirements and prerequisites; use a local `milestone/XX-short-name` branch; implement its real behavior; run applicable format/analyze/unit/widget/golden/integration/native-build/migration/accessibility/responsive/privacy/security/performance and regression gates. Diagnose and properly fix failures, rerun affected checks and regressions, and repeat until acceptance passes. Never weaken assertions, bypass failing tests, remove legitimate features or replace production behavior with mocks to obtain green results.

Update `docs/verification/MXX.md`, `PROGRESS.md`, `CONTINUATION.md`, requirement traceability and the milestone/status ledgers. Record actual commands/exits/counts, artifacts, screenshots, security/dependency impact, outstanding issues and next prerequisite. Commit each successful milestone locally with the prescribed subject; verify the resulting SHA and clean worktree, then **VERIFY → DOCUMENT → COMMIT → CONTINUE AUTOMATICALLY**. Routine local engineering, feature implementation, refactors, files/directories, tests, screenshots, local branches and commits require no additional confirmation.

If a genuine external blocker prevents acceptance, use BLOCKED with concrete evidence and the missing prerequisite, never PASS. Continue safe preparation and independent milestones only if their prerequisites can still be satisfied; do not declare dependent gates waived. Record the current branch, completed commits, exact resume commands, test status, unresolved blockers and next action in `docs/verification/CONTINUATION.md`, including before context/session interruption whenever possible. A future session must inspect actual Git state and resume the first incomplete milestone without repeating verified work.

The following still require explicit approval: unapproved third-party agent plugins or services requiring authorization; external-account connections/OAuth; exposing private code, remote indexing or private user-data uploads; purchases/charges; destructive or irreversible actions outside approved scope; remote pushes; app-store publication; production credentials; legal agreements. Finish all safe local preparation before asking, and never bypass security safeguards. Native hardware/signing/legal/publication limitations remain real release blockers.

Preserve the accepted native design contract and accessible/responsive interactions; use only verified available skills/tools. Once all implementation milestones pass, run the full available suite, final regressions and supported native builds, audit production/privacy/security/accessibility configuration, verify cleanliness, and produce a final report distinguishing completed work, environmental limits, owner approvals and actual release status. Continuous execution does not authorize claims of physical testing or publication that did not happen.

| Phase | Milestones | Main exit |
|---|---|---|
| Discovery and setup | M00–M02 | repo toolchain, product/UX decisions, approved design system |
| Foundation | M03–M04 | app shell, data model, migrations, encryption assessment |
| Daily core | M05–M07 | skills/goals, timer/session lifecycle, reflection/exercise tools |
| Evidence and insight | M08–M10 | private media, then-vs-now, honest meaningful progress |
| Finishing experience | M11–M12 | reminders, data lifecycle export/restore, settings |
| Hardening and launch | M13–M15 | cross-device audit, beta, store release/operations |

Milestone M15 requires signed release candidate, closed P0/P1 issues, final app privacy metadata and explicit human publication decision. If assets, store accounts, certificates, legal copy or physical iOS hardware are missing, mark **BLOCKED** accurately; never fabricate successful release.

## Use of specialized assistants

At startup call actual skill discovery (`find_skills` if available) and plugin-management workflow to find **headless**, **graphify**, **ponytail**, **ui-ux-pro-max**, **web-design-guidelines**, **shadcn**, **hallmark**, **emil-design-eng**. Read `docs/TOOLS_AND_SKILLS.md` for what each is useful for. Skills complement, not replace, Flutter widget tests and native-device checks. Verify publisher/origin and installation instructions, ask approval for external actions, report real availability and invocations.

## Paths, evidence and commands

See `docs/ARCHITECTURE.md` for repository skeleton and `docs/QUALITY.md` for gates. Minimum relevant verification:

```bash
flutter --version
flutter doctor -v
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
flutter test integration_test   # when device/emulator is available
flutter build apk --release     # when signing/toolchain are ready
flutter build ios --release     # on provisioned macOS with signing
```

Do not run privileged installation or release commands without permission. Verify commands against the installed SDK; a failed/skipped command cannot count as a pass. Track dependency locks, OS versions, emulator IDs and screenshot baselines in evidence logs.

## Success criteria

Users should be able to begin a skill without an account, complete a short session without network, observe personal history without invented metrics, compare a real prior artifact to a new one and recover their long-term history with an exported archive. No one should lose content because they changed skill names, moved timezones, went offline, denied permission or upgraded the app.

**Do the work in milestones and keep reporting precise truth.**
