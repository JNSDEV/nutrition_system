# Phase 1: Foundation - Context

**Gathered:** 2026-05-05
**Status:** Ready for planning

<domain>
## Phase Boundary

Migrate the existing knowledge base into a structured, browsable Markdown system that downstream slash commands (Phase 3) can read from cleanly.

Concretely, this phase delivers:
- `library/` — 11 named `.md` files migrated from `01_*.txt` … `15_*.txt` (excluding the 4 template-shaped files)
- `templates/` — 4 weekly/repeatable templates (weekly-plan, weekly-tracker, meal-prep-planner, shopping-list)
- `archive/legacy-txt/` — all 15 original `.txt` files preserved unmodified
- `calendar/cycling-2026.md` — single source of truth for Jonas's weekly training load through 2026-08-09
- `library/README.md` — orientation doc explaining how library + templates + trackers + commands fit together

**NOT in this phase:** trackers/ scaffolding (Phase 2), slash commands (Phase 3), top-level README.md (Phase 4).

</domain>

<decisions>
## Implementation Decisions

### Migration fidelity
- **D-01:** Migrate the 15 `.txt` files **verbatim with minimal touch**. Add an H1 title, convert obvious lists/numbered items to Markdown bullets where the source already uses list-shaped lines, and preserve all original wording otherwise. Do not paraphrase, restructure, or dedup. Originals in `archive/legacy-txt/` remain the source of truth for original phrasing.
- **D-02:** Source-to-target mapping is fixed (per PROJECT.md):
  - `01_goals.txt` → `library/goals.md`
  - `02_daily_structure.txt` → `library/daily-structure.md`
  - `03_meal_library.txt` → `library/meals.md`
  - `04_recipes.txt` → `library/recipes.md`
  - `05_portion_guidelines.txt` → `library/portions.md`
  - `06_cooking_rules.txt` → `library/cooking-rules.md`
  - `07_preferences.txt` → `library/preferences.md`
  - `08_training_nutrition.txt` → `library/training-nutrition.md`
  - `09_calorie_targets.txt` → `library/calorie-targets.md`
  - `12_macro_templates.txt` → `library/macro-templates.md`
  - `15_fast_food_and_eating_out_rules.txt` → `library/fast-food-rules.md`
  - `10_weekly_meal_plan.txt` → `templates/weekly-plan.md`
  - `11_weekly_tracker_template.txt` → `templates/weekly-tracker.md`
  - `13_meal_prep_planner.txt` → `templates/meal-prep-planner.md`
  - `14_shopping_list_week.txt` → `templates/shopping-list.md`

### Frontmatter / structure conventions
- **D-03:** Every migrated `.md` file (both `library/` and `templates/`) gets a **minimal YAML frontmatter block** with exactly these fields:
  ```yaml
  ---
  title: <Human-readable title>
  category: library | template
  source: <original .txt filename>
  last_updated: 2026-05-05
  ---
  ```
- **D-04:** No additional fields (no `tags`, no `applies_to`, no `kcal_role`). Resist scope creep into rich metadata — slash commands in Phase 3 can navigate by filename + H1/H2 + frontmatter `category` alone. Adding more is easy later; pruning stale metadata is hard.
- **D-05:** `last_updated` is set to the migration date (2026-05-05) for all files in this phase. Future edits update it manually.

### Cycling calendar shape
- **D-06:** `calendar/cycling-2026.md` is structured as **two tables** mirroring how it already exists in PROJECT.md:
  1. `## Standard week` — 7 rows (Mon–Sun) with columns: Day, Session, Duration, Est. kcal
  2. `## Sunday progression` — 13 rows from `May 11–17` through `Aug 3–9`, with columns: Week, Long ride, Est. kcal
- **D-07:** Frontmatter same shape as library files but `category: calendar` and `source: PROJECT.md` (since the calendar is lifted from the project doc, not from a `.txt` file).
- **D-08:** Slash commands (Phase 3) resolve "today's row" by: day-of-week → standard-week table; if Sunday → look up the date's week range in the Sunday progression table.
- **D-09:** Marker rows (`SPORTIVE`, `BENCHMARK`, `REHEARSAL`, `HEATHLAND`) are kept verbatim — they are load-shape signals Phase 3 will key off.

