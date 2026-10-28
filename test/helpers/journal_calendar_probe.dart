import 'dart:convert';
import 'dart:io';

import 'package:loop/features/journal/domain/journal_entry.dart';

void main() {
  final spring = DateTime(2026, 3, 8);
  final fall = DateTime(2026, 11, 1);
  stdout.writeln(
    jsonEncode({
      'springHours': JournalFilter.nextLocalDay(spring)
          .toUtc()
          .difference(spring.toUtc())
          .inHours,
      'fallHours': JournalFilter.nextLocalDay(fall)
          .toUtc()
          .difference(fall.toUtc())
          .inHours,
      'leapNext': JournalFilter.nextLocalDay(DateTime(2024, 2, 29))
          .toIso8601String(),
    }),
  );
}
