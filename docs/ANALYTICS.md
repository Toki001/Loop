# Success Metrics, Instrumentation and Learning Plan

## 1. Product north star

**Evidence-backed practice weeks**: among voluntarily participating beta testers who choose to report aggregated counts, the number of user-weeks with ≥1 completed practice session and ≥1 meaningful reflection, metric, or media artifact. This reflects the product mission but is not instrumented secretly in v1. For local users display their own statistics; server-side cohort analytics require separate opt-in and ADR.

## 2. Product hypotheses

H1: Users can begin their first practice without media permissions; measure the strict ≤30s Start target and also report the ≤60s threshold, excluding practice duration. H2: A no-pressure reflection prompt helps users identify their next action. H3: Then-vs-Now creates perceived value over basic streak tracking. H4: Offline/without-account onboarding increases trust but may create recovery concerns; clear export workflow mitigates. All remain unvalidated hypotheses. M01's [research protocol](RESEARCH.md) is prepared, not conducted.

## 3. Optional consented metrics for a future beta

- `first_session_completion`: enrolled tester self-report or opt-in anonymous event (no skill names/notes).
- `median_time_to_first_session`: capture only with meaningful consent and aggregation.
- `weekly_return`: opt-in broad reporting, not a requirement for functionality.
- `comparison_open_rate`: aggregate metadata only; never send images, audio or notes.
- `export_success`: aggregate success/error code without archive content.
- `permission_denial_recovery`: test lab observation, not stealth tracking.

No analytics SDK is to be added by default. If consented telemetry approved: document exact data fields, retention window, opt-out, platform privacy declarations, processor agreement, security, testability, and a switch to disable fully. Avoid persistent cross-device user tracking IDs.

## 4. Research plan

M01: 8–12 interviews balanced among artistic, language and technical practice; capture pain points, desired artifact types, whether weekly reminders help; limit personal recordings collection. M02: five moderated flow tests with prototypes; measure completion and confusion. M13 beta: privacy-respecting weekly optional diary asking whether comparisons help motivation, obstacles to logging, export trust; collect qualitative feedback with consent.

## 5. Product feedback decision rules

Do not claim feature impact based on five interviews. Label evidence as qualitative. Reconsider complexity of reflection if >25% of moderated testers abandon completion flow due to friction; reconsider first-time flow if majority can't start session in 60 sec; quantify after real beta, not by generated dummy data. Monetization only after documented retention and value research.