### library/README.md scope
- **D-10:** Includes both a **structure index** (what each file in `library/` and `templates/` contains, one line each) AND a short **operating-loop primer** (how library / templates / trackers / commands relate). Audience is dual: future cold Claude sessions reading the system, and Jonas/Partner as humans.
- **D-11:** Stays one page. No deep dive into individual commands (those don't exist yet — Phase 3). One short section pointing forward to Phase 4's top-level `README.md`.
- **D-12:** Same minimal frontmatter (`category: library`, `source: <discussion>`).

### Archive
- **D-13:** All 15 `.txt` files are **moved** (not copied) to `archive/legacy-txt/` with original filenames unchanged. Repo root ends up clean — only `archive/`, `library/`, `templates/`, `calendar/`, `.planning/`, and `CLAUDE.md` remain at the top level after Phase 1.
- **D-14:** Add a tiny `archive/legacy-txt/README.md` (one paragraph) explaining these are the originals, preserved for traceability, do not edit.

### Claude's Discretion
- File-by-file H1 titles can be inferred from the source filename (`03_meal_library.txt` → `# Meals`). Match the human-readable title in frontmatter.
- Within "verbatim with minimal touch", judgement calls about what counts as "obvious list-shaped lines" are Claude's. When unsure, lean toward less transformation.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project intent & requirements (already loaded)
- `.planning/PROJECT.md` — system overview, source-material mapping (lines 102–134), cycling calendar (lines 50–82), Jonas/Partner goals, operating loop
- `.planning/REQUIREMENTS.md` — atomic requirements LIB-01..04, CAL-01 in scope for this phase
- `.planning/ROADMAP.md` — Phase 1 success criteria (lines 26–32)
- `CLAUDE.md` (project) — system summary, core value statement

### Source material (to migrate)
- `01_goals.txt` … `15_*.txt` — 15 files in repo root, full list above in D-02
- These are the durable knowledge base. Migration must preserve their wording verbatim.

### Out of scope but referenced
- Phase 2 will create `trackers/` — do not pre-create directories or stub files in Phase 1
- Phase 4 will create top-level `README.md` and `docs/conventions.md` — `library/README.md` (D-10) is intentionally narrower

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- The 15 `*.txt` files in repo root contain all content needed for `library/` + `templates/` — no external sourcing required.
- The cycling calendar tables are already drafted inline in `.planning/PROJECT.md` (lines 50–82) — copy them over rather than re-derive.

### Established Patterns
- Repo currently has no code; this is a pure markdown content system. No build step, no tooling, no language stack.
- `.planning/` directory uses GSD conventions (PROJECT.md / REQUIREMENTS.md / ROADMAP.md / STATE.md). New top-level dirs (`library/`, `templates/`, `calendar/`, `archive/`) are siblings to `.planning/`.

### Integration Points
- Phase 2 will read `calendar/cycling-2026.md` to derive Jonas's daily kcal target — calendar shape (D-06..D-09) is the integration contract.
- Phase 3 slash commands will read `library/*.md` filtered by frontmatter `category` and content by H1/H2 — frontmatter shape (D-03..D-05) is the integration contract.

</code_context>

<specifics>
## Specific Ideas

- Frontmatter example (locked, D-03):
  ```yaml
  ---
  title: Meals
  category: library
  source: 03_meal_library.txt
  last_updated: 2026-05-05
  ---
  ```
- Cycling calendar shape (locked, D-06): two tables — `## Standard week` + `## Sunday progression` — direct lift from PROJECT.md lines 50–82.
- `library/README.md` skeleton (locked, D-10):
  ```
  # Library

  ## What's here
  - goals.md — ...
  - meals.md — ...
  ...

  ## How this fits
  - library/ = durable knowledge (read-only by commands)
  - templates/ = forms commands fill in
  - trackers/  = per-person logs (Phase 2)
  - Slash commands (Phase 3) read library + write into trackers
  ```

</specifics>

<deferred>
## Deferred Ideas

- **Rich frontmatter metadata** (`tags`, `applies_to`, `kcal_role`) — explicitly rejected for Phase 1 (D-04). Revisit if Phase 3 commands turn out to need finer filtering than filename + H1 + `category` provides.
- **Open question from PROJECT.md: Partner display name** — placeholder `Partner` stands. Decide in Phase 2 when seeding `trackers/partner/progress.md`.
- **Pre-expanded date-by-date cycling calendar** (one row per date) — rejected for now in favor of two-table shape. Reconsider if Phase 3 commands' date-resolution logic ends up brittle.
- **Mobile-logging mechanism** — out of scope; deferred to v2 per PROJECT.md.
- **Body-measurement tracking** — out of scope; deferred to v2 per PROJECT.md.

</deferred>

---

*Phase: 1-Foundation*
*Context gathered: 2026-05-05*
