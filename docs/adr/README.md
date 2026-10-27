# Architecture decision records

Existing binding decisions ADR-001–ADR-010 remain in [DECISIONS.md](../DECISIONS.md). Do not duplicate or renumber them. New decisions start at ADR-011 and use `ADR-011-short-title.md` here, linked from the decision ledger.

Use Context, Decision, Alternatives, Tradeoffs, Data/Security impact, Date, Status, and Verification/owner approval. Record whether a decision is proposed, accepted or superseded; a proposed decision does not grant approval for an external action.

M00 introduces no architecture change. Its provisional platform baseline and D-01–D-10 handoff are in [ENVIRONMENT.md](../verification/ENVIRONMENT.md) and [TRACEABILITY.md](../verification/TRACEABILITY.md). [ADR-011](ADR-011-product-interpretations.md) records M01 scope-preserving workflow interpretations and owner identity. M03 must validate SDK/package compatibility before pinning an operational build environment; M04 must resolve the security spike before making encryption claims.
