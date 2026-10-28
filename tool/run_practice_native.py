#!/usr/bin/env python3
"""Local M06 OS lifecycle harness. Never resets the normal Loop store.

Requires an already authorized device/simulator. Background verification waits
600 real seconds. kill_prepare intentionally terminates the test process and is
not represented as a completed Flutter test; recovery is a separate invocation.
"""
import argparse
import json
from pathlib import Path
import shutil
import subprocess
import threading
import time

ROOT = Path(__file__).resolve().parents[1]
APP = 'com.jameskierdoliguez.loop'


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--device', required=True)
    parser.add_argument('--platform', choices=['android', 'ios'], required=True)
    parser.add_argument('--verbose', action='store_true', help='Retain verbose Flutter host diagnostics in the ignored local log.')
    parser.add_argument('--stage', choices=['smoke', 'background', 'lock', 'kill_prepare', 'recovery', 'cleanup'], required=True)
    args = parser.parse_args()
    if args.stage == 'lock' and args.platform != 'android':
        parser.error('The lock probe requires the physical Android target.')
    output = ROOT / 'tmp' / f'm06-{args.platform}-{args.stage}'
    output.parent.mkdir(exist_ok=True)
    adb = shutil.which('adb') or str(Path.home() / 'Library/Android/sdk/platform-tools/adb')
    prefix = [adb, '-s', args.device] if args.platform == 'android' else ['xcrun', 'simctl']
    commands = []
    events = []
    started = time.monotonic()

    def run(tail):
        command = prefix + tail
        result = subprocess.run(command, capture_output=True, text=True)
        commands.append({'command': command[1:] if args.platform == 'android' else command,
                         'exit': result.returncode, 'stdout': result.stdout.strip(), 'stderr': result.stderr.strip(),
                         'elapsedSeconds': round(time.monotonic() - started, 3)})
        if result.returncode:
            raise RuntimeError(f'Native command failed: {tail[0]} (exit {result.returncode})')
        return result.stdout.strip()

    flutter = ['flutter', '--suppress-analytics', *(['--verbose'] if args.verbose else []), 'test', 'integration_test/practice_test.dart',
               '-d', args.device, '--no-pub', '--no-uninstall', '--timeout=45m', '--reporter', 'expanded', f'--dart-define=M06_STAGE={args.stage}']
    requested = threading.Event()
    kill_ready = threading.Event()
    process = subprocess.Popen(flutter, cwd=ROOT, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, bufsize=1)

    def read():
        with output.with_suffix('.log').open('w') as log:
            for line in process.stdout:
                log.write(line)
                log.flush()
                for marker in ['LOOP_M06_REQUEST_BACKGROUND:', 'LOOP_M06_PAUSED:', 'LOOP_M06_KILL_READY:', 'LOOP_M06_EVIDENCE:']:
                    if marker in line:
                        event = json.loads(line.split(marker, 1)[1])
                        events.append({'marker': marker[:-1], 'elapsedSeconds': round(time.monotonic()-started, 3), 'data': event})
                        print(json.dumps(events[-1]), flush=True)
                        if marker == 'LOOP_M06_REQUEST_BACKGROUND:': requested.set()
                        if marker == 'LOOP_M06_KILL_READY:': kill_ready.set()
    reader = threading.Thread(target=read)
    reader.start()
    expected_termination = False
    try:
        if args.stage in ('background', 'lock'):
            while not requested.wait(1):
                if process.poll() is not None: raise RuntimeError('Test exited before background request')
            if args.platform == 'android':
                run(['shell', 'input', 'keyevent', 'KEYCODE_SLEEP' if args.stage == 'lock' else 'KEYCODE_HOME'])
            else:
                # simctl has no supported Home command. Background by launching
                # Apple's built-in Settings; no account or setting is changed.
                run(['launch', args.device, 'com.apple.Preferences'])
            left = time.monotonic()
            required_seconds = 15 if args.stage == 'lock' else 600
            print(f'Native interruption interval started: {required_seconds} real seconds.', flush=True)
            next_progress = 30
            while time.monotonic() - left < required_seconds:
                if process.poll() is not None:
                    events.append({'marker': 'unexpectedProcessExit', 'interruptionSeconds': round(time.monotonic() - left, 3), 'flutterExit': process.returncode})
                    raise RuntimeError('Test exited while backgrounded')
                if time.monotonic() - left >= next_progress:
                    # Host-only output: never wake/foreground the app or alter
                    # the required native interval to keep a session alive.
                    print(f'Native background wait: {next_progress}/{required_seconds} real seconds.', flush=True)
                    next_progress += 30
                time.sleep(1)
            away = time.monotonic() - left
            if args.platform == 'android':
                if args.stage == 'lock':
                    run(['shell', 'input', 'keyevent', 'KEYCODE_WAKEUP'])
                    print('Unlock the phone normally if its lock screen appears; no lock settings are changed.', flush=True)
                run(['shell', 'am', 'start', '-n', f'{APP}/.MainActivity'])
            else:
                run(['launch', args.device, APP])
            events.append({'marker': 'externalBackgroundInterval', 'realSeconds': round(away, 3)})
        if args.stage == 'kill_prepare':
            while not kill_ready.wait(1):
                if process.poll() is not None: raise RuntimeError('Test exited before kill checkpoint')
            if args.platform == 'android':
                before = run(['shell', 'pidof', APP])
                if not before: raise RuntimeError('No live test process to terminate')
                run(['shell', 'am', 'force-stop', APP])
                after = subprocess.run(prefix + ['shell', 'pidof', APP], capture_output=True, text=True)
                commands.append({'command': ['shell', 'pidof', APP], 'exit': after.returncode, 'stdout': after.stdout.strip(), 'expectedAbsent': True})
                if after.stdout.strip(): raise RuntimeError('Process still alive after force-stop')
            else:
                run(['terminate', args.device, APP])
            expected_termination = True
        code = process.wait(timeout=240 if args.stage in ('background', 'lock') else 180)
        reader.join(timeout=10)
        if expected_termination:
            passed = kill_ready.is_set() and code != 0
        else:
            passed = code == 0 and (args.stage == 'cleanup' or any(e['marker'] == 'LOOP_M06_EVIDENCE' for e in events))
        result = {'platform': args.platform, 'device': args.device, 'stage': args.stage, 'flutterCommand': flutter,
                  'flutterExit': code, 'expectedOSTermination': expected_termination, 'completedFlutterTest': not expected_termination and code == 0,
                  'nativeCommands': commands, 'events': events, 'harnessGatePassed': passed}
        output.with_suffix('.json').write_text(json.dumps(result, indent=2) + '\n')
        print(json.dumps({'stage': args.stage, 'flutterExit': code, 'expectedOSTermination': expected_termination, 'harnessGatePassed': passed}), flush=True)
        if not passed: raise SystemExit(1)
    except Exception as error:
        failure = {'platform': args.platform, 'device': args.device, 'stage': args.stage,
                   'flutterCommand': flutter, 'flutterExit': process.poll(),
                   'expectedOSTermination': expected_termination,
                   'completedFlutterTest': False, 'harnessGatePassed': False,
                   'failureKind': type(error).__name__,
                  'elapsedSeconds': round(time.monotonic() - started, 3),
                   'nativeCommands': commands, 'events': events}
        output.with_suffix('.json').write_text(json.dumps(failure, indent=2) + '\n')
        raise
    finally:
        if process.poll() is None:
            process.terminate()
            process.wait(timeout=15)
        reader.join(timeout=10)


if __name__ == '__main__':
    main()
