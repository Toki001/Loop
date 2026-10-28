import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/design_system/components.dart';
import '../../skills/presentation/skill_widgets.dart';
import '../data/practice_repository.dart';
import '../domain/practice_engine.dart';
import 'practice_providers.dart';

class ManualPracticePage extends ConsumerStatefulWidget {
  const ManualPracticePage({super.key, required this.record});
  final PracticeRecord record;
  @override
  ConsumerState<ManualPracticePage> createState() => _ManualPracticePageState();
}

class _ManualPracticePageState extends ConsumerState<ManualPracticePage> {
  late final TextEditingController _minutes = TextEditingController(
    text: (widget.record.checkpoint?.manualSeconds ?? 0) > 0
        ? '${widget.record.checkpoint!.manualSeconds ~/ 60}'
        : '',
  );
  late final TextEditingController _seconds = TextEditingController(
    text: (widget.record.checkpoint?.manualSeconds ?? 0) % 60 == 0
        ? ''
        : '${widget.record.checkpoint!.manualSeconds % 60}',
  );
  late final TextEditingController _note = TextEditingController(
    text: widget.record.session.note ?? '',
  );
  late final DateTime _originalDate =
      DateTime.tryParse(widget.record.checkpoint?.manualDateLocal ?? '') ??
      DateUtils.dateOnly(DateTime.now());
  late DateTime _date = _originalDate;
  bool _confirmed = false;
  bool _busy = false;
  String? _error;
  int? get _durationSeconds {
    final minutes = _minutes.text.trim().isEmpty
        ? 0
        : int.tryParse(_minutes.text.trim());
    final seconds = _seconds.text.trim().isEmpty
        ? 0
        : int.tryParse(_seconds.text.trim());
    if (minutes == null ||
        seconds == null ||
        minutes < 0 ||
        seconds < 0 ||
        seconds > 59)
      return null;
    return minutes * 60 + seconds;
  }

  String _dateKey(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
  bool get _draftMatches =>
      _note.text == (widget.record.session.note ?? '') &&
      (_journal ? 0 : _durationSeconds) ==
          (widget.record.checkpoint?.manualSeconds ?? 0) &&
      _dateKey(_date) ==
          (widget.record.checkpoint?.manualDateLocal ??
              _dateKey(_originalDate));
  void _stage(PracticeEngine engine) {
    engine.stageDraft(
      _note.text,
      manualSeconds: _journal ? 0 : _durationSeconds ?? -1,
      manualDate: _dateKey(_date),
    );
  }

  bool get _journal => widget.record.session.manualIntent == 'evidence_only';
  @override
  void dispose() {
    _minutes.dispose();
    _seconds.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _save(PracticeEngine engine) async {
    if (_busy || engine.busy) return;
    final duration = _durationSeconds;
    if (!_confirmed ||
        !_journal && (duration == null || duration < 1 || duration > 604800)) {
      setState(
        () => _error =
            'Confirm the date and source${_journal ? '' : ', and enter at least one second and at most 7 days, with seconds from 0 to 59'}.',
      );
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final now = DateTime.now();
    final end = DateTime(
      _date.year,
      _date.month,
      _date.day,
      now.hour,
      now.minute,
      now.second,
    );
    if (await engine.completeManual(
          seconds: _journal ? 0 : duration!,
          endedAtUtc: end.toUtc(),
          confirmed: _confirmed,
          note: _note.text,
        ) &&
        mounted)
      context.go('/sessions/${engine.record!.session.id}');
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    final engine = ref.watch(practiceEngineProvider);
    return SkillEditorFrame(
      title: _journal ? 'Journal entry' : 'Manual practice',
      saveLabel: _journal ? 'Save journal entry' : 'Save manual practice',
      busy: _busy || engine.busy,
      dirty: !_draftMatches || _confirmed,
      onSave: () => _save(engine),
      error:
          _error ??
          (engine.failure == null
              ? null
              : storageFailureMessage(engine.failure!)),
      children: [
        Text(
          _journal ? 'Zero practice minutes' : 'Duration entered by you',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          _journal
              ? 'Save a personal observation without starting a timer. This entry adds no practice time.'
              : 'Enter your active practice, excluding breaks. This duration is entered by you.',
        ),
        if (!_journal)
          TextField(
            controller: _minutes,
            keyboardType: TextInputType.number,
            onChanged: (_) {
              _stage(engine);
              setState(() {});
            },
            decoration: const InputDecoration(
              labelText: 'Practice minutes',
              helperText: '0–10080 minutes. Add seconds below if useful.',
            ),
          ),
        if (!_journal)
          TextField(
            controller: _seconds,
            keyboardType: TextInputType.number,
            onChanged: (_) {
              _stage(engine);
              setState(() {});
            },
            decoration: const InputDecoration(
              labelText: 'Additional seconds',
              helperText:
                  '0–59 seconds. Total duration must be at least one second.',
            ),
          ),
        LoopButton(
          label:
              'Date: ${MaterialLocalizations.of(context).formatMediumDate(_date)}',
          kind: LoopButtonKind.secondary,
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _date.isAfter(DateUtils.dateOnly(DateTime.now()))
                  ? DateUtils.dateOnly(DateTime.now())
                  : _date.isBefore(DateTime(1900))
                  ? DateTime(1900)
                  : _date,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (date != null && mounted) setState(() => _date = date);
            _stage(engine);
          },
        ),
        const Text(
          'The finish time uses the current local time on the selected date. Manual start time is inferred from your entered duration.',
        ),
        TextField(
          controller: _note,
          minLines: 3,
          maxLines: 8,
          maxLength: 100000,
          onChanged: (_) {
            _stage(engine);
            setState(() {});
          },
          decoration: const InputDecoration(
            labelText: 'Note · optional',
            counterText: '',
          ),
        ),
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            _journal
                ? 'I intend to save a journal entry with no practice time.'
                : 'I confirm this duration and date are my own entry.',
          ),
          value: _confirmed,
          onChanged: (value) => setState(() => _confirmed = value ?? false),
        ),
        if (_draftMatches &&
            (_note.text.isNotEmpty || (_durationSeconds ?? 0) > 0))
          Semantics(
            liveRegion: true,
            child: const Text('Draft saved on this device'),
          ),
        LoopButton(
          label: 'Save entry draft',
          kind: LoopButtonKind.secondary,
          onPressed: _busy || engine.busy
              ? null
              : () {
                  _stage(engine);
                  engine.saveNote(_note.text);
                },
        ),
        LoopButton(
          label: 'Discard entry',
          kind: LoopButtonKind.destructiveText,
          onPressed: _busy || engine.busy
              ? null
              : () async {
                  if (await confirmSkillAction(
                        context,
                        title: 'Discard this entry?',
                        message:
                            'This unfinished entry will not count as practice.',
                        action: 'Discard entry',
                      ) &&
                      await engine.discard() &&
                      context.mounted)
                    context.go('/practice/setup');
                },
        ),
      ],
    );
  }
}
