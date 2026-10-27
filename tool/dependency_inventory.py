#!/usr/bin/env python3
"""Read resolved package metadata/licenses without installing anything.

Resolved dependency closure includes build hooks and packages declared upstream
as runtime dependencies; it does not assert which code survives AOT tree shaking.
SDK engine notices are multi-license and must never be labeled a single license.
"""
import hashlib
import json
from pathlib import Path
import subprocess
from urllib.parse import unquote, urljoin, urlparse

ROOT = Path(__file__).resolve().parents[1]


def main():
    result = subprocess.run(["flutter", "--suppress-analytics", "pub", "deps", "--json"],
                            cwd=ROOT, text=True, capture_output=True, check=True)
    graph = json.loads(result.stdout)
    packages = {value["name"]: value for value in graph["packages"]}
    closure = set()

    def visit(name):
        if name in closure:
            return
        closure.add(name)
        for dependency in packages[name]["dependencies"]:
            visit(dependency)

    for name in packages[graph["root"]]["directDependencies"]:
        visit(name)
    config_file = ROOT / ".dart_tool/package_config.json"
    config = json.loads(config_file.read_text())
    roots = {item["name"]: Path(unquote(urlparse(urljoin(config_file.as_uri(), item["rootUri"])).path))
             for item in config["packages"]}
    sdk_root = roots["flutter"].parent.parent
    records = []
    for name, package in sorted(packages.items()):
        if name == graph["root"]:
            continue
        license_path = roots[name] / "LICENSE"
        inherited = not license_path.is_file() and package["source"] == "sdk"
        if inherited:
            license_path = sdk_root / "LICENSE"
        body = license_path.read_text()
        digest = hashlib.sha256(license_path.read_bytes()).hexdigest()
        if name == "sky_engine":
            license_name = "Flutter engine bundled third-party notices (multiple licenses)"
        elif "Apache License" in body:
            license_name = "Apache-2.0"
        elif "MIT License" in body or "Permission is hereby granted, free of charge" in body:
            license_name = "MIT"
        elif "Neither the name" in body:
            license_name = "BSD-3-Clause"
        elif (name, package["version"], digest) == (
                "recase", "4.1.0", "389acee6b73f27ef83bdd997f32acc7dc12970c68fbc505284b7bf39d6d80bde"):
            # Full two-clause text manually reviewed for M04. Do not classify
            # arbitrary unrecognized licenses by absence of a third clause.
            license_name = "BSD-2-Clause"
        else:
            raise ValueError(f"Manual license review required: {name}")
        records.append({"name": name, "version": package["version"], "source": package["source"],
                        "scope": "resolved-runtime-closure" if name in closure else "development-only",
                        "license": license_name, "licenseSource": "Flutter SDK LICENSE" if inherited else "package LICENSE",
                        "licenseSha256": digest,
                        "dependencies": package["dependencies"]})
    output = ROOT / "build/verification/dependencies.json"
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_text(json.dumps({"sdks": graph["sdks"], "scopeNote": __doc__.strip(), "packages": records}, indent=2) + "\n")
    print(f"PASS: {len(records)} resolved package license sources hashed; {len(closure)} in runtime/build closure")


if __name__ == "__main__":
    main()
