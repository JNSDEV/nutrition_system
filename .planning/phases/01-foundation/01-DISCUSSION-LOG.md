# Phase 1: Foundation - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-05-05
**Phase:** 1-Foundation
**Areas discussed:** Migration fidelity, Frontmatter / structure conventions, Cycling calendar shape, library/README.md scope

---

## Migration fidelity

| Option | Description | Selected |
|--------|-------------|----------|
| Verbatim — minimal touch | Copy as-is; add H1 + light bullet conversion only. Originals stay source of truth in archive/legacy-txt/. | ✓ |
| Light restructure | Add H2 sections, normalize lists/tables, dedup repeats. | |
| Full rewrite into clean structured Markdown | Rewrite optimized for Claude/machine consumption. | |

**User's choice:** Verbatim — minimal touch (Recommended)
**Notes:** Lowest risk of losing nuance from original phrasing. Originals preserved in archive/.

---

## Frontmatter / structure conventions

| Option | Description | Selected |
|--------|-------------|----------|
| Minimal frontmatter | `title`, `category`, `source`, `last_updated`. | ✓ |
| No frontmatter — pure Markdown | Filename + H1/H2 only. | |
| Rich frontmatter | Adds `tags`, `applies_to`, `kcal_role`. | |

**User's choice:** Minimal frontmatter (Recommended)
**Notes:** Cheap to add, useful for Phase 3 commands to filter on `category`. Rich metadata explicitly deferred — risk of stale fields.

---

## Cycling calendar shape

| Option | Description | Selected |
|--------|-------------|----------|
| Two tables: standard week + Sunday progression | Mirrors PROJECT.md structure. Commands resolve by day-of-week + week-range. | ✓ |
| One flat table: every date 2026-05-05 → 2026-08-09 | Pre-expanded ~95 rows; trivial date grep. | |
| Week-by-week sections (## Week of YYYY-MM-DD) | One H2 per week with 7-row table inside. | |

**User's choice:** Two tables (Recommended)
**Notes:** Direct lift from PROJECT.md lines 50–82. Marker rows (SPORTIVE, BENCHMARK, REHEARSAL, HEATHLAND) preserved verbatim.

---

## library/README.md scope

| Option | Description | Selected |
|--------|-------------|----------|
| Structure index only | One-page map of files; no operating-loop content. | |
| Structure + operating-loop primer | Index PLUS short section explaining how library/templates/trackers/commands fit. | ✓ |
| Full operating-loop doc (effectively the v1 README) | Make this the top-level README; Phase 4 just refines. | |

**User's choice:** Structure + operating-loop primer (Recommended)
**Notes:** Dual audience — future cold Claude sessions and Jonas/Partner. Stays one page; points forward to Phase 4 README.

---

## Claude's Discretion

- File-by-file H1 titles inferred from source filename and frontmatter `title`.
- Judgement calls about what counts as an "obvious list-shaped line" during minimal-touch migration. Lean toward less transformation when unsure.

## Deferred Ideas

- Rich frontmatter fields (`tags`, `applies_to`, `kcal_role`) — revisit if Phase 3 commands need finer filtering.
- Pre-expanded date-by-date cycling calendar — revisit if Phase 3 date-resolution turns out brittle.
- Partner display name — open question carried to Phase 2 tracker seeding.
- Mobile-logging mechanism, body-measurement tracking — v2, per PROJECT.md.
