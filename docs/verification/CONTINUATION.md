# Durable execution checkpoint — 2026-10-27

**Mode:** continuous autonomous M01–M15 execution, authorized by the owner. No new prompt is needed after a verified milestone commit. Read AGENTS, AGENT, CODEX and the current milestone contract; preserve approval boundaries and quality gates.

**Completed commits:** M00 PASS `fa316ff`; policy `af667df`; M01 PASS `9b90ca94372e7e8f7926a63d3de3243ab5da1195`; M01 checkpoint `702a305`; M02 PASS `7ede417c8358d14bfc4f97686c7b6be53d225125`; M02 checkpoint `d5b1ac7`. Each committed gate was verified with a clean worktree. M03 actual product foundation is now verified below, awaiting its own local commit. Historical M00 verification is unchanged; empirical research remains pending.

**Last verified milestone/branch:** M03 PASS `95b8f7cc7cb51d9a4d9781e4b70b5bb21191ff61` on `milestone/03-native-foundation`, subject `milestone-03: native Flutter app foundation`. Commit exists; worktree was verified clean. This documentation-only checkpoint records the resulting SHA. **Next: M04**, create/switch `milestone/04-durable-persistence` after this checkpoint commit and immediately implement the next gate. Product/native design tests, builds, real iOS storage and process evidence are complete; no production release is implied.

**Current test status:** M03 full selected CI: 15 stages exit 0; formatter 25 files unchanged; strict root/preview analysis no issues; 42 application + 233 design + 1 native integration tests pass, none failed/skipped, 225 frozen PNG comparisons/22 AA pairs. Actual Android debug and iOS simulator debug builds pass; native retained-container rerun and separate product process launch pass. Two native screenshots visually reviewed. Icon-mutation/unmanifested-screenshot probes rejected, originals restored/probe removed. M02 historic design issues remain documented; frozen goldens unchanged. No real-media, participant, physical-device, signed production or remote CI verification has occurred.

**Owner identity decision:** Android applicationId and iOS Bundle Identifier are both `com.jameskierdoliguez.loop`; display name `Loop`. The owner explicitly supplied these during policy work. Use them consistently in M03/native/build/release configuration and never change without approval. Verify production availability before publication; availability is not established by this instruction.

**Open prerequisites:** no Android AVD/system image or connected physical mobile device; dedicated Loop iOS simulator now booted/tested, existing simulator data untouched. Missing third-party skills are documented in TOOLS; use allowed native/manual fallbacks. Research participants, physical hardware, store identity availability/signing/legal/publication and remote CI remain unverified external gates.

Safe resume commands (run from the repository root; inspect and preserve any new user changes before continuing):

```sh
git status --short --branch
git log -3 --format='%h %s'
cat docs/verification/CONTINUATION.md docs/verification/PROGRESS.md
python3 tool/check_baseline.py
git diff --check
git diff --cached --check
```

M03 commit/checkpoint complete: verify this checkpoint commit and clean worktree, then create/switch `milestone/04-durable-persistence` without resetting any existing branch. Resume M04 requirements/package verification and implementation automatically. M03 final repository check passed: 48 Markdown files/158 links, full traceability/30 ignore probes, 149 UTF-8 files, 225 frozen goldens/23 native artwork PNGs/two actual simulator screenshots; both Git whitespace checks and unchanged M00 history passed.

M03 actual evidence is in `docs/verification/M03.md` and `evidence/M03/`. A first retry test exposed an unhandled bootstrap future (fixed); iOS cache lacked its engine binary (official cache repair, builds pass); integration global error-builder cleanup was fixed. Flutter test normally uninstalls app/data; a verified `--no-uninstall` rerun preserved actual UI-written Dark/onboarding before product rebuild/install and separate process relaunch (32948/33095). No preferences were manufactured. Dedicated simulator `F39EEA3D-9939-4689-8958-6CDDBB36EF01` is booted with the real empty product shell, Dark/onboarding persisted. Existing simulators untouched. Raw logs under ignored `tmp/`. Current CI device option keeps its dedicated test app. No need to repeat passed core/goldens unless source changes or a new concern warrants it; final documentation/provenance/staging checks passed before the milestone commit.

M04 next: read full DATA_AND_METRICS/ARCHITECTURE/SECURITY_PRIVACY/QUALITY and M04 contract; verify current Drift/SQLite/generator/native package sources before selection. Add actual relational schema/FKs/indexes/repositories, migration fixtures and transaction tests, private file/checksum/path boundary, lossless preferences import and typed non-destructive DB initialization/recovery. Assess OS protection/backups/encryption in ADR before choosing; do not claim SQL/media encryption without real native validation. Reuse actual simulator for native reopen/process tests. Android has no device/AVD; physical Android is required M06. No remote CI is connected/executed.

Before interruption or each next commit, replace this checkpoint with actual completed commits, current branch/milestone, command results, safe next commands and blockers. Confirm every reported commit exists and the worktree is clean before continuing. Never treat an environmental/owner blocker as PASS or a context limit as permission to drop work.
