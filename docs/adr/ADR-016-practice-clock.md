# ADR-016 — Foreground-only practice and durable checkpoints

Date: 2026-10-28. Status: accepted and verified for M06 local acceptance; physical Android lifecycle and restart evidence in [M06](../verification/M06.md).

## Decision

One application-owned practice engine serializes session commands through repository transactions. Its `PracticeClock` uses `Stopwatch` for foreground segments; UTC timestamps describe history only. Inactive/hidden/paused/detached lifecycle events stop the segment synchronously, then persist the paused session. Resume always requires a deliberate user action. A queued Start/Resume rechecks foreground state after its write so lifecycle changes during I/O cannot restart time. No wake lock, background task, notification, recording or new permission is introduced.

Schema v4 adds a dependent `practice_checkpoints` table, leaving historical session rows and v1–v3 fixtures intact. It stores accumulated milliseconds, optional planned seconds, and checkpoint timestamp. The same transaction updates the session's floored total seconds/revision and its checkpoint. Keeping fractions across segments avoids losing a second on every pause. A five-second durable checkpoint cadence bounds ordinary hard-kill loss to time since the last successful checkpoint; storage stalls can extend that interval and are reported. Recovery never estimates absence from the wall clock. Legacy sessions without a checkpoint retain their recorded seconds. Every previously running session recovers paused, with a visible hard-kill caveat; legacy multiple drafts are retained for explicit selection, never discarded silently.

Only one unfinished entry may be created through the practice coordinator; starting/resuming still uses the existing SQL unique running-session invariant. Existing historical drafts are recoverable individually. A new plan cannot replace a pending draft. Exercise selections are snapshotted atomically with the draft; archived skills cannot start new practice. Repeated Finish targets the same immutable session ID and returns its completed record without creating a duplicate. Clock failure stops accrual and keeps unsaved elapsed time in memory for retry; a process kill can recover only durable time.

Timed practice may have a 1–180 minute plan or no target. Manual practice is a separate source with explicit duration/date confirmation. Evidence-only entries deliberately record zero practice seconds and are labeled as journal entries; blank reflection is allowed. M06 exposes a real completion confirmation and saved session summary; M07 extends it with reflection/readings and journal history. No simulated save or inactive future control is exposed.

## Verification and limits

Require deterministic clock/race/error tests, real SQLite migration/rollback/reopen, lifecycle/routing/large-text/golden checks, native simulator and physical Android tests, including foreground/background, lock, kill and duplicate Finish. Phone-call and reboot tests must distinguish actual hardware actions from injected lifecycle events. Full physical iPhone and release performance remain later gates. No dependency, remote service, encryption key or production fixture is added.

## Resource lifetime review

Bootstrap owns storage and waits for the practice engine’s queued work before closing its database. The lifecycle host exposes its owned engine to that owner without executing SQL. Provider disposal stops ticking and lifecycle observation; a Resume whose write completes after disposal must never restart the clock. Root-disposal tests must hold a real transaction open and verify the database stays usable until queued recovery finishes. Passing test counts alone do not excuse an unhandled background-isolate shutdown error in the log.
