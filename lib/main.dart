import 'package:flutter/material.dart';

import 'bootstrap.dart';
import 'app/licenses.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  registerLoopLicenses();
  // Unexpected build failures do not expose stack traces or private paths in UI.
  ErrorWidget.builder = (_) => const Material(
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Loop could not display this screen. Reopen the app to try again. Your saved history has not been reset.',
            ),
          ),
        ),
      ),
    ),
  );
  runApp(const BootstrapHost());
}
