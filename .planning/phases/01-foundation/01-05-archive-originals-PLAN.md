---
phase: 01-foundation
plan: 05
type: execute
wave: 3
depends_on: [01, 02, 03]
files_modified:
  - archive/legacy-txt/01_goals.txt
  - archive/legacy-txt/02_daily_structure.txt
  - archive/legacy-txt/03_meal_library.txt
  - archive/legacy-txt/04_recipes.txt
  - archive/legacy-txt/05_portion_guidelines.txt
  - archive/legacy-txt/06_cooking_rules.txt
  - archive/legacy-txt/07_preferences.txt
  - archive/legacy-txt/08_training_nutrition.txt
  - archive/legacy-txt/09_calorie_targets.txt
  - archive/legacy-txt/10_weekly_meal_plan.txt
  - archive/legacy-txt/11_weekly_tracker_template.txt
  - archive/legacy-txt/12_macro_templates.txt
  - archive/legacy-txt/13_meal_prep_planner.txt
  - archive/legacy-txt/14_shopping_list_week.txt
  - archive/legacy-txt/15_fast_food_and_eating_out_rules.txt
  - archive/legacy-txt/README.md
autonomous: true
requirements: [LIB-03]
must_haves:
  truths:
    - "All 15 original .txt files exist under archive/legacy-txt/ with original filenames unchanged"
    - "No .txt file remains in repo root"
    - "Each archived .txt file content is byte-identical to the original (move, not edit)"
    - "archive/legacy-txt/README.md explains these are originals preserved for traceability"
  artifacts:
    - path: "archive/legacy-txt/"
      provides: "Frozen originals of the 15 source .txt files"
      contains: "(15 .txt files + 1 README.md)"
    - path: "archive/legacy-txt/README.md"
      provides: "One-paragraph explanation of archive purpose (D-14)"
      contains: "originals"
  key_links:
    - from: "library/*.md and templates/*.md `source:` frontmatter"
      to: "archive/legacy-txt/<source>.txt"
      via: "Filename match — frontmatter `source:` value resolves to a file in archive/legacy-txt/"
      pattern: "archive/legacy-txt/[0-9]+_.*\\.txt"
---

<objective>
Move (not copy) all 15 root-level `*.txt` files into `archive/legacy-txt/` with filenames unchanged, and add a one-paragraph `README.md` explaining the archive's purpose (per D-13, D-14).

Purpose: Preserves original wording for traceability while making the repo root clean. The `source:` frontmatter field in every migrated file becomes resolvable to its archived original.
Output: 15 .txt files relocated under `archive/legacy-txt/`, plus `archive/legacy-txt/README.md`.

**Sequencing rationale:** This plan runs in Wave 3 because Plans 01, 02, and 03 must complete first — sources must already be migrated to .md before originals are moved out of root, otherwise mid-execution the migration tasks would have nothing to read.
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/execute-plan.md
@$HOME/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/ROADMAP.md
@.planning/STATE.md
@.planning/phases/01-foundation/01-CONTEXT.md
</context>

<tasks>

