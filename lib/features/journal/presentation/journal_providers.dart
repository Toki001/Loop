import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/storage.dart';
import '../../../core/data/database/loop_database.dart';
import '../data/journal_repository.dart';
import '../domain/journal_draft_writer.dart';
import '../domain/journal_entry.dart';

final journalRepositoryProvider = Provider<JournalRepository>(
  (ref) => JournalRepository(ref.watch(storageProvider).database),
);
final journalDraftWriterProvider = Provider<JournalDraftWriter>((ref) {
  final writer = JournalDraftWriter(ref.watch(journalRepositoryProvider));
  final listener = AppLifecycleListener(
    onStateChange: (state) {
      if (state != AppLifecycleState.resumed) unawaited(writer.flush());
    },
  );
  ref.onDispose(() {
    listener.dispose();
    writer.dispose();
  });
  return writer;
});
final journalDetailProvider = StreamProvider.autoDispose
    .family<JournalDetail?, String>(
      (ref, id) => ref.watch(journalRepositoryProvider).watchDetail(id),
    );
final recentJournalProvider = StreamProvider.autoDispose<List<JournalSummary>>(
  (ref) => ref
      .watch(journalRepositoryProvider)
      .watchTimeline(const JournalFilter(limit: 3)),
);
final skillJournalProvider = StreamProvider.autoDispose
    .family<List<JournalSummary>, String>(
      (ref, id) => ref
          .watch(journalRepositoryProvider)
          .watchTimeline(JournalFilter(skillId: id, limit: 20)),
    );

final journalTimelineProvider = StreamProvider.autoDispose
    .family<List<JournalSummary>, JournalFilter>(
      (ref, filter) =>
          ref.watch(journalRepositoryProvider).watchTimeline(filter),
    );
final journalSkillsProvider = StreamProvider.autoDispose<List<Skill>>(
  (ref) => ref.watch(journalRepositoryProvider).watchSkills(),
);
final journalExerciseTitlesProvider = StreamProvider.autoDispose
    .family<List<String>, String?>(
      (ref, skillId) => ref
          .watch(journalRepositoryProvider)
          .watchExerciseTitles(skillId: skillId),
    );

final journalOverviewProvider = StreamProvider.autoDispose<JournalOverview>(
  (ref) => ref.watch(journalRepositoryProvider).watchOverview(),
);
