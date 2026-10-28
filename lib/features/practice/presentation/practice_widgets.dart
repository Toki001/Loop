import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/design_system/components.dart';
import '../../skills/presentation/skill_widgets.dart';
import '../domain/practice_engine.dart';
import 'practice_providers.dart';

class PracticeFailure extends StatelessWidget {
  const PracticeFailure({super.key, required this.engine});
  final PracticeEngine engine;
  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: LoopNotice(
      title: 'Practice needs your attention',
      message:
          '${storageFailureMessage(engine.failure!)} The timer is stopped. Unsaved time is held while this app stays open; only saved checkpoints survive a restart.',
      icon: Icons.error_outline,
    ),
  );
}

class PendingPracticeNotice extends ConsumerWidget {
  const PendingPracticeNotice({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engine = ref.watch(practiceEngineProvider);
    return ListenableBuilder(
      listenable: engine,
      builder: (context, _) => engine.hasUnfinished
          ? LoopNotice(
              title: engine.running
                  ? 'Practice is running'
                  : 'Your unfinished practice',
              message:
                  'Open your saved session. Time resumes only when you choose.',
              icon: Icons.timer_outlined,
              action: LoopButton(
                label: 'Open practice',
                onPressed: engine.busy
                    ? null
                    : () async {
                        if (await engine.openPending() && context.mounted) {
                          context.push('/practice/active');
                        }
                      },
              ),
            )
          : engine.failure != null
          ? PracticeFailure(engine: engine)
          : const SizedBox.shrink(),
    );
  }
}
