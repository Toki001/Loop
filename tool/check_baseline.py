#!/usr/bin/env python3
"""Offline documentation, traceability and limited Git hygiene checks for Loop."""

from pathlib import Path
import re
import subprocess
import sys
from urllib.parse import unquote, urlsplit


ROOT = Path(__file__).resolve().parents[1]


def git(*args, input=None):
    return subprocess.run(
        ["git", *args], cwd=ROOT, input=input, capture_output=True, check=False
    )


def main():
    listing = git("ls-files", "--cached", "--others", "--exclude-standard", "-z")
    if listing.returncode:
        print("FAIL: initialize a local Git repository before checking the baseline")
        return 1
    paths = sorted(set(filter(None, listing.stdout.decode().split("\0"))))
    failures = []
    documents = 0
    links = 0
    scanned = 0
    patterns = {
        "private key": re.compile(r"-----BEGIN (?:RSA |EC |OPENSSH )?PRIVATE KEY-----"),
        "GitHub token": re.compile(r"\b(?:gh[pousr]_[A-Za-z0-9]{36,}|github_pat_[A-Za-z0-9_]{60,})\b"),
        "AWS access ID": re.compile(r"\b(?:AKIA|ASIA)[A-Z0-9]{16}\b"),
        "personal home path": re.compile(r"/(?:Users|home)/[\w.-]+/"),
    }
    for name in paths:
        path = ROOT / name
        if path.is_symlink():
            failures.append(f"{name}: symlink requires explicit review")
            continue
        if not path.is_file():
            continue
        raw = path.read_bytes()
        if b"\0" in raw:
            failures.append(f"{name}: binary requires separate provenance/privacy review")
            continue
        try:
            text = raw.decode("utf-8")
        except UnicodeDecodeError:
            failures.append(f"{name}: non-UTF-8 file requires separate review")
            continue
        scanned += 1
        for label, pattern in patterns.items():
            if pattern.search(text):
                failures.append(f"{name}: possible {label}; inspect locally (value omitted)")
        if path.suffix != ".md":
            continue
        documents += 1
        for number, line in enumerate(text.splitlines(), 1):
            trailing = re.search(r"[ \t]+$", line)
            if trailing and not (trailing.group() == "  " and line[:-2].strip()):
                failures.append(f"{name}:{number}: invalid trailing Markdown whitespace")
        # Ignore illustrative Markdown inside fenced code, including future paths.
        prose = re.sub(r"(?ms)^(```|~~~).*?^\1[^\n]*$", "", text)
        for target in re.findall(r"!?\[[^\]\n]*\]\(([^)\n]+)\)", prose):
            target = target.strip().split(' "', 1)[0].strip("<>")
            parsed = urlsplit(target)
            if parsed.scheme or target.startswith("#"):
                continue
            local_path = unquote(parsed.path)
            if not local_path:
                continue
            links += 1
            resolved = (path.parent / local_path).resolve()
            if not resolved.is_relative_to(ROOT) or not resolved.exists():
                failures.append(f"{name}: broken/outside local file link: {target}")

    trace = (ROOT / "docs/verification/TRACEABILITY.md").read_text()
    expected_groups = [
        ("US-", 18), ("A", 18), ("D-", 10), ("X-", 12)
    ]
    for prefix, count in expected_groups:
        found = re.findall(rf"^\| ({prefix}\d{{2}}) \|", trace, re.MULTILINE)
        expected = {f"{prefix}{n:02}" for n in range(1, count + 1)}
        if set(found) != expected or len(found) != count:
            failures.append(f"traceability: missing, extra or duplicate {prefix} rows")

    ignored = [
        ".env", ".env.production", "signing/release.jks", "signing/key.p12",
        "signing/AuthKey.p8", "signing/profile.mobileprovision", "android/key.properties",
        "android/local.properties", "android/.gradle/cache", "ios/Pods/Manifest.lock",
        "ios/Flutter/Generated.xcconfig", "ios/Runner.xcodeproj/xcuserdata/local/state",
        ".dart_tool/package_config.json", "build/app.apk", "exports/backup.zip",
        "local-data/practice.sqlite", "recordings/session.m4a", "media/photo.jpg",
        "local-data/practice.db-wal", "secrets/private.pem", "release/app.ipa",
        "archive/test.looparchive",
    ]
    allowed = [
        "pubspec.lock", "ios/Podfile.lock", "lib/main.dart", "CONTRIBUTING.md",
        "test/fixtures/manifest.json", "test/golden/goldens/today.png",
        "docs/verification/design/today.png", ".env.example",
    ]
    result = git("check-ignore", "--no-index", "--stdin", "-z",
                 input=("\0".join(ignored + allowed) + "\0").encode())
    if result.returncode not in (0, 1):
        failures.append("git check-ignore could not run")
    matches = set(filter(None, result.stdout.decode().split("\0")))
    for name in ignored:
        if name not in matches:
            failures.append(f"ignore rule missing: {name}")
    for name in allowed:
        if name in matches:
            failures.append(f"required source/fixture incorrectly ignored: {name}")

    for failure in failures:
        print(f"FAIL: {failure}")
    if failures:
        return 1
    print(f"PASS: {documents} Markdown files; {links} local file links resolved")
    print("PASS: 18 stories, 18 scenarios, 10 decisions, 12 cross-cutting rows")
    print(f"PASS: {len(ignored)} ignored + {len(allowed)} trackable path probes")
    print(f"PASS: limited secret/home-path scan of {scanned} UTF-8 files; no findings")
    print("Scope: local file links only (not anchors/remote URLs); no dependency or app tests")
    return 0


if __name__ == "__main__":
    sys.exit(main())
