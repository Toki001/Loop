# ADR 014 — Relational persistence and private file lifecycle

Date: 2026-10-27. Status: accepted; M04 verification is recorded in [the milestone report](../verification/M04.md).

## Context

Loop needs durable local records and private evidence without accounts or hidden uploads. The prior M03 product persisted only appearance/onboarding in a JSON file. Relational constraints, schema upgrades, recoverable interrupted file work and accurate protection claims are prerequisites for feature UI. [DATA_AND_METRICS](../DATA_AND_METRICS.md) and [SECURITY_PRIVACY](../SECURITY_PRIVACY.md) remain binding.

## Decision

Use Drift 2.35.3 / sqlite3 3.8.0 on the native background executor, ordinary bundled SQLite, foreign keys, WAL, FULL synchronous writes and explicit versioned migrations. Commit SQL source/generated Dart and frozen synthetic prior/current schema fixtures. Schema v2 adds durable deletion work to internal unreleased v1; migration DDL, record and user_version are one transaction. Reject damaged/newer/unversioned occupied databases without replacement. Import M03 preferences once transactionally, including unknown fields and retaining the original; existing SQL settings win. Only damaged legacy preferences expose a copy-preserving reset.

Metric definitions physically use `(id, version)`, with same-skill version FKs for readings/goals. Semantic edits create another version; historical units/provenance persist. Numeric observations are finite doubles, timestamps UTC epoch seconds and durations explicit integer values. Names use grapheme validation. Repository-owned writes/live-query errors have safe categories. Session state/revision invariants exist; foreground monotonic time belongs to M06.

Files live beneath private application support with UUIDv4 opaque names, strict flat relative paths, no symlink traversal, streamed size/SHA-256 checks, flush/close and temporary-file promotion before metadata commit. Failed reference commits compensate only their new file. Deletions queue work in the same SQL transaction; bounded reconciliation retries explicit work and retains unknown orphans. M08 must add decoding/EXIF/permission and real capture validation before enabling media.

Select platform protection for the product baseline: Android credential-protected private storage with backup/transfer exclusions; iOS backup exclusion and complete-until-first-authentication protection. The simulator's missing protection attribute is not a physical pass; physical builds require actual readback. Uninstall/device loss can lose data, stated in privacy copy. No app encryption key/token exists or secure-storage dependency is needed. Manual export/restore must pass M12.

## Alternatives and experiment

The owner explicitly approved an isolated synthetic SQLite3MultipleCiphers experiment. Host arm64 macOS, iOS27 arm64 simulator debug and physical Android16 arm64 profile passed encrypted WAL, non-plaintext header, correct-key reopen, missing/wrong-key rejection preserving bytes, deterministic corruption rejection, verified encrypted-copy recovery and explicit decryption. Actual engine: SQLite 3.54.0 / chacha20. Random 256-bit keys stay only in memory and are never returned/logged/persisted. The separate [experiment](../../tool/spikes/sqlite_encryption/README.md) is not imported or configured by Loop.

The full [JSON evidence](../verification/evidence/M04/encryption-android-profile.json) retains five alternating 1,000-row/256-byte runs per mode. Median open/create, plaintext versus cipher: host 0.970/24.690ms; iOS simulator debug 0.775/18.735ms; physical Android profile 12.165/94.820ms. These small, noisy workloads include warmup and do not measure app startup p95 or prove write-speed improvement. All cached native assets referenced by build-hook outputs matched the published package's pinned release hashes; independent build-attestation verification was not performed.

Application encryption is deferred because primitive tests do not establish key provisioning/storage, lock/reboot availability, rotation/loss, reinstall/restore or media encryption. A separately verified ADR/device lifecycle is required before integration. Reject custom crypto, hardcoded keys, remote services and database-only blanket media-encryption claims. This decision chooses the contract's supported baseline under the owner's authority to select the safest maintainable architecture; remaining physical/release threat validation is not waived.

## Tradeoffs and data/security impact

No backend, account, telemetry or private remote indexing. Platform protection depends on the OS/device; it cannot protect an already unlocked compromised same-UID process or guarantee OEM behavior. Dart path checks do not promise race-proof syscalls. Automatic backup exclusion increases the need for a verified M12 ownership flow. Physical iPhone protection/lock tests, API36.1 cross-platform transfer review, OEM backup tests and release signing/privacy review remain later gates. No approved Apple team identity exists; no cross-platform registration is invented. Original requested plugins remain unavailable/unindexed; [local imports](../verification/evidence/M04/local-import-graph.json), resolved package edges and manual SQL review define the impact boundary.

Primary references: [Drift setup](https://drift.simonbinder.eu/setup/), [native encryption](https://drift.simonbinder.eu/platforms/encryption/), [sqlite3 package/hooks](https://pub.dev/packages/sqlite3), [native release](https://github.com/simolus3/sqlite3.dart/releases/tag/sqlite3-3.8.0), [cipher documentation](https://utelle.github.io/SQLite3MultipleCiphers/docs/ciphers/cipher_chacha20/), [Android backup rules](https://developer.android.com/identity/data/autobackup), [Apple protection](https://developer.apple.com/documentation/foundation/fileprotectiontype/completeuntilfirstuserauthentication), [backup exclusion](https://developer.apple.com/documentation/foundation/urlresourcevalues/isexcludedfrombackup).
