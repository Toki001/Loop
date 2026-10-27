# Requirement traceability — M01 reviewed contract

This maps the existing contract to planned verification. **Functional app-story acceptance remains NOT IMPLEMENTED / NOT RUN; M02 design/component tests are verified separately.** M00 established coverage; M01 reviewed [workflows](../WORKFLOWS.md), [metric/templates](../SKILL_TEMPLATES.md) and [pending research](../RESEARCH.md). M02 supplies the [23-screen/state contract](../SCREEN_DESIGN.md), native primitives, contrast/accessibility design regressions and [225 hashed references](design/ARTIFACTS.json); this does not close US-16/A14's physical-runtime gate. [PRODUCT.md](../PRODUCT.md), [ACCEPTANCE_SCENARIOS.md](../ACCEPTANCE_SCENARIOS.md), [DATA_AND_METRICS.md](../DATA_AND_METRICS.md), [QUALITY.md](../QUALITY.md) and [SECURITY_PRIVACY.md](../SECURITY_PRIVACY.md) remain authoritative.

Screen numbers refer to PRODUCT §6. U = unit, R = real SQLite repository/integrity, W = widget/semantics, G = golden, E = native integration, H = physical/manual. All v1 rows are launch gates, including tests deferred to M13/M14. No story is satisfied by screenshot evidence alone.

| Story | UI / data responsibility | Delivery milestone(s) | Planned tests / scenarios | Launch acceptance |
|---|---|---|---|---|
| US-01 | Screens 2–4, 6; skill ID/name/category; onboarding | M03, M05, M07 | U grapheme validation; R restart; W/G setup; E A01 | Skill in 3 steps; no account/network/permission; fresh first loop within 60s |
| US-02 | Screens 6–7; skills archive/order; retained foreign keys | M05 | R archive/reorder, duplicate names; W long names; E A16 | Rename/archive/reorder persist and retain history |
| US-03 | Screens 7–8; goals and metric definitions | M05, M10 | U numeric/direction/qualitative goals; R updates; W/G editor; A09–A10 | No invented qualitative percentages; compatible targets only |
| US-04 | Screen 9; editable exercise/template copies | M05 | R duplicate/edit/archive/template upgrades; W/G; E goal/exercise flow | Templates are editable; historical snapshots retained |
| US-05 | Screens 10–12; session state/foreground segments | M06 | U fake monotonic clock; R serialized writes; W; E A02–A03; H Android | One active timer; background excluded; paused recovery; drift target verified |
| US-06 | Screens 10, 12–13; manual entry intent/source | M06, M07 | U validation/counts; R source; W manual editor; E A04 | Deliberate manual duration labeled; evidence-only zero time never inflates minutes |
| US-07 | Screens 12–13; notes/effort/nextStep | M07 | R atomic save/retry; W keyboard/empty/long notes; E A01 | Optional reflection saves offline, survives restart; next step visible |
| US-08 | Screens 12–13, 18; private media repository and OS adapters | M08 | R hash/file lifecycle; W/G denial; E A05; H camera/mic, revoke, disk-full | Deliberate capture only; copied private evidence survives restart; no orphan data |
| US-09 | Screens 16–17; eligibility query/serialized playback | M09 | U eligibility; W/G aspect ratios; E/H A06–A08 | Dated compatible moments; no stretch; audio exclusive; non-drag controls |
| US-10 | Screens 14–15; comparable readings/aggregations | M04, M07, M10 | U A08–A10, zero/null/direction/version/ordinal scales; R recompute; W text table | Same definition/unit/source; sample counts; no mastery score or invalid percent |
| US-11 | Screens 5, 7, 13–15; session timeline/calendar query | M07, M10 | R sorting/filtering; U UTC/local date boundaries; W/G empty; E history/reopen | Accurate chronological history and active time scoped to selected dates/skills |
| US-12 | Screen 20; reminder repository + local OS schedule | M11 | U timezone/DST/quiet hours; E/H A17, reboot/revoke/cancel | Opt-in best-effort reminders; denial never blocks practice; no duplicate schedules |
| US-13 | Screens 18–19; bounded local search | M10 | R escaped keywords/archive filter; U limits; W results; E A16 | Offline search returns retained entries without remote indexing |
| US-14 | Screens 21–22; versioned manifest/media; atomic restore | M12 | U archive bounds/traversal; R merge/rollback; E/H A11–A12 | All records and media hashes round-trip; malformed input changes nothing |
| US-15 | Screens 13, 18, 21; deletion/reconciler/OS cancellations | M07, M08, M12 | R cascade/cleanup retry; E/H A13 | Explicit scope/count/confirmation; files/drafts/schedules cleared; backup caveat honest |
| US-16 | All screens; shared semantics/layout/motion | M02, M03, M13, M14 | W/G small/large light/dark/200%; H A14 VoiceOver/TalkBack | Reachable controls, AA contrast, text charts, reduced motion, native hit targets |
| US-17 | Screens 12, 18, 20; permission states/manual alternatives | M07, M08, M11 | W denied/retry/settings; E/H A05/A17 | Core practice works without camera/microphone/photos/notifications |
| US-18 | Screen 13; revision metadata and derived queries | M07, M10 | R idempotent amendment/rollback; U totals; E edit/relaunch | Completed entry edits preserve provenance and recompute without double counting |

