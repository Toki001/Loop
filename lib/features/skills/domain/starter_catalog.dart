import 'skill_kind.dart';

class StarterExercise {
  const StarterExercise(this.id, this.title, this.instructions);
  final String id;
  final String title;
  final String instructions;
}

class StarterMetric {
  const StarterMetric(
    this.label,
    this.unit, {
    this.direction = 'up',
    this.minimum = 0,
    this.maximum,
    this.source = 'manual',
  });
  final String label;
  final String unit;
  final String direction;
  final double minimum;
  final double? maximum;
  final String source;
}

/// Instructions/definitions only. These never represent observed user results.
abstract final class StarterCatalog {
  static const accents = ['indigo', 'amber', 'plum', 'teal', 'coral'];
  static const iconKeys = [
    'practice',
    'music',
    'drawing',
    'language',
    'programming',
    'voice',
    'typing',
    'movement',
  ];

  static String label(SkillKind kind) => switch (kind) {
    SkillKind.music => 'Music',
    SkillKind.drawing => 'Drawing',
    SkillKind.language => 'Language',
    SkillKind.programming => 'Programming',
    SkillKind.voice => 'Singing and voice',
    SkillKind.typing => 'Typing',
    SkillKind.movement => 'Movement',
    SkillKind.custom => 'Custom',
  };

  static String suggestedName(SkillKind kind) => switch (kind) {
    SkillKind.music => 'Guitar',
    SkillKind.voice => 'Singing',
    SkillKind.custom => '',
    _ => label(kind),
  };

  static List<StarterExercise> exercises(SkillKind kind) => switch (kind) {
    SkillKind.music => const [
      StarterExercise(
        'music.chord-transitions.v1',
        'Two-chord transitions',
        'Choose two chords. Move between them at a comfortable pace. Notice one change to repeat next time.',
      ),
      StarterExercise(
        'music.short-scale.v1',
        'A short scale',
        'Choose a familiar scale and a comfortable tempo. Listen for evenness; record a tempo only if useful.',
      ),
      StarterExercise(
        'music.song-section.v1',
        'A difficult song section',
        'Choose a small section. Slow it down, repeat deliberately, and note what became easier.',
      ),
    ],
    SkillKind.drawing => const [
      StarterExercise(
        'drawing.gesture.v1',
        'Gesture study',
        'Choose a subject and explore its gesture. Keep the study as evidence if you want to compare later.',
      ),
      StarterExercise(
        'drawing.perspective.v1',
        'Perspective box',
        'Draw a box from a chosen viewpoint. Note one relationship you want to improve.',
      ),
      StarterExercise(
        'drawing.value.v1',
        'Value and shading study',
        'Choose a simple form. Explore a small value range and note your material or reference.',
      ),
    ],
    SkillKind.language => const [
      StarterExercise(
        'language.recall.v1',
        'Recall practice',
        'Choose familiar words. Try recalling them before checking. Keep recalled and attempted counts separate.',
      ),
      StarterExercise(
        'language.shadowing.v1',
        'Shadow a short passage',
        'Listen to a short passage and repeat at a comfortable pace. Note the passage and one observation.',
      ),
      StarterExercise(
        'language.speaking.v1',
        'Speak freely',
        'Choose a topic and speak for a comfortable interval. Note a phrase to revisit; recording is optional.',
      ),
    ],
    SkillKind.programming => const [
      StarterExercise(
        'programming.problem.v1',
        'Solve one problem',
        'Choose a small problem. Record your approach and the source of any manually entered result.',
      ),
      StarterExercise(
        'programming.project.v1',
        'A small project increment',
        'Choose one observable change. Describe what you tried and what remains; Loop does not execute code.',
      ),
      StarterExercise(
        'programming.refactor.v1',
        'Refactor and test',
        'Choose a small refactor. Use your own tools to verify behavior and note the test context.',
      ),
    ],
    SkillKind.voice => const [
      StarterExercise(
        'voice.phrase.v1',
        'A comfortable phrase',
        'Choose a comfortable phrase and pace. Stop if uncomfortable; this is personal practice, not health guidance.',
      ),
      StarterExercise(
        'voice.melody.v1',
        'Repeat a melody',
        'Choose a short melody. Notice one repeatable change; any rating is your own observation.',
      ),
      StarterExercise(
        'voice.song-section.v1',
        'A song section',
        'Choose a small section and describe what you hear. An optional recording can provide a later reference.',
      ),
    ],
    SkillKind.typing => const [
      StarterExercise(
        'typing.accuracy.v1',
        'A short accuracy drill',
        'Use a familiar tool and passage. Record accuracy separately from speed, with the tool or method.',
      ),
      StarterExercise(
        'typing.speed.v1',
        'Comfortable speed',
        'Use a consistent test method. Record words per minute and accuracy as separate observations.',
      ),
      StarterExercise(
        'typing.keys.v1',
        'Troublesome keys',
        'Choose a few awkward key combinations. Practice comfortably and note what to revisit.',
      ),
    ],
    SkillKind.movement => const [
      StarterExercise(
        'movement.technique.v1',
        'Technique rehearsal',
        'Choose a familiar movement and comfortable effort. Record a personal observation; no diagnosis or scoring.',
      ),
      StarterExercise(
        'movement.mobility.v1',
        'Comfortable mobility',
        'Choose a familiar comfortable movement. Stop if uncomfortable; Loop does not provide medical advice.',
      ),
      StarterExercise(
        'movement.sequence.v1',
        'A movement sequence',
        'Rehearse a familiar sequence. Optional sets or repetitions are manually entered, not wearable measurements.',
      ),
    ],
    SkillKind.custom => const [
      StarterExercise(
        'custom.focused.v1',
        'Focused practice',
        'Choose one small part to practice. Edit these instructions for your own context and repeatable next step.',
      ),
    ],
  };

  static List<StarterMetric> metrics(SkillKind kind) => switch (kind) {
    SkillKind.music => const [
      StarterMetric('Clean changes per minute', 'clean_changes_per_min'),
      StarterMetric('Tempo', 'bpm', minimum: 0.001),
    ],
    SkillKind.drawing => const [
      StarterMetric('Studies completed', 'count'),
      StarterMetric(
        'Reference confidence (self-rated)',
        'rating_1_5',
        direction: 'none',
        minimum: 1,
        maximum: 5,
        source: 'self_rating',
      ),
    ],
    SkillKind.language => const [
      StarterMetric('Words recalled', 'count'),
      StarterMetric('Words attempted', 'count'),
      StarterMetric('Speaking duration', 'seconds'),
    ],
    SkillKind.programming => const [
      StarterMetric('Problems solved (manual)', 'count'),
      StarterMetric('Tests passed (manual)', 'count'),
    ],
    SkillKind.voice => const [
      StarterMetric(
        'Phrase accuracy (self-rated)',
        'rating_1_5',
        direction: 'none',
        minimum: 1,
        maximum: 5,
        source: 'self_rating',
      ),
    ],
    SkillKind.typing => const [
      StarterMetric('Typing speed', 'wpm'),
      StarterMetric('Typing accuracy', 'percent', maximum: 100),
    ],
    SkillKind.movement => const [
      StarterMetric('Repetitions (manual)', 'count'),
    ],
    SkillKind.custom => const [],
  };
}
