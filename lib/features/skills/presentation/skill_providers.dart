import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/data/storage.dart';
import '../data/skill_management_repository.dart';

final skillManagementProvider = Provider<SkillManagementRepository>(
  (ref) => ref.watch(storageProvider).skillManagement,
);

final skillCardsProvider = StreamProvider.autoDispose
    .family<List<SkillCardData>, bool>(
      (ref, archived) =>
          ref.watch(skillManagementProvider).watchCards(archived: archived),
    );

final skillDetailProvider = StreamProvider.autoDispose
    .family<SkillDetailData?, String>(
      (ref, id) => ref.watch(skillManagementProvider).watchDetail(id),
    );
