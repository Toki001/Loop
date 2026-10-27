import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../shared/design_system/components.dart';
import '../../shared/design_system/tokens.dart';
import '../l10n/app_localizations.dart';
import '../widgets/development_notice.dart';

enum FoundationDestination { today, skills, practice, progress, library }

class FoundationPage extends StatelessWidget {
  const FoundationPage({super.key, required this.destination});
  final FoundationDestination destination;

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    final (title, heading, message, icon) = switch (destination) {
      FoundationDestination.today => (
        strings.today,
        strings.todayEmptyTitle,
        strings.todayEmptyBody,
        Icons.today_outlined,
      ),
      FoundationDestination.skills => (
        strings.skills,
        strings.skillsEmptyTitle,
        strings.skillsEmptyBody,
        Icons.layers_outlined,
      ),
      FoundationDestination.practice => (
        strings.practice,
        strings.practiceEmptyTitle,
        strings.practiceEmptyBody,
        Icons.play_circle_outline,
      ),
      FoundationDestination.progress => (
        strings.progress,
        strings.progressEmptyTitle,
        strings.progressEmptyBody,
        Icons.insights_outlined,
      ),
      FoundationDestination.library => (
        strings.library,
        strings.libraryEmptyTitle,
        strings.libraryEmptyBody,
        Icons.photo_library_outlined,
      ),
    };
    return LoopScaffold(
      title: title,
      actions: [
        IconButton(
          tooltip: strings.settings,
          onPressed: () => context.push('/settings'),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
      children: [
        if (destination == FoundationDestination.today)
          Text(
            strings.dateLabel(DateTime.now()),
            style: Theme.of(context).textTheme.bodySmall,
          ),
        LoopNotice(
          title: heading,
          message: message,
          icon: icon,
          action:
              destination == FoundationDestination.today ||
                  destination == FoundationDestination.practice
              ? LoopButton(
                  label: strings.seeSkills,
                  onPressed: () => context.go('/skills'),
                )
              : null,
        ),
        const DevelopmentNotice(),
      ],
    );
  }
}

class MissingItemPage extends StatelessWidget {
  const MissingItemPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return LoopScaffold(
      title: strings.appTitle,
      children: [
        LoopNotice(
          title: strings.missingTitle,
          message: strings.missingBody,
          icon: Icons.info_outline,
          action: LoopButton(
            label: strings.backToToday,
            onPressed: () => context.go('/today'),
          ),
        ),
      ],
    );
  }
}

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context)!;
    return LoopScaffold(
      title: strings.privacy,
      children: [
        Icon(
          Icons.lock_outline,
          color: LoopPalette.of(context).brand,
          size: 32,
        ),
        Text(strings.privacyBody, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }
}
