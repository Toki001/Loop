import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/onboarding/presentation/welcome_page.dart';
import '../features/settings/presentation/preferences_controller.dart';
import '../features/settings/presentation/settings_page.dart';
import '../shared/design_system/components.dart';
import 'l10n/app_localizations.dart';
import 'screens/foundation_pages.dart';

final initialLocationProvider = Provider<String>((ref) => '/today');
final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: ref.read(initialLocationProvider),
    restorationScopeId: 'loop-routes',
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final seen = ref.read(preferencesProvider).value.onboardingSeen;
      if (!seen && state.uri.path != '/onboarding') return '/onboarding';
      if (state.uri.path == '/practice/active') return '/practice/setup';
      return null;
    },
    errorBuilder: (context, state) => const MissingItemPage(),
    routes: [
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const WelcomePage(),
      ),
      StatefulShellRoute.indexedStack(
        restorationScopeId: 'loop-tabs',
        builder: (context, state, navigationShell) =>
            _AppShell(shell: navigationShell),
        branches: [
          for (final destination in FoundationDestination.values)
            StatefulShellBranch(
              restorationScopeId: 'tab-${destination.name}',
              routes: [
                GoRoute(
                  path: destination == FoundationDestination.practice
                      ? '/practice/setup'
                      : '/${destination.name}',
                  name: destination.name,
                  builder: (context, state) =>
                      FoundationPage(destination: destination),
                ),
              ],
            ),
        ],
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: '/settings/privacy',
        name: 'privacy',
        builder: (context, state) => const PrivacyPage(),
      ),
      GoRoute(
        path: '/practice/active',
        redirect: (context, state) => '/practice/setup',
      ),
      GoRoute(
        path: '/practice/review/:id',
        builder: (context, state) => const MissingItemPage(),
      ),
      GoRoute(
        path: '/skills/:id',
        builder: (context, state) => const MissingItemPage(),
      ),
      GoRoute(
        path: '/sessions/:id',
        builder: (context, state) => const MissingItemPage(),
      ),
      GoRoute(
        path: '/progress/:id',
        builder: (context, state) => const MissingItemPage(),
      ),
      GoRoute(
        path: '/compare',
        builder: (context, state) => const MissingItemPage(),
      ),
    ],
  );
  ref.listen<bool>(
    preferencesProvider.select((value) => value.value.onboardingSeen),
    (_, _) => router.refresh(),
  );
  ref.onDispose(router.dispose);
  return router;
});

class _AppShell extends StatelessWidget {
  const _AppShell({required this.shell});
  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return Scaffold(
      body: shell,
      bottomNavigationBar: LoopBottomNav(
        index: shell.currentIndex,
        navigateLabel: strings.navigate,
        labels: [
          strings.today,
          strings.skills,
          strings.practice,
          strings.progress,
          strings.library,
        ],
        onChanged: (index) =>
            shell.goBranch(index, initialLocation: index == shell.currentIndex),
      ),
    );
  }
}
