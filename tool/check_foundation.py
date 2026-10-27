#!/usr/bin/env python3
"""Enforce the reviewed SDK, identity and native release-isolation contract."""
import json
from pathlib import Path
import plistlib
import re
import subprocess
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]


def main():
    pin = json.loads((ROOT / "tool/toolchain.json").read_text())
    result = subprocess.run(["flutter", "--suppress-analytics", "--version", "--machine"],
                            cwd=ROOT, check=True, text=True, capture_output=True)
    actual = json.loads(result.stdout)
    assert actual["frameworkVersion"] == pin["flutter"], "Flutter version differs from pin"
    assert actual["frameworkRevision"] == pin["frameworkRevision"], "Flutter revision differs"
    assert actual["channel"] == pin["channel"], "Use the pinned stable channel"
    assert actual["dartSdkVersion"].split()[0] == pin["dart"], "Dart version differs"
    assert (ROOT / ".flutter-version").read_text().strip() == pin["flutter"]
    application_id = "com.jameskierdoliguez.loop"
    android = (ROOT / "android/app/build.gradle.kts").read_text()
    for key in ["namespace", "applicationId"]:
        assert f'{key} = "{application_id}"' in android, f"Android {key} changed"
    for key, value in [("compileSdk", pin["androidCompileSdk"]), ("targetSdk", pin["androidTargetSdk"]), ("minSdk", pin["androidMinSdk"])]:
        assert f"{key} = {value}" in android, f"Android {key} differs"
    assert "signingConfig = null" in android, "Never silently debug-sign release builds"
    manifest = (ROOT / "android/app/src/main/AndroidManifest.xml").read_text()
    assert 'android:label="Loop"' in manifest
    assert "uses-permission" not in manifest, "Review any new production permission"
    app = ET.fromstring(manifest).find('application')
    namespace = '{http://schemas.android.com/apk/res/android}'
    assert app.get(namespace + 'allowBackup') == 'false'
    assert app.get(namespace + 'fullBackupContent') == '@xml/backup_rules'
    assert app.get(namespace + 'dataExtractionRules') == '@xml/data_extraction_rules'
    domains = {'root', 'file', 'database', 'sharedpref', 'external',
               'device_root', 'device_file', 'device_database', 'device_sharedpref'}
    xml = ROOT / 'android/app/src/main/res/xml'
    legacy = ET.parse(xml / 'backup_rules.xml').getroot()
    extraction = ET.parse(xml / 'data_extraction_rules.xml').getroot()
    for rules in [legacy, extraction.find('cloud-backup'), extraction.find('device-transfer')]:
        assert rules is not None, 'Backup/transfer policy missing'
        assert not rules.findall('include'), 'Private backup inclusion needs review'
        assert {e.get('domain') for e in rules.findall('exclude') if e.get('path') == '.'} == domains
    project = (ROOT / "ios/Runner.xcodeproj/project.pbxproj").read_text()
    app_ids = re.findall(r"PRODUCT_BUNDLE_IDENTIFIER = ([^;]+);", project)
    assert app_ids.count(application_id) == 3 and set(app_ids) == {application_id, application_id + ".RunnerTests"}
    targets = re.findall(r"IPHONEOS_DEPLOYMENT_TARGET = ([^;]+);", project)
    assert targets and set(targets) == {pin["iosDeploymentTarget"]}
    info = plistlib.loads((ROOT / "ios/Runner/Info.plist").read_bytes())
    assert info["CFBundleDisplayName"] == info["CFBundleName"] == "Loop"
    assert info["CFBundleIdentifier"] == "$(PRODUCT_BUNDLE_IDENTIFIER)"
    build = (ROOT / "lib/app/build_info.dart").read_text()
    assert f"applicationId = '{application_id}'" in build
    pubspec = (ROOT / "pubspec.yaml").read_text()
    version = re.search(r"^version: ([^\n]+)", pubspec, re.M).group(1)
    name, number = version.split("+")
    assert f"version = '{name}'" in build and f"buildNumber = {number}" in build
    for source in (ROOT / "lib").rglob("*.dart"):
        text = source.read_text()
        assert not re.search(r"(?:import|export)\s+['\"][^'\"]*(?:design_preview|preview\.dart)", text), "Preview imported by application"
    print("PASS: exact SDK/identity, permissions, backup/transfer exclusions and preview isolation")


if __name__ == "__main__":
    main()
