# Data Model, Evidence Provenance and Progress Mathematics

## 1. Data principles

Personal progress is **observed evidence**, not invented intelligence. Store raw observations; calculate derived insights deterministically. Time spent is input, not skill mastery. Preserve history when names/exercises/units are edited. Missing data is `null`, not zero. A self-rating is clearly self-rated and is not interchangeable with an instrument measurement.

## 2. SQL / Drift table contract (logical schema)

### `settings`

`key` PK; typed `valueJson`; `updatedAtUtc`; keys include theme, weekStart, locale, onboardingVersion, quietHours and export preferences. Preferences migration-safe and defaulted.

### `skills`

`id` PK UUID; `name` text 1–60 chars; `kind` enum; `iconKey`; `accentKey`; `description` nullable; `createdAtUtc`; `updatedAtUtc`; `archivedAtUtc` nullable; `sortOrder` int; `defaultPracticeMinutes` int optional. No hard delete by default if sessions exist; explicit destructive cascade only from settings with confirmation.

### `goals`

`id` PK; `skillId` FK; `title`; `type` (`cumulative`, `threshold`, `weekly_target`, `deliverable`, `qualitative`); `metricDefinitionId` optional FK; `targetValue` decimal nullable; `targetUnit` nullable; `targetDateLocal` optional; `status` (`active`, `completed`, `paused`, `archived`); `completedAtUtc`; timestamps. For qualitative and deliverable goals, display milestone/checklist rather than fictitious numeric percent.

### `exercises`

`id` PK; `skillId` FK; `templateId` optional text; `title`; `instructions`; `defaultSeconds`; `sortOrder`; `isArchived`; timestamps. Core starter exercises materialized as user-modifiable copies during skill creation; use stable template IDs to avoid duplicate migration inserts.

### `sessions`

`id` PK; `skillId` FK; `startedAtUtc` nullable; `endedAtUtc` nullable; `activeSeconds` nonnegative int; `entryMode` `timed|manual`; `status` `draft|running|paused|completed|discarded`; `interruptionReason` nullable; `createdAtUtc`; `updatedAtUtc`; `revision` int nonnegative; `note` nullable; `nextStep` nullable; `effortRating` optional integer 1–5; `localDisplayZone` optional IANA name; `sourceDeviceId` internal random id optional. Repository enforces legal state transitions. Only completed entries count in analytics.

### `session_exercises`

`sessionId` FK, `exerciseId` nullable (for deleted/archived templates), `exerciseTitleSnapshot`, `ordinal`, optional `allocatedSeconds`, optional result note. Composite `(sessionId, ordinal)` unique; total allocations ≤ session activeSeconds if provided.

### `metric_definitions`

`id` PK; `skillId` FK; `label`; `unitKey` (e.g. `wpm`, `percent`, `bpm`, `clean_changes_per_min`, `count`, `rating_1_5`, custom); `valueType` `numeric|checklist|text`; `direction` `up|down|toward_target|none`; `targetValue` optional; `scaleMin/scaleMax` nullable; `sourceHint` `manual|instrument|self_rating`; `archivedAtUtc`; `version`. Changing units creates a new version rather than silently rewriting old data. Explicit known conversion only when mathematically legitimate.

### `metric_readings`

`id` PK; `sessionId` FK; `metricDefinitionId` FK; `definitionVersion`; `numericValue` finite decimal nullable; `textValue` nullable; `boolValue` nullable; `sourceType` `self_reported|instrument_import|derived`; `sourceNote` nullable; `measuredAtUtc`; `createdAtUtc`. Enforce type match and ranges. Prevent duplicate 'same metric' measurement per session unless explicit repetition/attempt index is supported.

### `media_assets`

`id` PK; `sessionId` FK; `kind` `image|audio`; `mime`; `byteLength` int; `sha256`; `relativePath`; `thumbnailRelativePath` nullable; `durationMs` nullable; `width/height` nullable; `label` nullable; `isBaseline` bool; `captureSource` `camera|microphone|file_import`; `createdAtUtc`; `storageState` `pending|ready|cleanup_pending|missing`. Unique file path; FK cascade metadata with reconciler for file lifecycle.

### `reminders`

`id` PK; `skillId` FK nullable; `enabled`; `localTimeHHmm`; `weekdaysBitset`; `ianaZone`; `quietHoursOverride`; `messageId`; `lastScheduledAtUtc`; `updatedAtUtc`. OS IDs stored for cancellation; notifications contain no sensitive personal media/text by default.

### `data_migrations`, `export_history`, `tombstones` (if needed)

Schema version and migration status; export metadata contains only timestamp, archive version, size, success/failure, **not** raw archive or user notes. Tombstones optional for future sync, must not make user-deleted media resurrect. Include indices for sessions by `(skillId, endedAtUtc)`, media `(sessionId, kind)`, readings `(metricDefinitionId, measuredAtUtc)` and exercises `(skillId,sortOrder)`.

## 3. Domain invariants

