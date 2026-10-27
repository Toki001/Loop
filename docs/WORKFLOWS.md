# Product workflow contract — M01 scope lock

The accepted v1 scope is the existing PRODUCT/CODEX contract. This document resolves implementation interpretations and defines identifiable verification paths; it does not claim the app works. Read [RESEARCH.md](RESEARCH.md), [SKILL_TEMPLATES.md](SKILL_TEMPLATES.md), [DATA_AND_METRICS.md](DATA_AND_METRICS.md) and [TRACEABILITY.md](verification/TRACEABILITY.md).

## Shared rules

- App launches empty and offline with no account or permission gate. Built-in exercise instructions are actual editable content; preview session/media fixtures never enter release startup.
- First Start target is ≤30 seconds from fresh launch, while also measuring the PRD's ≤60s first-use threshold. Practice duration is outside time-to-start. Finish-to-saved target is ≤60s; repeated start is at most two taps from Today with a selected skill. Targets are contractual design objectives, not measured results.
- Only a skill choice/name and a deliberate session operation are essential. Reflection, effort, metrics, media, goals and reminders are optional. A completed timed session with blank reflection remains a practice record; do not label it observed skill improvement. Evidence-only zero-duration manual entries are deliberate “journal entries”.
- Only completed distinct session IDs contribute to summaries. A paused/recovered draft is not counted. Editing changes revision metadata and recomputes existing totals, rather than adding a second completion.
- Global single timer; serialized state/repository writes; foreground monotonic segments; checkpoint and auto-pause on inactive/background. Hard-kill recovery uses only committed segments and explains possible time since last checkpoint.
- All saves distinguish saving, saved and failed states using actual storage results. Rapid repeat taps are idempotent; errors preserve input and offer recovery. No simulated success or placeholder navigation.
- Retain stable IDs and historical exercise/metric provenance when names, units, order or archive state change. Names may repeat; validate 1–60 grapheme clusters without truncating persisted content.
- Requests for permission follow the user's explicit camera/photo/record/reminder action. Denial preserves note/metric/manual workflows. No microphone in background and no compulsory media.

## F01 — Fresh offline first session (US-01, US-05, US-07, US-17; A01)

`launch/migrate → Welcome (Skip) → skill chooser (built-ins/Custom) → editable skill name → Practice Ready → Start → active → Finish → optional reflection → Save → Today/session detail`

Owner: onboarding/skills/practice/journal repositories (M03/M05–M07). Ready supports planned 1–180 minutes, untimed practice or deliberate manual log; changing a plan does not manufacture elapsed time. Save skill before starting; if it fails retain the form, report storage failure and retry. Duplicate names are allowed. No goals, network, notification, camera or microphone are required. Empty welcome/skills/Today states name the real next action. Test a fresh no-permission, airplane-mode flow and reopen the saved session with blank or note-only reflection.

## F02 — Casual untimed or manual log (US-06, US-07; A04)

Untimed live practice uses the same foreground clock, with no target countdown. A manual log is a separate deliberate entry, labeled `entryMode=manual`; user confirms entered duration and date. A zero-duration evidence-only entry is explicitly labeled and adds no practice minutes. Finish/save uses the same atomic journal use case as a timed session. Reject negative/non-finite/out-of-bound duration without losing notes; distinguish goal plan duration from recorded time. Tests verify provenance, no duplicate counting, UTC/local display policy and save/relaunch.

## F03 — Recording with denial/interruption (US-08, US-17; A05)

`Finish/Session Detail → Record or Add photo → contextual explanation/OS request → capture/pick → preview → attach pending evidence → actual save → private Library`

Capture is explicit and visibly active with Stop. Denied/revoked permission offers note/manual alternatives plus contextual retry/settings; never loops the OS prompt or blocks core save. Camera/picker cancel is neutral. Imported files are copied into private storage with opaque IDs, verified bytes/bounds/hash; ready references commit only after successful staging. On interruption/background stop/pause capture safely and explain what survived; no fake successful attachment. Disk-full/hash/corruption errors retain the journal and old assets, clean only owned temp data, offer retry/remove. Physical-device tests are required at M08/M14.

## F04 — Repeat session/draft recovery (US-02, US-04, US-05; A02–A03, A15)

