# Loop Design System — Calm Momentum

## 1. Art direction

Build a modern premium product that looks **specifically designed for practice**, not a fintech clone, SaaS dashboard or gamified streak app. Visual metaphor: a quiet notebook meets precise studio instrumentation. Growth is expressed in linked artifacts and quiet repetition, not loud confetti. Spacious editorial typography; compact useful data; repeated card and progress components; a single lively cobalt highlight; meaningful thumbnails. Inspired by PesoFlow's calming white cards, neutral backgrounds and restrained blue accent, not its banking flows.

**Brand:** Loop (wordmark with a simple open loop mark; do not rely on a generic gradient infinity logo). Give it a tasteful single-color app icon with high legibility at small sizes. Font license and asset attribution recorded; Inter or equivalent high-quality sans with system fallback. Avoid mixing four fonts.

## 2. Color tokens (light / dark)

| Semantic token | Light | Dark | Use |
|---|---|---|---|
| `background` | `#F6F7FA` | `#10131B` | app canvas |
| `surface` | `#FFFFFF` | `#1A1F2A` | elevated content |
| `surfaceAlt` | `#EEF1F6` | `#252B37` | secondary zones |
| `ink` | `#171C28` | `#F2F4F8` | primary text |
| `inkMuted` | `#667085` | `#AEB8CA` | supporting text |
| `line` | `#DCE1E9` | `#3A4250` | borders/dividers |
| `brand` | `#365CF5` | `#86A0FF` | primary actions, key states |
| `brandSoft` | `#E9EEFF` | `#27345C` | background highlights; M02 light adjustment for normal-text AA |
| `success` | `#17795E` | `#6EE7B7` | completed, validated |
| `warning` | `#9A5C13` | `#F8CD88` | storage/permission caution |
| `danger` | `#BA3140` | `#FF9BA6` | destructive action |
| `focus` | `#1652DF` | `#B7C8FF` | keyboard/accessibility focus |

Tokens are **starting recommendations**, validated via WCAG contrast on actual backgrounds; adjust pairings that fail (small text AA contrast ≥4.5:1, large text ≥3:1 where applicable). Do not encode state in color alone. Skill accents: a restrained set (indigo, amber, plum, teal, coral), chosen only for icon/side stripe or small chart series, not every card background.

## 3. Typography, shape, spacing

- Use a deliberate 4pt base / 8pt rhythm with common gaps `4, 8, 12, 16, 20, 24, 32, 40`; no arbitrary jitter.
- Screen horizontal margin: 20 on common phones, 16 on compact, max 720 content width on tablet; respect safe areas and keyboard insets.
- Hero text: 30–34 semibold, line height ~1.12; screen heading: 24–28; section: 18–20; body: 15–16; supporting: 13–14; tiny metadata 12 **only if accessible**.
- Numeric timer is tabular and legible, not a giant neon dial. Large numeric charts use tabular figures.
- Card radius 16, small control radius 10–12, chips radius 999. Surface elevation subtle border/soft shadow, no floating clouds of blur. One consistent shadow.
- Minimum touch target 44×44pt iOS / 48×48dp Android equivalent where applicable; internal hit areas not visually tiny.
- Icon family consistent stroke and sizes 18/20/24; labels beside ambiguous icons.
- Charts must display axis/unit and have an accessible textual alternative.

## 4. Navigation and information hierarchy

Five destinations: Today, Skills, Practice, Progress, Library. Settings from header. Practices and reflection screens are contextual overlays/stack pages, not permanent nested bottom bars. Preserve tab stack and back behavior. Prefer a modest central Practice action, not an enormous FAB hiding content. Use floating keyboard-safe actions only when necessary.

The app's core loop should be obvious:

`I want to practice` → `What am I working on?` → `Start` → `Finish` → `What did I learn?` → `See change` → `Next time`

Top of **Today**: short date/context, focused "Ready to practice?" header, *one* primary current skill card with Start action, one compact overview (e.g. "2 sessions this week") and recent evidence. Don't stack three giant analytics charts above the button.

**Skills**: concise grid or list based on width with visible last practiced, next step and active goal; an empty state. **Practice**: large timer, current exercise, pause/finish, distraction-free. **Progress**: one selected skill and honest history; not five simultaneous charts. **Library**: useful artifact thumbnails, searchable, privacy indicator. **Then-vs-Now**: a distinctive editorial split canvas with transparent dates, no fabricated photo-enhancing filter.

## 5. Component inventory

Create in `lib/shared/design_system/` with usage docs and golden tests:

