import '../../../core/data/local_failure.dart';
import '../../../core/data/validation.dart';
import 'skill_kind.dart';
import 'starter_catalog.dart';

class SkillDraft {
  const SkillDraft({
    required this.name,
    required this.kind,
    this.iconKey = 'practice',
    this.accentKey = 'indigo',
    this.description,
    this.practiceMinutes = 10,
    this.includeStarters = true,
    this.firstGoal,
  });
  final String name;
  final SkillKind kind;
  final String iconKey;
  final String accentKey;
  final String? description;
  final int? practiceMinutes;
  final bool includeStarters;
  final String? firstGoal;

  void validate() {
    validName(name);
    validText(description, maximum: 4000);
    if (firstGoal != null && firstGoal!.trim().isNotEmpty) {
      validName(firstGoal!, maximum: 120);
    }
    if (!StarterCatalog.accents.contains(accentKey) ||
        !StarterCatalog.iconKeys.contains(iconKey) ||
        practiceMinutes != null &&
            (practiceMinutes! < 1 || practiceMinutes! > 180)) {
      throw const LocalFailure(LocalFailureKind.invalid);
    }
  }
}
