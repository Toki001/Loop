import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:loop/core/data/local_failure.dart';
import 'package:loop/core/media/private_files.dart';

Matcher _failure(LocalFailureKind kind) =>
    throwsA(isA<LocalFailure>().having((e) => e.kind, 'kind', kind));

void main() {
  late Directory directory;
  late PrivateFiles files;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('loop-private-files-');
    files = await PrivateFiles.open(Directory('${directory.path}/private'));
  });
  tearDown(() => directory.delete(recursive: true));

  test(
    'streamed copy produces opaque private path and a verified checksum',
    () async {
      final bytes = List<int>.generate(200000, (i) => i % 256);
      final stored = await files.write(
        Stream.fromIterable([bytes.sublist(0, 100000), bytes.sublist(100000)]),
      );
      expect(stored.byteLength, bytes.length);
      expect(stored.sha256, sha256.convert(bytes).toString());
      expect(
        (await (await files.read(stored)).expand((chunk) => chunk).toList()),
        bytes,
      );
      expect(
        await Directory('${files.root.path}/staging').list().toList(),
        isEmpty,
      );
    },
  );

  test(
    'zero, oversize and failed input never promote a partial file',
    () async {
      await expectLater(
        files.write(const Stream.empty()),
        _failure(LocalFailureKind.invalid),
      );
      await expectLater(
        files.write(Stream.value([1, 2, 3]), maxBytes: 2),
        _failure(LocalFailureKind.invalid),
      );
      await expectLater(
        files.write(
          Stream.error(
            const FileSystemException('synthetic unavailable input'),
          ),
        ),
        _failure(LocalFailureKind.unavailable),
      );
      expect(await files.mediaPaths().toList(), isEmpty);
      expect(
        await Directory('${files.root.path}/staging').list().toList(),
        isEmpty,
      );
    },
  );

  test('checksum mismatch rejects import, mutation and truncation', () async {
    await expectLater(
      files.write(
        Stream.value([1, 2]),
        expectedSha256: List.filled(64, '0').join(),
      ),
      _failure(LocalFailureKind.checksum),
    );
    final stored = await files.write(Stream.value([1, 2]));
    await File('${files.root.path}/${stored.relativePath}')
        .writeAsBytes([2, 1]);
    await expectLater(
      files.verify(stored),
      _failure(LocalFailureKind.checksum),
    );
    await File('${files.root.path}/${stored.relativePath}').writeAsBytes([1]);
    await expectLater(files.read(stored), _failure(LocalFailureKind.checksum));
  });

  for (final path in [
    '../outside',
    '/media/x',
    'media/../../x',
    'media/x\\y',
    'media/%2e%2e/x',
    'media//x',
    'file:///x',
    'media/x\u0000.blob',
  ]) {
    test('reject untrusted path ${path.replaceAll('\u0000', 'NUL')}', () async {
      await expectLater(
        files.delete(path),
        _failure(LocalFailureKind.unsafePath),
      );
    });
  }

  test(
    'symlinked file cannot read, overwrite or delete its outside target',
    () async {
      final outside = await File('${directory.path}/outside')
          .writeAsBytes([8, 9]);
      final stored = await files.write(Stream.value([1, 2]));
      final path = '${files.root.path}/${stored.relativePath}';
      await File(path).delete();
      await Link(path).create(outside.path);
      await expectLater(
        files.verify(stored),
        _failure(LocalFailureKind.unsafePath),
      );
      await expectLater(
        files.delete(stored.relativePath),
        _failure(LocalFailureKind.unsafePath),
      );
      expect(await outside.readAsBytes(), [8, 9]);
    },
  );

  test('symlinked private directory cannot expose external storage', () async {
    final outside = await Directory('${directory.path}/outside').create();
    await Directory('${files.root.path}/media').delete();
    await Link('${files.root.path}/media').create(outside.path);
    await expectLater(
      files.write(Stream.value([1])),
      _failure(LocalFailureKind.unsafePath),
    );
    expect(await outside.list().toList(), isEmpty);
    await expectLater(
      PrivateFiles.open(Directory('${files.root.path}/media')),
      _failure(LocalFailureKind.unsafePath),
    );
  });

  test(
    'unavailable staging preserves original media and allows retry',
    () async {
      final original = await files.write(Stream.value([4, 5]));
      await Directory('${files.root.path}/staging').delete();
      final obstruction = await File('${files.root.path}/staging')
          .writeAsString('synthetic obstruction');
      await expectLater(
        files.write(Stream.value([6, 7])),
        _failure(LocalFailureKind.unsafePath),
      );
      await files.verify(original);
      await obstruction.delete();
      await files.write(Stream.value([6, 7]));
      expect(await files.mediaPaths().toList(), hasLength(2));
    },
  );

  test('missing evidence is typed and deletion is idempotent', () async {
    final stored = await files.write(Stream.value([1]));
    await files.delete(stored.relativePath);
    await files.delete(stored.relativePath);
    await expectLater(
      files.verify(stored),
      _failure(LocalFailureKind.notFound),
    );
  });
}
