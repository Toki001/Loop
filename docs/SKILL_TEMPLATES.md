# Skill and measurement template contract — M01

These are starter instructions and optional measurement definitions for future M05/M07 implementation, not fake user histories, observed results or claims of expertise. Copy editable exercise templates once into user-owned records on skill creation with stable template IDs; never overwrite customization on upgrade. Skills may have no goal, no metric and no attachment.

| Skill kind | Starter exercises (suggestions, not prescriptions) | Optional meaningful evidence | Measurement template / unit / direction / bounds |
|---|---|---|---|
| Guitar/instrument | Two-chord transitions; short scale; difficult song section | Short audio or what felt cleaner | Clean changes/min `clean_changes_per_min`, up, ≥0; tempo `bpm`, up or user-defined target, >0; both manually reported unless an approved instrument exists |
| Drawing/visual art | Gesture study; perspective box; value/shading study | Photo, material/reference note | Studies `count`, up, integer ≥0; reference confidence `rating_1_5`, none, ordinal integer 1–5 and explicitly self-rated |
| Language | Recall practice; shadow a short passage; speak freely | Audio or words/context note | Recalled/attempted are separate nonnegative counts with recalled ≤ attempted; derived recall ratio only if attempts >0 and compatible method; speaking duration `seconds`, up, ≥0; confidence ordinal 1–5 |
| Programming | Solve one problem; small project increment; refactor/test | Inert screenshot or text/link; no execution | Problems solved `count`, up, integer ≥0; tests passed `count`, up, integer ≥0, manually entered and labeled with source/test context |
| Singing/voice | Comfortable breath/phrase; repeat melody; song section | Short audio and optional personal observation | Phrase accuracy `rating_1_5`, none, self-rated ordinal 1–5; any pitch-range measure is optional user report with explicitly chosen unit/method, no diagnosis |
| Typing | Short accuracy drill; comfortable speed drill; troublesome keys | Entered external result/screenshot | Speed `wpm`, up, ≥0; accuracy `percent`, up, 0–100; always separate dimensions with tool/method noted, no composite mastery |
| Fitness/movement | Technique rehearsal; comfortable mobility; movement sequence | Note/image; video not in v1 | Sets/repetitions `count`, up or none chosen by user, integer ≥0; manual only, no medical advice/health or wearable inference |
| Custom | User-named exercise, optional instructions/duration | Note/image/audio | User-defined numeric with explicit unit/scale/direction or checklist/text; no automatic scoring or inferred competence |

Each metric stores a stable definition ID, skill ID, immutable version, unit key, numeric/checklist/text type, direction (`up`, `down`, `toward_target`, `none`), optional target/scale and source hint. Readings keep finite value, definition version, measurement/source method, source note and dates. Renaming labels preserves identity; changing unit/meaning creates a new version. Measurements must belong to the session's skill. Custom fields do not bypass finiteness/type/range validation. Counts are nonnegative integers; a legitimate signed custom measure needs its explicit definition, not a universal clamp.

## Honest calculations and edge cases

| Case | Required behavior / future test |
|---|---|
| No reading | Store null/absence, never default to zero; no trend or mastery estimate |
| Same skill/definition/version/unit/source method | Absolute delta permitted, dates/provenance/sample count shown; mismatches rejected |
| Zero baseline | +10 absolute can be shown for 0→10; no division by zero, infinity/NaN or percent |
| Negative baseline | If the definition legitimately permits it, percentage uses `abs(baseline)` and direction is explained |
| Ordinal rating | Show 2/5→4/5; no “100% more skilled” claim |
| Downward measure | A lower error count can be labeled lower, not a green up arrow with reversed meaning |
| Toward-target | Compare distance from the defined target; neither up nor down always means better |
| Accuracy 80→90% | Show +10 percentage points; any relative percent must be explicitly labeled and valid; do not mix with WPM |
| Attempt count zero | No recall/accuracy ratio; show missing denominator and retain raw observations |
| Fewer than two comparable readings | “Not enough measurements yet”; no predictive line or invented improvement |
| Amended/deleted session | Recompute distinct completed IDs/readings; never duplicate previous contribution |
| Qualitative/deliverable goal | Explicit done/undone or checklist state; no fabricated fractional percentage |

Practice duration and effort remain context rather than ability. An external test's pass count is user-entered evidence, not Loop executing or verifying code. No claim of automated musical, visual, language, voice or health assessment is admitted. DATA_AND_METRICS remains the formula/schema authority. Future tests must use deterministic synthetic fixtures, never populate production startup with sample progress.
