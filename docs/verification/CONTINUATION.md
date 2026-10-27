# Durable execution checkpoint — 2026-10-27

**Mode:** continuous autonomous M01–M15 execution, authorized by the owner. No new prompt is needed after a verified milestone commit. Read AGENTS, AGENT, CODEX and the current milestone contract; preserve approval boundaries and quality gates.

**Completed:** M00 PASS, actual commit `fa316ff`, branch `milestone/00-baseline`. Historical M00 verification is unchanged. The policy change is on `policy/continuous-execution`; its containing commit is resolved by `git log -1 --format=%H -- AGENTS.md`. No application exists yet.

**Current branch:** `policy/continuous-execution`. **Next action:** verify and commit policy documentation, confirm clean worktree, create `milestone/01-product-contract`, and execute M01. Once M01 passes and its local commit is verified, immediately start M02.

**Test status:** M00 checks passed; run the documentation checker and staged/unstaged Git diff checks for policy updates before commit. No application tests, builds, snapshots or real interviews have occurred.

**Owner identity decision:** Android applicationId and iOS Bundle Identifier are both `com.jameskierdoliguez.loop`; display name `Loop`. The owner explicitly supplied these during policy work. Use them consistently in M03/native/build/release configuration and never change without approval. Verify production availability before publication; availability is not established by this instruction.

**Open prerequisites:** no Android AVD or connected physical mobile device was verified in M00; existing iOS simulators are available but shut down. Missing third-party skills are documented in TOOLS; use allowed native/manual fallbacks. Research participants, native hardware/signing/legal/publication approvals must never be invented.

Safe resume commands (run from the repository root; inspect and preserve any new user changes before continuing):

```sh
git status --short --branch
git log -3 --format='%h %s'
cat docs/verification/CONTINUATION.md docs/verification/PROGRESS.md
python3 tool/check_baseline.py
git diff --check
git diff --cached --check
```

If still on the policy branch before its commit, stage only the reviewed policy/ledger files and commit `docs: enable continuous milestone execution`. After a clean verified policy commit, create `git switch -c milestone/01-product-contract` (if it already exists, inspect it and use `git switch milestone/01-product-contract`; never reset it). Read M01 and implement its research protocol, clearly hypothetical personas, workflows, metric/copy review, scope lock, decision and traceability updates. Empirical research stays pending without real participants, as the M01 contract permits. Resolve contradictory requirements by documented engineering interpretation without changing material product scope silently.

Before interruption or each next commit, replace this checkpoint with actual completed commits, current branch/milestone, command results, safe next commands and blockers. Confirm every reported commit exists and the worktree is clean before continuing. Never treat an environmental/owner blocker as PASS or a context limit as permission to drop work.
