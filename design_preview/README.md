# Loop native design review harness

This package renders **synthetic design fixtures only**. It is not a practice timer, private media store or finished Loop application. Every screen identifies itself as a design preview; explanatory interactions never claim data saved. Root `lib/shared/design_system` contains reusable native primitives with no fixture dependency. This harness imports the root SDK-only Flutter package; M03 adds the actual Android/iOS app separately.

Ten representative screens: Welcome, Today, Skills, Practice, Finish, Progress, Then-vs-Now, Library, Settings and Components. Four shared states: empty, loading, storage error and permission denied. Screen/state selectors are development controls. All 23 screen contracts, data/recovery/accessibility states and remaining component patterns are in [SCREEN_DESIGN.md](../docs/SCREEN_DESIGN.md).

From the repository root, with the verified Flutter 3.47.5 / Dart 3.13.4 SDK:

```sh
flutter --suppress-analytics pub get --offline
cd design_preview
flutter --suppress-analytics pub get --offline
flutter --suppress-analytics analyze --no-pub
flutter --suppress-analytics test --no-pub
```

No third-party direct runtime package is added: Flutter SDK, its locked test transitives and local root path dependency only. Offline resolution uses the existing SDK/package cache. Flutter cache/service access may need the host's approved execution path. The root package has no product main/native platform project yet; this is deliberate M02 scope, not a bootable production shell.

Goldens are native widget renders at compact Android 320×568, large Android 412×915, iPhone-like 390×844 and tablet 768×1024, both light/dark and 100%/200% text. Ten screens plus four recovery states yield 224 images, plus one deterministic simulated-keyboard reference. Tests additionally verify contrast, reachable large-type navigation and practice/finish controls, keyboard activation/hit target, verbal timer semantics and reduced-animation handling. No render proves real camera/audio, storage, timekeeping, OS permission behavior or physical platform usability.

Initial baseline creation uses `flutter --suppress-analytics test --no-pub --update-goldens`, followed by visual review, provenance hashes and a run **without** that flag. Do not automatically accept future differences. Pin SDK/renderer and review source/fixture changes before regenerating. Reference PNGs live in [design artifacts](../docs/verification/design/README.md); no user media is included.

Production typography follows the platform system font (no redistributed custom font). Native golden tests are pinned to macOS and explicitly load Roboto/MaterialIcons from the installed Flutter SDK plus the existing OS Hiragino Sans GB font for the Unicode fixture. Installed license records are Roboto Apache 2.0 and MaterialIcons CC BY 4.0; the OS font is used locally only. No font is copied or redistributed; see [asset attribution](../docs/ASSET_ATTRIBUTION.md). A different renderer/font platform needs separately reviewed references, not auto-acceptance. Procedural study artwork and open-loop vector mark are original project code. Preview dates/notes/counts/artwork are synthetic and must not enter release startup, marketing testimonials or claims of real user improvement.
