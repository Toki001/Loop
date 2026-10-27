#!/usr/bin/env python3
"""Prepare the owner's approved, isolated native cipher experiment.

No product cipher change, account connection, upload, key storage or publishing.
Creates only a dedicated ignored Flutter harness; pub/native commands stay
explicit in the experiment README. Does not delete an existing project.
"""
from pathlib import Path
import shutil
import subprocess

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "tool/spikes/sqlite_encryption"
DESTINATION = ROOT / "tmp/loop_cipher_probe"


def main():
    if not DESTINATION.exists():
        subprocess.run(["flutter", "--suppress-analytics", "create", "--empty", "--no-pub",
                        "--platforms=ios,android", "--org", "com.jameskierdoliguez.loop",
                        "--project-name", "loop_cipher_probe", str(DESTINATION)], check=True, cwd=ROOT)
    manifest = DESTINATION / "pubspec.yaml"
    if not manifest.is_file() or "name: loop_cipher_probe\n" not in manifest.read_text():
        raise SystemExit("Refusing to overwrite an unrecognized probe project")
    manifest.write_text("""name: loop_cipher_probe
publish_to: none
version: 0.0.1+1
environment:
  sdk: '>=3.13.4 <4.0.0'
dependencies:
  flutter:
    sdk: flutter
  sqlite3: 3.8.0
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
hooks:
  user_defines:
    sqlite3:
      source: sqlite3mc
""")
    for directory in ("lib", "integration_test", "test_driver"):
        (DESTINATION / directory).mkdir(exist_ok=True)
    shutil.copyfile(SOURCE / "lib/experiment.dart", DESTINATION / "lib/experiment.dart")
    shutil.copyfile(SOURCE / "native_probe_test.dart.template", DESTINATION / "integration_test/probe_test.dart")
    shutil.copyfile(SOURCE / "native_probe_driver.dart.template", DESTINATION / "test_driver/probe_driver.dart")
    # The empty template's flutter_lints dependency is intentionally absent.
    (DESTINATION / "analysis_options.yaml").write_text("analyzer:\n  language:\n    strict-casts: true\n")
    print("Prepared isolated harness at tmp/loop_cipher_probe; no dependencies installed or tests run by this script.")


if __name__ == "__main__":
    main()
