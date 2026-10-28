import 'package:flutter/widgets.dart';

import '../../journal/presentation/journal_detail_page.dart';

/// Retained public page name for existing practice routes and tests.
class SavedPracticePage extends StatelessWidget {
  const SavedPracticePage({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context) => JournalDetailPage(id: id);
}
