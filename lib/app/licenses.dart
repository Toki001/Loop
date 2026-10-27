import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

bool _registered = false;

/// The SDK bundles the icon font but its generated NOTICES omitted this license
/// in the verified M03 artifact. Preserve the actual SDK license and credit.
void registerLoopLicenses() {
  if (_registered) return;
  _registered = true;
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString(
      'assets/licenses/MaterialIcons_LICENSE.txt',
    );
    yield LicenseEntryWithLineBreaks(
      const ['Material Icons'],
      'Material Icons, distributed with Flutter SDK 3.47.5.\n'
      'Source: https://github.com/flutter/flutter\n'
      'Glyphs unchanged; Loop adjusts display size and color.\n'
      'License supplied by the SDK: CC BY 4.0.\n'
      'https://creativecommons.org/licenses/by/4.0/\n\n$license',
    );
  });
}
