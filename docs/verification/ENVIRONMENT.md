# Development environment baseline — 2026-10-27

Evidence: [per-command capture](evidence/M00/environment-commands.json), [source-kit hashes](evidence/M00/source-kit.json), [tool audit](TOOLS.md). Dates use Asia/Manila. Committed records replace personal installation paths with variables. Invoke portable commands from the repository root; resolve `FLUTTER_SDK` and `ANDROID_SDK_ROOT` locally rather than copying another machine's paths.

## Initial workspace

The root directory is named `loop`. Initial inspection found **21 Markdown files only**: 4 root contract/readme files, 13 specifications in `docs/`, and 4 prompts. No `.git`, app source, pubspec, lockfile, native project, CI configuration, assets or tests existed. Initial `git status --short --branch` and `git log` exited 128 (not a Git repository). Source hashes were captured before edits. No PesoFlow screenshots/source were available or inspected.

`git init -b milestone/00-baseline` first failed with “Operation not permitted” on `.git`; the host approved the narrowly scoped elevated retry under the user's explicit local-commit authorization. Initialization succeeded. Existing Git author name/email are configured; no identity was invented. No custom hooks path, signing requirement or init template was configured. No remote was created or contacted for Loop; GitHub public upstream reads are separate from configuring Loop CI. Host-approved diagnostic retries also completed Flutter doctor and simulator discovery; the initial failures below remain in the record.

## Toolchain inventory

| Component | Observed state | Capability / limitation |
|---|---|---|
| Host | macOS 26.6.2 build 25G83, arm64 | Version output, not device compatibility proof |
| Flutter | **3.47.5 stable**, framework revision `6a19cca56475dbfba1478ee68d7bd0c2ef891da1`; metadata, SDK Git and doctor agree | Initial sandbox version/doctor exit 1 on cache writes. Approved elevated `doctor -v` and concise `doctor` both exit 0, “No issues found”. SDK available for M03; no project build validated |
| Dart | Direct cached SDK binary reports **3.13.4 stable**, macos_arm64 | Direct `dart --version` succeeds; PATH Dart wrapper uses Flutter bootstrap and is not separately operationally validated |
| Xcode | **27.0**, build **27A266a**; selected Xcode developer dir | `xcodebuild -version` succeeds; iPhoneOS and simulator SDK queries report 27.0 with sandbox/cache warnings. No app compilation/signing tested |
| CocoaPods | **1.17.0** | Version command succeeds; no Pods/project resolved |
| Android SDK | Platform-tools **37.0.1**; emulator **37.1.11**; command-line tools **23.0**; platforms API 35, 36 and android-37.0; build-tools 36.0.0; NDK 28.2.13676358; CMake 3.22.1 | Approved doctor marks Android toolchain healthy and all Android licenses accepted. Actual Gradle/project compatibility not yet tested. SDK utilities are not on PATH; use resolved SDK paths |
| JDK on PATH | Oracle **26.0.1** | Version succeeds; do not assume compatible with future Gradle/AGP |
| Android Studio bundled JDK | OpenJDK **25.0.3** | Version succeeds; select supported build JDK in M03 after Gradle/AGP verification |
| Android emulator | `emulator -list-avds` exits 0 with no entries; AVD directory empty | No configured AVD; no native testing target provisioned or launched |
| Android device discovery | Initial `adb devices -l` exits 1: smartsocket listener denied; approved doctor starts the existing ADB daemon successfully and lists no Android devices | No Android target connected during successful discovery; physical hardware availability outside the session remains unknown |
| iOS simulator discovery | Initial `simctl` fails (exit 1); approved `xcrun simctl list devices available` exits 0 | 23 existing simulators across iOS 18.2 and 27.0, all Shutdown. Representative compact iPhone SE (3rd generation), large iPhone 16 Pro Max and iPads exist. No simulator booted or app tested; device IDs and custom names omitted |
| Physical iPhone | None reported by approved doctor; no physical device verified | No pairing/signing/account access attempted; remains a beta hardware gate |
| Node / npm | **22.23.4 / 10.9.9** | Available for discovery; no JS app or new packages installed |
| Git / Python | **2.55.0 / 3.14.7** | Baseline source control and stdlib checker available |
| GitHub CLI / CI | `gh` exists; no local workflow/remote/provider configuration | No authentication probe or CI run; Flutter CI is M03 |

## Supported platform baseline (D-02)

For planning, choose **Android 7.0 / API 24 minimum** and **iOS 15 minimum**, native arm64 targets first. These are the lower ends of the currently documented [Flutter 3.47 mobile support](https://docs.flutter.dev/reference/supported-platforms). Retaining this broad coverage is an engineering default rather than an adoption claim; audience/device research is still pending. No known oldest-supported physical device is available in this session. M03 must validate all selected native plugins, JDK/Gradle/AGP, SDK and minimum-OS smoke before encoding build settings; a needed minimum-OS increase requires a recorded decision and owner scope review.

Minimum deployment OS is separate from build/target policy. As checked on 2026-10-27, [Google Play's requirement](https://developer.android.com/google/play/requirements/target-sdk) is target API **36+** for new mobile apps/updates since August 31, 2026. Plan compile/target API 36 or higher supported by the verified toolchain; no target is encoded yet. [Apple's requirements](https://developer.apple.com/news/upcoming-requirements/) specify Xcode 26+/iOS 26 SDK for uploads since April 28, 2026, and iOS 13+ deployment target since September 9, 2026. Installed version numbers meet those numeric floors; submission compatibility has not been tested. Recheck current policies in M03 and M14; do not treat this dated baseline as permanent approval.

## Future package baseline and checks

No application dependencies were installed, selected or locked. Binding choices remain Flutter stable, Riverpod, go_router and Drift/SQLite with private media. All other packages in ARCHITECTURE are candidates requiring maintenance/license/native compatibility review when implemented. The verified M00 SDK baseline is Flutter 3.47.5/Dart 3.13.4 at the revision above; a source-controlled SDK pin and pubspec belong to M03, after confirming app/plugin build compatibility. M03 commits the lockfile after `pub get`, `pub outdated`, format, analyze, tests and native build/smoke succeed.

M00 does not run app `pub get`, analysis, unit/widget/golden/integration tests, APK/AAB/iOS release builds or screenshots: there is no application to exercise. They are **NOT APPLICABLE to the discovery milestone / NOT RUN**, and remain required at their owning milestones. Native device access, signing, policy and release checks remain visibly open in [TRACEABILITY.md](TRACEABILITY.md).

Before M03, use the host-approved SDK-cache/service access or an owner-prepared supported runner. Re-run Flutter version/doctor; validate a compatible JDK with generated Gradle/AGP; configure and boot an authorized Android AVD or connect an owner-provided Android device; choose an existing iOS simulator. Physical Android/iPhone gates remain open. Do not auto-install SDKs, accept licenses, pair devices, change global permissions or sign builds under discovery authorization. See [final diagnostic evidence](evidence/M00/diagnostics-final.json) for the successful retries.
