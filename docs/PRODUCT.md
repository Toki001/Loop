# Loop Product Requirements Document (PRD)

## 1. Thesis and positioning

Most practice apps record effort. **Loop records evidence of deliberate practice.** People learn guitar, draw, sing, code, type, learn languages and work on other crafts without a consistent feedback loop. They abandon hobbies because their past efforts disappear into calendars and streak counters. Loop creates a durable story of skill development: intentions, practice, measurable observations, examples of work and the next useful action.

Positioning: *The personal practice journal that makes improvement visible.* Primary audience: self-directed learners aged 16+ (release age rating and data protections reviewed) who have 1–5 active hobbies, short sessions and intermittent motivation. Secondary audience: teachers/coaches using a learner's personally exported portfolio; no coach accounts in v1.

Not: social network, course marketplace, AI tutor, fitness/health diagnostic app, coding IDE, music transcription app or competitive leaderboard.

## 2. First-run experience

**Acceptance journey — first use:** Launch → welcome (skip possible) → pick a suggested skill or Custom → give it an editable name → suggested 10-minute practice plan (can choose 1–180 minutes or untimed) → Start → Pause/Resume → Finish → optional reflection/metric/evidence → Save → Today updates. No account, internet, microphone, photos or notification permission required. Preserve the ≤30s Start target from CODEX and separately report the ≤60s first-use threshold; practice duration is outside time-to-start. Finish-to-saved target is ≤60s. These are design/test targets, not measured results; see [WORKFLOWS.md](WORKFLOWS.md).

**Acceptance journey — next session:** Today surfaces last skill and recommended next exercise, not a manipulative streak. Start again in at most two taps. After multiple sessions, Progress offers changes for comparable metrics and dates; comparison offers two historical artifacts when compatible media exists.

**Acceptance journey — new device:** User chooses export on old device → receives versioned portable archive with manifest and media, with accurately labeled encryption mode → verifies backup → imports into an empty or existing installation on another device with collision-resolution preview → validates counts/hash → atomic commit or full rollback. Optional passphrase encryption requires vetted authenticated crypto/KDF and tested recovery; the ARCHITECTURE plaintext fallback requires explicit warning and owner privacy sign-off before enabling. Explain that app removal without export may irreversibly remove local history; don't mislead about system cloud backups.

## 3. Primary user stories and tests

| ID | As a user I can... | Acceptance |
|---|---|---|
| US-01 | create a skill in 3 steps | no login; custom names; validation; restart persists |
| US-02 | edit/archive/reorder skills | archival retains sessions; no accidental data loss |
| US-03 | set outcomes/targets | quantity, duration or evidence-based goals with target date optional |
| US-04 | choose an exercise | contextual templates, customizable, no false competency labels |
| US-05 | time and pause practice | correct monotonic foreground time; reboot/interruption explained |
| US-06 | log untimed practice | duration entered manually, source marked `manual` |
| US-07 | reflect meaningfully | success/difficulty/next step prompts are optional, not gates |
| US-08 | attach photo/audio to session | permissions on demand; preview, remove, offline persists |
| US-09 | use Then vs. Now | dates, side-by-side images or A/B audio, no manipulated quality claims |
| US-10 | see metrics over time | only comparable same-unit data; no fabricated trend |
| US-11 | view practice history | chronological, filters by skill/date/exercise, quick details |
| US-12 | receive optional reminders | OS time zone behavior; opt-out and permission denial recover |
| US-13 | search entries/media | works offline without indexing data to any server |
| US-14 | export/restore all my data | archive contains media and records; restore transactional |
| US-15 | delete one entry or all local data | confirmation, dependent file cleanup and accurate warning |
| US-16 | use app with accessibility tech | VoiceOver/TalkBack, large type, control labels, contrast |
| US-17 | continue without attachment permission | all core workflows available, placeholders explain alternatives |
| US-18 | edit a completed session | audit source/timestamps; analytics recompute; no duplicate counting |

## 4. Skill taxonomy and domain-appropriate evidence

Define `SkillKind` with built-in categories plus `custom`. All categories use a common session journal but carry optional typed metric templates. Templates editable and not prescriptive. Avoid forcing one universal `level` score.