<task type="auto">
  <name>Task 1: Move all 15 .txt files into archive/legacy-txt/</name>
  <read_first>
    - .planning/phases/01-foundation/01-CONTEXT.md (D-13, D-14 archive rules)
    - (Optional) `ls *.txt` in repo root to confirm 15 files present before moving
  </read_first>
  <files>archive/legacy-txt/01_goals.txt through archive/legacy-txt/15_fast_food_and_eating_out_rules.txt</files>
  <action>
    1. Verify Plans 01, 02, 03 succeeded: check that `library/` has 11 .md files, `templates/` has 4 .md files, and `calendar/cycling-2026.md` exists. If any missing, ABORT — do not move originals before migrations are confirmed.
    2. `mkdir -p archive/legacy-txt`
    3. Detect git tracking: run `git ls-files --error-unmatch 01_goals.txt 2>/dev/null`. If it succeeds (file is git-tracked), use `git mv` for all 15 files. Otherwise use plain `mv`.
    4. Move each of the 15 .txt files individually (preserves filenames exactly):
       ```
       <git mv|mv> 01_goals.txt archive/legacy-txt/
       <git mv|mv> 02_daily_structure.txt archive/legacy-txt/
       <git mv|mv> 03_meal_library.txt archive/legacy-txt/
       <git mv|mv> 04_recipes.txt archive/legacy-txt/
       <git mv|mv> 05_portion_guidelines.txt archive/legacy-txt/
       <git mv|mv> 06_cooking_rules.txt archive/legacy-txt/
       <git mv|mv> 07_preferences.txt archive/legacy-txt/
       <git mv|mv> 08_training_nutrition.txt archive/legacy-txt/
       <git mv|mv> 09_calorie_targets.txt archive/legacy-txt/
       <git mv|mv> 10_weekly_meal_plan.txt archive/legacy-txt/
       <git mv|mv> 11_weekly_tracker_template.txt archive/legacy-txt/
       <git mv|mv> 12_macro_templates.txt archive/legacy-txt/
       <git mv|mv> 13_meal_prep_planner.txt archive/legacy-txt/
       <git mv|mv> 14_shopping_list_week.txt archive/legacy-txt/
       <git mv|mv> 15_fast_food_and_eating_out_rules.txt archive/legacy-txt/
       ```
    5. Do NOT edit, reformat, or otherwise modify file contents. The archive holds bit-for-bit originals.
  </action>
  <verify>
    <automated>ls library/*.md | wc -l | grep -qx '      11' && ls templates/*.md | wc -l | grep -qx '       4' && test -f calendar/cycling-2026.md || { echo "ABORT: prereq plans incomplete"; exit 1; }; for f in 01_goals 02_daily_structure 03_meal_library 04_recipes 05_portion_guidelines 06_cooking_rules 07_preferences 08_training_nutrition 09_calorie_targets 10_weekly_meal_plan 11_weekly_tracker_template 12_macro_templates 13_meal_prep_planner 14_shopping_list_week 15_fast_food_and_eating_out_rules; do test -f "archive/legacy-txt/$f.txt" || { echo "MISSING: $f"; exit 1; }; test ! -f "./$f.txt" || { echo "STILL IN ROOT: $f"; exit 1; }; done; ls archive/legacy-txt/*.txt | wc -l | grep -qx '      15' && echo OK</automated>
  </verify>
  <acceptance_criteria>
    - `archive/legacy-txt/` directory exists
    - All 15 files exist at `archive/legacy-txt/<original-name>.txt` with original filenames unchanged
    - None of the 15 .txt files remain in repo root (`! test -f ./01_goals.txt`, etc., for all 15)
    - `ls archive/legacy-txt/*.txt | wc -l` returns 15
    - File contents byte-identical to pre-move originals (no editing)
  </acceptance_criteria>
  <done>All 15 originals are archived; repo root contains no loose .txt files.</done>
</task>

<task type="auto">
  <name>Task 2: Add archive/legacy-txt/README.md</name>
  <read_first>
    - .planning/phases/01-foundation/01-CONTEXT.md (D-14 — short paragraph, no edits message)
  </read_first>
  <files>archive/legacy-txt/README.md</files>
  <action>
    Create `archive/legacy-txt/README.md` with exactly this content (D-14: tiny, one paragraph):

```
# Archive — legacy .txt originals

These 15 `.txt` files are the original Phase-0 knowledge dump. They were
migrated verbatim into `library/*.md` and `templates/*.md` during Phase 1
(see each migrated file's frontmatter `source:` field for the mapping).
They are preserved here unmodified for traceability and original-phrasing
audit. **Do not edit them.** If knowledge needs updating, update the
corresponding `.md` file in `library/` or `templates/` instead.
```

    No frontmatter — this is a plain README, not part of the indexed knowledge base.
  </action>
  <verify>
    <automated>test -f archive/legacy-txt/README.md && grep -q "originals" archive/legacy-txt/README.md && grep -q "Do not edit" archive/legacy-txt/README.md && grep -q "library/" archive/legacy-txt/README.md && echo OK</automated>
  </verify>
  <acceptance_criteria>
    - `archive/legacy-txt/README.md` exists
    - Contains the word `originals`
    - Contains the phrase `Do not edit`
    - References `library/` (the migration target)
    - File is short (≤ 15 lines, one paragraph per D-14)
  </acceptance_criteria>
  <done>Archive directory has its README; the archive is self-documenting.</done>
</task>

</tasks>

<verification>
- All 15 originals present at `archive/legacy-txt/<name>.txt`
- Zero .txt files remain in repo root
- `archive/legacy-txt/README.md` present
- Repo root after this plan contains only: `archive/`, `library/`, `templates/`, `calendar/`, `.planning/`, `CLAUDE.md` (per D-13)
</verification>

<success_criteria>
ROADMAP Phase 1 success criterion #3 satisfied: User can open `archive/legacy-txt/` and confirm all 15 original `.txt` files are present and unmodified.
</success_criteria>

<output>
After completion, create `.planning/phases/01-foundation/01-05-SUMMARY.md` documenting: files moved, move method (git mv vs mv), final state of repo root.
</output>
