# Quality, Test Strategy and Non-Functional Gates

## 1. Test pyramid

- **Pure unit:** duration/state machine, goals, metric comparability, timezone grouping, media filename validation, archives/manifest parsing, restore transaction and merge collision resolver.
- **Repository/integration (local):** Drift CRUD, migrations on real SQLite engine, FK constraints, transaction rollback, media reconciler, state after restart, duplicate save prevention.
- **Flutter widget:** screen actions, routing, form validation, accessibility semantics, all empty/error states, large text, responsive layouts, theme.
- **Golden:** approved designs for small Android/large Android/iPhone-like surfaces, light/dark, dynamic text scale, comparison viewer; animation excluded or stabilized deterministically.
- **End-to-end on emulator/device:** install, onboarding, skill/goal/exercise CRUD, timer interrupts, record audio, take photo, background/foreground, process kill, export/restore, delete-all, notification scheduling, app upgrade.
- **Manual usability/accessibility:** TalkBack/VoiceOver, permission handling, battery saver, low storage, app switcher, phone call interruptions, screen rotation and offline mode.
- **Security/negative tests:** malicious archive/path traversal, malformed media, file size and memory bounds, privacy/sdk declaration.

## 2. Mandatory test cases by product area

| Area | P0/P1 representative acceptance scenarios |
|---|---|
| First run | fresh empty install; no signup; airplane mode; no permissions |
| Skill CRUD | duplicate names, long Unicode, archive with history, add/edit/deletion semantics |
| Goals | numeric vs qualitative progress, unit and measure compatibility, edit/reach/overachieve |
| Timer | fast double-tap, interruption, background, kill, reboot, DST, negative time impossible |
| Reflection | save empty note, large note, keyboard exit, validation, retry on full disk |
| Media | no permission, rotate image, 0byte corrupt, large, phone call during recording |
| Then-vs-Now | 0/1/2 assets, wrong kind, delete one asset, playing two audios, drag accessible |
| Timeline/progress | cross-week grouping, timezone shift, no samples, filter, edit recompute |
| Reminders | app notifications denied, time zone change, repeated schedule, cancellation |
| Export | missing file, out of space, corrupt checksum, ZIP slip, archive version unsupported |
| Restore | fresh install, merge into populated app, duplicate IDs, rollback and retry |
| Accessibility | 200% text, semantic labels, screen reader focus, contrast, reduced motion |
| Release | reproducible builds, no debug flags, correct app version, proper store assets |

## 3. Automated commands and evidence

Run with actual SDK/toolchain and capture exit code:

```bash
flutter doctor -v
flutter pub get
flutter pub outdated
dart format --output=none --set-exit-if-changed lib test integration_test
flutter analyze
flutter test test/unit
flutter test test/widget
flutter test test/golden
flutter test
flutter test integration_test -d <verified-device-id>
flutter build apk --release
flutter build appbundle --release
flutter build ios --release
```

Commands may need adjustment to match created paths and SDK. No CI credential injection or account connection without approval. `flutter test` doesn't prove permissions or app-store readiness; actual hardware required for final acceptance. Pin exact CI environment and capture deterministic results. Keep skipped tests visible and classify platform blockers.

## 4. Gates per merge/phase

**Feature gate:** relevant unit+widget tests green, contracts respected, no analyzer warnings, practical accessibility, data migration tested if schema touched, verification log updated.

**Milestone gate:** feature gate plus UX screenshot/behavior evidence for touched screens, error-state review, device smoke on available targets, privacy impact and no release placeholders. One good-quality commit per milestone; blocked milestones have no false completion.

**Beta gate:** full fresh-install and upgrade paths; high-risk E2E test suite on Android emulator + a physical low/midrange device, iOS simulator + physical iPhone if targeting iOS; manual real microphone/camera and permission scenarios; export/restore round-trip; unsigned/public metadata warnings closed; 0 P0/P1.

**Public gate:** store-ready binary, release-signing provenance, versioning, tested rollback/update procedure, up-to-date privacy disclosures, approved screenshots/listings, opt-in action from owner, staged rollout monitoring and incident support.

## 5. Performance and reliability objectives

Benchmarks must be measured in release/profile mode and include dataset shape. Provisional targets: cold-start p95 <2.5s on named midrange device; list interaction smooth near 60fps on supported devices; timer clock drift <2s over 30min foreground test when compared to monotonic source; no background time counted; 1,000 sessions and ~2,000 thumbnails memory-bounded; archive of realistic 500MB corpus exported/imported or document safe cap; crash-free beta sessions ≥99.5% **only if instrumented with user consent or derived from authorized beta reports**, no unsupported guarantee. Watch startup I/O, DB indexes, image decoder memory and audio session cleanup.

## 6. Accessibility minimum

Respect OS large text (at least 200%), semantic naming and focus order, tap targets, screen-reader usable timer (announce at sensible cadence, not every second), accessible photo comparison alternate controls, audio A/B controls and timeline text alternatives, color contrast AA for normal text, reduced motion, no color-only meaning, haptic not sole feedback. Test on VoiceOver, TalkBack and keyboard/switch navigation where available. Fix blockers prior to beta.

## 7. Device matrix

| Device type | Representative checks | Status |
|---|---|---|
| Android compact/low RAM | keyboard, offline, media, timeline perf, battery saver | TBD actual hardware |
| Android midrange physical | recorder permission, camera, process kill, export/share | TBD actual hardware |
| Android recent emulator | repeatable integration suite and accessibility | TBD |
| iPhone simulator | navigation, layout, archive, golden parity | TBD |
| iPhone physical | microphone, camera, interruptions, Files export/import, reminders | TBD actual hardware |
| Tablet (iPad or Android) | responsive max width, landscape, navigation | TBD if launch supports |

No claim of "iOS tested" based solely on simulator build. Define exact supported Android/iOS OS versions during M00 and cross-check store targets in M14.

## 8. CI design

- PR: format, analyzer, pure unit, repository tests, widget/goldens with baseline diffs, dependency audit and secret scan.
- Main: integration on supported emulator when feasible, Android APK/AAB build; iOS archive only in provisioned macOS environment; artifacts contain no private sample recordings.
- Tags: manually approved version bump, release notes/changelog, immutable build/commit hashes, checksums and staged distribution.
- Recovery: failed pipeline blocks merge/release; rollback to previous signed store version or corrective update, acknowledging app store constraints. Database migrations should remain forward-safe; user data not arbitrarily rolled back.

## 9. Defect classification

P0: data loss or unauthorized recording/exposure, app launch blocking, archive exploit, invalid totals misrepresenting essential record. P1: major common use case broken, media inaccessible after restart, unusable permission state, severe accessibility blocker. P2: nonblocking visual defect or rare edge case with workaround. P3: polish. No P0/P1 at public launch; P2 can be accepted with explicit owner sign-off and public-facing impact assessment.

## 10. Golden/UI proof is not functional proof

Screenshot match only verifies pixels; it does not verify state persistence, timer correctness, export integrity, accessible navigation or OS permissions. Every screen needs a corresponding behavioral acceptance case and every important behavior needs an E2E route. Do not mark a milestone complete by presenting static Stitch/HTML screenshots.
