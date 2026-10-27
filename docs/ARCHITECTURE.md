# Loop Technical Architecture

## 1. Platform and non-functional contract

Target iOS and Android (supported OS baselines pinned in M00 after analyzing adoption, package requirements and app-store policy). Development on macOS, Flutter stable + Dart stable compatible. Do not force web deployment or backend to ship mobile v1. Minimum supported device must run core without internet. App usable without login. Media capture optional, offline-only; distribution-ready signed builds and debug/release parity.

Targets for measurement (not unverified guarantees): app cold boot p95 <2.5s on midrange device with realistic data; practice timer updates visually at 1Hz without excess CPU; navigation action feedback <100ms except disk I/O; list smooth under 1,000 sessions and 2,000 thumbnails through pagination/lazy loading; app uncrashable for malformed import; media operations memory bounded. Define benchmark device, dataset and release mode before publishing performance claims.

## 2. Architecture layers

```text
UI (Flutter screens + widgets + app state)
  ↓
Feature view model / Riverpod notifier (async state + user intent)
  ↓
Domain application use cases (session lifecycle, metrics, export/restore)
  ↓
Repositories (only write API; transaction orchestration)
  ↓
Drift SQLite DAOs + media store + platform adapters
  ↓
Encrypted/OS-protected app-private disk; microphone/camera/notifications
```

Native OS adapters for capture, local notifications, files and secure key storage behind interfaces with deterministic fakes. No UI-level raw SQL, direct media filename handling or platform channels outside adapters. Use Dart sealed states or explicit asynchronous result objects for failures. Prefer simple repository interfaces over an abstract 'universal provider' pattern.

## 3. Proposed repository layout

```text
loop/
├── README.md
├── AGENTS.md
├── AGENT.md
├── CODEX.md
├── analysis_options.yaml
├── pubspec.yaml
├── pubspec.lock
├── .gitignore
├── .github/workflows/ci.yml
├── android/                    # Flutter-generated
├── ios/                        # Flutter-generated
├── assets/{icons,fonts,illustrations}/
├── lib/
│   ├── main.dart
│   ├── bootstrap.dart
│   ├── app/{app.dart,routing.dart,theme.dart,l10n/}
│   ├── shared/
│   │   ├── design_system/{tokens/,components/}
│   │   ├── infrastructure/{errors,clock,ids,platform/}
│   │   ├── widgets/
│   │   └── helpers/
│   ├── core/
│   │   ├── data/{database/,daos/,migrations/,model/}
│   │   ├── media/{media_repository.dart,files/,image/,audio/}
│   │   ├── notifications/
│   │   ├── import_export/
│   │   └── analytics/             # Local calculations, NOT tracking SDK
│   └── features/
│       ├── onboarding/{data,domain,presentation}/
│       ├── skills/{data,domain,presentation}/
│       ├── goals/{data,domain,presentation}/
│       ├── exercises/{data,domain,presentation}/
│       ├── practice/{data,domain,presentation}/
│       ├── reflections/{data,domain,presentation}/
│       ├── progress/{data,domain,presentation}/
│       ├── comparisons/{data,domain,presentation}/
│       ├── library/{data,domain,presentation}/
│       ├── reminders/{data,domain,presentation}/
│       └── settings/{data,domain,presentation}/
├── l10n/{app_en.arb}/
├── test/{unit,widget,golden,fixtures,helpers}/
├── integration_test/{flows/,recovery/}
├── tool/{seed_fixtures.dart,verify_archives.dart,benchmark.dart}
└── docs/
    ├── ... specifications copied from kit ...
    └── verification/{INDEX.md,M00.md,...}
```

Adapt file hierarchy to Flutter conventions if needed but document deviations; avoid gigantic folder scaffolds of empty placeholder files. Use one package/application first, not monorepo microservices. Create folders as features are implemented.

## 4. Dependencies and upgrade policy

Reference candidates (select versions at implementation after verifying compatibility, maintenance, licensing, security and transitive risks): `flutter_riverpod`, `go_router`, `drift`, `drift_flutter` or suitable drift sqlite setup, `sqlite3_flutter_libs` if applicable, `freezed`/`json_serializable` (only if actually valuable), `path_provider`, `permission_handler` or permission APIs per plugin, `image_picker`, `camera`, `record`, `just_audio`, `flutter_local_notifications`, `timezone`, `intl`, `share_plus`, `file_picker`, `archive`, `crypto`, a chart library such as `fl_chart`, `flutter_secure_storage` for key material, `flutter_test`, `integration_test`, `mocktail`, linting. Package list is a **candidate**, not a license to install all. Audit duplicate plugins and maintenance. Use `flutter pub outdated`, lockfile and SBOM. Avoid unnecessary network dependency. Verify native permission scripts, manifest, Podfile and SDK minimum before final selection.

## 5. Source of truth, atomicity and migrations

Database schema: `docs/DATA_AND_METRICS.md`. Enable SQLite foreign keys; define delete behaviors intentionally. Migration numbering + full upgrade test from historical fixture. Back up in a transaction/snapshot and include referenced media atomically as far as feasible. Write media to temporary file, fsync/close if platform supports, hash, validate, move to private storage, then commit reference; failure compensates file. Deletion: transaction for DB and staged garbage collection/retry for file, idempotent. Reconciliation startup job finds temp/orphaned refs, does not wipe precious evidence automatically.

