import 'package:flutter/widgets.dart';

import '../../journal/presentation/journal_editor_page.dart';
import '../data/practice_repository.dart';

class ManualPracticePage extends StatelessWidget {
  const ManualPracticePage({super.key, required this.record});
  final PracticeRecord record;
  @override
  Widget build(BuildContext context) =>
      JournalEditorPage(id: record.session.id);
}
