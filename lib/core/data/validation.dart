import 'package:characters/characters.dart';
import 'package:uuid/uuid.dart';

import 'local_failure.dart';

String newId() => const Uuid().v4();
DateTime utcNow() => DateTime.now().toUtc();

String validName(String value, {int maximum = 60}) {
  final trimmed = value.trim();
  if (trimmed.isEmpty ||
      trimmed.characters.length > maximum ||
      trimmed.length > 4096) {
    throw const LocalFailure(LocalFailureKind.invalid);
  }
  return trimmed;
}

void validText(String? value, {int maximum = 100000}) {
  if (value != null && value.length > maximum) {
    throw const LocalFailure(LocalFailureKind.invalid);
  }
}

void finite(double? value) {
  if (value != null && !value.isFinite) {
    throw const LocalFailure(LocalFailureKind.invalid);
  }
}

void requireChanged(int count) {
  if (count != 1) throw const LocalFailure(LocalFailureKind.notFound);
}
