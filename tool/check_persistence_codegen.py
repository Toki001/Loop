#!/usr/bin/env python3
"""Fail if the reviewed Drift SQL source changes generated Dart output."""
from hashlib import sha256
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
GENERATED = ROOT / 'lib/core/data/database/loop_database.g.dart'


def main():
    before = sha256(GENERATED.read_bytes()).hexdigest()
    subprocess.run([
        'dart', '--suppress-analytics', 'run', 'build_runner', 'build',
        '--build-filter=lib/core/data/database/loop_database.g.dart',
    ], cwd=ROOT, check=True)
    assert sha256(GENERATED.read_bytes()).hexdigest() == before, (
        'Drift output was stale; review the generated diff and rerun checks'
    )
    print('PASS: Drift generated output matches the committed SQL schema')


if __name__ == '__main__':
    main()
