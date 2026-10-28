# Native foundation and boot lifecycle

M03 introduces the actual product entrypoint. Earlier M02 renders remain a separate, synthetic design harness. See [ADR-013](adr/ADR-013-native-bootstrap.md) for decisions and [M03 verification](verification/M03.md) for actual command/device results. This shell is not a finished practice journal.

## Identity and version

| Surface | Established value |
|---|---|
| Android namespace/application ID | `com.jameskierdoliguez.loop` |
| iOS app bundle ID, Debug/Profile/Release | `com.jameskierdoliguez.loop` |
| iOS test target | `com.jameskierdoliguez.loop.RunnerTests` |
| Native display name / localized app title | Loop |
| Initial version/build | `0.1.0+1` |
| Runtime pins | [toolchain.json](../tool/toolchain.json), [.flutter-version](../.flutter-version), both package lockfiles |

The owner supplied these identifiers on 2026-10-27. Never change them without approval. A successful local build does not establish App Store/Play availability or trademark clearance. Verify those at the release gate. No signing team, release keystore or production credential is configured. Android release signing is deliberately unset.

## Boot and durable settings

The steps below describe the original M03 foundation. M04 supersedes file-only settings with [Drift/private persistence](PERSISTENCE.md): native protection/exclusions, transactional retained-file import, SQL-backed preferences and non-destructive database recovery. The original M03 report/artifacts remain historical. The current CI also checks generated Drift output, schema fixtures and backup XML. Physical Android storage/process tests became available in M04; physical iPhone and release gates remain pending.

1. `lib/main.dart` initializes Flutter bindings and a generic error widget without raw exception text, then starts `BootstrapHost`.
2. Bootstrap resolves the native application-support directory through `path_provider`. While waiting it shows a truthful local-loading state.
3. `FilePreferencesRepository` loads `preferences.json`, a bounded schema-v1 JSON file containing appearance and onboarding choice. An absent file is a legitimate first install. No skills, timer, metrics or history are seeded.
4. Bootstrap injects the repository and committed preferences into Riverpod, then builds localized `LoopApp` and its stable router. A save applies to UI state only after the flushed temporary file is renamed successfully; failed saves retain the prior choice and offer retry.
5. Damaged settings show recovery. Explicit reset copies the original to an opaque recovery filename before replacing only preferences. Unknown schema versions cannot be reset by this UI. Unavailable storage offers retry. No path or internal error is shown. M04 must migrate these preferences without loss when adding Drift/settings; journal recovery remains separate.

This file replacement protects the old value against ordinary write failure and is serialized within the repository. It is not an absolute guarantee against device power loss or failing storage hardware. Preferences are not app-encrypted. M04 defines OS protection/backup policy for the wider data model.

## Navigation and boundaries

| Path | Current behavior |
|---|---|
| `/onboarding` | Choose a skill or skip; persist onboarding choice, then navigate |
| `/today`, `/skills`, `/practice/setup`, `/progress`, `/library` | Five retained tab branches, honest empty states, actual Settings navigation |
| `/settings` | Real system/light/dark preference, retry, privacy information and license acknowledgments |
| `/settings/privacy` | Current local-first behavior and OS backup/share caveat |
| `/practice/active` | Redirect to setup while no durable active draft exists |
| Missing skill/session/review/progress/comparison or unknown route | Recover to Today; no incoming identifier is echoed |

M05 supersedes the original guarded skill paths with owned setup. M06 adds real practice setup, active draft and persisted saved-summary routes; [M06 verification](verification/M06.md) passes local acceptance, including physical Android lifecycle and separate-process recovery. The application-owned lifecycle host observes foreground state before routing and drains queued practice writes before bootstrap closes SQL. Full reflection/history/media/export routes remain gated. Current native normal-main installs and schema4/process-retention evidence are recorded separately from M03's historical shell results.

Fresh-install routes pass through onboarding. Current onboarding finishes at its chosen action, rather than replaying an unverified record link. Settings pushes over the shell; Back returns to the retained tab. Restoration IDs retain tab/route state without constructing a session. External App Links/Universal Links/custom schemes are not registered; a domain, ownership verification and link-security policy are prerequisites.

Foundation screen content, dates and navigation labels use English ARB/delegates; shared captions, M05 editor/catalog/goal feedback and the emergency error fallback also remain English. Adding a locale requires extracting/translating those captions and testing layouts. Native widgets reuse M02 tokens and primitives. At 200% text, the bottom bar exposes the accessible navigation sheet and direct Practice action. Safe areas, scrollable content and keyboard resizing follow the design contract. The product imports no `design_preview` code. [M05](verification/M05.md) exposes functional owned skill/goal/exercise setup, and Welcome's Choose a skill opens its category picker directly. Session/media/reminder/export controls remain gated by their functional milestones; the explanatory capability notice is debug-only.

## Reproducible local and CI verification

Use the preinstalled pinned SDK; this project does not install agent plugins or change global tool settings. `flutter pub get --enforce-lockfile` resolves the reviewed runtime packages. Generated native wrapper/cache files remain ignored; Flutter provides its Gradle wrapper during build and the distribution is checksum-pinned.

```sh
python3 tool/ci.py --android --ios
python3 tool/ci.py --android --ios --device DEDICATED_SIMULATOR_ID
```

The common entrypoint runs SDK/native identity checks, enforced locks, license-source inventory, formatting, strict root/preview analysis, application unit/widgets, frozen M02 goldens, documentation/privacy provenance checks and selected native builds. The optional device argument adds the real foundation integration test. It stops on the first failed check and records command exits in ignored `build/verification/ci.json`; a selected subset is never described as the full suite.

Goldens require the pinned macOS renderer/fonts recorded in [ARTIFACTS.json](verification/design/ARTIFACTS.json); do not auto-update them in CI. Native Android builds require the installed API 36 SDK, compatible JDK and accepted licenses. iOS builds require installed Xcode/iOS SDK/runtime; simulator builds need no production signing. Android runtime testing requires an actual device or preconfigured AVD. Never silently install an emulator image, accept new legal terms or substitute browser rendering for a native device test.

[The optional workflow](../.github/workflows/verify.yml) calls the same script on an owner-provisioned Mac runner with `loop-toolchain-3.47.5`. There is no approved remote or connected runner yet. A later authorized connection/push is required to execute it; local checks cannot prove a remote status. It has read-only contents permission, a pinned official checkout revision, no persisted credentials, no pull-request trigger, SDK installation, artifact upload or publication step. The simulator test remains available locally or on an explicitly selected CI device; no physical-device coverage is inferred.

The integration test uses actual application support storage and UI writes, traverses all tabs, chooses Dark, then creates a fresh bootstrap/provider graph and verifies the persisted theme/onboarding choice. It creates no journal fixtures or network dependency. The explicit dedicated-device CI option uses `--no-uninstall`, preserving its test app/preferences for a separate product build/install and process-relaunch check; Flutter otherwise uninstalls the test app and its data by default. Separate process termination/relaunch and screenshots, when performed, are recorded in M03; the test alone does not claim a process kill.

M07 final explicit-main Android/iOS debug builds are installed and reopened on the connected physical Android and all three existing iOS simulators, preserving settings/counts and upgrading to schema5 without reset. Four normal-product OS frames show the owner-directed expressive UI; Android system bars follow the app theme. Separate isolated journal stages verify complete reflection/readings through distinct processes on Android and retained iOS; see [M07](verification/M07.md). No native performance, physical-iPhone, signing or release claim follows.
