---
phase: 01-foundation
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - library/goals.md
  - library/daily-structure.md
  - library/meals.md
  - library/recipes.md
  - library/portions.md
  - library/cooking-rules.md
  - library/preferences.md
  - library/training-nutrition.md
  - library/calorie-targets.md
  - library/macro-templates.md
  - library/fast-food-rules.md
autonomous: true
requirements: [LIB-01, LIB-02]
must_haves:
  truths:
    - "User can list 11 .md files under library/"
    - "Each library .md file opens with the locked YAML frontmatter (title, category: library, source, last_updated)"
    - "Original wording from the source .txt is preserved verbatim in each migrated file"
  artifacts:
    - path: "library/goals.md"
      provides: "Migrated content of 01_goals.txt"
      contains: "category: library"
    - path: "library/daily-structure.md"
      provides: "Migrated content of 02_daily_structure.txt"
      contains: "category: library"
    - path: "library/meals.md"
      provides: "Migrated content of 03_meal_library.txt"
      contains: "category: library"
    - path: "library/recipes.md"
      provides: "Migrated content of 04_recipes.txt"
      contains: "category: library"
    - path: "library/portions.md"
      provides: "Migrated content of 05_portion_guidelines.txt"
      contains: "category: library"
    - path: "library/cooking-rules.md"
      provides: "Migrated content of 06_cooking_rules.txt"
      contains: "category: library"
    - path: "library/preferences.md"
      provides: "Migrated content of 07_preferences.txt"
      contains: "category: library"
    - path: "library/training-nutrition.md"
      provides: "Migrated content of 08_training_nutrition.txt"
      contains: "category: library"
    - path: "library/calorie-targets.md"
      provides: "Migrated content of 09_calorie_targets.txt"
      contains: "category: library"
    - path: "library/macro-templates.md"
      provides: "Migrated content of 12_macro_templates.txt"
      contains: "category: library"
    - path: "library/fast-food-rules.md"
      provides: "Migrated content of 15_fast_food_and_eating_out_rules.txt"
      contains: "category: library"
  key_links:
    - from: "library/*.md"
      to: "archive/legacy-txt/*.txt (Plan 05)"
      via: "frontmatter `source:` field naming the original .txt"
      pattern: "source: [0-9]+_.*\\.txt"
---

<objective>
Migrate the 11 library-shaped `.txt` files in repo root into `library/*.md` files with locked YAML frontmatter and verbatim content (per D-01, D-02, D-03).

Purpose: Establishes the durable knowledge base that Phase 3 slash commands will read by `category: library` + filename + H1/H2 (per D-04 contract).
Output: 11 markdown files under `library/` matching the D-02 source-to-target mapping.
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
Per D-01: **verbatim with minimal touch**.
- Add an H1 title (e.g. `# Meals` for `meals.md`) immediately after the frontmatter closing `---`.
- Convert obvious list-shaped lines (lines beginning with `-`, `*`, `1.`, `2.`, etc., or visually-bulleted text) into Markdown bullets.
- Preserve all original wording. Do **not** paraphrase, restructure, dedup, or reorder sections.
- When unsure if a line is "list-shaped", lean toward less transformation (leave as plain prose).
- Do **not** add any frontmatter fields beyond the four locked in D-03 (no `tags`, no `applies_to`, no `kcal_role` — D-04).

**Frontmatter template (D-03, embed verbatim, substituting `<title>` and `<source>`):**
```yaml
---
title: <Human title>
category: library
source: <original .txt filename>
last_updated: 2026-05-05
---
```

