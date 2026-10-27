# Migration fixture provenance

These SQL files contain synthetic, unreleased M04 schemas and data. They have never been a published Loop database or a user's journal. Product code does not import them. Binary database files remain ignored.

`schema_v1.sql` freezes the initial relational schema before durable file cleanup. `seed_v1.sql` covers every v1 table, including completed manual intent, an exercise snapshot, a versioned reading, a goal and an opaque media reference. Tests create its three synthetic media bytes separately. V2 adds the cleanup queue and cascade trigger without rewriting those values. Schema/version migration commits atomically.

`schema_v2.sql` is exported from the actual generated Drift schema using `dart --suppress-analytics run drift_dev schema export lib/core/data/database/loop_database.dart`. The JSON export also describes the current v2 schema. Keep historical v1 unchanged; future changes increment the schema and add fixtures. Tests compare real migrated and fresh schemas, indexes, triggers, rows, foreign keys and cleanup, and inject a migration interruption to verify rollback/retry.