| Skill | Suggested exercises | Meaningful evidence | Example metric (user-reported unless instrumented) |
|---|---|---|---|
| Guitar/instrument | chord transitions, scales, song sections | short audio clip, chord notes | clean changes/min, tempo bpm, songs learned count |
| Drawing/visual art | gesture sketch, perspective, shading | photographs, side-by-side artwork | studies completed count, reference accuracy 1–5 self-rating |
| Language | shadowing, vocabulary retrieval, speaking | pronunciation audio, note | words recalled/attempted, minutes speaking, self-confidence |
| Programming | algorithms, small project, refactor | code screenshot/photo and text link (no code execution) | problems solved count, tests passed (manual) |
| Singing/voice | breath support, melody repetition | audio takes | song segment accuracy **self-rated**, pitch range optional self-report |
| Typing | focused drills, speed + accuracy | screenshot or entered results | WPM and accuracy %, source of measurement captured |
| Fitness/movement | technique, mobility | notes or video postponed | sets/reps optional; no diagnosis, medical advice or wearables in v1 |
| Custom | custom exercise | text/image/audio | custom numeric, duration or checklist measure |

Metrics must state unit, scale, direction (higher/lower/target range), instrument/source, comparability rules and provenance. An exercise can have zero metrics. User may mark media "baseline" or "milestone" with notes; milestones are meaningful labels, not AI judgments.

## 5. Feature requirements

### Skills, goals, plans

- Create skill: name (1–60 grapheme clusters), kind, icon, color from predefined safe accents, note, activation date, order; uniqueness is not enforced across skills (names may repeat), ID is immutable.
- Goal types: cumulative count, reach value, weekly consistency suggestion, deliverable milestone and qualitative goal; optional due date, no bogus percent completion for qualitative goals; archived goals remain visible.
- Templates: starter per skill, configurable exercises (title, instructions, default seconds, prompt and metric template). Allow duplicate/edit/remove; built-in templates never overwrite user customizations on upgrade.
- 'Next practice' suggests continuation based on last recorded next-step, not generated intelligence. User can override/skip.
- Multiple active skills supported; optional practice targets are guide rails, no penalty on missed days.

### Session lifecycle

State graph: `draft → running ↔ paused → completed` or `draft/running/paused → discarded`. `completed → amended` is represented by revision metadata rather than a new timed session. Prevent duplicate completion across rapid taps and app resumes. Only one active timer globally in v1. On `pause` persist accumulated monotonic duration. On background: auto-pause for reliably counted practice, annotate interrupted; on foreground ask resume. If process is killed, restore a paused draft with last committed accumulated time; never add wall-clock absence to practice time. Manual sessions require deliberate confirmation and are labeled.

Session: skill, exercise(s), start UTC, end UTC, actual active seconds, source (`timed`/`manual`), perceived effort (optional), note, next-step, set of metric readings, media, attachments status, exact creation/update metadata. Multiple short exercises within one session can have allocations; no requirement to force allocation in MVP.

### Timeline and comparisons

Timeline includes session entries with dates, effort, evidence thumbnails, notes, exercise labels, tags and filters; calendar is secondary presentation. Then-vs-Now picker filters by skill and media type; default to oldest vs newest **only with user confirmation**, preserve crop/aspect and honest labels. For photos: side-by-side and manual scrub slider with full view fallback and assistive labels. For audio: A/B controls, progress, equal volume preference; never mix unconsented tracks or claim objective scoring; speed controls deferred unless reliable. Metric compare: show delta only for same skill + metric definition + unit + compatible direction; show absent/mixed data explanation.

### Insights

Display total active duration (with context), sessions, practice distribution, goal progress only when calculable, recent reflections and best/worst metric trends accurately. Show baseline and time horizon chosen. Never compare different skills by a single mastery %; effort and outcome are separate views. At <2 comparable values show "Not enough measurements yet" rather than trend arrows.

### Media

Private image import, in-app camera capture, short audio recording/playback, thumbnail generation, secure local file path references, explicit discard recovery, file quota indication and storage settings. User must be able to practice without media. Video reserved for post-v1 after storage/runtime study. Attachment annotation optional, accessible transcript *manual* note field available.

### Notifications and settings

