import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/settings/domain/preferences.dart';
import '../features/settings/presentation/preferences_controller.dart';
import '../shared/design_system/tokens.dart';
import 'l10n/app_localizations.dart';
import 'routing.dart';

class LoopApp extends ConsumerWidget {
  const LoopApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearance = ref.watch(
      preferencesProvider.select((state) => state.value.appearance),
    );
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      restorationScopeId: 'loop-app',
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: LoopTheme.build(Brightness.light),
      darkTheme: LoopTheme.build(Brightness.dark),
      themeMode: switch (appearance) {
        Appearance.system => ThemeMode.system,
        Appearance.light => ThemeMode.light,
        Appearance.dark => ThemeMode.dark,
      },
      themeAnimationDuration: const Duration(milliseconds: 160),
      routerConfig: ref.watch(routerProvider),
    );
  }
}
