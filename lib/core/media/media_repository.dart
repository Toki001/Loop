import 'package:drift/drift.dart';

import '../data/database/loop_database.dart';
import '../data/local_failure.dart';
import '../data/validation.dart';
import 'private_files.dart';

class MediaRepository {
  const MediaRepository(this._db, this.files);
  final LoopDatabase _db;
  final PrivateFiles files;

  Stream<List<MediaAsset>> watchForSession(String sessionId) =>
      guardLocalStream(
        () =>
            (_db.select(_db.mediaAssets)
                  ..where((a) => a.sessionId.equals(sessionId))
                  ..orderBy([
                    (a) => OrderingTerm.asc(a.createdAtUtc),
                    (a) => OrderingTerm.asc(a.id),
                  ]))
                .watch(),
      );

  /// Only call after M08's media format/permission validation. This layer
  /// guarantees byte integrity and transaction/file compensation, not codecs.
  Future<MediaAsset> attach({
    required String sessionId,
    required String kind,
    required String mime,
    required Stream<List<int>> bytes,
    required String captureSource,
    String? label,
    int? width,
    int? height,
    int? durationMs,
    int maxBytes = 100 * 1024 * 1024,
  }) => guardLocal(() async {
    validText(label, maximum: 1000);
    if (!(kind == 'image' && mime.startsWith('image/') ||
        kind == 'audio' && mime.startsWith('audio/'))) {
      throw const LocalFailure(LocalFailureKind.invalid);
    }
    final stored = await files.write(bytes, maxBytes: maxBytes);
    try {
      return await _db.transaction(
        () => _db
            .into(_db.mediaAssets)
            .insertReturning(
              MediaAssetsCompanion.insert(
                id: newId(),
                sessionId: sessionId,
                kind: kind,
                mime: mime,
                byteLength: stored.byteLength,
                sha256: stored.sha256,
                relativePath: stored.relativePath,
                durationMs: Value(durationMs),
                width: Value(width),
                height: Value(height),
                label: Value(label),
                captureSource: captureSource,
                createdAtUtc: utcNow(),
                storageState: 'ready',
              ),
            ),
      );
    } on Object {
      // Only the file created by this failed operation is eligible for cleanup.
      // If disk access also fails, retain it for reconciliation; never mask the
      // original commit failure or delete an unrelated/unreferenced old file.
      try {
        await files.delete(stored.relativePath);
      } on Object {
        try {
          await _db
              .into(_db.fileCleanupQueue)
              .insertOnConflictUpdate(
                FileCleanupQueueCompanion.insert(
                  relativePath: stored.relativePath,
                  queuedAtUtc: utcNow(),
                ),
              );
        } on Object {
          // Unavailable storage can prevent even recording cleanup intent.
          // Reconciliation reports the retained orphan without deleting it.
        }
      }
      rethrow;
    }
  });

  Future<void> updateLabel(
    String id, {
    required String? label,
    required bool isBaseline,
  }) => guardLocal(() async {
    validText(label, maximum: 1000);
    requireChanged(
      await (_db.update(_db.mediaAssets)..where((a) => a.id.equals(id))).write(
        MediaAssetsCompanion(
          label: Value(label),
          isBaseline: Value(isBaseline),
        ),
      ),
    );
  });

  Future<void> delete(String id) => guardLocal(
    () => _db.transaction(() async {
      requireChanged(
        await (_db.delete(_db.mediaAssets)..where((a) => a.id.equals(id))).go(),
      );
      // The SQL trigger queues both main file and thumbnail in this transaction.
    }),
  );
}

class ReconcileReport {
  const ReconcileReport({
    required this.checked,
    required this.missing,
    required this.unreadable,
    required this.unreferenced,
    required this.deleted,
    required this.cleanupRemaining,
    required this.scanLimited,
  });
  final int checked;
  final int missing;
  final int unreadable;
  final int unreferenced;
  final int deleted;
  final int cleanupRemaining;
  final bool scanLimited;
}

/// Bounded startup maintenance; unknown files are counted, never removed.
class FileReconciler {
  const FileReconciler(this._db, this.files);
  final LoopDatabase _db;
  final PrivateFiles files;

  Future<ReconcileReport> run({int limit = 200}) => guardLocal(() async {
    if (limit <= 0) throw const LocalFailure(LocalFailureKind.invalid);
    var deleted = 0;
    var unreadable = 0;
    final pending = await (_db.select(
      _db.fileCleanupQueue,
    )..limit(limit)).get();
    for (final item in pending) {
      final referenced =
          await (_db.select(_db.mediaAssets)
                ..where(
                  (a) =>
                      a.relativePath.equals(item.relativePath) |
                      a.thumbnailRelativePath.equals(item.relativePath),
                )
                ..limit(1))
              .get();
      if (referenced.isNotEmpty) continue;
      try {
        await files.delete(item.relativePath);
        await (_db.delete(
          _db.fileCleanupQueue,
        )..where((q) => q.relativePath.equals(item.relativePath))).go();
        deleted++;
      } on LocalFailure {
        unreadable++;
      }
    }
    var checked = 0;
    var missing = 0;
    final assets = await (_db.select(_db.mediaAssets)..limit(limit + 1)).get();
    for (final asset in assets.take(limit)) {
      checked++;
      if (asset.storageState == 'cleanup_pending') {
        await (_db.delete(
          _db.mediaAssets,
        )..where((a) => a.id.equals(asset.id))).go();
        continue;
      }
      var state = 'ready';
      try {
        await files.verify(
          StoredFile(asset.relativePath, asset.byteLength, asset.sha256),
        );
      } on LocalFailure catch (failure) {
        if (failure.kind == LocalFailureKind.notFound ||
            failure.kind == LocalFailureKind.checksum) {
          state = 'missing';
          missing++;
        } else {
          unreadable++;
          continue;
        }
      }
      if (asset.storageState != state) {
        await (_db.update(_db.mediaAssets)..where((a) => a.id.equals(asset.id)))
            .write(MediaAssetsCompanion(storageState: Value(state)));
      }
    }
    var unreferenced = 0;
    var scanned = 0;
    var limited = assets.length > limit;
    await for (final path in files.mediaPaths()) {
      if (scanned++ >= limit) {
        limited = true;
        break;
      }
      final found =
          await (_db.select(_db.mediaAssets)
                ..where(
                  (a) =>
                      a.relativePath.equals(path) |
                      a.thumbnailRelativePath.equals(path),
                )
                ..limit(1))
              .get();
      if (found.isEmpty) unreferenced++;
    }
    final count = await _db
        .customSelect('SELECT COUNT(*) AS n FROM file_cleanup_queue')
        .getSingle();
    return ReconcileReport(
      checked: checked,
      missing: missing,
      unreadable: unreadable,
      unreferenced: unreferenced,
      deleted: deleted,
      cleanupRemaining: count.read<int>('n'),
      scanLimited: limited,
    );
  });
}
