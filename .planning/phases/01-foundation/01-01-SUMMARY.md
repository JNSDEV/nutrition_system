---
phase: 01-foundation
plan: 01-library-migration
subsystem: library
tags: [migration, markdown, foundation]
requires: []
provides:
  - library/ directory with 11 categorized markdown files
  - locked D-03 frontmatter contract on every library file
  - source: field linking each library .md to its origin .txt (forward link to plan 01-05 archive)
affects:
  - downstream Phase 3 slash commands (will read library/ by category + filename + H1/H2)
tech-stack:
  added: []
  patterns:
    - YAML frontmatter (4 locked fields: title, category, source, last_updated)
    - H1 derived from filename per D-02 mapping table
key-files:
  created:
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
  modified: []
decisions:
  - Honored D-01 (verbatim with minimal touch) — original section headers (e.g. "Breakfast:", "Jonas:") were left as plain prose lines rather than promoted to H2/H3, because the source .txt files use them as label-prefixed list groupings, not true heading structure. Keeping them as prose preserves the original feel and avoids implying a hierarchy that wasn't in the source.
  - Existing dash-prefixed lines were preserved as-is (already valid Markdown bullets — no transformation needed).
  - Numbered recipe headers in 04_recipes.txt (e.g. "1. Protein Overnight Oats") were left as plain text (not converted to ordered-list items or H2s) — they read as titles within prose, and the surrounding section structure (Jonas:/Partner:/Important:/Bake:) supports that interpretation.
metrics:
  duration: ~5 minutes
  completed: 2026-05-05
---

# Phase 01 Plan 01: Library Migration Summary

Migrated 11 library-shaped `.txt` files from repo root into `library/*.md` with the locked D-03 frontmatter (title, category, source, last_updated) and H1 titles per the D-02 mapping table — verbatim content preserved per D-01.

## What Was Built

`library/` directory containing 11 categorized markdown files, each with:
- 4-field YAML frontmatter (per D-03, no extra fields per D-04)
- H1 title matching the human-readable `title:` frontmatter value
- Verbatim body content from the source `.txt` (per D-01)

| File | Source | Lines |
|------|--------|-------|
| library/goals.md | 01_goals.txt | 15 |
| library/daily-structure.md | 02_daily_structure.txt | 29 |
| library/meals.md | 03_meal_library.txt | 38 |
| library/recipes.md | 04_recipes.txt | 71 |
| library/portions.md | 05_portion_guidelines.txt | 29 |
| library/cooking-rules.md | 06_cooking_rules.txt | 36 |
| library/preferences.md | 07_preferences.txt | 39 |
| library/training-nutrition.md | 08_training_nutrition.txt | 31 |
| library/calorie-targets.md | 09_calorie_targets.txt | 25 |
| library/macro-templates.md | 12_macro_templates.txt | 49 |
| library/fast-food-rules.md | 15_fast_food_and_eating_out_rules.txt | 32 |

**Total:** 394 lines across 11 files.

## Tasks Executed

| Task | Name | Commit |
|------|------|--------|
| 1 | Create library/ and migrate first 6 files | fb74408 |
| 2 | Migrate remaining 5 library files | 0f25776 |

## Acceptance Criteria

- [x] `library/` directory exists with exactly 11 `.md` files (`ls library/*.md | wc -l` → 11)
- [x] Every file opens with `---` on line 1 and the 4 locked frontmatter fields
- [x] Every file has `category: library`
- [x] Every file has `last_updated: 2026-05-05`
- [x] Every file has `source:` matching the D-02 mapping
- [x] No file contains forbidden frontmatter fields (`tags`, `applies_to`, `kcal_role`) per D-04
- [x] Original wording preserved verbatim — spot-checked distinctive phrases (e.g. "No aluminium for crisping", "226-260 g skyr", "HEATHLAND" was not in scope)
- [x] All 15 original `.txt` files still in repo root (moving them is plan 01-05's job)

## Judgement Calls (D-01 "list-shaped" interpretation)

The source `.txt` files were already structured cleanly — almost every body line was either a dash-prefixed bullet, a numbered recipe header, or a label line ending in `:` followed by bullets. No paragraph-prose lines required judgement about whether to bullet them.

Specific decisions:

1. **Section labels (`Breakfast:`, `Jonas:`, `Partner:`, `Whole cake:`, `Bake:`, `Important:`, `Optional:`, `For 4 portions:`)** — left as plain prose lines (not promoted to H2/H3). They function as inline labels for the bullet groups that follow, and the source treats them as such. Promoting them to headings would imply a navigable section hierarchy not present in the original. Phase 3 commands navigate by H1 + filename per D-04, so the absence of H2 here is intentional.
2. **Numbered recipes in `04_recipes.txt`** (`1. Protein Overnight Oats`, `2. Cottage Cheese Protein Pancakes`, etc.) — left as plain text. They function as recipe titles, and the surrounding label-line/bullet-group pattern is consistent with prose-style recipe presentation. Not converted to Markdown ordered-list items because each "item" spans many sub-bullets and would not render cleanly as a nested ordered list.
3. **Already-bulleted lines** (lines starting with `- `) — preserved exactly as-is (already valid Markdown).
4. **Blank lines between source sections** — preserved.

## Deviations from Plan

None — plan executed exactly as written. All Rule 1–4 conditions checked; no fixes or architectural questions surfaced.

## Self-Check: PASSED

Verified:
- All 11 `library/*.md` files exist on disk
- Both commits exist in `git log` (fb74408, 0f25776)
- All 15 original `.txt` files still present in repo root (verified via `ls *.txt | wc -l` → 15)
- No forbidden frontmatter fields present (verified via `grep -lE "^(tags|applies_to|kcal_role):" library/*.md` → no matches)
