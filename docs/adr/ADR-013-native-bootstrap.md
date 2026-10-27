# ADR-013 — Native bootstrap, preferences and verification

**Date:** 2026-10-27. **Status:** accepted engineering implementation within M03. No production signing, store identity availability or legal/brand approval is implied.

## Context

M03 needs real native navigation, saved appearance, localization and recoverable startup before M04 introduces the journal database. The owner supplied the permanent identity. Preview fixtures must remain outside application startup. Existing SDKs are available; external CI has no approved repository/runner connection.

## Decision

Use `com.jameskierdoliguez.loop` for Android namespace/application ID and all three iOS app build configurations; `Loop` is the native and localized display name. Tests use the derived `.RunnerTests` ID. Keep version/build in pubspec and checked constants for the acknowledgments page. Verify identity consistency automatically and recheck store availability before publication, never rename silently.

Pin Flutter 3.47.5/revision and Dart 3.13.4 via `.flutter-version`, `tool/toolchain.json` and executable verification. Commit both package lockfiles. Keep Android API 24 minimum, compile/target 36, iOS 15 minimum, Gradle 9.3.1 (official SHA-256), AGP 9.1.0, Kotlin 2.4.0 and Java bytecode 17. Local Flutter selects Studio JDK 25; Gradle 9.3.1 supports it. PATH Java 26 is unsuitable for this Gradle version. Do not mutate global Java/Flutter configuration.

Bootstrap resolves app-private application support storage through `path_provider`, reads a bounded versioned preferences file, then injects the repository and committed settings into Riverpod. This preferences-only file has no skills, sessions or evidence. M04 must preserve/import it transactionally when introducing the settings table; it cannot silently reset existing appearance/onboarding. Writes serialize, flush to a same-directory temporary file, then rename. This is an atomic file replacement on the supported native filesystems, not a promise of survival under every power-loss/storage-controller failure. Unknown v1 fields survive known-field edits. Unsupported schemas stay intact. Damaged preferences can be reset explicitly only after copying the original; journal/media paths are never reset by this control. Failures become typed UI state immediately, including retry, rather than an unhandled future or raw path/stack trace.

Use a stable `GoRouter` provider and `StatefulShellRoute.indexedStack` for five tabs. Restoration IDs preserve tab/route state; appearance updates never replace the router. Settings is pushed above the shell and returns to the same tab. First-install links pass through skippable onboarding; completing/skip persists the choice before navigation. This foundation deliberately returns to the chosen onboarding action, rather than opening an unverified incoming record afterward. Missing/unknown records have an honest recovery page without echoing incoming identifiers. Active-session links redirect to setup while no draft repository exists. Later session milestones must replace this guard with durable draft validation and unsaved-change behavior. No authentication, external URL scheme, associated domain or verified App Link is introduced; external links await an owner-controlled domain and security review.

English ARB localization includes dates and navigation; native Material localization delegates support future locales. Reuse the accepted design system, keyboard resizing, safe areas and large-text navigation sheet. Retail startup imports no preview fixture. Incomplete feature actions remain absent; a debug-only notice explains current capabilities. The six staged capability flags remain false until their respective functional milestones. A release build cannot show the debug notice.

Use a single fail-fast `tool/ci.py` for local and provisioned CI verification, including frozen design goldens and selected native builds/device integration. The optional GitHub workflow requires an explicitly provisioned owner-controlled Mac runner and a later authorized push; it cannot run on untrusted pull requests, installs no SDK/tools, uses read-only repository permission, retains no credentials and uploads no artifacts. No hosted/remote CI success is inferred from a local run.

## Alternatives and tradeoffs

Deferring all preferences until M04 would leave M03 theme persistence unimplemented. Adding a second preferences plugin would increase native dependencies for a tiny file and would still require recovery/version handling. Starting Drift early would combine milestones. The narrow file repository is temporary bootstrap infrastructure with explicit migration responsibility. Same-process read/rename safety and repository serialization are tested; hostile concurrent modification inside a compromised sandbox is outside this boundary.

Self-hosted CI configuration avoids silently installing tools or connecting a service. It requires owner runner setup before a remote status check can exist. Local execution remains reproducible and records actual command exits. Device release gates and physical Android/iPhone checks are unchanged.

## Data/security impact

Only appearance/onboarding are stored. No login, telemetry, crash SDK, service credential, upload or production runtime permission is added. Debug Android retains Flutter tooling's Internet permission; merged artifact permissions must be recorded separately from source declarations. Native icons are original project vector rasterizations with exact path/hash provenance; brand/trademark clearance remains open. Release signing is unset, never debug signing. Encryption, backup exclusions, OS file protection and journal recovery remain M04 requirements; no blanket encryption claim is made.
