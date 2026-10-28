# ADR-017 — Atomic journal reflection and durable editing

Date: 2026-10-28. Status: accepted; M07 local data/UI/native verification passed, release gates remain.

## Decision

Keep practice timing owned by the existing serialized engine. A journal repository composes the existing practice/session and metric repositories inside one SQL transaction for Finish: session/reflection, existing exercise snapshots, clock checkpoint, readings and draft removal either commit together or remain unchanged. Reflection is optional. Identical completed retries return the existing identity; different payloads require an explicit revision-aware amendment. Editing timed history never fabricates or rewrites measured duration. Manual duration/date amendments require explicit confirmation and retain manual provenance. Readings use immutable definition/version and explicit source; user-entered readings remain self-reported, never imported/instrumented by implication.

Schema5 adds an optional `what_got_easier` session column using SQLite ADD COLUMN, avoiding a rebuild of a table with inbound references. A dependent `journal_drafts` table stores bounded versioned JSON, purpose (finish/edit), base revision and update timestamp. Raw form drafts preserve incomplete numeric text without treating it as a reading. Frozen v1–v4 fixtures remain unchanged. Both changes and migration ledger entries share a transaction; failures leave the prior database intact for retry.

A small application-owned draft writer debounces input, serializes actual repository writes, flushes on lifecycle interruption/navigation/Save and exposes a real failure/retry state. Bootstrap drains this writer before closing SQL. Successful completion removes the form only after queued writes have drained; errors retain its content. No new framework or dependency is introduced.

Completed journal views read live repository streams with stable date/ID order and skill/date/exercise-snapshot filters. Date filtering uses inclusive local midnight and exclusive next calendar midnight converted to UTC; grouping displays the current device timezone and explains that policy. No timezone name is invented as an IANA identifier. Archived skills retain readable history. Empty views never seed entries or measurements.

Deletion requires confirmation and checks the viewed revision. An in-memory undo receipt can restore metadata-only sessions and their stable dependent IDs atomically, subject to surviving parents and collision checks. Sessions with media cannot offer this undo promise: deletion uses the existing durable file-cleanup queue, and files are not resurrected from metadata. Media lifecycle remains M08; UI must accurately describe scope.

## Verification requirements

Migration preservation/DDL rollback/retry; transaction failure after session and after reading writes; identical Finish/amend retries and conflicting revisions; typed/ranged/finite same-skill readings with immutable unit/version/source; draft reopen including invalid text; writer lifecycle/root disposal while SQL is pending; manual provenance and date bounds; stable stream/filter order and calendar boundaries; real SQL-backed large text/keyboard/error/edit/delete/undo UI; native fresh skill→practice→reflection→save→separate-process detail; complete source CI and native builds. No PASS until those actual results exist.

## Scope and limits

No metric trend, skill score, fake history, media control, remote service, permission, encryption/key, package or release claim is added. Existing M06 lifecycle/foreground clock and M02 frozen visual contracts remain prerequisites. Physical iPhone, manual screen readers and profile/release coverage remain later explicit gates.
