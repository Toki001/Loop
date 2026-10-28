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

**Decision:** private directory and honest OS protection baseline; choose application encryption only after native/key/restore lifecycle validation. M04's owner-approved cipher primitive experiment passed host, iOS simulator and physical Android checks; [ADR-014](adr/ADR-014-private-persistence.md) retains ordinary SQLite until the complete key/media lifecycle is proved. Physical iPhone/OEM/release threat review remains open. Never claim blanket media encryption.

## ADR-009 — No media video in public v1

**Decision:** images + short audio first. **Reason:** reduce storage/performance/UX complexity. **Revisit:** based on visual arts/movement user research and tested capacity.

## ADR-010 — Evidence-only zero-duration entries

**Decision:** explicitly allowed but labeled "journal entry", not counted toward practice minutes. **Reason:** users may record an achievement without timing it.

## Decisions requiring owner or M01 research

| ID | Question | Proposed safe default | Responsible milestone |
|---|---|---|---|
| D-01 | Primary launch audience? | General hobbyists, English locale, international | M01 |
| D-02 | iOS/Android OS min versions? | M00 engineering baseline Android API 24+/iOS 15+; validate native packages/devices in M03, current store policy again in M14 | M00/M03 |
| D-03 | App bundle ID / package ID? | RESOLVED by owner 2026-10-27: Android/iOS `com.jameskierdoliguez.loop`, display name Loop; never change without approval; production availability still to verify before publication | M03/M14 |
| D-04 | Logo and product name conflicts? | Owner display name Loop; brand/logo/availability clearance not established and remains a release gate | M01/M14 |
| D-05 | App encryption scope? | M04 platform baseline selected under owner authority after synthetic cipher tests; no app-managed key/cipher integrated; physical/key/restore/OEM threat review remains | M04/M13/M14 |
| D-06 | Export encrypted default? | clear plain-archive warning until audited crypto available | M12 |
| D-07 | Media retention/limits? | ergonomic maximums determined by performance and user tests | M08 |
| D-08 | Subscription model? | none in v1; separate monetization sprint | post-launch |
| D-09 | Accessibility/language locales? | English initially; text/RTL-ready, 200% type | M02/M13 |
| D-10 | Platform launch sequencing? | Android beta then iOS beta; public both after validation | M14/M15 |

If a changed decision affects code, add `ADR-0xx` with Context, Decision, Alternatives, Tradeoffs, Data/Security impact and date; update dependent docs and tests. Do not silently break contract.

M01 reviewed all ten decisions without assuming owner approval beyond the explicitly supplied D-03 identity. General hobbyists/English-first and free v1 remain the contract's safe defaults; research/locale demand and brand conflicts are not validated. [ADR-011](adr/ADR-011-product-interpretations.md) records scope-preserving timing, optional evidence, export-mode and identity interpretations; M04/M12 security and privacy decisions remain open.

M02 [ADR-012](adr/ADR-012-native-design-harness.md) records the root SDK-only design package/harness, tiny AA color correction, accessible action/navigation layouts and pinned native golden renderer/fonts. Original open-loop artwork is an engineering design, not trademark/production-brand clearance. D-04/D-09 and real-device accessibility remain at their release gates.

M03 [ADR-013](adr/ADR-013-native-bootstrap.md) implements the owner-approved identity, pinned native runtime, versioned preferences/recovery, stable guarded shell and local/CI verification boundary. Android debug compiles with API 24 minimum/36 target; iOS simulator compiles with deployment 15 and runs on iOS 27. Actual older-OS/physical coverage and current store policy remain M14 gates. Preferences must migrate losslessly into M04 settings; no journal encryption or remote CI pass is implied.

M04 [ADR-014](adr/ADR-014-private-persistence.md) selects ordinary private SQLite under verified/configured OS protections after the owner-approved isolated cipher experiment. M05 [ADR-015](adr/ADR-015-skill-management.md) adds atomic owned setup and v3 goal metadata/completion preservation. Neither decision permits application encryption, remote services, private indexing or weaker release gates without the required evidence/authority.

M06 [ADR-016](adr/ADR-016-practice-clock.md) adds foreground-only monotonic practice, dependent v4 fractional checkpoints, explicit manual/journal provenance and paused recovery. Automatic writes preserve human Pause; bootstrap drains queued engine work before closing storage. Implementation, automated checks and physical Android lock/background/kill/recovery acceptance pass; see [M06](verification/M06.md). No background service, key or new permission is introduced.

M07 [ADR-017](adr/ADR-017-session-journal.md) adds atomic reflection/readings, schema5 raw drafts, live journal views and revision-aware edits/metadata Undo. [ADR-018](adr/ADR-018-expressive-native-design.md) implements the owner's2026-10-28 seven-image UI revision: rich focus cards, layered surfaces, distinctive navigation and dark mode. Android/iOS journal setup/new-process resume, final full CI and four-target normal-main retention/visual review pass; no release claim follows. No dependency, OS permission, remote service or application key is added.