- Skill ID immutable; archived skill histories remain accessible/exportable.
- `completed` sessions require skill, end date and nonnegative duration; manual sessions require a recorded manual entry intent, may be zero seconds only for evidence-only journal if deliberate and labeled (no artificial practice minutes).
- `activeSeconds` from segments, not naive `end - start` in paused/background sessions.
- No more than one `running` timer; transactional enforcement via repository and tests (DB unique partial index if supported).
- All media references remain inside app-private storage; a broken attachment is visible as missing with recover/relink guidance, not a crash.
- Metric readings must map to same skill as session/definition and retain immutable unit/version history.
- Analytics only query completed, non-deleted sessions; edited session idempotently updates derived values.
- Import merges with collision ID map and preserves foreign-key integrity; export hashes allow full integrity check.

## 4. Metric formula reference

**Recorded active practice time** = sum of `activeSeconds` for completed sessions matching selected skill/date range. Convert to displayed minutes/hours only after summing seconds; rounding never happens per session before aggregation.

**Session count** = number of distinct completed session IDs (one completion counts once regardless of exercise count/media edits).

**Days practiced** = count distinct *local calendar dates* of session end in selected display timezone policy. Specify policy (prefer current locale for UI, with tooltip; store original zone for audit). Weekly grouping uses configured week start; DST changes never alter stored duration.

**Practice frequency** = sessions or practiced days within exact selected reporting interval, not a magical `consistency` score. Avoid 'streak loss' messaging; if streak exists in a future version make it opt-in and explain timezone rule.

**Target progress** for additive goal: `clamp(sum qualifying readings / target, 0, 1)` if target > 0 and definition compatible; track overachievement separately; do not count a metric source twice if amended. Threshold goal uses latest comparable reading vs target with direction-specific status; avoid zero-to-target percentage where baseline undefined. Qualitative goals have explicit done/undone states only.

**Change (absolute)** = `latest - baseline` for same metric definition version, unit and source method; include measurement dates. **Change (%)** = `(latest-baseline)/abs(baseline)*100` only when baseline ≠ 0; hide if undefined. For negative-direction metrics (e.g. errors), improvement sign = `-(latest-baseline)`; for target-seeking show distance to target; user-visible arrows are labeled and interpreted, not just green up. Rating scales display ordinal shift (e.g. 2/5 → 4/5), not false percentages.

**Rolling average** = mean of selected equally comparable readings, `n` disclosed; don't fit fake predictive curves from 2 samples. Default charts plot raw observations with date labels. **Range filter** inclusive local date start, exclusive next-day UTC conversion; test DST, leap day and week boundaries. Duration charts don't use goal metrics as `mastery`.

**Text reflections** are not automatically scored as performance. A structured `effortRating` can be shown separately but not as an estimate of ability. Don't compute cross-category 'skill score' for users.

## 5. Comparison eligibility

Two `media_assets` must have same `skillId` via session and `kind`, be ready/readable, and belong to distinct user-selected moments. Images of differing dimensions must be contained without stretching; audio A/B strictly serialized playback. Audio rate, compression or volume differences are not evidence of improved skill; labels explain. Quantitative comparisons require same metricDefinition ID+version+unit, or explicit reviewed unit conversion and source disclosures; exclude missing/malformed values.

Then/Now ordering defaults chronological. If same date/time, show session ordinal; allow reverse only as a deliberate user action, don't imply temporal progression inaccurately. Both asset sessions link back; permanently deleting either degrades comparison gracefully.

## 6. Fixtures and test cases

Create deterministic seed **only for tests, debug previews and goldens**: sample skills guitar, drawing, typing, 35 sessions over multiple weeks, some missing notes and media, multiple goals; stable IDs and times. No fixtures in release startup. Test:

- Manual entry vs timed entry are counted once; edits don't duplicate.
- Two short sessions total seconds round correctly.
- Paused five minutes and foreground one minute records one minute, not six.
- Process kill does not accrue background time.
- Repeated session Finish does not double insert.
- DST jump, timezone travel, week-start change and leap day group correctly.
- Goal overachievement clamps progress visually but raw values retained.
- WPM definition v1 and BPM v1 never compare; incompatible versions don't compare.
- Baseline zero yields no invalid percent.
- Negative metric (error count) direction does not report regression as improvement.
- Missing/corrupt audio, changed imported file path and 0-byte image don't crash.
- Very long skill names/emoji/RTL graphemes render and migrate.
- Archive with duplicate paths/traversal/oversized expansion rejected before touching real data.
- Full data deletion removes sessions and media under permitted semantics.

## 7. Example portable export manifest contract

```json
{
  "product": "Loop",
  "archiveSchema": 1,
  "createdAtUtc": "2026-10-27T07:00:00Z",
  "dataFile": "data/records.ndjson",
  "recordCounts": {"skills": 1, "sessions": 2, "mediaAssets": 1},
  "media": [
    {"assetId":"example-asset-uuid", "path":"media/example-asset-uuid.jpg", "bytes":12345, "sha256":"<64-hex>"}
  ]
}
```

This is a **schema illustration**, not a finished exporter. Never trust manifest-provided paths, record counts or hash without independent verification. Pin format spec and round-trip migrations in tests.
