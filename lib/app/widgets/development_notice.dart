import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../shared/design_system/components.dart';
import '../l10n/app_localizations.dart';

class DevelopmentNotice extends StatelessWidget {
  const DevelopmentNotice({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();
    final strings = AppLocalizations.of(context)!;
    return LoopNotice(
      title: strings.developmentTitle,
      message: strings.developmentBody,
      icon: Icons.build_outlined,
    );
  }
}
