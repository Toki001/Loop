# Contributing to Loop

Read [AGENTS.md](AGENTS.md), [AGENT.md](AGENT.md), [CODEX.md](CODEX.md) and the specifications in [README.md](README.md) before editing. The current execution status lives in the [verification index](docs/verification/INDEX.md). The kit describes the intended app; it is not working application code.

The owner has authorized continuous M01–M15 execution: work on one milestone at a time from [MILESTONES.md](docs/MILESTONES.md), then continue automatically after verification and commit. Read [CONTINUATION.md](docs/verification/CONTINUATION.md) and [PROGRESS.md](docs/verification/PROGRESS.md) to resume; do not redo M00. Use branches `milestone/XX-short-name`; the initial branch is `milestone/00-baseline`. Keep existing history and unrelated changes. Commit only reviewed, verified work as `milestone-XX: <verified outcome>`. Never push, publish, install unapproved third-party agent tools/services, grant OAuth access, index private source remotely, or spend money without explicit owner authorization. A local commit is not release approval.

For this documentation baseline, run from the repository root:

```sh
python3 tool/check_baseline.py
git diff --check
git diff --cached --check
git status --short --branch
```

The checker verifies local Markdown file links, US/A/D traceability coverage, ignore rules, and a limited secret/path hygiene scan. It permits exactly two trailing spaces for Markdown hard breaks; `.gitattributes` delegates Markdown line-ending whitespace to this check so the original contract's semantic breaks are preserved. It needs only Python 3 and Git, makes no network calls and prints findings without secret contents. It is not a full vulnerability scanner. Review the staged diff and file list before committing; keep verification evidence free of usernames, device identifiers and private recordings.

M02 adds a narrow binary exception for generated native golden PNGs under `docs/verification/design/goldens/`: each must match the explicit synthetic provenance/hash manifest. Unlisted/changed binaries still fail. Review source/fixtures and visual differences before updating that manifest; never bless a new screenshot automatically or put private media in the allowed directory. Native design checks run from `design_preview`; its goldens are macOS/SDK/font-pinned and are not physical-device or persistence proof.

Create each evidence report using the exact report headings from [AGENT.md](AGENT.md). Record command, exit code, test counts, device type, screenshots if actually produced, privacy impact and blockers. `BLOCKED`, `NOT RUN` and `NOT APPLICABLE` never count as passing app tests. Run the additional gates in [QUALITY.md](docs/QUALITY.md) when an application exists. Application CI belongs to M03; there is no passing CI run at M00.

Use `local-data/`, `recordings/`, `media/` and `exports/` only for ignored private development artifacts. Test and golden fixtures must be synthetic, documented, licensed and separated from production startup. Large archive fixtures should be generated inside ignored scratch storage. A `.gitignore` cannot prevent someone placing personal content elsewhere: inspect every staged binary manually. Retain the future app's `pubspec.lock`, `Podfile.lock`, migration fixtures and reviewed goldens in source control.

Document architecture changes under [docs/adr](docs/adr/README.md) before changing the binding contract. Keep unresolved owner decisions visible. New app identifiers, encryption claims, analytics, cloud services, payments and publishing need their applicable approvals; absence of optional tools does not relax the native acceptance gates.
