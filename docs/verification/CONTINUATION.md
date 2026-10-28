# Durable execution checkpoint — 2026-10-28

Owner authorizes continuous M01–M15 execution, one verified local milestone/branch/commit at a time. Confirm SHA and clean worktree, then immediately start the next incomplete milestone; no prompt to continue. Read AGENTS/AGENT/CODEX and actual Git state. Never push/publish/connect accounts/install unapproved agent tools/index or upload private code/purchase/handle production credentials/accept legal agreements without approval. Preserve M00 historical evidence, frozen M02 images and historical schema fixtures. Context limits require a checkpoint, not a restart.

## Completed milestones

M00 `fa316ff`; policy `af667df`; M01 `9b90ca94372e7e8f7926a63d3de3243ab5da1195` (checkpoint702a305); M02 `7ede417c8358d14bfc4f97686c7b6be53d225125` (checkpointd5b1ac7); M03 `95b8f7cc7cb51d9a4d9781e4b70b5bb21191ff61` (checkpoint9b01ffe); M04 `86e800ed31bc3f7b3fc58142d2160ccd4e1df97e` (checkpoint51571809a775decef904558563b533deffdd9c87); M05 `930fb53ec8e08f291cc3cdb50a31e5e3be027d71` (checkpointa95097f35a6b60e4031c28413eaab62375ca3df2); M06 `6ae862a5adaa15ad055d50afd7803aa934184b83` (checkpoint `f43687b29a36feed947cecfe519ee6e25db072f6`). Each verified clean. Do not redo completed measurements. M06 physical lock/background600.165sec/live kill/recovery passed; complete evidence and failed attempts remain in M06 report.

## Current state — M07 committed and verified clean

M07 `9b7a1a9a362d842b5178e2db0a65e0fe5cee7319`, subject `milestone-07: complete offline practice journaling`, committed on `milestone/07-practice-journal` and verified clean. This documentation checkpoint records its actual SHA; verify the checkpoint commit/clean tree, then immediately create `milestone/08-private-media`. No active native build/test or supervisor remains; final normal-main binaries are installed on the phone and all three existing iOS simulators. Inspect actual Git state before committing.

The owner supplied seven visual references and explicitly requested a substantial, apparent UI/UX improvement while continuing. ADR-018 and DESIGN now govern this accepted revision. Production has rich cobalt/indigo focus cards with original open-loop artwork, editorial type, layered rounded surfaces, colorful badges, prominent time panels, real activity summary, compact timeline filters, a floating ink navigation dock and deliberate near-black dark theme. All seven reference qualities/hashes are recorded in `evidence/M07/design-reference-review.json`. No reference assets, logos, avatars or fonts were redistributed. Keep this direction for subsequent screens. M02 gallery explicitly selects its historical theme;225 frozen images and all285 historical references remain intact.

## M07 verified implementation

ADR-017/schema5: optional What got easier ADD COLUMN and dependent versioned JSON drafts, preserving v1–v4 fixtures. Atomic Finish coordinates session/checkpoint, existing exercise snapshots, optional notes/easier/next/effort/readings and draft cleanup. Typed finite/range/unit/version/source validation, real SQL-full/mid-write rollback, idempotent lost-response retries, optimistic revision amendments and retained manual provenance. Timed duration cannot be rewritten by editing. Raw invalid numeric text persists in drafts; application-owned debounced writer flushes on lifecycle/navigation/Save and drains before SQL shutdown. Lost-response retry forgets its pending timer instead of recreating a finish draft. Reading selection uses its own choosing state, with real error recovery.

Live Today/Skill/Detail and full journal sort/filter by skill/local calendar bounds/exercise snapshot title; current-device timezone disclosed. Views/edit/delete and metadata-only10-second Undo work; deleted files never get an undo promise. Overview sums completed recorded seconds and counts completed sessions, including explicitly entered manual values and zero-duration journal entries; no improvement/ability score. Skill detail supports explicit return sections. No new dependency, permission, external service, key, login, upload or retail fixture.

## Actual final checks

`python3 tool/ci.py --android --ios --device F39EEA3D-9939-4689-8958-6CDDBB36EF01`, final session88722 exit0, log `tmp/m07-final-ci-system-bar.log`:16/16,279 app +233 design +1 retained-iOS bootstrap;106 Dart files/0 format changes; strict analysis, locks,104 license sources (68 runtime/build+36 dev), Drift codegen, repository/whitespace and explicit-main Android/iOS debug builds. Zero closed-database/unhandled-isolate errors. Native foundation intentionally opens a second readback connection and retains Drift's debug warning; integrity passes. Three constrained transitive newer versions are metadata, not a security guarantee. CI finishes after native testing with explicit `--target=lib/main.dart` to prevent test artifacts remaining in product builds.

92 current functional production golden comparisons and225 historical preview comparisons pass;377 total hashed references. Eleven sampled golden reviews;40 AA pairs for new palettes/hero including ornament tint/navigation. M07 adds61 app cases over M06:32 journal/Today goldens,16 repository,8 journal widgets,2 migrations,1 DST subprocess,1 held-SQL root draft drain,1 contrast test. `test/helpers/drive_async.dart` pumps real SQLite I/O plus Flutter fake-async callbacks; do not block held transactions with plain `tester.runAsync`.