| Scenario | Primary milestone(s) | Verification boundary / release gate |
|---|---|---|
| A01 | M03, M05, M07 | E fresh offline skill → note-only session → relaunch; H time first use |
| A02 | M06, M13, M14 | U clock + E lifecycle + H Android/iPhone: 90s active, 5min absent, 30s active ≈120s |
| A03 | M06, M07 | U/R double Finish, E rapid taps; single row/readings/media set |
| A04 | M06, M07, M10 | U/R manual provenance and total; E manual 20min |
| A05 | M07, M08 | W + H deny/revoke mic/photos; save manual alternative, capture stops |
| A06 | M09 | G differing photo ratios; E source navigation; H screen-reader comparison controls |
| A07 | M09 | U player arbitration + H audio start/stop/background resource release |
| A08 | M09, M10 | U/R incompatible unit/version/source; W explanatory empty state |
| A09 | M10 | U baseline 0 →10: +10; no infinity/NaN/percent |
| A10 | M05, M10 | U goal semantics + W qualitative goal state, no artificial percent |
| A11 | M12, M14 | E/H two-device archive: 5 skills, 30 sessions, 3 images, 2 audio; counts/hashes match |
| A12 | M12, M13 | U/R traversal/symlink/duplicates/corrupt/oversize/version; source remains unchanged |
| A13 | M12, M14 | E/H clear DB/media/thumbnails/drafts/schedules; external exports/backups excluded |
| A14 | M02, M13, M14 | W/G 200%/reduced motion; H compact Android and iPhone, TalkBack/VoiceOver |
| A15 | M04, M13, M14 | R actual SQLite historical schema → new; E upgrade/interruption without reset |
| A16 | M05, M10 | R/E offline keyword + archived skill/history; filter totals correct |
| A17 | M11, M14 | U DST/zone/quiet hours; H notifications deny/disable/reboot, best-effort copy |
| A18 | M14, M15 | H signed clean/upgrade installs, packaged SDK/privacy audit, explicit owner publication approval |

Cross-cutting launch requirements must also be closed:

