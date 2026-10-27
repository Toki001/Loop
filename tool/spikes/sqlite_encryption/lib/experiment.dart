import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:sqlite3/sqlite3.dart';

class EncryptionExperimentFailure implements Exception {
  const EncryptionExperimentFailure(this.stage);
  final String stage;
  @override
  String toString() => 'Encryption experiment failed at stage: $stage';
}

String _temporaryKey() {
  final random = Random.secure();
  return List.generate(
    32,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}

bool _sameBytes(List<int> a, List<int> b) =>
    a.length == b.length &&
    Iterable<int>.generate(a.length).every((i) => a[i] == b[i]);

void _require(bool condition, String stage) {
  if (!condition) throw EncryptionExperimentFailure(stage);
}

bool _rejects(String path, String? key) {
  final database = sqlite3.open(path);
  try {
    if (key != null) database.execute("PRAGMA key = '$key';");
    database.select('SELECT value FROM probe');
    return false;
  } on SqliteException {
    return true;
  } finally {
    database.close();
  }
}

void _verify(String path, String key) {
  final database = sqlite3.open(path);
  try {
    database.execute("PRAGMA key = '$key';");
    _require(
      database.select('SELECT value FROM probe').single['value'] ==
          'Synthetic cipher test',
      'correct-key data',
    );
    _require(
      database.select('PRAGMA integrity_check').single.values.single == 'ok',
      'encrypted integrity',
    );
  } finally {
    database.close();
  }
}

Map<String, Object?> _benchmark(String path, String? key) {
  final open = Stopwatch()..start();
  final database = sqlite3.open(path);
  try {
    if (key != null) database.execute("PRAGMA key = '$key';");
    database.execute('PRAGMA journal_mode = WAL');
    database.execute('PRAGMA synchronous = FULL');
    database.execute(
      'CREATE TABLE sample (id INTEGER PRIMARY KEY, value TEXT NOT NULL)',
    );
    open.stop();
    final write = Stopwatch()..start();
    database.execute('BEGIN IMMEDIATE');
    final insert = database.prepare('INSERT INTO sample VALUES (?, ?)');
    try {
      final payload = List.filled(256, 'x').join();
      for (var i = 0; i < 1000; i++) {
        insert.execute([i, payload]);
      }
    } finally {
      insert.close();
    }
    database.execute('COMMIT');
    write.stop();
    final read = Stopwatch()..start();
    _require(
      database
              .select(
                'SELECT COUNT(*) AS n, SUM(length(value)) AS bytes FROM sample',
              )
              .single['n'] ==
          1000,
      'benchmark row count',
    );
    read.stop();
    return {
      'openAndCreateMicros': open.elapsedMicroseconds,
      'writeTransactionMicros': write.elapsedMicroseconds,
      'aggregateReadMicros': read.elapsedMicroseconds,
    };
  } finally {
    database.close();
  }
}

/// Synthetic-only host/mobile probe, independent from Loop's runtime. Keys are
/// generated in memory, never returned, stored, or included in error messages.
Future<Map<String, Object?>> runEncryptionExperiment() async {
  final directory = await Directory.systemTemp.createTemp('loop-cipher-spike-');
  var stage = 'initialization';
  try {
    final key = _temporaryKey();
    final path = '${directory.path}/synthetic.sqlite';
    final first = sqlite3.open(path);
    String sqliteVersion;
    Object? cipherName;
    try {
      final cipher = first.select('PRAGMA cipher;');
      _require(cipher.isNotEmpty, 'cipher availability');
      cipherName = cipher.single.values.single;
      stage = 'encrypted WAL creation';
      first.execute("PRAGMA key = '$key';");
      first.execute('PRAGMA journal_mode = WAL');
      first.execute('CREATE TABLE probe (value TEXT NOT NULL)');
      first.execute('INSERT INTO probe VALUES (?)', ['Synthetic cipher test']);
      sqliteVersion =
          first.select('SELECT sqlite_version() AS version').single['version']
              as String;
      first.execute('PRAGMA wal_checkpoint(TRUNCATE)');
    } finally {
      first.close();
    }
    stage = 'encrypted header';
    final header = await File(path).openRead(0, 16).first;
    _require(
      !ascii.decode(header, allowInvalid: true).startsWith('SQLite format 3'),
      stage,
    );
    stage = 'missing and wrong key';
    final before = await File(path).readAsBytes();
    _require(_rejects(path, null) && _rejects(path, _temporaryKey()), stage);
    _require(
      _sameBytes(before, await File(path).readAsBytes()),
      'wrong-key nondestructive',
    );
    stage = 'correct-key reopen';
    _verify(path, key);
    stage = 'corruption detection';
    final backup = await File(path)
        .copy('${directory.path}/verified-backup.sqlite');
    final corrupted = await File(path)
        .copy('${directory.path}/corrupted.sqlite');
    final damaged = await corrupted.readAsBytes();
    for (var i = 0; i < 64; i++) {
      damaged[i] ^= 255;
    }
    await corrupted.writeAsBytes(damaged, flush: true);
    _require(_rejects(corrupted.path, key), stage);
    _require(
      _sameBytes(damaged, await corrupted.readAsBytes()),
      'corruption nondestructive',
    );
    stage = 'verified backup recovery';
    final recovered = await backup.copy('${directory.path}/recovered.sqlite');
    _verify(recovered.path, key);
    stage = 'explicit decryption';
    final decryptedFile = await backup.copy(
      '${directory.path}/decrypted.sqlite',
    );
    final decrypted = sqlite3.open(decryptedFile.path);
    try {
      decrypted.execute("PRAGMA key = '$key';");
      decrypted.execute("PRAGMA rekey = '';");
    } finally {
      decrypted.close();
    }
    _require(
      ascii
          .decode(await decryptedFile.openRead(0, 16).first, allowInvalid: true)
          .startsWith('SQLite format 3'),
      'decrypted header',
    );
    final plain = sqlite3.open(decryptedFile.path);
    try {
      _require(
        plain.select('SELECT value FROM probe').single['value'] ==
            'Synthetic cipher test',
        'decrypted data',
      );
    } finally {
      plain.close();
    }
    stage = 'bounded performance';
    final plainRuns = <Map<String, Object?>>[];
    final cipherRuns = <Map<String, Object?>>[];
    for (var run = 0; run < 5; run++) {
      // Alternate order. Same native engine, schema, payload and durability.
      if (run.isEven) {
        plainRuns.add(_benchmark('${directory.path}/plain-$run.sqlite', null));
        cipherRuns.add(_benchmark('${directory.path}/cipher-$run.sqlite', key));
      } else {
        cipherRuns.add(_benchmark('${directory.path}/cipher-$run.sqlite', key));
        plainRuns.add(_benchmark('${directory.path}/plain-$run.sqlite', null));
      }
    }
    return {
      'source': 'sqlite3mc',
      'platform': Platform.operatingSystem,
      'sqliteVersion': sqliteVersion,
      'cipher': cipherName,
      'cipherAvailable': true,
      'walWrite': true,
      'plaintextHeaderAbsent': true,
      'missingKeyRejected': true,
      'wrongKeyRejected': true,
      'wrongKeyPreservedFile': true,
      'correctKeyReopen': true,
      'corruptionRejectedWithoutReset': true,
      'verifiedBackupRecovery': true,
      'explicitDecryptionPreservedData': true,
      'physicalDeviceOrKeyLifecycleVerified': false,
      'benchmark': {
        'rows': 1000,
        'payloadBytesPerRow': 256,
        'runsPerMode': 5,
        'sameEngineUnencrypted': plainRuns,
        'encrypted': cipherRuns,
        'scope': 'local probe; not a production Flutter benchmark',
      },
    };
  } on EncryptionExperimentFailure {
    rethrow;
  } on Object {
    // A raw SQLite error from a failed key PRAGMA could include its SQL key.
    throw EncryptionExperimentFailure(stage);
  } finally {
    await directory.delete(recursive: true);
  }
}
