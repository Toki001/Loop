import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'local date bounds use 23 and25-hour DST days and calendar leap boundaries',
    () async {
      final result = await Process.run(
        'dart',
        [
          '--suppress-analytics',
          'run',
          'test/helpers/journal_calendar_probe.dart',
        ],
        environment: {'TZ': 'America/New_York'},
      );
      expect(result.exitCode, 0, reason: result.stderr.toString());
      final data = jsonDecode(result.stdout.toString()) as Map<String, dynamic>;
      expect(data['springHours'], 23);
      expect(data['fallHours'], 25);
      expect(data['leapNext'], '2024-03-01T00:00:00.000');
    },
  );
}
