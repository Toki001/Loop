# Durable execution checkpoint — 2026-10-28

**Policy:** owner-authorized continuous M01–M15 execution. One verified local milestone at a time; confirm commit/clean worktree, record actual SHA and continue immediately. Read AGENTS/AGENT/CODEX and the current contract. Preserve M00 historical evidence and frozen M02 images. Never push/publish/connect accounts/install unapproved agent tools/index private code/purchase/handle production credentials/accept legal agreements without approval. Context limits require a checkpoint, not a restart.

## Completed and committed

M00 `fa316ff`; policy `af667df`; M01 `9b90ca94372e7e8f7926a63d3de3243ab5da1195` (checkpoint702a305); M02 `7ede417c8358d14bfc4f97686c7b6be53d225125` (checkpointd5b1ac7); M03 `95b8f7cc7cb51d9a4d9781e4b70b5bb21191ff61` (checkpoint9b01ffe); M04 `86e800ed31bc3f7b3fc58142d2160ccd4e1df97e` (checkpoint51571809a775decef904558563b533deffdd9c87). M05 `930fb53ec8e08f291cc3cdb50a31e5e3be027d71`, subject `milestone-05: skill goals and exercise management`, checkpoint `a95097f35a6b60e4031c28413eaab62375ca3df2`. M06 `6ae862a5adaa15ad055d50afd7803aa934184b83`, subject `milestone-06: interruption-safe practice timer`, verified clean after commit. Successful commits/checkpoints were confirmed clean. Do not redo them.

## Current state

M06 committed and verified clean. This documentation checkpoint records its actual SHA. Immediately create `milestone/07-practice-journal` and implement M07; inspect actual Git state. Do not repeat completed M06 native measurements without a new failure/source change.

Owner normal unlock was confirmed, including after the lock test. Read-only keyguard showing=false; no security settings changed. All final Android timer gates passed. Normal product entrypoint restored; actual OS screenshot reviewed. Background supervisor is FINISHED/exit0, not running. No native test remains running. M07 prerequisites are satisfied; implementation is next.

## Verified M06 implementation

ADR-016, schema4 dependent fractional/manual checkpoints, transactional practice repository and serialized Stopwatch engine, global timer, synchronous lifecycle freeze, deliberate Resume, paused recovery, timed/untimed/manual/journal screens, note drafts, confirmations, saved summaries and Today resume. Only skills/sessions flags are true. Manual1sec–7days requires confirmation; journal-only deliberately records zero. v1–v3 fixtures and225 M02 images unchanged.

Review fixed automatic-checkpoint busy locking (Pause stays available), invalid-draft Discard, future-date picker, short durations, long timer layout, note feedback, legacy multiple drafts and root shutdown. Bootstrap drains queued work before SQL close; storage close is idempotent; disposed pending Resume cannot restart time. Real held-transaction root-disposal regression verifies this. Use `test/helpers/drive_async.dart` for real SQLite I/O plus Flutter fake-async callbacks instead of blocking queued transactions in `tester.runAsync`.

**Source-current full CI:** `python3 tool/ci.py --android --ios --device F39EEA3D-9939-4689-8958-6CDDBB36EF01`, log `tmp/m06-current-final-ci.log`, completed session73559 exit0.16/16 checks;218 app +233 design +1 retained-iOS bootstrap;84 Dart files/0 format changes; strict analysis, codegen, locks, licenses, repository checks and both debug builds pass. Zero closed-database/unhandled-isolate errors. Selected76-case shutdown/engine/golden and30-case engine/widget regressions passed.65 new cases:18 engine+2 migration+12 widgets+32 goldens+1 root-disposal. Earlier failed/intermediate runs remain separately named.

285 goldens =225 frozen M02+28 M05+32 M06; ten M06 samples reviewed. Native manifest18 files, eight M06 reviewed captures (seven native widget frames excluding OS chrome, one actual normal-main Android OS screenshot). Synthetic stores are marker-owned UUID directories; normal data hashes checked.104 license sources/68 runtime-build/36 dev, no dependency/permission/key/service change. Three constrained transitive updates are metadata, not a vulnerability guarantee.

## Final physical Android results

Device `NBDEXCJNL7JR9DIJ`,2409BRN2CA, Android16/API36 arm64. Current-source JSON under `docs/verification/evidence/M06/`:

- `android-lock-final.json`: PID26640,15.047sec real sleep,4599ms unchanged after normal owner unlock; one completion.
- `android-smoke-final.json`: PID27959, sampled4247ms/reference4248ms, saved4403ms; actual UI plus repeated Finish, one row.
- `android-kill-prepare-final.json`: live PID28928 checkpoint5006ms, present before force-stop/absent after; intentional incomplete Flutter79, not ordinary test PASS.
- `android-recovery-final.json`: distinct PID30219 reopened paused at exactly5006ms, no automatic time, completed once.
- `android-background-final.json`: PID6143, full120sec foreground and600.165 real background seconds; paused/after/saved120483ms, one completion, integrity/FKs and normal data unchanged.
- `background-supervised-job.json`: bounded local job FINISHED/exit0 after760sec. Host supervisor2700sec deadline; CLI/test45m and all assertions retained. Optional verbose/host-only30sec progress is the only harness diagnostic change. No OS settings override.
- `android-foundation-final.json`: completed one-test/teardown PASS and native private/backup-excluded/schema4/integrity markers. Separate process exit code was not retained at context handoff and is honestly null; debug Drift second-connection warning documented.
- `normal-main-install.json`: final Android normal `lib/main.dart`, PIDs8029→8216, settings hash/journal counts unchanged, schema4/integrity/FKs, no synthetic retail rows or marker; actual foreground Today screenshot reviewed. Three iOS current-source normal-main installs/retention also retained.