Use UUIDv7 or cryptographically unique stable IDs and never rely on names as keys. Persist UTC timestamps and IANA timezone used for display/local scheduling as appropriate. Track app schema version and archive version independently. Never use local clock changes to infer active session elapsed seconds.

## 6. Session timer correctness

Implement `PracticeClock` abstraction with monotonic `Stopwatch`/ticker, `AppLifecycleListener` (or supported equivalent) and durable checkpoints. Source of truth for accrued active duration is persisted completed foreground segments; visible display derives monotonic delta while app is foreground-running. On lifecycle inactive/paused, checkpoint and auto-pause. On recovery after termination, restore paused state and last durably checkpointed seconds, never bill elapsed time during absence. Periodic checkpoints mitigate hard-kill loss; on abnormal kill, clearly state possible loss since last checkpoint, but never fabricate. Acquire no microphone until user taps Record. Handle pause/resume double taps via single state machine serialized writes. No background timer feature in v1; verify behavior on Android and iOS power management.

## 7. Navigation and state restoration

Route shell for bottom navigation; authenticated routes absent. Routes by stable IDs: `/today`, `/skills`, `/skills/:id`, `/practice/setup`, `/practice/active`, `/practice/review/:id`, `/sessions/:id`, `/progress`, `/compare`, `/library`, `/settings`, `/settings/data`, `/onboarding`. App bootstrap loads database, migrations and pending session before routing; recovery UI on failure. Treat cold start from notification as a deep link into skill, not start timer automatically. Preserve unsaved reflections across view rebuilds; prompt before losing unsaved changes, with draft persistence for long forms.

## 8. Media storage and lifecycle

`EvidenceFile` stores `id`, `sessionId`, mime, kind, extension from verified bytes, byteLength, SHA-256, dimensions/duration, orientation, createdUtc, relative storage path, thumbnail path and state. Never trust user filename/path to form an output path. Sandbox all stored paths under private app dir, verify canonical path. Copy imported media (do not hold external picker URI), strip EXIF location if safe and documented, preserve orientation and quality; require consent before any destructive conversion. Limit file sizes and clip lengths with clear guidance; cap decoded pixel count to avoid image decompression bombs; stream hash/copy. Support file share/export only on explicit user action. Use OS backups policy carefully, ensure media and DB are backed up consistently or excluded with user-visible warning.

## 9. Import/export and restore

Prefer explicit versioned portable ZIP with `manifest.json`, SQLite-independent JSON/NDJSON records and `media/<opaque-id>.<ext>` evidence, checksum list and archive schema version. Encrypt passphrase-protected archive only with vetted authenticated encryption/KDF; never write custom cryptography. If encryption implementation cannot be audited, ship unencrypted archive with explicit warning and OS protected share flow rather than deceptive crypto promise; require owner privacy sign-off before enabling. Export data model must remain independently parseable. Bound archive processing by item count, expanded size and path, reject zip-slip/symlinks/duplicate IDs/corrupt hash/invalid schema, stage extract to private temp, preview imported items, do transactional DB merge (default safely skip or replace with explicit choice), reconcile files, rollback on failure. Import never silently overwrites existing data. Export/restore is a **v1 release gate**.

## 10. Notifications

On-device local schedules based on IANA zone / local wall time and weekdays. App may schedule rolling horizon due to iOS/Android limits. Reconcile on timezone change, app restart, permission change and reboot where platform supports. Exact alarms permission requested only if justified; preference is inexact friendly reminders. Cancellation and pause-all must delete OS schedules. Delivery may be OS-limited; UI says reminders are best effort. No remote push or user tracking.

## 11. Error-handling contract

Typed error classes: `ValidationFailure`, `PermissionDenied`, `StorageUnavailable`, `MediaCorrupt`, `NoSpace`, `ArchiveUnsupported`, `MigrationFailure`, `UnexpectedFailure`. Presentation translates into usable guidance without stack traces. Log limited diagnostic codes locally only, never user audio, notes, full paths, secrets or identifiers to third-party services. Critical unhandled errors enter recovery screen with export and safe restart options where practical.

## 12. Cloud-ready but not cloud-dependent

Domain IDs and updatedAt/revision support eventual cloud sync, but no sync API, login or backend code in v1. If approved later: threat model and migration to account-bound credentials, conflict resolution for timestamps/media, end-to-end security decision, deletion rights, infrastructure and cost controls. Don't ship a simulated 'connect account' button.

## 13. CI and release reproducibility

GitHub Actions or approved CI for format/analyze/unit/widget/golden smoke, Android debug & release candidates, static secret scan/dependency audit and artifact retention. iOS build requires macOS runner, signing approval and Apple account. Cache dependencies without embedding keys. Golden baselines reviewed via diffs; no auto-accept golden updates. Reproducible build metadata: git SHA, SDK version, package lock hash, target ABI, product flavor and signing provenance (exclude secrets). Environment `.env` never source-controlled if secrets.
