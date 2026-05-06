---
phase: 03-slash-commands
plan: "06"
type: execute
wave: 2
depends_on:
  - "03-00"
files_modified:
  - .claude/commands/swap-meal.md
autonomous: true
requirements:
  - CMD-06

must_haves:
  truths:
    - "Running /swap-meal mid-day returns 1-3 alternative meals from library/meals.md that fit the remaining macro budget"
    - "The command identifies which person and which meal slot from the chat context or asks if unclear"
    - "Remaining macros = today's CAL-02 target minus already-logged meals' estimates"
    - "Alternatives are filtered by the same archetype (lunch/dinner/etc.) and macro fit"
    - "Each option is presented with its library reference"
    - "The command never writes a file"
    - "If no daily log exists yet, the command asks for remaining macro budget intent instead of failing"
  artifacts:
    - path: ".claude/commands/swap-meal.md"
      provides: "/swap-meal slash command"
      contains: "description: , argument-hint:"
  key_links:
    - from: ".claude/commands/swap-meal.md"
      to: "trackers/{person}/daily/{today}.md"
      via: "reads logged meals to compute remaining macros"
      pattern: "trackers.*daily"
    - from: ".claude/commands/swap-meal.md"
      to: "library/meals.md"
      via: "searches for alternative meals in the same archetype"
      pattern: "library/meals"
    - from: ".claude/commands/swap-meal.md"
      to: "library/cal-02-contract.md"
      via: "resolves today's kcal/macro target"
      pattern: "cal-02-contract"
---

<objective>
Create the `/swap-meal` slash command file. This is the lightest command in the set: read the current state of today's daily log, compute remaining macro budget, search the meal library for alternatives in the same slot that fit, and return 1-3 options. Chat-only — no file write.

Purpose: Let either person change a planned meal mid-day without blowing their macros, with zero manual calculation.

Output: `.claude/commands/swap-meal.md`
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/execute-plan.md
@$HOME/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/phases/03-slash-commands/03-CONTEXT.md
@.claude/commands/README.md
@library/cal-02-contract.md
</context>

<interfaces>
<!-- Key file shapes the executor needs. -->

From library/cal-02-contract.md:
  Input: { date: YYYY-MM-DD, person: jonas | farva }
  Output includes: kcal_total, protein_g, carb_g, fat_g (for the full day target)

From trackers/{person}/daily/{today}.md:
  ## Meals section: already-logged meal lines with library:meals#{anchor} refs
  Macro estimates derived from anchor lookups in library/meals.md

Remaining macros = CAL-02 target − sum of all already-logged meal estimates.

library/meals.md: meals keyed by H2/H3 anchor; each section includes archetype
  (breakfast / lunch / dinner / snack) and rough macro profile.

library/macro-templates.md: macro archetypes per session_type — used to confirm
  that a candidate alternative fits today's training context.

No file write on any path (D-24).
</interfaces>

<tasks>

<task type="auto">
  <name>Task 1: Write .claude/commands/swap-meal.md</name>
  <files>.claude/commands/swap-meal.md</files>
  <action>
Create `.claude/commands/swap-meal.md` with the following structure (per D-01, D-02):

**Frontmatter:**
```
---
description: Get a mid-day meal alternative from the library that fits your remaining macros.
argument-hint:
---
```

**Prompt body** — imperative instructions to Claude covering D-23 and D-24:

---

**Step 1 — Identify person and meal slot (D-23)**
Read the user's message for person and slot context. Rules:
- If the user names a person ("swap Jonas's lunch"): scope to that person.
- If no person is named: ask "Who is the swap for — Jonas or Farva?" before continuing.
- If a meal slot is named (lunch / dinner / snack): use it.
- If no slot is named: ask "Which meal slot — lunch, dinner, or snack?"

Keep the ask to one question if possible (combine person + slot into one if both are missing: "Who is the swap for, and which slot — e.g. 'Jonas, lunch'?").

**Step 2 — Read today's daily log (D-23)**
Read `trackers/{person}/daily/{today}.md`.
- If the file does not exist: say "No logged meals yet today for {Person}. What was your remaining macro budget intent? (E.g. 'about 600 kcal, high protein')" — then use the user's stated intent as the remaining budget for Step 4.
- If the file exists: extract the `## Meals` lines. For each meal already logged, look up its `library:meals#{anchor}` in `library/meals.md` to get its estimated macros (kcal, protein_g, carb_g, fat_g). Sum across all logged meals.

