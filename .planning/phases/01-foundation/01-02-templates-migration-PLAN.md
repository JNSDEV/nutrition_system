---
phase: 01-foundation
plan: 02
type: execute
wave: 1
depends_on: []
files_modified:
  - templates/weekly-plan.md
  - templates/weekly-tracker.md
  - templates/meal-prep-planner.md
  - templates/shopping-list.md
autonomous: true
requirements: [LIB-01, LIB-02]
must_haves:
  truths:
    - "User can list 4 .md files under templates/"
    - "Each templates .md file opens with the locked YAML frontmatter (title, category: template, source, last_updated)"
    - "Original wording from the source .txt is preserved verbatim in each migrated file"
  artifacts:
    - path: "templates/weekly-plan.md"
      provides: "Migrated content of 10_weekly_meal_plan.txt"
      contains: "category: template"
    - path: "templates/weekly-tracker.md"
      provides: "Migrated content of 11_weekly_tracker_template.txt"
      contains: "category: template"
    - path: "templates/meal-prep-planner.md"
      provides: "Migrated content of 13_meal_prep_planner.txt"
      contains: "category: template"
    - path: "templates/shopping-list.md"
      provides: "Migrated content of 14_shopping_list_week.txt"
      contains: "category: template"
  key_links:
    - from: "templates/*.md"
      to: "archive/legacy-txt/*.txt (Plan 05)"
      via: "frontmatter `source:` field naming the original .txt"
      pattern: "source: 1[0134]_.*\\.txt"
---

<objective>
Migrate the 4 template-shaped `.txt` files in repo root into `templates/*.md` files with locked YAML frontmatter and verbatim content (per D-01, D-02, D-03).

Purpose: Establishes the weekly/repeatable template files that Phase 3 slash commands (`/weekly-plan`, `/shopping-list`, `/log-day`) fill in.
Output: 4 markdown files under `templates/` matching the D-02 source-to-target mapping.
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/execute-plan.md
@$HOME/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/ROADMAP.md
@.planning/STATE.md
@.planning/phases/01-foundation/01-CONTEXT.md
</context>

<migration_rules>
Per D-01: **verbatim with minimal touch** (same rules as Plan 01).
- Add H1, convert obvious list-shaped lines to Markdown bullets, preserve original wording otherwise.
- Frontmatter has exactly the 4 fields from D-03 (`title`, `category: template`, `source`, `last_updated: 2026-05-05`). No additional fields (D-04).

**Frontmatter template (D-03, `category: template` per D-03 enum):**
```yaml
---
title: <Human title>
category: template
source: <original .txt filename>
last_updated: 2026-05-05
---
```

**Mapping (D-02):**
| Target file | `title:` | H1 | `source:` |
|---|---|---|---|
| templates/weekly-plan.md | Weekly Meal Plan | `# Weekly Meal Plan` | 10_weekly_meal_plan.txt |
| templates/weekly-tracker.md | Weekly Tracker | `# Weekly Tracker` | 11_weekly_tracker_template.txt |
| templates/meal-prep-planner.md | Meal Prep Planner | `# Meal Prep Planner` | 13_meal_prep_planner.txt |
| templates/shopping-list.md | Shopping List | `# Shopping List` | 14_shopping_list_week.txt |
</migration_rules>

<tasks>

<task type="auto">
  <name>Task 1: Create templates/ directory and migrate all 4 template files</name>
  <read_first>
    - 10_weekly_meal_plan.txt
    - 11_weekly_tracker_template.txt
    - 13_meal_prep_planner.txt
    - 14_shopping_list_week.txt
    - .planning/phases/01-foundation/01-CONTEXT.md (for D-01..D-05 frontmatter shape)
  </read_first>
  <files>templates/weekly-plan.md, templates/weekly-tracker.md, templates/meal-prep-planner.md, templates/shopping-list.md</files>
  <action>
    1. `mkdir -p templates`
    2. For each source .txt in the mapping table above, create the corresponding `templates/*.md`.
    3. Each file structure:
       - Line 1: `---`
       - Lines 2–5: the four frontmatter fields (`title`, `category: template`, `source: <txt name>`, `last_updated: 2026-05-05`)
       - Line 6: `---`
       - Line 7: blank
       - Line 8: H1 from mapping table
       - Line 9: blank
       - Lines 10+: verbatim body of source .txt, with obvious list-shaped lines converted to `- ` bullets.
    4. Do NOT add fields beyond the 4 in D-03 (D-04).
  </action>
  <verify>
    <automated>test -d templates && for pair in "weekly-plan:10_weekly_meal_plan.txt" "weekly-tracker:11_weekly_tracker_template.txt" "meal-prep-planner:13_meal_prep_planner.txt" "shopping-list:14_shopping_list_week.txt"; do f="${pair%%:*}"; src="${pair##*:}"; test -f "templates/$f.md" || exit 1; head -1 "templates/$f.md" | grep -qx '\-\-\-' || exit 1; grep -q "^category: template$" "templates/$f.md" || exit 1; grep -q "^source: $src$" "templates/$f.md" || exit 1; grep -q "^last_updated: 2026-05-05$" "templates/$f.md" || exit 1; done; ls templates/*.md | wc -l | grep -qx '       4' && echo OK</automated>
  </verify>
  <acceptance_criteria>
    - `templates/` directory exists
    - All 4 files exist with line 1 = `---`
    - Each file contains `category: template`
    - Each file contains `source: <correct mapped .txt filename>`
    - Each file contains `last_updated: 2026-05-05`
    - Each file contains its mapped H1 (e.g. `# Weekly Meal Plan`)
    - `ls templates/*.md | wc -l` returns 4
    - No file contains `tags:`, `applies_to:`, or `kcal_role:` (D-04)
    - Original wording preserved verbatim
  </acceptance_criteria>
  <done>templates/ contains exactly 4 .md files, all conforming to D-03 frontmatter and D-01 verbatim rule.</done>
</task>

</tasks>

<verification>
- `ls templates/*.md | wc -l` → 4
- All 4 files have the 4 locked frontmatter fields and only those 4
- All 4 reference their D-02-mapped source .txt
</verification>

<success_criteria>
ROADMAP Phase 1 success criterion #2 satisfied: User can open `templates/` and find the four weekly/repeatable templates (weekly-plan, weekly-tracker, meal-prep-planner, shopping-list).
</success_criteria>

<output>
After completion, create `.planning/phases/01-foundation/01-02-SUMMARY.md` documenting: files created, total line counts, any judgement calls about "list-shaped" lines.
</output>
