# ADR-011 — Preserve scope and resolve workflow interpretations

**Date:** 2026-10-27. **Status:** accepted engineering interpretation under owner-authorized routine decisions; empirical research pending. No material v1 scope change or legal/production approval is claimed.

## Context

The kit mixes a 30-second Start promise, a one-minute first-use journey containing practice itself, optional reflection/media, and an encrypted-archive example beside an owner-approved plaintext fallback. M01 must make test boundaries explicit without losing features or inventing research.

## Decision

Keep the stricter first Start target ≤30s and also report whether first use meets ≤60s; practice duration is outside time-to-start. Finish-to-saved ≤60s and repeat-start ≤2 taps remain. These are targets, not verified outcomes. Save with blank reflection is allowed by PRODUCT/QUALITY; a timed session records effort/context without asserting observed improvement. Evidence-only zero-duration entries remain explicit manual journal entries.

Export remains mandatory portable records+media+hashes with exact encryption labeling. Optional passphrase encryption requires vetted authenticated crypto/KDF and recovery tests; plaintext requires the existing owner privacy sign-off before enabling. Resolving wording does not authorize either an unreviewed crypto implementation or activation of the plaintext fallback.

The owner has explicitly set Android applicationId and iOS Bundle Identifier to `com.jameskierdoliguez.loop`, display name `Loop`. Use consistently from M03, do not change without approval, and verify store availability before publication. This is an owner decision, not an inferred domain claim or availability clearance.

## Alternatives

Reject silently weakening the 30-second target, forcing a note/metric to save, counting background duration, treating a self-rating as an instrument score, promising encryption without tested crypto, or inventing a final production identity. Deferring research is permitted explicitly by M01; fabricating participant responses is not.

## Tradeoffs

Some progress views remain empty until comparable evidence exists. First-use timing needs clear measurement boundaries. Export mode and security spike remain later gates. The product can be designed from hypotheses now, but qualitative validation remains pending and may require future ADRs.

## Data/Security impact

No new collection, dependencies, backend, analytics, signing, keys or external service. Owner-approved identity has no account-availability proof. Real participant notes remain outside Git with consent. Source definitions/provenance are preserved and no production data exists yet.

## Verification

Static F01–F08 walkthrough, story/scenario traceability, metric edge-case review and documentation checks are recorded in M01 verification. Runtime/native/timing/participant verification is not performed by this ADR and remains required later.
