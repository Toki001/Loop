# Loop verification ledger

M00–M04 are verified; empirical research remains pending and M02 evidence is design-only. The owner authorized continuous M01–M15 execution on 2026-10-27. Follow [PROGRESS.md](PROGRESS.md) and [CONTINUATION.md](CONTINUATION.md) for durable state. The actual Android/iOS foundation builds and iOS simulator smoke pass; functional practice features, physical testing and release gates remain M05–M15.

| Milestone | Execution status | Evidence / next gate |
|---|---|---|
| M00 | PASS — discovery baseline only | [Baseline report](M00.md); verified local commit, resolve SHA via Git history |
| M01 | PASS — engineering scope; research pending | [Workflow/scope review](M01.md); no fabricated participant results; owner identity recorded |
| M02 | PASS — native design gate | [M02](M02.md); 233 design tests, 225 goldens, 23-screen contract; no app persistence/device claim |
| M03 | PASS — local native foundation | [M03](M03.md); 42 app + 233 design + 1 iOS integration tests, native debug builds, actual process persistence/screenshots; remote CI/Android runtime unavailable |
| M04 | PASS — local persistence | [M04](M04.md); 93 app + 233 design tests, Android physical/iOS simulator storage and process persistence, migration/negative recovery, owner-approved cipher experiment; physical iPhone/key/release limits remain |
| M05 | PENDING | Skills/goals/exercises |
| M06 | PENDING | Timer/state/lifecycle; physical Android test |
| M07 | PENDING | Reflection and first complete offline practice loop |
| M08 | PENDING | Private photo/audio lifecycle and physical capture tests |
| M09 | PENDING | Honest image/audio/metric comparison |
| M10 | PENDING | Local insights and offline search |
| M11 | PENDING | Optional reminders and platform behavior |
| M12 | PENDING | Portable export/restore/deletion; integrity/device round-trip |
| M13 | PENDING | Security, performance and accessibility; close P0/P1 |
| M14 | PENDING | Physical Android/iPhone matrix, approved signing/beta/policy |
| M15 | PENDING | Explicit owner publishing approval, stores, rollout and operations |

Read the [traceability matrix](TRACEABILITY.md), [tool audit](TOOLS.md), [environment baseline](ENVIRONMENT.md), [initial diagnostics](evidence/M00/environment-commands.json) and [successful diagnostic retries](evidence/M00/diagnostics-final.json). Requested unavailable plugins retain manual/native fallbacks; none were installed. Android has no configured AVD; a physical Android16 target became available and passed M04 storage/process checks. M03 created/booted an isolated Loop simulator and tested the real app; existing simulators/data were preserved. Physical iPhone and complete feature/device release verification remain open. The incomplete iOS engine cache was refreshed from the official SDK after actual build failure; final native builds passed.

Next task is **M05** after the verified M04 local commit/checkpoint. No interviews or empirical product sign-off occurred. Follow [MILESTONES.md](../MILESTONES.md) and the contribution workflow. M00's report remains historical; its then-current authorization wording is superseded by continuous execution. Design/simulator checks cannot replace later complete practice flows, physical-device evidence, policy review or owner approvals. No remote CI, signing, publishing or store availability is claimed.
