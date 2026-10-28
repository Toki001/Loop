# Loop verification ledger

M00–M07 local engineering gates are verified; empirical research remains pending and M02 evidence is design-only. The owner authorized continuous M01–M15 execution on 2026-10-27. Follow [PROGRESS.md](PROGRESS.md) and [CONTINUATION.md](CONTINUATION.md) for actual commit state. Android/iOS owned skill setup, native builds and persistence pass; media/evidence and complete physical/release gates remain M08–M15.

| Milestone | Execution status | Evidence / next gate |
|---|---|---|
| M00 | PASS — discovery baseline only | [Baseline report](M00.md); verified local commit, resolve SHA via Git history |
| M01 | PASS — engineering scope; research pending | [Workflow/scope review](M01.md); no fabricated participant results; owner identity recorded |
| M02 | PASS — native design gate | [M02](M02.md); 233 design tests, 225 goldens, 23-screen contract; no app persistence/device claim |
| M03 | PASS — local native foundation | [M03](M03.md); 42 app + 233 design + 1 iOS integration tests, native debug builds, actual process persistence/screenshots; remote CI/Android runtime unavailable |
| M04 | PASS — local persistence | [M04](M04.md); 93 app + 233 design tests, Android physical/iOS simulator storage and process persistence, migration/negative recovery, owner-approved cipher experiment; physical iPhone/key/release limits remain |
| M05 | PASS — local skill management | [M05](M05.md); 16 CI checks, 153 app + 233 design tests, six feature/three bootstrap native stages, retained/fresh installs; final normal binaries restored |
| M06 | PASS — local timer/manual entry | [M06](M06.md); 16 CI checks, 218 app +233 design +1 iOS bootstrap; final physical Android lock/background/kill/recovery and normal-main retention pass; actual commit in PROGRESS |
| M07 | PASS — local offline journal | [M07](M07.md); 16 CI checks,279 app +233 design +1 native bootstrap; Android/iOS two-process journal;92 new goldens; expressive normal-main UI installed/reviewed on four targets |
| M08 | PENDING | Private photo/audio lifecycle and physical capture tests |
| M09 | PENDING | Honest image/audio/metric comparison |
| M10 | PENDING | Local insights and offline search |
| M11 | PENDING | Optional reminders and platform behavior |
| M12 | PENDING | Portable export/restore/deletion; integrity/device round-trip |
| M13 | PENDING | Security, performance and accessibility; close P0/P1 |
| M14 | PENDING | Physical Android/iPhone matrix, approved signing/beta/policy |
| M15 | PENDING | Explicit owner publishing approval, stores, rollout and operations |

Read the [traceability matrix](TRACEABILITY.md), [tool audit](TOOLS.md), [environment baseline](ENVIRONMENT.md), [initial diagnostics](evidence/M00/environment-commands.json) and [successful diagnostic retries](evidence/M00/diagnostics-final.json). Requested unavailable plugins retain manual/native fallbacks; none were installed. Android has no configured AVD; a physical Android16 target became available and passed M04 storage/process checks. M03 created/booted an isolated Loop simulator and tested the real app; existing simulators/data were preserved. Physical iPhone and complete feature/device release verification remain open. The incomplete iOS engine cache was refreshed from the official SDK after actual build failure; final native builds passed.

Next task is **M08**; M07 `9b7a1a9a362d842b5178e2db0a65e0fe5cee7319` is committed and verified clean. Actual branch/checkpoint state is in CONTINUATION. No interviews or empirical product sign-off occurred. Follow [MILESTONES.md](../MILESTONES.md) and the contribution workflow. M00's report remains historical; its then-current authorization wording is superseded by continuous execution. Design/simulator checks cannot replace later complete practice flows, physical-device evidence, policy review or owner approvals. No remote CI, production signing, publishing or store availability is claimed.
