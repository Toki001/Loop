import 'dart:async';
import 'dart:io';

import 'package:drift/drift.dart' show CouldNotRollBackException;
import 'package:drift/isolate.dart';
import 'package:sqlite3/common.dart';

enum LocalFailureKind {
  invalid,
  notFound,
  conflict,
  full,
  unavailable,
  corrupt,
  unsupportedVersion,
  unsafePath,
  checksum,
}

/// Safe to display/log: never carries SQL, parameters, user text or file paths.
class LocalFailure implements Exception {
  const LocalFailure(this.kind);
  final LocalFailureKind kind;

  @override
  String toString() => 'Local storage failure: ${kind.name}';
}

LocalFailure localFailure(Object error) {
  if (error is LocalFailure) return error;
  if (error is DriftRemoteException) {
    return localFailure(error.remoteCause);
  }
  // SQLITE_FULL may auto-rollback before Drift sends ROLLBACK. Preserve the
  // original typed failure even when that redundant rollback is rejected.
  if (error is CouldNotRollBackException) return localFailure(error.cause);
  if (error is SqliteException) {
    return LocalFailure(switch (error.resultCode) {
      13 => LocalFailureKind.full,
      11 || 26 => LocalFailureKind.corrupt,
      19 || 5 || 6 => LocalFailureKind.conflict,
      _ => LocalFailureKind.unavailable,
    });
  }
  if (error is FileSystemException) {
    return LocalFailure(switch (error.osError?.errorCode) {
      28 => LocalFailureKind.full,
      2 => LocalFailureKind.notFound,
      _ => LocalFailureKind.unavailable,
    });
  }
  return const LocalFailure(LocalFailureKind.unavailable);
}

Future<T> guardLocal<T>(Future<T> Function() action) async {
  try {
    return await action();
  } on Object catch (error) {
    throw localFailure(error);
  }
}

Stream<T> guardLocalStream<T>(Stream<T> Function() source) {
  try {
    return source().transform(
      StreamTransformer<T, T>.fromHandlers(
        handleError: (error, stack, sink) => sink.addError(localFailure(error)),
      ),
    );
  } on Object catch (error) {
    return Stream<T>.error(localFailure(error));
  }
}
