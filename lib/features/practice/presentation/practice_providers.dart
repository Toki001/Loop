import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/storage.dart';
import '../data/practice_repository.dart';
import '../domain/practice_engine.dart';
import '../domain/practice_clock.dart';

final practiceRepositoryProvider = Provider<PracticeRepository>(
  (ref) => PracticeRepository(ref.watch(storageProvider).database),
);
final practiceClockProvider = Provider<PracticeClock>(
  (ref) => StopwatchPracticeClock(),
);
final practiceTickingProvider = Provider<bool>((ref) => true);

final practiceEngineProvider = Provider<PracticeEngine>((ref) {
  final engine = PracticeEngine(
    ref.watch(practiceRepositoryProvider),
    clock: ref.watch(practiceClockProvider),
    ticking: ref.watch(practiceTickingProvider),
  );
  final listener = AppLifecycleListener(
    onStateChange: (state) {
      unawaited(engine.setForeground(state == AppLifecycleState.resumed));
    },
  );
  final state = WidgetsBinding.instance.lifecycleState;
  if (state != null && state != AppLifecycleState.resumed)
    unawaited(engine.setForeground(false));
  unawaited(engine.initialize());
  ref.onDispose(() {
    listener.dispose();
    engine.dispose();
  });
  return engine;
});

/// Initializes recovery/lifecycle observation before any route can start time.
class PracticeLifecycleHost extends ConsumerWidget {
  const PracticeLifecycleHost({
    super.key,
    required this.child,
    this.onEngineReady,
  });
  final Widget child;
  final ValueChanged<PracticeEngine>? onEngineReady;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engine = ref.watch(practiceEngineProvider);
    onEngineReady?.call(engine);
    return child;
  }
}
