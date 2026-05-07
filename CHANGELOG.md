# Changelog

All notable changes to this project are documented here.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Granularity: per milestone, not per phase. For phase-level history, see `git log` and `.planning/phases/`.

## [Unreleased]

## [1.0.0] - 2026-05-07

### Added

- Knowledge base in `library/` — meals, recipes, portions, cooking rules, calorie targets, macro templates, training-nutrition guidance, fast-food rules, and more (11 files migrated from `.txt` originals)
- Cycling calendar in `calendar/cycling-2026.md` — standard weekly session pattern and Sunday long-ride progression through Heathland (Aug 2026), driving Jonas's daily kcal target
- File-shape templates in `templates/` — daily log, weekly summary, weekly plan, shopping list
- Per-person trackers in `trackers/jonas/` and `trackers/farva/` with seeded `progress.md` baselines (starting weights, targets, Heathland event for Jonas)
- Six slash commands: `/prep-today`, `/log-day`, `/weekly-plan`, `/shopping-list`, `/weekly-review`, `/swap-meal` — implementing the full daily/weekly operating loop
- Shared slash-command conventions in `.claude/commands/README.md` (file-shape, date semantics, library-anchor resolution, person identifiers, D-22 kcal-adjustment schema)
- Top-level onboarding docs: `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`
- Reference doc: `docs/conventions.md` — file paths, naming rules, frontmatter, date format, person-name resolution, rename procedure
- Originals archived (not deleted) to `archive/legacy-txt/` for traceability
