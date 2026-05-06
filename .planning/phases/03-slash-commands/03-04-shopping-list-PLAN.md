---
phase: 03-slash-commands
plan: "04"
type: execute
wave: 3
depends_on:
  - "03-03"
files_modified:
  - .claude/commands/shopping-list.md
autonomous: true
requirements:
  - CMD-04

must_haves:
  truths:
    - "Running /shopping-list reads the active weekly plan and aggregates ingredients from library/recipes.md"
    - "The aggregated list is subtracted against the pantry baseline from templates/shopping-list.md"
    - "The proposed list is grouped by store section: produce / proteins / pantry / fridge / freezer"
    - "The user can inline-edit the proposal before confirming"
    - "On confirm, the command writes trackers/weekly-plans/YYYY-Www-shopping.md"
    - "If no active weekly plan exists, the command outputs an error message and stops"
  artifacts:
    - path: ".claude/commands/shopping-list.md"
      provides: "/shopping-list slash command"
      contains: "description: , argument-hint:"
  key_links:
    - from: ".claude/commands/shopping-list.md"
      to: "trackers/weekly-plans/YYYY-Www.md"
      via: "reads meal plan to extract recipe anchors"
      pattern: "weekly-plans"
    - from: ".claude/commands/shopping-list.md"
      to: "library/recipes.md"
      via: "reads ingredients per recipe anchor"
      pattern: "library/recipes"
    - from: ".claude/commands/shopping-list.md"
      to: "templates/shopping-list.md"
      via: "subtracts pantry baseline from aggregated list"
      pattern: "templates/shopping-list"
    - from: ".claude/commands/shopping-list.md"
      to: "trackers/weekly-plans/YYYY-Www-shopping.md"
      via: "writes confirmed shopping list"
      pattern: "shopping.md"
---

<objective>
Create the `/shopping-list` slash command file. This command derives a shopping list from the active weekly plan by walking each meal's recipe anchor, aggregating ingredients, subtracting pantry items already on the baseline, and presenting a grouped list for the user to edit before writing to file.

Purpose: Eliminate manual shopping list compilation — one command turns a confirmed weekly plan into a ready-to-use shopping list.

Output: `.claude/commands/shopping-list.md`
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/execute-plan.md
@$HOME/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/phases/03-slash-commands/03-CONTEXT.md
@.claude/commands/README.md
@templates/shopping-list.md
</context>

<interfaces>
<!-- Key file shapes the executor needs. -->

From templates/shopping-list.md (pantry baseline — existing file):
  Sections: dairy/protein staples, proteins, grains/starches, vegetables, canned goods, pantry/spices, extras
  Items are weekly quantities for 2 people on the standard meal rotation.
  Shopping list aggregation subtracts items from this baseline (i.e., items that are "always stocked").

From trackers/weekly-plans/YYYY-Www.md (active plan):
  Contains meal entries with library:meals#{anchor} or library:recipes#{anchor} refs.
  4-portion scaling already baked into recipe ingredients (per Phase 1 convention).

From library/recipes.md:
  Contains ingredient lists per recipe, keyed by H2/H3 heading (kebab-case = anchor).

Output file: trackers/weekly-plans/YYYY-Www-shopping.md
Store sections for grouping: produce / proteins / pantry / fridge / freezer
</interfaces>

<tasks>

<task type="auto">
  <name>Task 1: Write .claude/commands/shopping-list.md</name>
  <files>.claude/commands/shopping-list.md</files>
  <action>
Create `.claude/commands/shopping-list.md` with the following structure (per D-01, D-02):

**Frontmatter:**
```
---
description: Derive this week's shopping list from the active weekly plan and propose it before writing to file.
argument-hint:
---
```

**Prompt body** — imperative instructions to Claude covering D-18 and D-19:

---

**Step 1 — Check for active weekly plan (D-18)**
Determine this ISO week (YYYY-Www, system clock). Check whether `trackers/weekly-plans/{this-iso-week}.md` exists.
- If it does NOT exist: output "No active weekly plan — run `/weekly-plan` first to create one." and stop.

