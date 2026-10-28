#!/usr/bin/env python3
"""The same fail-fast quality entrypoint for local and provisioned CI runners.

Does not install SDKs, plugins, accept licenses, upload artifacts or publish.
Requires the pinned preinstalled SDK/toolchain; M02 goldens require macOS fonts.
"""
import argparse
import json
from pathlib import Path
import subprocess
import sys
import time

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--android", action="store_true")
    parser.add_argument("--ios", action="store_true")
    parser.add_argument("--device", help="Explicit dedicated simulator/device ID for integration tests")
    args = parser.parse_args()
    results = []
    output = ROOT / "build/verification/ci.json"
    output.parent.mkdir(parents=True, exist_ok=True)

    def run(command, cwd=ROOT):
        print(f"CHECK ({cwd.relative_to(ROOT) or '.'}): {' '.join(command)}", flush=True)
        start = time.monotonic()
        result = subprocess.run(command, cwd=cwd, check=False)
        results.append({"command": command, "cwd": str(cwd.relative_to(ROOT)),
                        "exit": result.returncode, "seconds": round(time.monotonic() - start, 3)})
        output.write_text(json.dumps({"results": results}, indent=2) + "\n")
        if result.returncode:
            sys.exit(result.returncode)

    flutter = ["flutter", "--suppress-analytics"]
    run([sys.executable, "tool/check_foundation.py"])
    run(flutter + ["pub", "get", "--enforce-lockfile"])
    run(flutter + ["pub", "get", "--enforce-lockfile"], ROOT / "design_preview")
    run([sys.executable, "tool/dependency_inventory.py"])
    run([sys.executable, "tool/check_persistence_codegen.py"])
    run(["dart", "--suppress-analytics", "format", "--output=none", "--set-exit-if-changed",
         "lib", "test", "integration_test", "tool", "design_preview/lib", "design_preview/test"])
    run(flutter + ["analyze"])
    run(flutter + ["analyze"], ROOT / "design_preview")
    run(flutter + ["test", "--reporter", "expanded"])
    run(flutter + ["test", "--reporter", "expanded"], ROOT / "design_preview")
    run([sys.executable, "tool/check_baseline.py"])
    run(["git", "diff", "--check"])
    run(["git", "diff", "--cached", "--check"])
    if args.device:
        run(flutter + ["test", "integration_test/foundation_test.dart", "-d", args.device, "--no-pub", "--no-uninstall", "--reporter", "expanded"])
    # Tests compile a different entrypoint into shared native build directories.
    # Finish with explicit product builds so artifacts cannot retain that target.
    if args.android:
        run(flutter + ["build", "apk", "--debug", "--no-pub", "--target=lib/main.dart"])
    if args.ios:
        run(flutter + ["build", "ios", "--simulator", "--debug", "--no-codesign", "--no-pub", "--target=lib/main.dart"])
    print(f"PASS: {len(results)} selected checks; results in build/verification/ci.json", flush=True)


if __name__ == "__main__":
    main()
