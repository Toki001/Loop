import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

import '../data/local_failure.dart';

class StoredFile {
  const StoredFile(this.relativePath, this.byteLength, this.sha256);
  final String relativePath;
  final int byteLength;
  final String sha256;
}

class _DigestSink implements Sink<Digest> {
  Digest? value;
  @override
  void add(Digest data) => value = data;
  @override
  void close() {}
}

/// All paths are private, flat and generated here; original names are not used.
class PrivateFiles {
  PrivateFiles._(this.root);
  final Directory root;
  static final _mediaPath = RegExp(
    r'^media/[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\.blob$',
  );

  static Future<PrivateFiles> open(Directory directory) => guardLocal(() async {
    final type = await FileSystemEntity.type(
      directory.path,
      followLinks: false,
    );
    if (type != FileSystemEntityType.notFound &&
        type != FileSystemEntityType.directory) {
      throw const LocalFailure(LocalFailureKind.unsafePath);
    }
    await directory.create(recursive: true);
    final store = PrivateFiles._(
      Directory(await directory.resolveSymbolicLinks()),
    );
    for (final child in ['media', 'staging']) {
      await store._directory(child);
    }
    return store;
  });

  static void validateMediaPath(String path) {
    if (!_mediaPath.hasMatch(path)) {
      throw const LocalFailure(LocalFailureKind.unsafePath);
    }
  }

  Future<Directory> _directory(String name) async {
    if (await FileSystemEntity.type(root.path, followLinks: false) !=
            FileSystemEntityType.directory ||
        await root.resolveSymbolicLinks() != root.path) {
      throw const LocalFailure(LocalFailureKind.unsafePath);
    }
    final directory = Directory(p.join(root.path, name));
    final type = await FileSystemEntity.type(
      directory.path,
      followLinks: false,
    );
    if (type != FileSystemEntityType.notFound &&
        type != FileSystemEntityType.directory) {
      throw const LocalFailure(LocalFailureKind.unsafePath);
    }
    await directory.create();
    if (!p.isWithin(root.path, await directory.resolveSymbolicLinks())) {
      throw const LocalFailure(LocalFailureKind.unsafePath);
    }
    return directory;
  }

  /// Checks database and sidecar names too; SQLite must never follow a link.
  Future<File> databaseFile() => guardLocal(() async {
    await _directory('media');
    for (final name in [
      'loop.sqlite',
      'loop.sqlite-wal',
      'loop.sqlite-shm',
      'loop.sqlite-journal',
    ]) {
      await _ordinary(File(p.join(root.path, name)));
    }
    return File(p.join(root.path, 'loop.sqlite'));
  });

  Future<void> _ordinary(File file) async {
    final type = await FileSystemEntity.type(file.path, followLinks: false);
    if (type != FileSystemEntityType.notFound &&
        type != FileSystemEntityType.file) {
      throw const LocalFailure(LocalFailureKind.unsafePath);
    }
  }

  Future<File> _resolve(String relativePath) async {
    validateMediaPath(relativePath);
    await _directory('media');
    final file = File(p.join(root.path, relativePath));
    await _ordinary(file);
    return file;
  }

  /// Streams bytes without decoding them. M08 validates image/audio formats.
  Future<StoredFile> write(
    Stream<List<int>> source, {
    int maxBytes = 100 * 1024 * 1024,
    String? expectedSha256,
  }) => guardLocal(() async {
    if (maxBytes <= 0) throw const LocalFailure(LocalFailureKind.invalid);
    final staging = await _directory('staging');
    final id = const Uuid().v4();
    final relative = 'media/$id.blob';
    final temporary = File(p.join(staging.path, '$id.part'));
    final destination = await _resolve(relative);
    if (await temporary.exists() || await destination.exists()) {
      throw const LocalFailure(LocalFailureKind.conflict);
    }
    RandomAccessFile? output;
    var promoted = false;
    final digest = _DigestSink();
    final hasher = sha256.startChunkedConversion(digest);
    var count = 0;
    try {
      output = await temporary.open(mode: FileMode.write);
      await for (final chunk in source) {
        if (chunk.length > maxBytes - count) {
          throw const LocalFailure(LocalFailureKind.invalid);
        }
        count += chunk.length;
        hasher.add(chunk);
        await output.writeFrom(chunk);
      }
      hasher.close();
      if (count == 0) throw const LocalFailure(LocalFailureKind.invalid);
      final checksum = digest.value.toString();
      if (expectedSha256 != null && checksum != expectedSha256) {
        throw const LocalFailure(LocalFailureKind.checksum);
      }
      await output.flush();
      await output.close();
      output = null;
      await _resolve(relative);
      await temporary.rename(destination.path);
      promoted = true;
      return StoredFile(relative, count, checksum);
    } finally {
      await output?.close();
      if (!promoted) {
        await _ordinary(temporary);
        if (await temporary.exists()) await temporary.delete();
      }
    }
  });

  Future<void> verify(StoredFile expected) => guardLocal(() async {
    final file = await _resolve(expected.relativePath);
    if (!await file.exists())
      throw const LocalFailure(LocalFailureKind.notFound);
    if (await file.length() != expected.byteLength ||
        (await sha256.bind(file.openRead()).first).toString() !=
            expected.sha256 ||
        await file.length() != expected.byteLength) {
      throw const LocalFailure(LocalFailureKind.checksum);
    }
  });

  /// Reader gets a validated stream, never a public storage path.
  Future<Stream<List<int>>> read(StoredFile expected) => guardLocal(() async {
    await verify(expected);
    return (await _resolve(expected.relativePath)).openRead();
  });

  Future<void> delete(String relativePath) => guardLocal(() async {
    final file = await _resolve(relativePath);
    if (await file.exists()) await file.delete();
  });

  /// Discovery does not delete unknown files or follow directory links.
  Stream<String> mediaPaths() async* {
    final directory = await _directory('media');
    await for (final entry in directory.list(followLinks: false)) {
      final relative = 'media/${p.basename(entry.path)}';
      if (entry is File && _mediaPath.hasMatch(relative)) yield relative;
    }
  }
}
