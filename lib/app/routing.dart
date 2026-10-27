import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/onboarding/presentation/welcome_page.dart';
import '../features/settings/presentation/preferences_controller.dart';
import '../features/settings/presentation/settings_page.dart';
import '../features/skills/domain/skill_kind.dart';
import '../features/skills/presentation/exercise_editor_page.dart';
import '../features/skills/presentation/goal_editor_page.dart';
import '../features/skills/presentation/skill_detail_page.dart';
import '../features/skills/presentation/skill_editor_page.dart';
import '../features/skills/presentation/skills_page.dart';
import '../shared/design_system/components.dart';
import 'l10n/app_localizations.dart';
import 'screens/foundation_pages.dart';

final initialLocationProvider = Provider<String>((ref) => '/today');
final routerProvider = Provider<GoRouter>((ref) {
  final rootNavigator = GlobalKey<NavigatorState>();
  final router = GoRouter(
    navigatorKey: rootNavigator,
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
                  builder: (context, state) => switch (destination) {
                    FoundationDestination.skills => const SkillsPage(),
                    FoundationDestination.today => const SkillContextPage(
                      practice: false,
                    ),
                    FoundationDestination.practice => const SkillContextPage(
                      practice: true,
                    ),
                    _ => FoundationPage(destination: destination),
                  },
                  routes: destination != FoundationDestination.skills
                      ? []
                      : [
                          GoRoute(
                            path: 'new',
                            parentNavigatorKey: rootNavigator,
                            builder: (context, state) =>
                                const SkillCategoryPage(),
                            routes: [
                              GoRoute(
                                path: 'setup',
                                parentNavigatorKey: rootNavigator,
                                builder: (context, state) => SkillEditorPage(
                                  kind:
                                      SkillKind.values
                                          .where(
                                            (kind) =>
                                                kind.name ==
                                                state
                                                    .uri
                                                    .queryParameters['kind'],
                                          )
                                          .firstOrNull ??
                                      SkillKind.custom,
                                ),
                              ),
                            ],
                          ),
                          GoRoute(
                            path: ':id',
                            parentNavigatorKey: rootNavigator,
                            builder: (context, state) => SkillDetailPage(
                              id: state.pathParameters['id']!,
                            ),
                            routes: [
                              GoRoute(
                                path: 'edit',
                                parentNavigatorKey: rootNavigator,
                                builder: (context, state) => SkillEditorPage(
                                  id: state.pathParameters['id']!,
                                ),
                              ),
                              GoRoute(
                                path: 'goals/new',
                                parentNavigatorKey: rootNavigator,
                                builder: (context, state) => GoalEditorPage(
                                  skillId: state.pathParameters['id']!,
                                ),
                              ),
                              GoRoute(
                                path: 'goals/:goalId/edit',
                                parentNavigatorKey: rootNavigator,
                                builder: (context, state) => GoalEditorPage(
                                  skillId: state.pathParameters['id']!,
                                  id: state.pathParameters['goalId']!,
                                ),
                              ),
                              GoRoute(
                                path: 'exercises/new',
                                parentNavigatorKey: rootNavigator,
                                builder: (context, state) => ExerciseEditorPage(
                                  skillId: state.pathParameters['id']!,
                                ),
                              ),
                              GoRoute(
                                path: 'exercises/:exerciseId/edit',
                                parentNavigatorKey: rootNavigator,
                                builder: (context, state) => ExerciseEditorPage(
                                  skillId: state.pathParameters['id']!,
                                  id: state.pathParameters['exerciseId']!,
                                ),
                              ),
                            ],
                          ),
                        ],
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
