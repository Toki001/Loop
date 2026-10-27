# Loop implementation backlog (mapped to milestones)

This backlog is subordinate to `docs/MILESTONES.md` and `docs/PRODUCT.md`. IDs are suggested issue identifiers; they are not completed tickets.

## Must-have launch epics

| Epic | P0/P1 task clusters | Milestones |
|---|---|---|
| LOOP-01 Foundation | app shell, feature router, theme, localization, CI, sensible fatal error recovery | M03 |
| LOOP-02 Storage | drift migrations, transaction semantics, private media paths, key/OS protection assessment | M04 |
| LOOP-03 Skill setup | category templates, custom skills, archive semantics, goals and exercises | M05 |
| LOOP-04 Practice engine | durable timer segments, background pause, kill recovery, manual log | M06 |
| LOOP-05 Journal | finish reflection, metric readers, edit/revision, timeline filters | M07 |
| LOOP-06 Evidence | camera/photo imports, mic recording, audio playback, file reconciliation | M08 |
| LOOP-07 Comparison | chronology-aware eligible picker, image slider, audio A/B, accessible alternatives | M09 |
| LOOP-08 Insights | honest sample thresholds, dates/units/timezone, chart/list, search | M10 |
| LOOP-09 Local reminders | schedules, quiet hours, permission states, timezone and cancellation | M11 |
| LOOP-10 Ownership | export archive, checksum/hash, transactional restore, deletion, privacy UI | M12 |
| LOOP-11 Quality | P0/P1 triage, golden/device matrix, perf, privacy disclosures | M13 |
| LOOP-12 Shipping | signing, policy, store assets, beta, staged launch | M14–15 |

## Deferred with explicit trigger

| Feature | Why deferred | Before admission |
|---|---|---|
| AI voice/singing feedback | unvalidated performance and privacy risks | explicit opt-in, rigorous evaluation, no fake scores |
| Auto chord/tempo recognition | instrument/acoustic noise variance | benchmark on representative devices |
| Code kata runner | execution sandbox and abusive code risk | separate security architecture |
| Shared social challenges | moderation/privacy/compliance | scoped online accounts and legal review |
| Remote multi-device sync | backend, conflict resolution, personal media uploads | architecture ADR, threat model, cost budget |
| Paid plans | user value and receipts complexity | monetization ADR and store policy implementation |
| Video evidence | storage explosion, transcoding and accessibility | limits and mobile profiling |
| Wearables and health integrations | regulated/sensitive data scope | separate privacy review and owner approval |

## Product definition of Launch P0/P1

The app must not ship if any user can easily lose saved reflections/media without clear recovery, if practice minutes are inflated by background time, if exported archives cannot restore, if denied permissions block manual practice, if screens overflow on supported phones/accessibility, or if release claims contradict actual SDK/data flows. Small cosmetic polish is lower priority than these guarantees.
