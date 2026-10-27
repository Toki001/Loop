import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/l10n/app_localizations.dart';
import '../../../shared/design_system/components.dart';
import '../../settings/presentation/preferences_controller.dart';

class WelcomePage extends ConsumerWidget {
  const WelcomePage({super.key});

  Future<void> _finish(
    BuildContext context,
    WidgetRef ref,
    String route,
  ) async {
    final saved = await ref
        .read(preferencesProvider.notifier)
        .completeOnboarding();
    if (context.mounted && saved) context.go(route);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context)!;
    final state = ref.watch(preferencesProvider);
    return LoopScaffold(
      bottomNavigationBar: LoopActionBar(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LoopButton(
              label: strings.chooseSkill,
              icon: Icons.arrow_forward,
              busy: state.saving,
              onPressed: state.saving
                  ? null
                  : () => _finish(context, ref, '/skills/new'),
            ),
            const SizedBox(height: 8),
            LoopButton(
              label: strings.skipForNow,
              kind: LoopButtonKind.text,
              onPressed: state.saving
                  ? null
                  : () => _finish(context, ref, '/today'),
            ),
          ],
        ),
      ),
      children: [
        const SizedBox(height: 24),
        Text(
          strings.welcomeTitle,
          style: Theme.of(context).textTheme.displaySmall,
        ),
        Text(strings.welcomeBody, style: Theme.of(context).textTheme.bodyLarge),
        LoopNotice(
          title: strings.privateTitle,
          message: strings.privateBody,
          icon: Icons.lock_outline,
        ),
        if (state.saveFailed)
          Semantics(
            liveRegion: true,
            child: Text(strings.preferencesSaveFailed),
          ),
      ],
    );
  }
}
