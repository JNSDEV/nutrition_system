---
phase: 01-foundation
plan: 04
type: execute
wave: 2
depends_on: [01, 02]
files_modified:
  - library/README.md
autonomous: true
requirements: [LIB-04]
must_haves:
  truths:
    - "User can open library/README.md and see a one-line index entry for every file in library/ and templates/"
    - "User can read library/README.md and understand how library / templates / trackers / commands relate"
    - "Document stays one page (no deep dive into individual commands)"
  artifacts:
    - path: "library/README.md"
      provides: "Orientation doc for the knowledge base"
      contains: "## What's here"
  key_links:
    - from: "library/README.md"
      to: "library/*.md and templates/*.md"
      via: "Structure index lists every migrated filename with one-line descriptor"
      pattern: "- (goals|meals|recipes|portions|cooking-rules|preferences|training-nutrition|calorie-targets|macro-templates|daily-structure|fast-food-rules)\\.md"
---

<objective>
Create `library/README.md` — a one-page orientation doc that (a) indexes every file in `library/` and `templates/` with a one-line descriptor, and (b) explains how library, templates, trackers, and commands fit together (per D-10..D-12).

Purpose: Cold Claude sessions and Jonas/Partner as humans both need a single entry point to navigate the knowledge base.
Output: One markdown file at `library/README.md`.
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

<tasks>

<task type="auto">
  <name>Task 1: Write library/README.md</name>
  <read_first>
    - .planning/phases/01-foundation/01-CONTEXT.md (D-10..D-12 README scope)
    - .planning/PROJECT.md (operating loop section, lines ~84–99, for the loop primer)
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
    - templates/weekly-plan.md
    - templates/weekly-tracker.md
    - templates/meal-prep-planner.md
    - templates/shopping-list.md
    (Read each to derive an accurate one-line descriptor from the H1 + first non-frontmatter prose paragraph.)
  </read_first>
  <files>library/README.md</files>
  <action>
    Create `library/README.md` with this exact structure:

```
---
title: Library
category: library
source: <discussion>
last_updated: 2026-05-05
---

# Library

This file is the entry point to the durable knowledge base. It indexes every
file in `library/` and `templates/`, and explains how the four content areas
(library, templates, trackers, slash commands) fit together.

## What's here

### library/ — durable knowledge (read-only by commands)

- goals.md — <one-line descriptor based on file content>
- daily-structure.md — <descriptor>
- meals.md — <descriptor>
- recipes.md — <descriptor>
- portions.md — <descriptor>
- cooking-rules.md — <descriptor>
- preferences.md — <descriptor>
- training-nutrition.md — <descriptor>
- calorie-targets.md — <descriptor>
- macro-templates.md — <descriptor>
- fast-food-rules.md — <descriptor>

### templates/ — forms commands fill in

- weekly-plan.md — <descriptor>
- weekly-tracker.md — <descriptor>
- meal-prep-planner.md — <descriptor>
- shopping-list.md — <descriptor>

## How this fits

- **library/** = durable knowledge. Slash commands read it; humans edit it directly when knowledge changes.
- **templates/** = blank forms. Slash commands (Phase 3) clone these and fill them in for a specific week or day.
- **trackers/** = per-person logs (Phase 2 — Jonas and Partner each get a `daily/`, `weekly/`, and `progress.md`). Slash commands write here.
- **calendar/cycling-2026.md** = single source of truth for Jonas's training load. Phase 2 commands resolve "today's row" to set Jonas's daily kcal target.
- **Slash commands** (Phase 3) read library + calendar + trackers, and write into trackers. The six commands are: `/prep-today`, `/log-day`, `/weekly-plan`, `/shopping-list`, `/weekly-review`, `/swap-meal`.

## What's next

A top-level `README.md` (Phase 4) will explain the full daily/weekly operating
loop and the mobile-logging pattern. This file stays narrowly focused on the
content layout.
```

    Substitute each `<descriptor>` with a concise one-liner derived from the H1 + opening prose of the corresponding file. Examples (style, not content):
    - `goals.md — Jonas's and Partner's weight + performance targets`
    - `meals.md — Catalogue of recurring meals with rough macro shape`

    Keep the document under ~80 lines (D-11: stays one page). Do not enumerate the 6 commands' behaviour beyond their names — those don't exist yet.

    Frontmatter per D-12: `category: library`, `source: <discussion>`, plus `title` and `last_updated: 2026-05-05`.
  </action>
  <verify>
    <automated>test -f library/README.md && head -1 library/README.md | grep -qx '\-\-\-' && grep -q "^category: library$" library/README.md && grep -q "^source: <discussion>$" library/README.md && grep -q "^last_updated: 2026-05-05$" library/README.md && grep -q "^## What's here$" library/README.md && grep -q "^## How this fits$" library/README.md && for f in goals daily-structure meals recipes portions cooking-rules preferences training-nutrition calorie-targets macro-templates fast-food-rules weekly-plan weekly-tracker meal-prep-planner shopping-list; do grep -q "^- $f\.md " library/README.md || { echo "MISSING: $f"; exit 1; }; done && wc -l library/README.md | awk '{ if ($1 > 100) { print "TOO LONG"; exit 1 } else { print "OK" } }'</automated>
  </verify>
  <acceptance_criteria>
    - `library/README.md` exists
    - Line 1 is `---`
    - Contains `category: library`
    - Contains `source: <discussion>`
    - Contains `last_updated: 2026-05-05`
    - Contains `## What's here`
    - Contains `## How this fits`
    - Contains one `- <name>.md ` line for every one of the 11 library files (goals, daily-structure, meals, recipes, portions, cooking-rules, preferences, training-nutrition, calorie-targets, macro-templates, fast-food-rules)
    - Contains one `- <name>.md ` line for every one of the 4 template files (weekly-plan, weekly-tracker, meal-prep-planner, shopping-list)
    - Total length ≤ 100 lines (one page per D-11)
    - Names all 6 commands by name only; does NOT describe their full behaviour
  </acceptance_criteria>
  <done>library/README.md exists, indexes all 15 migrated files, explains the four-area model, fits one page.</done>
</task>

</tasks>

<verification>
- File exists with correct frontmatter
- All 15 migrated files appear in the structure index
- Loop primer covers library / templates / trackers / commands relationship
- Document is one page (≤ 100 lines)
</verification>

<success_criteria>
ROADMAP Phase 1 success criterion #4 satisfied: User can read `library/README.md` and understand how library, templates, and trackers relate to each other and to the slash commands.
</success_criteria>

<output>
After completion, create `.planning/phases/01-foundation/01-04-SUMMARY.md` documenting: file created, line count, descriptor sources.
</output>