**H1 + frontmatter title mapping (D-02 + Claude's discretion):**
| Target file | `title:` | H1 | `source:` |
|---|---|---|---|
| library/goals.md | Goals | `# Goals` | 01_goals.txt |
| library/daily-structure.md | Daily Structure | `# Daily Structure` | 02_daily_structure.txt |
| library/meals.md | Meals | `# Meals` | 03_meal_library.txt |
| library/recipes.md | Recipes | `# Recipes` | 04_recipes.txt |
| library/portions.md | Portion Guidelines | `# Portion Guidelines` | 05_portion_guidelines.txt |
| library/cooking-rules.md | Cooking Rules | `# Cooking Rules` | 06_cooking_rules.txt |
| library/preferences.md | Preferences | `# Preferences` | 07_preferences.txt |
| library/training-nutrition.md | Training Nutrition | `# Training Nutrition` | 08_training_nutrition.txt |
| library/calorie-targets.md | Calorie Targets | `# Calorie Targets` | 09_calorie_targets.txt |
| library/macro-templates.md | Macro Templates | `# Macro Templates` | 12_macro_templates.txt |
| library/fast-food-rules.md | Fast Food & Eating Out Rules | `# Fast Food & Eating Out Rules` | 15_fast_food_and_eating_out_rules.txt |
</migration_rules>

<tasks>

<task type="auto">
  <name>Task 1: Create library/ directory and migrate first 6 files</name>
  <read_first>
    - 01_goals.txt
    - 02_daily_structure.txt
    - 03_meal_library.txt
    - 04_recipes.txt
    - 05_portion_guidelines.txt
    - 06_cooking_rules.txt
    - .planning/phases/01-foundation/01-CONTEXT.md (for D-01..D-05 frontmatter shape)
  </read_first>
  <files>library/goals.md, library/daily-structure.md, library/meals.md, library/recipes.md, library/portions.md, library/cooking-rules.md</files>
  <action>
    1. `mkdir -p library`
    2. For each source .txt in this batch, create the corresponding `library/*.md` file per the mapping table in `<migration_rules>` above.
    3. Each file structure:
       - Line 1: `---`
       - Lines 2–5: the four frontmatter fields per D-03 (`title`, `category: library`, `source: <txt name>`, `last_updated: 2026-05-05`)
       - Line 6: `---`
       - Line 7: blank
       - Line 8: H1 (e.g. `# Goals`)
       - Line 9: blank
       - Lines 10+: verbatim body of the source .txt, with obvious list-shaped lines converted to Markdown `- ` bullets (per D-01). Preserve original wording.
    4. Do NOT add fields beyond the 4 in D-03 (D-04). Do NOT paraphrase.
  </action>
  <verify>
    <automated>test -d library && for f in goals daily-structure meals recipes portions cooking-rules; do test -f "library/$f.md" || exit 1; head -1 "library/$f.md" | grep -qx '\-\-\-' || exit 1; grep -q "^category: library$" "library/$f.md" || exit 1; grep -q "^last_updated: 2026-05-05$" "library/$f.md" || exit 1; done; echo OK</automated>
  </verify>
  <acceptance_criteria>
    - `library/` directory exists
    - `library/goals.md` line 1 is `---`
    - `library/goals.md` contains `category: library`
    - `library/goals.md` contains `source: 01_goals.txt`
    - `library/goals.md` contains `last_updated: 2026-05-05`
    - `library/goals.md` contains `# Goals`
    - Same checks pass for: daily-structure.md (source 02_), meals.md (source 03_), recipes.md (source 04_), portions.md (source 05_), cooking-rules.md (source 06_)
    - No file contains `tags:`, `applies_to:`, or `kcal_role:` (D-04 — only the 4 locked fields)
    - Original wording from each source .txt appears in the migrated file (spot-check a distinctive phrase)
  </acceptance_criteria>
  <done>6 library files exist with correct frontmatter, H1, and verbatim content.</done>
</task>

<task type="auto">
  <name>Task 2: Migrate remaining 5 library files</name>
  <read_first>
    - 07_preferences.txt
    - 08_training_nutrition.txt
    - 09_calorie_targets.txt
    - 12_macro_templates.txt
    - 15_fast_food_and_eating_out_rules.txt
    - .planning/phases/01-foundation/01-CONTEXT.md (for D-01..D-05 frontmatter shape)
  </read_first>
  <files>library/preferences.md, library/training-nutrition.md, library/calorie-targets.md, library/macro-templates.md, library/fast-food-rules.md</files>
  <action>
    Same migration procedure as Task 1, applied to the remaining 5 library-shaped files per the mapping table in `<migration_rules>`.
    Note: `12_macro_templates.txt` → `library/macro-templates.md` (not 10/11 — those are templates, handled in Plan 02).
    Note: `15_fast_food_and_eating_out_rules.txt` → `library/fast-food-rules.md` with `title: Fast Food & Eating Out Rules`.
  </action>
  <verify>
    <automated>for pair in "preferences:07_preferences.txt" "training-nutrition:08_training_nutrition.txt" "calorie-targets:09_calorie_targets.txt" "macro-templates:12_macro_templates.txt" "fast-food-rules:15_fast_food_and_eating_out_rules.txt"; do f="${pair%%:*}"; src="${pair##*:}"; test -f "library/$f.md" || exit 1; head -1 "library/$f.md" | grep -qx '\-\-\-' || exit 1; grep -q "^category: library$" "library/$f.md" || exit 1; grep -q "^source: $src$" "library/$f.md" || exit 1; grep -q "^last_updated: 2026-05-05$" "library/$f.md" || exit 1; done; ls library/*.md | wc -l | grep -qx '      11' && echo OK</automated>
  </verify>
  <acceptance_criteria>
    - All 5 files exist with correct frontmatter referencing the right source .txt
    - `ls library/*.md | wc -l` returns 11
    - No file contains forbidden frontmatter fields (D-04)
    - Original wording preserved verbatim
  </acceptance_criteria>
  <done>library/ contains exactly 11 .md files, all conforming to D-03 frontmatter and D-01 verbatim rule.</done>
</task>

</tasks>

<verification>
- `ls library/*.md | wc -l` → 11
- All 11 files have the 4 locked frontmatter fields and only those 4 (D-03, D-04)
- All 11 files reference their D-02-mapped source .txt in `source:`
- All 11 files preserve original wording (spot-check distinctive phrases)
</verification>

<success_criteria>
ROADMAP Phase 1 success criterion #1 satisfied: User can open `library/` and find 11 named .md files covering goals, meals, recipes, portions, cooking rules, preferences, training nutrition, calorie targets, macro templates, daily structure, and fast-food rules.
</success_criteria>

<output>
After completion, create `.planning/phases/01-foundation/01-01-SUMMARY.md` documenting: files created, total line counts, any judgement calls about "list-shaped" lines.
</output>