**Step 2 — Read inputs**
Read all three sources:
1. `trackers/weekly-plans/{this-iso-week}.md` — extract all meal entries. For each entry, note whether it carries a `library:recipes#{anchor}` or `library:meals#{anchor}` reference.
2. `library/recipes.md` — for each recipe anchor from Step 1, find the matching heading section and extract its ingredient list with quantities. 4-portion scaling is already baked in (per Phase 1 convention) — do not rescale.
3. `templates/shopping-list.md` — the pantry baseline. Items listed here are "always stocked"; subtract them from the aggregated list (i.e. flag them as "pantry — skip unless running low" rather than deleting entirely, so the user can override).

**Step 3 — Aggregate and group (D-19)**
Combine all ingredient quantities across all meals. Merge duplicates (e.g. chicken breast appears in 3 recipes → sum quantities). Then group the final list into these store sections:
- **Produce:** fresh vegetables, fruit
- **Proteins:** meat, fish, eggs, tofu, dairy proteins (skyr, cottage cheese, whey)
- **Pantry:** dried goods (oats, pasta, rice), canned goods, spices, sauces
- **Fridge:** milk, condiments, fresh dairy
- **Freezer:** any frozen items

For items that are in the pantry baseline, append "(pantry — skip unless running low)" in parentheses after the quantity.

**Step 4 — Propose in chat**
Present the grouped list as a markdown list in chat. At the end, say:
"Does this look right? You can edit inline ('skip eggs, I have 12', 'double the chicken') or just say 'ok' to write it."

Accept natural-language edits. Apply them to the list and show only the changed section (no need to re-render the whole list for small edits). Repeat until confirmed.

**Step 5 — Write on confirm (D-19)**
On confirmation, write `trackers/weekly-plans/{this-iso-week}-shopping.md`.

Use this frontmatter:
```yaml
---
title: Shopping List — {this-iso-week}
category: shopping-list
iso_week: {this-iso-week}
last_updated: {today}
source: trackers/weekly-plans/{this-iso-week}.md
---
```

Body: the confirmed grouped shopping list (markdown bulleted list by section). Confirm in chat: "Shopping list written to `trackers/weekly-plans/{this-iso-week}-shopping.md`. Open it on your phone while shopping."
  </action>
  <verify>
File exists at `.claude/commands/shopping-list.md`.
`grep -c "argument-hint:\|weekly-plan first\|pantry\|produce\|proteins\|aggregate\|propose\|confirm" .claude/commands/shopping-list.md`
Should return 5 or more distinct matches.
  </verify>
  <done>`.claude/commands/shopping-list.md` exists with correct frontmatter, reads the active weekly plan and errors gracefully if missing (D-18), aggregates + subtracts pantry baseline, groups by store section, proposes before writing (D-19).</done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>Created `.claude/commands/shopping-list.md` — the shopping list command that aggregates ingredients from the weekly plan and proposes before writing.</what-built>
  <how-to-verify>
Manually read `.claude/commands/shopping-list.md` and confirm:
1. Frontmatter: `description:` present; `argument-hint:` empty (D-02).
2. Missing-plan guard: outputs error and stops if `trackers/weekly-plans/{iso-week}.md` does not exist (D-18).
3. Reads `library/recipes.md` for ingredient extraction by anchor (D-18).
4. Pantry baseline from `templates/shopping-list.md` is subtracted (flagged, not deleted) (D-18).
5. Grouped by store section: produce / proteins / pantry / fridge / freezer (D-19).
6. Proposal shown in chat before any file write (D-19).
7. Accepts natural-language inline edits before confirming.
8. Written file path: `trackers/weekly-plans/{iso-week}-shopping.md` with frontmatter (D-19).
  </how-to-verify>
  <resume-signal>Type "approved" or describe what is missing or incorrect.</resume-signal>
</task>

</tasks>

<verification>
- `.claude/commands/shopping-list.md` exists
- D-18: reads active weekly plan; errors to chat with prescribed message if missing; walks recipe anchors; subtracts pantry baseline
- D-19: propose-then-write with natural-language inline edit support; grouped by store section; writes to correct path with frontmatter
- ROADMAP success criterion 4 satisfied: shopping list derived from active weekly plan, normalized against pantry baseline
</verification>

<success_criteria>
Running `/shopping-list` with an active week's plan produces a grouped, baseline-subtracted shopping list in chat. The user edits inline until satisfied, then the list is written to `trackers/weekly-plans/YYYY-Www-shopping.md`. Running it without an active plan outputs the prescribed error and stops.
</success_criteria>

<output>
After completion, create `.planning/phases/03-slash-commands/03-04-shopping-list-SUMMARY.md`
</output>
