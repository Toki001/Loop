# Architecture Decision Records (ADRs) and Decisions to Confirm

## ADR-001 — Flutter over a responsive web shell

**Decision:** Flutter native Android/iOS. **Reason:** audio capture, camera, local notifications, offline data and consistent fluid UX. **Tradeoff:** OS-specific verification remains essential and browser-only checks insufficient.

## ADR-002 — Offline-first/no account public v1

**Decision:** No sign-in/backend. **Reason:** immediate start, privacy, low operating cost. **Cost:** cross-device sync not available; export/restore and candid uninstall warning become release critical.

## ADR-003 — Drift SQLite + private media files

**Decision:** relational durable data and separate app-private media with integrity hashes. **Reason:** filterable history and robust migrations; audio/photo payloads don't belong in rows. **Tradeoff:** lifecycle/reconciliation required.

## ADR-004 — Evidence > universal skill score

**Decision:** typed per-skill metrics, provenance and comparable artifacts. **Reason:** arbitrary universal score misleading; users improve in different dimensions. **Tradeoff:** some charts unavailable until enough entries.

## ADR-005 — No AI inference or cloud scoring in v1

**Decision:** self-report/instrumented input only, transparent formulas. **Reason:** trust, cost, scientific uncertainty, privacy. **Tradeoff:** less automation at launch.

## ADR-006 — Free initial launch

**Decision:** no built-in paywall v1; Pro value researched post-launch. **Reason:** focus on reliability and retention. **Tradeoff:** no immediate subscription revenue. Monetization requires separate ADR/store compliance.

## ADR-007 — Local notifications optional

**Decision:** on-device best-effort reminders; no remote push. **Reason:** aligns with offline/no account. **Tradeoff:** scheduling restrictions and OS behavior.

## ADR-008 — App-managed database encryption TBD after security spike

**Decision:** private directory and honest OS protection baseline; choose SQLCipher or comparable well-maintained encryption only after cross-platform native spike, key lifecycle and archive implications documented. Never claim blanket encryption if only DB encrypted while media remain plaintext. **Open blocker:** owner threat tolerance and native compatibility review.

## ADR-009 — No media video in public v1

**Decision:** images + short audio first. **Reason:** reduce storage/performance/UX complexity. **Revisit:** based on visual arts/movement user research and tested capacity.

## ADR-010 — Evidence-only zero-duration entries

**Decision:** explicitly allowed but labeled "journal entry", not counted toward practice minutes. **Reason:** users may record an achievement without timing it.

## Decisions requiring owner or M01 research

| ID | Question | Proposed safe default | Responsible milestone |
|---|---|---|---|
| D-01 | Primary launch audience? | General hobbyists, English locale, international | M01 |
| D-02 | iOS/Android OS min versions? | choose stable supported baseline after device matrix and plugins | M00/M03 |
| D-03 | App bundle ID / package ID? | owner-controlled reverse domain; never invent as final | M03 |
| D-04 | Logo and product name conflicts? | treat Loop as working product name pending checks | M01/M14 |
| D-05 | App encryption scope? | test OS protection and app-managed encryption costs | M04/M13 |
| D-06 | Export encrypted default? | clear plain-archive warning until audited crypto available | M12 |
| D-07 | Media retention/limits? | ergonomic maximums determined by performance and user tests | M08 |
| D-08 | Subscription model? | none in v1; separate monetization sprint | post-launch |
| D-09 | Accessibility/language locales? | English initially; text/RTL-ready, 200% type | M02/M13 |
| D-10 | Platform launch sequencing? | Android beta then iOS beta; public both after validation | M14/M15 |

If a changed decision affects code, add `ADR-0xx` with Context, Decision, Alternatives, Tradeoffs, Data/Security impact and date; update dependent docs and tests. Do not silently break contract.
