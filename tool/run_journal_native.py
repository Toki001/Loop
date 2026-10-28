#!/usr/bin/env python3
"""Run one isolated M07 native stage; preserve real exits and structured evidence.

Run setup then resume on the same authorized target. Resume asserts a distinct
native PID and removes only the marker-owned UUID test store after verification.
Normal product data is hash-guarded by the integration test. Never uninstall.
"""
import argparse
import json
from pathlib import Path
import subprocess
import time

ROOT = Path(__file__).resolve().parents[1]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--device', required=True)
    parser.add_argument('--platform', choices=['android', 'ios'], required=True)
    parser.add_argument('--stage', choices=['setup', 'resume', 'cleanup'], required=True)
    parser.add_argument('--label', default='final')
    args = parser.parse_args()
    if not args.label.replace('-', '').isalnum():
        parser.error('Use an alphanumeric/hyphen label.')
    stem = ROOT / 'tmp' / f'm07-{args.platform}-{args.stage}-{args.label}'
    stem.parent.mkdir(exist_ok=True)
    command = ['flutter', '--suppress-analytics', 'test', 'integration_test/journal_test.dart',
               '-d', args.device, '--no-pub', '--no-uninstall', '--timeout=15m',
               '--reporter', 'expanded', f'--dart-define=M07_STAGE={args.stage}']
    events = []
    started = time.monotonic()
    with stem.with_suffix('.log').open('w') as log:
        process = subprocess.Popen(command, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, bufsize=1)
        try:
            for line in process.stdout:
                log.write(line)
                log.flush()
                marker = 'LOOP_M07_EVIDENCE:'
                if marker in line:
                    event = json.loads(line.split(marker, 1)[1])
                    events.append(event)
                    print(json.dumps(event), flush=True)
            code = process.wait(timeout=60)
        finally:
            if process.poll() is None:
                process.terminate()
                process.wait(timeout=15)
    passed = code == 0 and (args.stage == 'cleanup' or len(events) == 1)
    result = dict(platform=args.platform, device=args.device, stage=args.stage,
                  flutterCommand=command, flutterExit=code, completedFlutterTest=code == 0,
                  elapsedSeconds=round(time.monotonic() - started, 3), events=events,
                  harnessGatePassed=passed)
    stem.with_suffix('.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result), flush=True)
    return 0 if passed else 1


if __name__ == '__main__':
    raise SystemExit(main())
