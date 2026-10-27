# ADR-012 — Native design harness and accessible control layout

**Date:** 2026-10-27. **Status:** accepted local engineering decision for M02 under continuous execution authorization. Product scope, stack and final owner identity are unchanged. Brand/legal/physical-device acceptance is not implied.

## Context

M02 needs native visual evidence before M03 creates the product shell. Dart package imports cannot reach a shared library using invalid relative URIs from another package. Small-screen 200% text and keyboard tests also need real reachable actions, not merely absence of overflow exceptions.

## Decision

Create an SDK-only root Flutter package for `lib/shared/design_system` now and a separate development-only `design_preview` path-dependent harness. There is no root product main, native Android/iOS scaffold, storage or routing in M02. M03 extends this same root package rather than introducing a production monorepo or copying design components. Keep preview fixtures out of the root library and future retail startup.

Preserve the supplied palette except light `brandSoft`, adjusted from `#E8EDFF` to `#E9EEFF` because actual cobalt text contrast on the old background was 4.4902:1. Test 22 essential pairings at ≥4.5:1. Decorative low-contrast dividers are not relied on as input/state indicators.

At text scales above 125%, use a full-width Navigate action opening the same five labeled destinations plus a full-width direct Practice action. Standard five-tab navigation remains at ordinary size; no text-scale clamp or broken-word labels. At 200%, active practice Pause/Resume and Finish remain pinned and stacked. Reflection Save is pinned in a keyboard-aware action bar while fields scroll. This maintains control reachability rather than shrinking text.

Native golden renders are pinned to the recorded macOS/Flutter 3.47.5 renderer and installed font resources. Tests load SDK Roboto/MaterialIcons and the OS's existing Hiragino Sans GB for the synthetic Unicode name; fonts are read locally, never redistributed or downloaded. Production follows platform typography. A different renderer/font platform requires an explicit reviewed baseline, not automatic golden acceptance. CI must run these references on the matching macOS runner; Linux/device verification remains distinct.

## Alternatives and tradeoffs

Reject web screenshots as native proof, duplicate widget copies, installing unavailable agent plugins, loading remote fonts, clamping Dynamic Type, squeezing navigation labels or allowing save/stop to disappear under the keyboard. A small design harness adds one local test package but no third-party direct runtime dependency. The accessible navigation menu costs one tap for secondary destinations at large text; Practice stays direct. Native rendering still cannot prove app persistence, timer, media, permission or physical accessibility behavior.

## Data/Security impact

Only deterministic clearly labeled synthetic fixtures and original procedural artwork/vector code. No account, network, personal media, analytics or product permissions. Golden PNGs require an explicit provenance/hash manifest and sampled visual review. No local user/font files are copied into Git. Owner Android/iOS identifiers remain `com.jameskierdoliguez.loop`.

## Verification

M02 records strict analysis, formatter, contrast, native widget/golden matrix, keyboard, RTL, semantics and reduced-motion checks, sampled visual review and initial failures/fixes. No participant interviews, phone tests, product builds or release success is claimed from these references.