Incomplete failures remain explicit. Final background attempt1 PID30598 stopped before600sec; read-only owned DB paused120406ms/integrity and normal journal unchanged. Attempt2 verbose host runner cancelled at about600sec whole-command runtime/444.812sec background; teardown calls stopApp, initiating cause unknown. Do not claim proven OEM/app/SDK defect. Supervised rerun passed the entire interval without weakening limits. Earlier lock timeout awaiting owner unlock and older failed background attempts remain historical. Scoped cleanup subsequently passed; only marker-owned data removed. `copied-final-frame-cleanup.json` verifies exact four source-frame hashes before deletion; normal journal untouched. Current `phone-prerequisite.json` supersedes retained `phone-before-owner-unlock.json`.

## iOS and normal-main evidence

Retained iOS27 simulator `F39EEA3D-9939-4689-8958-6CDDBB36EF01`: before root-shutdown fix, smoke, live kill/recovery5004ms and full120398ms/600sec background passed; filenames explicitly say before-shutdown-fix. Final source passed retained-iOS bootstrap in full CI and normal-main retention.

Older compact iPhoneSE3/iOS18.2 `6B9A9F58-46D2-473D-806C-15F8042AF1DA`: fresh foundation, current-source timer smoke4051ms/reference4051ms/saved4175ms, skill setup PID27730→new-process resume29130 all passed. Initial fresh policy race retained; read-only polling observes bootstrap false→true without configuring policy. Only proven-empty new-simulator test app was removed for fresh rerun. M05 fresh iOS27 `97AA9381-B1F4-4EA9-AC54-3FF97CF5B6E1` remains intact and upgraded3→4 with preferences/counts unchanged. No duplicate simulator needed.

`product-main-artifacts.json` records explicit main APK/kernel and64 source hashes, no test markers, ordinary SQLite. Android final build/install commands are current; `before-final-android-*` preserve earlier all-target evidence. Build-time source was uncommitted/basea95097, correctly labeled. All product sources remain byte-matched to those artifacts. No gratuitous iOS/full-suite rerun after documentation-only packaging. New source failure/fix requires affected and regression checks.

## Continue M07

Final packaging checks passed:59 Markdown/300 local links,326 UTF-8 files scanned,285 golden/23 icon/18 capture hashes, whitespace/Python;237 historical files and64 product-source hashes unchanged. Local import enumeration306 edges (205 local+86 package+15 Dart),31 transitive DB/engine consumers, zero presentation SQL findings; this is not Graphify. M06 commit and clean worktree verified; this small docs checkpoint records the actual SHA. Confirm clean again, then immediately create `milestone/07-practice-journal` and implement M07. No prompt/approval to continue.

```sh
git status --short --branch
git log -4 --oneline
python3 tool/check_baseline.py
git diff --check
git diff --cached --check
python3 -m py_compile tool/run_practice_native.py
```

M07 full contract: optional notes/What got easier/next-step/effort/compatible metric readings; atomic Finish with exercise snapshots/reflection/readings and idempotent retry; live repository streams for Today/Skill Detail/Session Detail; filterable timeline, edits/revisions/delete and feasible undo; durable forms, keyboard/large text/disk-full retry; real native fresh→skill→practice→save→new-process detail. Read design/data/quality/security/scenario contracts and write ADR before schema/architecture changes. Preserve foreground-only clock semantics and frozen M02 evidence. No M07 implementation has been started yet.

Remaining queue M07→M08→M09→M10→M11→M12→M13→M14→M15. Real call/reboot/battery saver, thirty-minute profile drift, older Android, manual TalkBack/VoiceOver and physical iPhone remain later gates. Prepare all safe local work before genuinely necessary external approvals.

## Persistent authority and release limits

Official Android/iOS identity `com.jameskierdoliguez.loop`, display Loop; owner approved, never change without approval. Verify availability/brand before publication. No physical iPhone, older Android/emulator matrix, approved Apple signing/team/store accounts, legal/brand clearance, empirical participants/research or remote CI. These remain real later gates.

Owner explicitly approved the isolated synthetic sqlite3 3.8.0/SQLite3MultipleCiphers experiment after its initial automatic-review rejection. M04 host/iOS simulator/physical Android cipher primitives passed, with keys random/in-memory and never logged. ADR-014 selects ordinary SQLite/OS protection; no cipher/key is integrated because production key/media/restore/lock/reboot/physical-iPhone lifecycle and native license redistribution gates are incomplete. Do not request that experiment approval again or weaken these limits. Preserve M04 results.

Requested agent plugins remain absent/unconnected per verified TOOLS and eight refreshed M06 searches; local Flutter/native checks and actual import enumeration are the fallback. No private remote graph/upload, account, telemetry, new permission or key was introduced. Do not hallucinate plugin invocation or install an unrelated search hit.
