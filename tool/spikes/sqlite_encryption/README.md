# Isolated SQLite cipher experiment

The owner explicitly approved this experiment on 2026-10-27 after automatic approval review rejected the first dependency-resolution attempt. Scope: sqlite3 3.8.0 and its SQLite3MultipleCiphers native build, synthetic data, host/native integrity and bounded performance. No Loop runtime cipher integration, remote indexing, account, upload, real data or stored keys is authorized by this package.

Verified [sqlite3 package](https://pub.dev/packages/sqlite3) publisher `simonbinder.eu`, MIT bindings; [immutable release](https://github.com/simolus3/sqlite3.dart/releases/tag/sqlite3-3.8.0) supplies native binaries with hashes pinned in the published package. Its installed `doc/hook.md` documents supported Android/iOS/host ABIs and hook source selection. SQLite is public domain; [SQLite3MultipleCiphers](https://github.com/utelle/SQLite3MultipleCiphers) is Ulrich Telle's maintained fork under MIT (retained license here). Review the full native build's upstream notices/SBOM before product redistribution; the bindings' MIT label is not a substitute. [Default cipher documentation](https://utelle.github.io/SQLite3MultipleCiphers/docs/ciphers/cipher_chacha20/) describes ChaCha20-Poly1305 and PBKDF2 parameters; the probe records its actual cipher/version instead of assuming availability.

`lib/experiment.dart` generates temporary keys using `Random.secure`, tests encrypted WAL and non-plaintext headers, missing/wrong keys, correct-key reopen, deterministic header corruption without reset, recovery from a verified encrypted copy, explicit decryption/reopen, and five alternating runs of identical 1,000-row/256-byte transactions with/without a key. It sanitizes failures because SQLite's raw PRAGMA exception could contain a key. No key appears in output, filenames or persisted configuration. Temporary databases/copies are removed after the experiment. A wrong-key string is generated independently, never hardcoded.

Reproduce host checks from this directory using the pinned SDK:

```sh
dart --suppress-analytics pub get --enforce-lockfile
dart --suppress-analytics run bin/check.dart
```

For a separate disposable Flutter harness, from the repository root run `python3 tool/prepare_cipher_probe.py`. It creates/updates only the recognized ignored `tmp/loop_cipher_probe` project and copies these reviewed sources/templates. Its application identifier is separate from Loop; it never replaces the product's cipher settings. Then, from that harness:

```sh
flutter --suppress-analytics pub get
flutter --suppress-analytics test integration_test/probe_test.dart -d F39EEA3D-9939-4689-8958-6CDDBB36EF01 --no-pub --no-uninstall --reporter expanded
flutter --suppress-analytics drive --driver=test_driver/probe_driver.dart --target=integration_test/probe_test.dart --profile -d NBDEXCJNL7JR9DIJ --no-pub
```

Device IDs are the actually verified dedicated simulator and physical Android at M04, not portable defaults. Re-inspect connected targets/ownership before later runs. `flutter test` in this SDK rejects `--profile`; Android uses supported `flutter drive --profile` instead. iOS simulator checks run debug. Driver results are in the harness's `build/integration_response_data.json`; logcat can truncate long JSON prints. M04 evidence retains complete JSON separately per target.

Host and iOS simulator results do not measure physical phone performance. Five small runs measure only this bounded workload on the same cipher-capable engine; warmup, filesystem and debugger noise are visible. They are not app startup p95, a production benchmark, proof of all page/WAL threat cases, key lifecycle, physical Data Protection or encryption of media. A composite legacy result flag `physicalDeviceOrKeyLifecycleVerified=false` means the complete protection/key-lifecycle gate remains unverified; it must not erase the separately documented physical Android execution.

The product decision remains platform-protected ordinary SQLite pending complete key provisioning/storage, rotation/loss, lock/reboot, backup/restore and device testing. No application key is needed or silently introduced by M04. See [ADR 014](../../../docs/adr/ADR-014-private-persistence.md) and [M04](../../../docs/verification/M04.md).