**Step 3 — Resolve today's CAL-02 target**
Read `library/cal-02-contract.md` for schema. Then resolve for this person and today's date:
- `library/calorie-targets.md` (formula) → base_kcal
- `library/macro-templates.md` (archetype for today's session_type)
- `calendar/cycling-2026.md` (Jonas only: session_type + training_est_kcal)
Compute daily totals: kcal_total, protein_g, carb_g, fat_g.

**Step 4 — Compute remaining budget (D-23)**
remaining_kcal = kcal_total − sum_logged_kcal
remaining_protein_g = protein_g − sum_logged_protein_g
remaining_carb_g = carb_g − sum_logged_carb_g
remaining_fat_g = fat_g − sum_logged_fat_g

State remaining budget in chat before showing options: "Remaining budget for {Person}: ~{remaining_kcal} kcal, {remaining_protein_g}g protein, {remaining_carb_g}g carb, {remaining_fat_g}g fat."

**Step 5 — Search library/meals.md for alternatives (D-23)**
Read `library/meals.md`. Filter meals by:
1. Same archetype as the meal slot (lunch/dinner/snack). If dinner: include dinners and substantial lunches (multi-archetype match is fine as a fallback if no dinner-only match fits).
2. Macro profile fits within the remaining budget: kcal of the meal ≤ remaining_kcal + 10% tolerance.
3. Protein content is consistent with Jonas's `protein_floor_g_per_day` constraint (from `trackers/jonas/progress.md`) — for Jonas only; skip for Farva.
4. Do not suggest the meal slot that's already being replaced (i.e. the planned meal the user wants to swap).

Return 1–3 options. For each option:
- Meal name and `library:meals#{anchor}` reference.
- Estimated macros (kcal, protein, carb, fat).
- One-sentence note on fit (e.g. "High-protein, ~500 kcal — fits your remaining budget with 100 kcal to spare.").

If fewer than 1 option fits within budget, relax the tolerance to +20% and note: "Tight budget — closest option slightly over, but best available."

**Step 6 — Present options and close (D-24)**
Show the 1–3 options as a numbered list. Close with:
"Pick one and log it: either tell me and I'll update your daily log with `/log-day`'s smart-merge, or make the edit manually in `trackers/{person}/daily/{today}.md`."

Do not write any file. Do not make any further changes. This command is chat-only (D-24).
  </action>
  <verify>
File exists at `.claude/commands/swap-meal.md`.
`grep -c "argument-hint:\|remaining.*kcal\|library:meals\|no file\|chat-only\|smart-merge\|log-day\|CAL-02\|cal-02-contract" .claude/commands/swap-meal.md`
Should return 5 or more distinct matches.
  </verify>
  <done>`.claude/commands/swap-meal.md` exists with correct frontmatter, identifies person/slot conversationally (D-23), reads today's log to compute remaining macros (D-23), searches library for archetype-matching alternatives (D-23), returns 1-3 options with library refs, and writes no files (D-24).</done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>Created `.claude/commands/swap-meal.md` — the mid-day meal swap command that computes remaining macros and returns library alternatives.</what-built>
  <how-to-verify>
Manually read `.claude/commands/swap-meal.md` and confirm:
1. Frontmatter: `description:` present; `argument-hint:` empty (D-02).
2. Person/slot identification: asks if unclear; combines into one question if both missing (D-23).
3. No daily log case: asks for macro budget intent rather than failing (D-23, empty-state matrix from README).
4. Reads today's daily log, sums logged meals' macro estimates (D-23).
5. Resolves CAL-02 target (reads cal-02-contract.md + calorie-targets.md + macro-templates.md + cycling-2026.md) (D-23).
6. Remaining budget shown in chat before options.
7. Filters library/meals.md by same archetype + macro fit + Jonas protein floor (D-23).
8. Returns 1-3 options with library:meals#{anchor} references.
9. Fallback for tight budgets: relax tolerance + note.
10. Absolutely no file write anywhere in the prompt body (D-24).
  </how-to-verify>
  <resume-signal>Type "approved" or describe what is missing or incorrect.</resume-signal>
</task>

</tasks>

<verification>
- `.claude/commands/swap-meal.md` exists
- D-23: reads today's daily log, resolves CAL-02 target, computes remaining budget, searches library/meals.md by archetype + macro fit
- D-24: chat-only, no file write under any code path
- Empty-state handled: no daily log → asks for intent
- ROADMAP success criterion 6 satisfied: alternative meal from library fitting remaining macros returned mid-day
</verification>

<success_criteria>
Running `/swap-meal` mid-day returns 1-3 alternative meals from the library with their macro profiles, sized to the remaining budget for that person. No files are written. The user is directed to log the chosen swap via `/log-day` or manual edit.
</success_criteria>

<output>
After completion, create `.planning/phases/03-slash-commands/03-06-swap-meal-SUMMARY.md`
</output>