| ID | Contract and implementation milestone(s) | Verification / launch condition |
|---|---|---|
| X-01 | Local-first/no login/backend/AI/paywall/telemetry; M03–M15 | Offline E2E; dependency/native permission audit; no hidden transfers or retail fixtures; no analytics SDK by default |
| X-02 | Private storage/backup/encryption claims; M04, M08, M13 | Real native DB/WAL/media/backup lifecycle, interruption and recovery evidence; ADR-008/D-05 resolved |
| X-03 | Data integrity; M04–M12 | Transactions, FKs, immutable IDs, migrations, staged media writes, disk-full, idempotency, export/restore corruption tests |
| X-04 | All 23 screens/states; M02–M12 | Each screen: purpose/actions/validation/loading/empty/error/denied/success/recovery; W/G plus behavioral E2E |
| X-05 | Native responsive craft; M02, M03, M13 | Light/dark, compact/large, keyboard, 200%, long Unicode, rotation/tablet policy, text alternatives, reduced motion |
| X-06 | Performance; M06, M08, M10, M12–M14 | Named release/profile devices and dataset; p95 boot <2.5s objective; drift <2s/30min; 1,000 sessions/2,000 thumbnails; bounded 500MB archive or justified cap |
| X-07 | Security negative matrix; M04, M08, M12–M14 | No P0/P1; archive traversal/bombs/symlinks, media bounds, permission revoke, logs/paths/keys, rollback/forward fix tested |
| X-08 | Reproducibility/dependencies/licenses; M03–M15 | Verified stable SDK pin, locked dependencies, package maintenance/outdated checks, SBOM/licenses, CI/build hashes and signing provenance |
| X-09 | Real hardware; M06, M08, M11–M14 | Physical Android lifecycle/camera/mic/export; physical iPhone beta matrix; browser/goldens cannot replace device checks |
| X-10 | Research and outcomes; M01, M02, M13 | 8–12 interviews + 5 moderated prototype tests planned; consented beta diary; hypotheses labeled until measured |
| X-11 | Release/policy/ownership; M14, M15 | Actual store policy/SDK/manifest/privacy/support/age/brand review, signed artifacts, owner permission, closed P0/P1, staged rollout/support |
| X-12 | Scope/flags/approvals; M00–M15 | One authorized milestone, future features disabled/absent in retail; no uploads/OAuth/indexing/install/spend without approval; data export/deletion never paywalled |

Decision inventory from [DECISIONS.md](../DECISIONS.md); M00 does not invent owner approval:

| Decision | Current state / safe handling | Owner / next gate |
|---|---|---|
| D-01 | Research pending; general hobbyists/English/international remain assumptions | Product owner, M01 |
| D-02 | Engineering baseline: Android API 24+, iOS 15+; operational validation pending, see [environment](ENVIRONMENT.md) | Engineering at M03; confirm audience/device coverage in M01, recheck packages and policy at M14 |
| D-03 | Owner resolved: Android/iOS `com.jameskierdoliguez.loop`, display name Loop; immutable without approval; store availability not yet verified | Implement in M03; availability/identity review M14 before production publication |
| D-04 | Loop is a working name; no trademark/asset conflict clearance claimed | Owner, M01/M14 |
| D-05 | OS-private storage baseline; app encryption spike and threat tolerance unresolved | Owner + engineering, M04/M13 |
| D-06 | Archive encryption unresolved; plain warning is a proposal pending owner privacy sign-off | Owner before M12 enablement |
| D-07 | File/duration/storage caps unmeasured; no limits invented here | Engineering + research, M08 |
| D-08 | Free v1; no payments implemented; later changes require separate ADR | Owner, post-launch |
| D-09 | English initial; text/RTL-ready architecture + 200% accessibility contract; locale scope confirmation pending | Owner/design, M02/M13 |
| D-10 | Android beta then iOS beta proposed; public both only after validation | Owner, M14/M15 |

M01 [ADR-011](../adr/ADR-011-product-interpretations.md) preserves the strict ≤30s Start target, separately reports the ≤60s first-use threshold and ≤60s Finish-to-saved, and excludes practice duration from time-to-start. PRODUCT's archive wording now matches ARCHITECTURE: encryption must be accurate/vetted; plaintext needs explicit owner privacy sign-off before enablement. Actual timing/research and M12 export security/privacy acceptance remain pending. No launch gate is dropped.