Today presents the real last next-step/exercise and selected skill. Practice resumes a paused draft deliberately or opens Ready; it never silently starts a timer on deep link or notification. If a draft exists for another skill, explain it and offer resume or explicit discard before another timer. Archive retains history, but new practice chooses an active skill or explicitly reactivates it. Restart restores a paused committed draft, not background time. Double Start/Finish/Resume are serialized. Migration failure enters recovery, never silent reset. Test phone interruptions, lock, timezone/reboot, hard kill, rapid taps and old schema.

## F05 — Then-vs-Now (US-09, US-10; A06–A09)

`skill/progress/library → same-skill compatible picker → select two distinct readable moments → confirm dates/sources → viewer → source session/back`

Default suggestion oldest/newest still requires selection confirmation. Images preserve aspect/orientation; default two-up, optional direct scrub with named non-drag controls/full view. Audio A/B never autoplays/mixes; pause the prior source before playing the next, stop on exit/background, retain date/source/note labels. Metrics require matching definition ID/version/unit/source method and compatible direction; ordinal ratings display ordinal shift, not percentage improvement. With zero/one asset explain eligibility and offer a real add-evidence action. Missing/deleted/corrupt asset degrades safely; invalid pairs show no delta. No enhancement/filter or audio setting implies scientifically measured improvement.

## F06 — Portable export/restore (US-14; A11–A12)

`Settings/Data → Export → review sensitive contents/counts/mode → snapshot + media/hash manifest → validate archive → actual share/save → cleanup after share lifecycle`

`Settings/Data → Restore/pick → bounded private staging → validate schema/paths/IDs/hashes/references → preview counts/collisions → explicit choice → atomic merge/files promotion → verify counts → outcome`

Archive format is versioned and SQLite-independent. Encryption is represented exactly: optional passphrase mode only with vetted authenticated crypto/KDF and tested recovery; unencrypted mode requires explicit warning and the existing owner privacy sign-off before enablement. M01 does not grant that sign-off. No custom cryptography. Default collision proposal is skip identical IDs; a different existing record needs explicit reviewed choice and stable remapping; no silent overwrite. Full final collision semantics are an M12 implementation decision with tests. Wrong passphrase/malformed input/disk-full/missing asset/cancel leave original DB/media unchanged. Export failure never advertises a successful backup; warn uninstall/loss may erase unexported local history. User-initiated external sharing is the only transfer; external backups/recipients are outside the app's deletion guarantee.

## F07 — History edits, archive and deletion (US-02, US-11, US-13, US-15, US-18; A13, A16)

Timeline/search works offline by skill/date/exercise/notes, including explicitly shown archived skills. Details expose source, dates, metrics and evidence. Edits retain session ID, revision and provenance and recalculate summaries. Archiving a skill retains history; destructive deletion clearly names scope/count, has confirmation, reconciles dependent files/thumbnails/drafts and cancels relevant reminders. Clear All Data requires explicit irreversible confirmation and truthful external-export/system-backup exclusions. Disk-full/delete retry is idempotent; no hidden resurrection from cached state. Synthetic fixtures test many sessions, Unicode, duplicate names, amendments and cleanup failure.

## F08 — Goals, honest progress and reminders (US-03, US-10, US-12, US-16; A09–A10, A14, A17)

Goals use cumulative, threshold, weekly suggestion, deliverable or qualitative semantics. Percent only when the denominator and compatible readings make it meaningful; qualitative/deliverable goals have explicit status. Date/skill/range/source/sample count scope is visible; <2 comparable readings has no fabricated trend. Charts have values/text equivalents. Reminders are optional local best-effort weekday/wall-time schedules, explicit OS permission at use, quiet hours and pause-all; denied/revoked permission never affects practice. Zone/DST/reboot/OS-cap reconciliation and cancel-after-archive/delete are tested. All eight flows require large text, both themes, reduced motion, native hit targets, meaningful semantics and reachable keyboard-safe actions.

## Scope and review record

v1 includes every existing US-01–US-18 and launch epic LOOP-01–LOOP-12. No auth, cloud sync, AI scoring, executable user code, social features, video, wearables, subscription/paywall or telemetry SDK is admitted. These remain the existing deferred backlog and require separately approved ADR/privacy/cost decisions. Export, deletion and created history remain freely accessible.

M01 performed a static walkthrough of F01–F08 against PRODUCT, ACCEPTANCE_SCENARIOS, DATA_AND_METRICS and privacy requirements, including denial, no-space, interruption, malformed import, duplicate completion, incompatible metrics, amendment, archive, missing media and destructive cleanup. This is specification review, not app E2E or participant validation. All flows have planned tests in traceability. Empirical research stays pending; no material product scope was changed, so no human scope sign-off is claimed.
