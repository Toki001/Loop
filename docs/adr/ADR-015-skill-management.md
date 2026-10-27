# ADR-015 — User-owned skill setup and honest goals

Date: 2026-10-27. Status: accepted and verified for M05; actual results in the linked milestone report.

## Context and decision

M05 consumes the verified M04 repository/private-storage boundary. Create a skill, optional starter exercises/metric definitions and optional first goal in one transaction. Catalogs contain editable instructions/measurement definitions only, never recorded practice or invented results. Stable exercise template IDs are copied once; startup/upgrades never overwrite user customization. Names may repeat; immutable UUIDs own references. Archive retains history; hard deletion remains the later confirmed ownership flow. Reordering has labeled up/down alternatives, independent of drag gestures.

Add nullable goal motivation and preserve completed-at timestamps on archive in schema v3 with a tested transactional goals-table rebuild; freeze v1/v2 unchanged. Goals have no inbound FKs; Drift recreates their unit triggers. An already archived legacy goal with no recorded completion remains unknown rather than receiving an invented date. Preserve all existing settings, journal rows and queued file work. Schema/version/data migration records stay transactional, including sequential v1→v3 upgrades. Dates use strict local calendar strings; plans allow 1–180 minutes or untimed in the editor. Skill icons/accents come from a bounded local catalog with labels/fallbacks.

Goal evidence uses completed sessions only, exact metric identity/version/unit and compatible measurement method. Additive progress is limited to additive counts/durations; never sum WPM, percentages or ordinal ratings. Threshold goals report the latest compatible raw value/direction and missing-data explanation, not a fabricated zero-to-target mastery percentage. Weekly targets count distinct local practice days in the chosen current week and are suggestions. Deliverable/qualitative goals are explicitly done/undone; user-marked completion is labeled accordingly. No goal becomes an automatic assertion of skill improvement.

Custom numeric measures are created atomically with the goal, with explicit unit, direction, manual source and non-negative scale (percent bounded 0–100). A failed goal rolls back its new definition. Existing definition/version identities remain fixed; qualitative/deliverable goals create no numeric definition or reading. Cumulative scope is all completed recorded practice, not an implicit claim about time since goal creation. Legacy weekly units such as `sessions` are preserved and require review rather than being relabeled as practice days. Thresholds display their direction and units; ordinal ratings remain observations, never additive ability scores.

## Alternatives and tradeoffs

Keep native Flutter/Riverpod/GoRouter and existing design primitives. Avoid a new form/state framework or agent-plugin dependency. Repository-owned snapshot queries feed views; views do not execute SQL. Staged M05 screens expose functional skill/goal/exercise controls; session clock/capture/insight/reminder/export controls stay gated. Later milestones extend skill context with real history/evidence. All drafts retain values on failure, guard unsaved exits and await actual commits before navigating.

## Data/security impact and verification

No new runtime package, permission, server, account, upload or application encryption. Existing OS protection and M04 limitations remain. Fresh/upgrade migration, transactional setup/reorder/duplicate/archive, goal eligibility, Unicode, failed saves, responsive/keyboard/200%/semantics, goldens and native retained-data/reopen are required before M05 PASS. Required plugin exact-name searches were refreshed: no exact installed/available match; do not substitute unrelated services or install without owner approval. Use verified local/native checks and the existing design contract. [M05](../verification/M05.md) records actual results; no completion is implied by this ADR.
