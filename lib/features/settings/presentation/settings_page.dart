import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/build_info.dart';
import '../../../app/l10n/app_localizations.dart';
import '../../../shared/design_system/components.dart';
import '../domain/preferences.dart';
import 'preferences_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = AppLocalizations.of(context)!;
    final state = ref.watch(preferencesProvider);
    final controller = ref.read(preferencesProvider.notifier);
    return LoopScaffold(
      title: strings.settings,
      children: [
        LoopSectionHeader(title: strings.appearance),
        Text(strings.appearanceBody),
        LoopCard(
          padding: 4,
          child: RadioGroup<Appearance>(
            groupValue: state.value.appearance,
            onChanged: (value) {
              if (value != null && !state.saving)
                controller.setAppearance(value);
            },
            child: Column(
              children: [
                for (final option in [
                  (Appearance.system, strings.systemAppearance),
                  (Appearance.light, strings.lightAppearance),
                  (Appearance.dark, strings.darkAppearance),
                ])
                  RadioListTile<Appearance>(
                    value: option.$1,
                    title: Text(option.$2),
                    enabled: !state.saving,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (state.saving)
          Semantics(liveRegion: true, child: Text(strings.savingPreferences)),
        if (state.saveFailed)
          LoopNotice(
            title: strings.preferencesSaveFailed,
            message: strings.appearanceBody,
            icon: Icons.error_outline,
            action: LoopButton(
              label: strings.retry,
              onPressed: controller.retry,
            ),
          ),
        LoopCard(
          child: Column(
            children: [
              LoopListRow(
                title: strings.privacy,
                subtitle: strings.privateTitle,
                icon: Icons.lock_outline,
                onTap: () => context.push('/settings/privacy'),
              ),
              const Divider(),
              LoopListRow(
                title: strings.licenses,
                subtitle:
                    '${LoopBuildInfo.displayName} ${LoopBuildInfo.versionLabel}',
                icon: Icons.info_outline,
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: strings.appTitle,
                  applicationVersion: LoopBuildInfo.versionLabel,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
