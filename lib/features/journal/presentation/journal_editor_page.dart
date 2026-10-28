import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/screens/foundation_pages.dart';
import '../../../core/data/local_failure.dart';
import '../../../core/data/database/loop_database.dart';
import '../../../shared/design_system/components.dart';
import '../../practice/presentation/practice_providers.dart';
import '../../skills/presentation/skill_widgets.dart';
import '../domain/journal_entry.dart';
import '../domain/journal_form.dart';
import 'journal_measure_dialog.dart';
import 'journal_form_fields.dart';
import 'journal_providers.dart';

class JournalEditorPage extends ConsumerStatefulWidget {
  const JournalEditorPage({super.key, required this.id, this.editing = false});
  final String id;
  final bool editing;
  @override
  ConsumerState<JournalEditorPage> createState() => _JournalEditorPageState();
}

class _JournalEditorPageState extends ConsumerState<JournalEditorPage> {
  JournalDetail? _detail;
  JournalFormData? _form;
  int _baseRevision = 0;
  bool _loading = true,
      _missing = false,
      _busy = false,
      _choosingReading = false,
      _draftRestored = false,
      _hasStaged = false;
  String? _error;
  final _errorKey = GlobalKey();
  final _note = TextEditingController();
  final _easier = TextEditingController();
  final _next = TextEditingController();
  String get _purpose => widget.editing ? 'edit' : 'finish';
  bool get _manual => _detail?.session.entryMode == 'manual';
  bool get _journalOnly => _detail?.session.manualIntent == 'evidence_only';
  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _note.dispose();
    _easier.dispose();
    _next.dispose();
    super.dispose();
  }

  Future<void> _load({bool discardDraft = false}) async {
    if (mounted)
      setState(() {
        _loading = true;
        _error = null;
      });
    try {
      final repository = ref.read(journalRepositoryProvider);
      final engine = ref.read(practiceEngineProvider);
      var detail = await repository.find(widget.id);
      if (detail == null ||
          widget.editing && detail.session.status != 'completed') {
        if (mounted)
          setState(() {
            _missing = true;
            _loading = false;
          });
        return;
      }
      if (!widget.editing && detail.session.status != 'completed') {
        if (engine.record?.session.id != widget.id &&
            !await engine.select(widget.id))
          throw engine.failure ?? const LocalFailure(LocalFailureKind.conflict);
        if (!await engine.pause(reason: 'reflection'))
          throw engine.failure ??
              const LocalFailure(LocalFailureKind.unavailable);
        detail = (await repository.find(widget.id))!;
      }
      if (discardDraft) {
        final writer = ref.read(journalDraftWriterProvider);
        await writer.flush();
        writer.forget(widget.id, _purpose);
        await repository.clearDrafts(widget.id);
      }
      final draft = discardDraft
          ? null
          : await repository.draft(widget.id, _purpose);
      final checkpoint = (await repository.practice.find(widget.id))
          ?.checkpoint;
      final form = draft == null
          ? JournalFormData.fromDetail(detail, checkpoint: checkpoint)
          : JournalFormData.decode(draft.formJson);
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _form = form;
        _baseRevision = draft?.baseRevision ?? detail!.session.revision;
        _draftRestored = draft != null;
        _hasStaged = false;
        _loading = false;
        _note.text = form.note;
        _easier.text = form.whatGotEasier;
        _next.text = form.nextStep;
      });
    } on Object catch (error) {
      if (mounted)
        setState(() {
          _loading = false;
          _error = storageFailureMessage(error);
        });
    }
  }

  void _stage() {
    if (_form == null || _busy) return;
    _hasStaged = true;
    _form!.note = _note.text;
    _form!.whatGotEasier = _easier.text;
    _form!.nextStep = _next.text;
    ref
        .read(journalDraftWriterProvider)
        .stage(
          sessionId: widget.id,
          purpose: _purpose,
          baseRevision: _baseRevision,
          form: _form!.toJson(),
        );
  }

  void _showError(String message) {
    if (!mounted) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _error = message);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _errorKey.currentContext;
      if (context != null)
        unawaited(Scrollable.ensureVisible(context, duration: Duration.zero));
    });
  }

  Future<void> _saveDraft() async {
    if (_busy || _choosingReading) return;
    if (!_form!.withinDraftLimit) {
      _showError(
        'This reflection is too large to save. Shorten notes or remove readings and try again.',
      );
      return;
    }
    _stage();
    if (!await ref.read(journalDraftWriterProvider).flush())
      _showError(
        'The draft could not be saved. Keep this screen open and try again.',
      );
  }

  Future<void> _leave() async {
    if (_busy || _choosingReading) return;
    setState(() => _busy = true);
    final saved = await ref.read(journalDraftWriterProvider).flush();
    if (!mounted) return;
    setState(() => _busy = false);
    if (!saved) {
      _showError(
        'Your latest draft could not be saved. Keep this screen open and retry after storage is available.',
      );
      return;
    }
    context.go(
      widget.editing
          ? '/sessions/${widget.id}'
          : _manual
          ? '/today'
          : '/practice/active',
    );
  }

  Future<void> _save() async {
    if (_busy || _choosingReading || _form == null || _detail == null) return;
    FocusManager.instance.primaryFocus?.unfocus();
    final form = _form!;
    JournalReflection reflection;
    ManualJournalAmendment? manual;
    try {
      if (!form.withinDraftLimit)
        throw const JournalFormValidation(
          'This reflection is too large to save. Shorten notes or remove readings and try again.',
        );
      reflection = form.reflection(_detail!.definitions);
      if (_manual) {
        final duration = form.duration(journalOnly: _journalOnly);
        final date = form.date();
        final original = _detail!.session;
        final changed =
            duration != original.activeSeconds ||
            form.dateLocal !=
                JournalFormData.dateKey(
                  original.endedAtUtc?.toLocal() ?? DateTime.now(),
                );
        if (!widget.editing || changed) {
          if (!form.manualConfirmed)
            throw const JournalFormValidation(
              'Confirm this date and duration are your own entry.',
            );
          final now = DateTime.now();
          final end = DateTime(
            date.year,
            date.month,
            date.day,
            now.hour,
            now.minute,
            now.second,
          ).toUtc();
          manual = ManualJournalAmendment(
            seconds: duration,
            endedAtUtc: end,
            confirmed: true,
          );
        }
      }
    } on JournalFormValidation catch (error) {
      _showError(error.message);
      return;
    } on Object catch (error) {
      _showError(storageFailureMessage(error));
      return;
    }
    _stage();
    setState(() {
      _busy = true;
      _error = null;
    });
    final writer = ref.read(journalDraftWriterProvider);
    try {
      final persisted = widget.editing
          ? null
          : await ref.read(journalRepositoryProvider).find(widget.id);
      if (persisted?.session.status == 'completed') {
        // Completion may have committed before its response was lost. Do not
        // recreate a finish draft; compare intent against that durable result.
        if (_manual) {
          if (manual!.seconds != persisted!.session.activeSeconds ||
              form.dateLocal !=
                  JournalFormData.dateKey(
                    persisted.session.endedAtUtc!.toLocal(),
                  ))
            throw const LocalFailure(LocalFailureKind.conflict);
          manual = ManualJournalAmendment(
            seconds: manual.seconds,
            endedAtUtc: persisted.session.endedAtUtc!,
            confirmed: true,
          );
        }
        await writer.idle;
        writer.forget(widget.id, _purpose);
      } else if (!await writer.flush()) {
        throw writer.failures[writer.key(widget.id, _purpose)] ??
            const LocalFailure(LocalFailureKind.unavailable);
      }
      if (widget.editing) {
        await ref
            .read(journalRepositoryProvider)
            .amend(
              widget.id,
              expectedRevision: _baseRevision,
              reflection: reflection,
              manual: manual,
            );
      } else {
        final engine = ref.read(practiceEngineProvider);
        if (engine.record?.session.id != widget.id)
          throw const LocalFailure(LocalFailureKind.conflict);
        final saved = _manual
            ? await engine.completeManual(
                seconds: manual!.seconds,
                endedAtUtc: manual.endedAtUtc,
                confirmed: true,
                note: reflection.note,
                reflection: reflection,
              )
            : await engine.finish(reflection: reflection);
        if (!saved)
          throw engine.failure ??
              const LocalFailure(LocalFailureKind.unavailable);
      }
      writer.forget(widget.id, _purpose);
      if (mounted) context.go('/sessions/${widget.id}');
    } on Object catch (error) {
      if (localFailure(error).kind == LocalFailureKind.conflict) {
        try {
          final latest = await ref
              .read(journalRepositoryProvider)
              .find(widget.id);
          if (mounted && latest != null) setState(() => _detail = latest);
        } on Object {
          /* Keep the draft and original safe error. */
        }
      }
      if (mounted) _showError(storageFailureMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _discard() async {
    if (_busy || _choosingReading) return;
    if (!await confirmSkillAction(
          context,
          title: widget.editing
              ? 'Discard these edits?'
              : 'Discard this unfinished entry?',
          message: widget.editing
              ? 'The saved session stays unchanged. This reflection draft will be removed.'
              : 'The unfinished timer, reflection draft and selected exercises will not count as practice.',
          action: widget.editing ? 'Discard edits' : 'Discard entry',
        ) ||
        !mounted)
      return;
    setState(() => _busy = true);
    final writer = ref.read(journalDraftWriterProvider);
    await writer.flush();
    try {
      if (widget.editing)
        await ref.read(journalRepositoryProvider).clearDrafts(widget.id);
      else if (ref.read(practiceEngineProvider).record?.session.id !=
              widget.id ||
          !await ref.read(practiceEngineProvider).discard())
        throw ref.read(practiceEngineProvider).failure ??
            const LocalFailure(LocalFailureKind.unavailable);
      writer.forget(widget.id, _purpose);
      if (mounted)
        context.go(
          widget.editing ? '/sessions/${widget.id}' : '/practice/setup',
        );
    } on Object catch (error) {
      if (mounted) _showError(storageFailureMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _addReading() async {
    if (_busy || _choosingReading) return;
    setState(() => _choosingReading = true);
    try {
      await _chooseReading();
      if (mounted) _stage();
    } on Object catch (error) {
      _showError(storageFailureMessage(error));
    } finally {
      if (mounted) setState(() => _choosingReading = false);
    }
  }

  Future<void> _chooseReading() async {
    if (_detail == null) return;
    final selected = _form!.readings.map((r) => r.definitionId).toSet();
    final latest = <String, MetricDefinition>{};
    for (final d in _detail!.definitions) {
      if (!latest.containsKey(d.id) || d.version > latest[d.id]!.version)
        latest[d.id] = d;
    }
    final chosen = await showDialog<Object>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Add a reading'),
        children: [
          for (final definition in _detail!.definitions.where(
            (d) =>
                identical(latest[d.id], d) &&
                d.archivedAtUtc == null &&
                !selected.contains(d.id),
          ))
            SimpleDialogOption(
              padding: const EdgeInsets.all(16),
              onPressed: () => Navigator.pop(context, definition.id),
              child: Text('${definition.label} · ${definition.unitKey}'),
            ),
          SimpleDialogOption(
            padding: const EdgeInsets.all(16),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Create a measure'),
          ),
          SimpleDialogOption(
            padding: const EdgeInsets.all(16),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (!mounted || chosen == null) return;
    if (chosen == true) {
      final definition = await showDialog<Object>(
        context: context,
        builder: (context) => JournalMeasureDialog(
          skillId: _detail!.skill.id,
          repository: ref.read(journalRepositoryProvider).metrics,
        ),
      );
      if (!mounted || definition == null) return;
      final refreshed = await ref
          .read(journalRepositoryProvider)
          .find(widget.id);
      if (!mounted || refreshed == null) return;
      setState(() => _detail = refreshed);
      // A saved definition is available in the picker; no empty reading is invented.
      await _chooseReading();
      return;
    }
    final definition = _detail!.definitions
        .where((d) => d.id == chosen)
        .reduce((a, b) => a.version > b.version ? a : b);
    setState(
      () => _form!.readings.add(
        JournalReadingForm(
          definitionId: definition.id,
          version: definition.version,
        ),
      ),
    );
    _stage();
  }

  @override
  Widget build(BuildContext context) {
    if (_missing) return const MissingItemPage();
    if (_loading || _detail == null || _form == null)
      return LoopScaffold(
        title: 'Practice journal',
        children: [
          SkillLoadNotice(error: _error, retry: _load),
          if (_error != null)
            LoopButton(
              label: 'Discard reflection draft and reload',
              kind: LoopButtonKind.secondary,
              onPressed: () async {
                if (await confirmSkillAction(
                      context,
                      title: 'Remove this unfinished reflection draft?',
                      message:
                          'The saved session and practice time stay intact.',
                      action: 'Remove draft',
                    ) &&
                    mounted)
                  await _load(discardDraft: true);
              },
            ),
          if (_error != null)
            LoopButton(
              label: 'Back to Today',
              onPressed: () => context.go('/today'),
            ),
        ],
      );
    final detail = _detail!;
    final form = _form!;
    if (!widget.editing && detail.session.status == 'completed')
      return LoopScaffold(
        title: 'Practice journal',
        children: [
          const Text('This practice is already saved.'),
          LoopButton(
            label: 'View saved practice',
            onPressed: () => context.go('/sessions/${widget.id}'),
          ),
        ],
      );
    final writer = ref.watch(journalDraftWriterProvider);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) await _leave();
      },
      child: Theme(
        data: Theme.of(context).copyWith(
          inputDecorationTheme: Theme.of(context).inputDecorationTheme
              .copyWith(helperMaxLines: 8, errorMaxLines: 8),
        ),
        child: LoopScaffold(
          title: widget.editing
              ? 'Edit practice'
              : _manual
              ? (_journalOnly ? 'Journal entry' : 'Manual practice')
              : 'Finish practice',
          actions: [
            IconButton(
              tooltip: 'Keep draft and return',
              onPressed: _busy || _choosingReading ? null : _leave,
              icon: const Icon(Icons.close),
            ),
          ],
          bottomNavigationBar: LoopActionBar(
            child: LoopButton(
              label: widget.editing ? 'Save changes' : 'Save and finish',
              busy: _busy,
              onPressed: _choosingReading ? null : _save,
            ),
          ),
          children: [
            Text(
              detail.skill.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            if (_error != null)
              Semantics(
                key: _errorKey,
                liveRegion: true,
                child: LoopNotice(
                  title: 'Not saved yet',
                  message: _error!,
                  icon: Icons.error_outline,
                ),
              ),
            if (_draftRestored)
              const Text(
                'Your unfinished reflection was restored from this device.',
              ),
            if (widget.editing && _baseRevision != detail.session.revision)
              LoopNotice(
                title: 'This record has a newer revision',
                message: 'Your draft is kept. Saving different values will require reviewing the current record.',
                icon: Icons.history,
                action: LoopButton(
                  label: 'Discard draft and load current record',
                  onPressed: () async {
                    if (await confirmSkillAction(
                          context,
                          title: 'Load current saved record?',
                          message:
                              'This removes only your unfinished edit draft.',
                          action: 'Load current record',
                        ) &&
                        mounted)
                      await _load(discardDraft: true);
                  },
                ),
              ),
            AbsorbPointer(
              absorbing: _busy || _choosingReading,
              child: FocusScope(
                canRequestFocus: !_busy && !_choosingReading,
                child: JournalFormFields(
                  key: ObjectKey(form),
                  id: widget.id,
                  editing: widget.editing,
                  detail: detail,
                  form: form,
                  writer: writer,
                  note: _note,
                  easier: _easier,
                  next: _next,
                  hasStaged: () => _hasStaged,
                  restored: _draftRestored,
                  onChanged: _stage,
                  onSaveDraft: _saveDraft,
                  onAddReading: _addReading,
                  onLeave: _leave,
                  onDiscard: _discard,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