Per-skill reminders with local times, selected weekdays, preview, one-tap pause-all, Quiet Hours, permission fallback. Settings: theme, time format, week start, units/date preferences, reminder settings, storage usage, help, privacy policy, export/restore, clear data, app version, accessibility tips, feedback link (optional device share sheet). No fake profile/login page.

## 6. Screens: numbered UX inventory

1. Splash/initial load (local migration + recovery).
2. Welcome / why Loop / Skip / privacy promise.
3. Skill picker (suggestions and custom).
4. Skill setup (name, accent, goal optional).
5. Today: contextual greeting, next step, Quick Practice, activity insight, recent session.
6. Skills: compact cards, sort, archived filter, add.
7. Skill Detail: skill header, goals, exercises, timeline and evidence.
8. Add/Edit Goal: type-aware fields and completion semantics.
9. Exercise template list + editor.
10. Practice Ready: choice and optional plan; timer/untimed.
11. Active Practice: timer, progress, pause, minimal controls, lock-screen policy.
12. Finish / Reflection: save, discarded warning, add evidence and metrics.
13. Session Detail/Edit: dates, metrics, attachments and deletion.
14. Progress Overview: skill chooser, ranges and honest computed values.
15. Skill Progress: charts with values, comparison baselines and filters.
16. Then vs Now picker: two media or measurements of same compatible type.
17. Comparison Viewer: image swipe or audio A/B, date labels and details.
18. Library: private media, type and skill filters, full viewer.
19. Search: recent entries/exercises/notes; no remote index.
20. Reminder Scheduler: local schedule and permission states.
21. Settings/Privacy/Storage: export, restore, clear local data.
22. Export/Restore review: progress, counts, errors, collision policy.
23. Accessibility/help/about and empty/error/permission states.

Each screen must define view, user intent, actions, validation, empty/loading/error/success state, data dependencies, accessible semantics and golden test. Screens can reuse modular elements, not bespoke one-off pages.

## 7. Content design / microcopy

- Style: warm, capable, concise, non-judgmental; no exaggerated positivity, guilt or infantilization.
- Today empty: "Your practice starts here" / "Add a skill and make your first session count."
- Without metrics: "A reflection is progress, too. Add a measure when it helps."
- Missed practice: no red broken-streak warnings.
- Comparison: "Choose two moments to see what has changed." Date and source obvious.
- Permission denied: "You can still log this session without a recording." A retry/settings path, not a block.
- Deletion: explicit irreversible scope and count.

## 8. Business and future monetization

Ship **free v1 without a paywall** for learning and trust; all existing data is accessible and exportable. Candidate later: one-time Pro entitlement or subscription after value validation. Do not implement unsupported store payments. Candidate paid extras: advanced charts, enhanced export templates, larger local media library, cross-device sync (needs server), guided programs. Never withhold data export, deletion, essential access, or already-created histories. Before paid release, create entitlement and store receipt verification ADR; cross-device subscription behavior and restore purchases must work under platform rules; pricing, trial terms, cancellation and disclosures reviewed with store policies.

## 9. Release acceptance outcomes

- New installs complete core journey without account/network/permissions.
- Two sessions with comparable evidence show accurate Then-vs-Now.
- App process-kill, phone reboot and timezone change do not manufacture duration.
- Hundreds of entries and media attachments remain navigable and recoverable.
- Privacy, full export/restore, deletion and platform permission behavior verified.
- No UI overflow at 200% text scale and representative small phones.
- Actual Store/Play production readiness and user-approved publishing decision documented.

## 10. Product risks / validation

Interview 8–12 hobbyists across two or more practice disciplines; 5 moderated prototype tests. Measure whether users understand *reflection* vs *timer*, whether prompts are burdensome, ability to find previous artifacts and actual intent to return. Include accessibility and low-end Android. Do not claim retention uplift without data. Use offline-first interviews where telemetry consent is absent.

M01 scope review: [research protocol and hypothetical personas](RESEARCH.md), [workflow/failure contract](WORKFLOWS.md), and [starter exercise/metric definitions](SKILL_TEMPLATES.md) are prepared. Empirical validation is pending: no interviews or participant tests have occurred. Existing v1 scope is frozen for M02–M12 unless an ADR changes it; no material scope change or human research sign-off is claimed. Engineering interpretations and the owner-supplied app identity are in [ADR-011](adr/ADR-011-product-interpretations.md).