- `LoopScaffold`, `LoopAppBar`, `LoopBottomNav`, `LoopSectionHeader`.
- `LoopButton` (primary, secondary, text, destructive + all feedback states), `LoopIconButton`.
- `LoopCard`, `SkillCard`, `ExerciseRow`, `SessionRow`, `GoalCard`, `EvidenceTile`.
- `TimerDisplay`, `PracticeControls`, `SessionProgress`, `MetricValue`, `ComparisonPicker`.
- `LoopTextField`, `LoopNumberField`, `LoopChip`, `LoopSegmentedControl`, `LoopDatePicker`.
- `LoopSheet`, `LoopDialog`, `LoopSnackbar`, `LoopToast`, `EmptyState`, `ErrorState`, `PermissionState`, `Skeleton`.
- `TimelineGroup`, `AccessibleMetricChart`, `MediaThumbnail`, `AudioPlaybackBar`, `BeforeAfterImage`.

Never create duplicate button styles per page. Compose with Flutter widgets; shadcn is **web-only inspiration** for the optional site.

## 6. Detailed wireframe specifications

### Today

- Status bar/safe area; date in muted type + concise greeting, settings icon.
- Today's focus: selected skill icon and label, "Next: practice two chord changes" or user-provided next step, primary Start action, tiny secondary change skill.
- This week's activity: three useful figures max: total minutes, sessions, skill count; unit clear.
- Recently practiced: last 3 entries with actual thumbnails/notes, see all link.
- If no skills: generous empty state with Add first skill, no fictitious history. If no sessions: scaffold focus ready and a simple first-run tip.

### Skill detail

- Color accent, name, category, editable context menu.
- Current goal and one next exercise first. A tab or segmented choice between Timeline, Goals, Evidence (no giant nested menus).
- Session cards sorted newest, each clickable; filter date/exercise, clear filter; archive retains history.

### Active practice

- Clear activity name, subtitled skill, `00:00` timer with accessible verbal duration.
- Pause/Resume as prominent action; Finish with confirmation if accidentally tapped; note taking optional while paused.
- Backgrounding auto-pauses; return shows "Paused while you were away". Media recording must stop/pause safely according to OS policy and explicitly inform user.
- Respect user screen timeout policy; do not force wake lock unless justified and battery-aware.

### Finish reflection

- Summary active time with small edit manual control only via explicit change; default no required fields.
- "What got easier?" and "What should you try next?" concise optional prompts; choose metric(s) related to the exercise.
- Camera/import/record controls with explanation; Save and Finish atomic action; retry on storage failure; direct discard option with warning.

### Progress

- Skill filter + range 7d/30d/90d/all; summary accurately scoped.
- Practice frequency: number of sessions by week; metric trend only if comparable data; goals progress with provenance.
- Then-vs-Now teaser using genuine evidence; if insufficient media show add evidence CTA instead of fake comparison.
- Accessibility view lists values and dates and does not require manipulating a chart.

### Before/After media

- Photos: side-by-side mode (default) and draggable reveal on demand, labels `Then · MMM d, yyyy`, `Now · ...`, link to source sessions; test differing aspect ratios and orientation.
- Audio: A and B controlled playback, never autoplay and never play simultaneously, comparable loudness instruction rather than inaccurate loudness normalization promises. Provide notes below.
- Quantitative: delta is displayed with unit, measurement sources and a disclaimer that self-reported values are not verified instrument readings.

### Settings and Data

- Storage card: total files/MB exact, export button, restore button, deletion action clearly separated.
- App transparency: Offline, no account, what leaves device if export shared, requested permissions.
- Theme and appearance, quiet reminders, help/privacy, app version and feedback.

## 7. Required screen states and responsive cases

Each screen has: no-data, normal, loading, persisted error, recoverable permission denied and slow media cases where relevant; large font, reduced motion, keyboard open, long translated text, device rotation, RTL readiness if applicable. Use true app data or deterministic test fixtures; golden images cannot prove real storage integration.

## 8. Motion and tactility

- Button response 100–160ms; navigation/containers around 160–240ms; large modal up to ~280ms. Content appears promptly: animation must not delay input.
- Use opacity/transform where efficient; no constant animated background, noisy particles or oscillating progress indicators. Progress animations correspond to actual changes and can be interrupted.
- New-session completion can use a restrained check and haptic, never mandatory celebration/streak fireworks. Respect accessibility reduced-motion setting and battery/performance budget.
- Audio scrubbing and photo comparison must respond directly to finger position; provide non-drag alternative.

## 9. Aesthetic rejection checklist

Reject: every card in a different pastel; accidental Material defaults mixed with bespoke buttons; too many badges; giant gradient hero; fake graph rise; meaningless 100% mastery gauge; emojis as primary navigation; decorative typing animations; nested scrolling chaos; invisible tap targets; inconsistent icons; overly rounded pills for everything; giant empty hero on a workhorse screen; illegible gray captions.

## 10. Fidelity and review artifacts

At M02 prepare a component gallery and reproducible goldens for each major screen/state using baseline device sizes (e.g. small Android, large Android, iPhone, tablet), light/dark and 200% text. Record artifacts under `docs/verification/design/` in the app repo (unless images are large; store link + hashes and maintain retention). After actual device run, compare screenshot differences and fix. Document contrast, accessibility semantics, tap hit areas and scroll behavior. If external design tools or PesoFlow screenshots are unavailable, don't claim they were used.