Earlier failures are retained, not relabeled: onboarding native selector; introduced reading-picker busy guard; fixture revision/selector errors; lost Finish response pending timer; large heading word wrap; two contrast pairs; stale14-table count (now15 and empty drafts asserted); changed test-description formatting. Selected first design run100 passed; full final counts above are authoritative. Initial source-current CI279 pass and subsequent system-bar CI both pass; prior evidence is separately prefixed `before-system-bar-`. No assertion weakening/timeout removal.

## Native journal and final product evidence

Physical Android `NBDEXCJNL7JR9DIJ`,2409BRN2CA Android16/API36 arm64: setup PID20956 → resume21582,4384ms, one completed session/reading/exercise snapshot, revision6 after one amendment. Retained iOS27 `F39EEA3D-9939-4689-8958-6CDDBB36EF01`: setup60426 → resume61401,3718ms, same aggregate invariants. Four Flutter stages exit0/test1; own fresh UUID store/onboarding/skill/practice/Save/edit/Today/timeline → distinct-process detail. Normal journal hashes unchanged. Resume removes only strict marker-owned stores. Ten reviewed synthetic native widget frames exclude OS chrome (eight unique hashes). Copied frame hashes were verified before exact source cleanup; markers absent.

After native journal stages, a bar-only AnnotatedRegion refinement removed Android's gray navigation scrim and follows app theme/icon contrast without changing device security settings. Final16-check CI includes it. Final normal `lib/main.dart` kernels omit all M05/M06/M07 test scope markers and contain ordinary SQLite. Main restore script `tmp/m07_restore_main.py` completed exit0; final normal Android PIDs23708→23947, retained iOS72712→72768, M05-fresh iOS72829→72886 and older SE3/iOS18.2 PID72961→73021 retained settings/counts, schema5, integrity/FKs and empty real journals. Fresh/older existing sims upgraded4→5 without reset. All four OS screenshots were viewed and reviewed, including correct final Android system bar. Initial Android host capture showed only system chrome; later actual capture without restart shows Today and owned-PID logs have no Flutter exception. Cause/latency is unproven; do not claim cold-start performance PASS.

Final evidence in M07 report, `evidence/M07/ci.json`, `tests.json`, `impact.json`, `product-main-artifacts.json`, `normal-main-install.json` and `native/ARTIFACTS.json`. Build-time source is honestly uncommitted/basef43687b, not mislabeled as a future commit. No physical iPhone or signing/store claim.

## Safe next actions

```sh
git status --short --branch
python3 tool/check_baseline.py
git diff --check
git diff --cached --check
python3 -m py_compile tool/ci.py tool/run_journal_native.py
```

Final M07 packaging passed:63 Markdown/345 local links,378 UTF-8 limited privacy scan,377 golden/23 artwork/32 native-capture hashes, whitespace/Python;422 historical files,79 product-artifact source hashes and71 Dart impact hashes preserved. M07 commit and clean tree verified. Confirm checkpoint and clean tree, then immediately begin M08. Read M08 full contracts and ADR requirements; inspect actual public maintained media package sources/licenses/platform permissions before adding dependencies. Prepare functional private capture/import/audio lifecycle, bounded decoding/metadata/EXIF policy, media library, denial/no-space/corrupt/process/deletion tests and genuine physical Android camera/microphone proof. Preserve the owner-directed design. Do not skip M08 release-critical/native gates or ask whether to continue.

## Persistent authority and release limits

Official identity `com.jameskierdoliguez.loop` on Android/iOS, display Loop; owner-approved and immutable without approval. Verify store/brand availability before publication. Existing iOS targets: retained F39 above; M05-fresh `97AA9381-B1F4-4EA9-AC54-3FF97CF5B6E1`; compact older `6B9A9F58-46D2-473D-806C-15F8042AF1DA`. No duplicate simulators/reset needed. No physical iPhone, older Android matrix, approved production signing/team/store accounts, legal/brand clearance, empirical research or remote CI. Manual TalkBack/VoiceOver, real call/reboot/battery saver, thirty-minute profile drift and broader release performance remain required later gates.

Owner approved the isolated synthetic sqlite3 3.8.0/SQLite3MultipleCiphers experiment. Primitives passed host/iOS simulator/physical Android profile, with random memory-only unlogged keys. ADR-014 selects ordinary SQLite/OS protection because production key/media/restore/lock/reboot/physical-iPhone and native-license lifecycle gates remain incomplete. Do not request the experiment approval again or integrate cipher/key without complete evidence.

Requested eight agent plugins remain absent/unconnected per actual M06 searches and TOOLS. Current catalogs and applicable Find Skills/Plugin Management/Apple Design instructions were inspected; no `find_skills` function exposed. Actual local Dart import enumeration and Flutter/native/manual design work are the fallback, not Graphify/headless claims. No private remote graph, agent-tool install, account, telemetry or new permission. Remaining queue after M07: M08→M09→M10→M11→M12→M13→M14→M15.
