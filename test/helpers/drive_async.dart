import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

/// Pump real SQLite/native I/O and Flutter's fake-async queue without blocking
/// one queue while awaiting the other. Fail boundedly instead of hanging.
Future<T> driveAsync<T>(WidgetTester tester, Future<T> task) async {
  late T value;
  Object? error;
  StackTrace? trace;
  var done = false;
  unawaited(
    task.then(
      (v) {
        value = v;
        done = true;
      },
      onError: (Object e, StackTrace s) {
        error = e;
        trace = s;
        done = true;
      },
    ),
  );
  final deadline = DateTime.now().add(const Duration(seconds: 8));
  while (!done && DateTime.now().isBefore(deadline)) {
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 5)),
    );
  }
  expect(
    done,
    true,
    reason: 'The actual asynchronous transaction must complete.',
  );
  if (error != null) Error.throwWithStackTrace(error!, trace!);
  return value;
}
