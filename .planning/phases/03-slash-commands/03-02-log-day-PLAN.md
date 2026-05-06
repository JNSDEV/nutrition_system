---
phase: 03-slash-commands
plan: "02"
type: execute
wave: 2
depends_on:
  - "03-00"
files_modified:
  - .claude/commands/log-day.md
autonomous: true
requirements:
  - CMD-02

must_haves:
  truths:
    - "Running /log-day on a new day creates trackers/jonas/daily/YYYY-MM-DD.md and trackers/farva/daily/YYYY-MM-DD.md from templates/daily-log.md"
    - "Running /log-day again on the same day smart-merges (appends meals/notes/training; overwrites scalar actuals if supplied)"
    - "The command asks for MFP/Cronometer totals as a follow-up chat turn (two-step flow)"
    - "Meal entries are mapped to library:meals#{anchor} format; off-library items prefixed with (off-library)"
    - "A one-line diff summary is shown in chat on re-run"
    - "Training section is auto-suggested for Jonas from cycling-2026.md; blank for Farva"
    - "The command writes both people's files in one invocation by default"
  artifacts:
    - path: ".claude/commands/log-day.md"
      provides: "/log-day slash command"
      contains: "description: , argument-hint:"
  key_links:
    - from: ".claude/commands/log-day.md"
      to: "templates/daily-log.md"
      via: "instantiates template for new daily log file"
      pattern: "templates/daily-log"
    - from: ".claude/commands/log-day.md"
      to: "trackers/{person}/daily/YYYY-MM-DD.md"
      via: "writes (new) or smart-merges (existing)"
      pattern: "trackers.*daily"
    - from: ".claude/commands/log-day.md"
      to: "library/cal-02-contract.md"
      via: "resolves today's kcal target for kcal_estimate computation"
      pattern: "cal-02-contract"
---

<objective>
Create the `/log-day` slash command file. This is the most frequently used command and the most complex: it handles both first-run template instantiation and smart-merge on re-runs, a two-step MFP/Cronometer paste flow, conversational meal entry with library-anchor mapping, and a diff summary on re-run.

Purpose: Make daily logging frictionless — one command logs both people, handles partial data gracefully, and never loses prior entries.

Output: `.claude/commands/log-day.md`
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/execute-plan.md
@$HOME/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/phases/03-slash-commands/03-CONTEXT.md
@.claude/commands/README.md
@library/cal-02-contract.md
@templates/daily-log.md
</context>

<interfaces>
<!-- Key file shapes the executor needs. No exploration required. -->

From templates/daily-log.md frontmatter fields:
  title, category, person, source, last_updated, date,
  weight_kg, kcal_estimate, kcal_actual,
  protein_estimate_g, protein_actual_g,
  carb_estimate_g, carb_actual_g,
  fat_estimate_g, fat_actual_g

Meal line format (D-12 from Phase 2):
  `- {Meal slot}: {meal_name} (library:meals#{anchor}) — {free-text deviation, optional}`
  Off-library: `- {Meal slot}: (off-library) {free text}`

Smart-merge rules (D-12 from Phase 3 CONTEXT.md):
  Append: ## Meals lines, ## Notes text, ## Training text (Jonas)
  Overwrite if non-null supplied: weight_kg, kcal_actual, protein_actual_g, carb_actual_g, fat_actual_g
  Recompute: kcal_estimate and macro estimates from updated meal list
  Always update: last_updated

From library/cal-02-contract.md:
  Input: { date: YYYY-MM-DD, person: jonas | farva }
  Jonas output: session_type, base_kcal, training_est_kcal, kcal_total, protein_g, carb_g, fat_g
  Farva output: kcal_total, protein_g, carb_g, fat_g
</interfaces>

<tasks>

<task type="auto">
  <name>Task 1: Write .claude/commands/log-day.md</name>
  <files>.claude/commands/log-day.md</files>
  <action>
Create `.claude/commands/log-day.md` with the following structure (per D-01, D-02 — no positional args, defaults to today + both people):

**Frontmatter:**
```
---
description: Create or update today's daily log for Jonas and Farva — meals, weight, training, and macros.
argument-hint:
---
```

**Prompt body** — imperative instructions to Claude covering D-10, D-11, D-12, D-13. Write in clear prose with numbered steps so the command execution is unambiguous.

---

**Step 1 — Determine scope (D-10)**
Default: today's date (system clock), both Jonas and Farva. If the user specifies a different person or date in the follow-up turn, adjust accordingly.

**Step 2 — Check existing files**
For each person, check whether `trackers/{person}/daily/{today}.md` already exists.
- **New file:** proceed to Step 3 (fresh log).
- **Existing file:** proceed to Step 3 then apply smart-merge rules in Step 5.

**Step 3 — Two-step MFP/Cronometer paste flow (D-11)**
Open with one chat turn:
> "Ready to log today for Jonas and Farva. Do you have MFP/Cronometer totals to paste for either person? You can paste now, say 'no' to skip, or give me partial data — I'll fill in the rest from meal estimates."

Parse the user's reply:
- If a paste is supplied, extract kcal, protein, carb, fat numbers per person. Heuristic: look for `kcal`/`calories`, `protein`/`g protein`, `carb`/`carbohydrate`, `fat` adjacent to a number. Attribute to a person by name proximity in the paste. If a single combined paste has no names, ask which person it belongs to before proceeding.
- If the user says "no" or provides nothing, leave `kcal_actual` and macro actuals as `null` — they can be filled on a later re-run.
- Partial data (one person only) is fine — fill what you have, leave the other person's actuals as `null`.

**Step 4 — Conversational meal entry (D-13)**
Ask (in the same reply as Step 3's response, or immediately after): "What did each of you eat today?"

Map each reported item to the closest `library:meals#{anchor}` from `library/meals.md` (best-effort match by name/description). Format as:
`- {Meal slot}: {meal_name} (library:meals#{anchor}) — {deviation if any}`
If no library match exists, prefix with `(off-library)`.

**Step 5 — Resolve CAL-02 targets**
Read `library/cal-02-contract.md` for the schema. Then read:
- `library/calorie-targets.md` (formula) to get `base_kcal` for each person.
- `library/macro-templates.md` (archetype matching today's session_type).
- `calendar/cycling-2026.md` (today's row — Jonas only): session_type + training_est_kcal.

Compute `kcal_estimate` = sum of estimated kcal from each meal's library anchor. If the library anchor has no kcal data, note "estimate unavailable for {meal}" in the Notes section.

**Step 6 — Auto-suggest Training section (Jonas only)**
For Jonas's file: populate `## Training` with the cycling-2026.md row for today: session_type, planned km/hours/est. kcal. Add a note: "Edit this section if the actual session differed." Leave `## Training` blank for Farva.

**Step 7 — Write the files**
For a **new** daily log: instantiate `templates/daily-log.md`. Fill all known frontmatter fields. Populate `## Meals`, `## Training` (Jonas), `## Notes` with what is known; leave remaining placeholders explicit.

For a **re-run (smart-merge, D-12)**, apply these rules:
| Field | Rule |
|-------|------|
| `## Meals` lines | Append new lines. Do not deduplicate — same meal twice is plausibly two eating events; user removes if typo. |
| `## Notes` text | Append. |
| `## Training` text (Jonas) | Append. |
| `weight_kg` | Overwrite if a new non-null value is supplied in this session. |
| `kcal_actual`, `protein_actual_g`, `carb_actual_g`, `fat_actual_g` | Overwrite if supplied in this session. |
| `kcal_estimate` and macro estimates | Recompute from the full updated meal list. |
| `last_updated` | Always update to today. |
| All other frontmatter | Leave untouched. |

After writing, show a one-line diff summary in chat:
"Jonas: +2 meals, kcal_actual null → 2400. Farva: +1 meal." (adapt to what actually changed)

**File paths:**
- `trackers/jonas/daily/{today}.md`
- `trackers/farva/daily/{today}.md`

Both `trackers/jonas/daily/` and `trackers/farva/daily/` directories were scaffolded in Phase 2 — do not recreate them.
  </action>
  <verify>
File exists at `.claude/commands/log-day.md`. Check key decision touchpoints:
`grep -c "smart-merge\|MFP\|Cronometer\|off-library\|kcal_actual\|Templates/daily-log\|templates/daily-log\|diff summary\|append\|Append" .claude/commands/log-day.md`
Should return 5 or more distinct matches across these terms.
Also check: `grep -c "argument-hint:" .claude/commands/log-day.md` returns 1.
  </verify>
  <done>`.claude/commands/log-day.md` exists with correct Claude Code frontmatter, implements the two-step MFP paste flow (D-11), smart-merge rules for all field types (D-12), conversational meal entry with library-anchor mapping (D-13), and one-line diff summary on re-run. Both Jonas and Farva files are written per D-10.</done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>Created `.claude/commands/log-day.md` — the daily logging command with smart-merge and MFP paste parsing.</what-built>
  <how-to-verify>
Manually read `.claude/commands/log-day.md` and confirm:
1. Frontmatter: `description:` present, `argument-hint:` present and empty (D-02).
2. Two-step MFP paste flow: command opens with a question asking for MFP/Cronometer totals before writing anything (D-11).
3. Smart-merge table present, covering: Meals (append), Notes (append), Training (append), weight_kg (overwrite if supplied), kcal_actual/macros (overwrite if supplied), kcal_estimate (recompute), last_updated (always update) — D-12.
4. Conversational meal entry: maps items to `library:meals#{anchor}`, prefixes unknown items with `(off-library)` — D-13.
5. Training auto-suggested for Jonas from cycling-2026.md; blank for Farva.
6. One-line diff summary shown in chat on re-run — D-12.
7. No mention of positional args.
  </how-to-verify>
  <resume-signal>Type "approved" or describe what is missing or incorrect.</resume-signal>
</task>

</tasks>

<verification>
- `.claude/commands/log-day.md` exists
- D-10: today + both people by default
- D-11: two-step MFP/Cronometer paste flow with named-person attribution heuristic
- D-12: full smart-merge rules (append vs overwrite by field type) + diff summary
- D-13: conversational meal entry mapped to library anchors; off-library prefix
- ROADMAP success criterion 2 satisfied: daily-log files created/updated for both Jonas and Farva with training auto-suggested from cycling calendar
</verification>

<success_criteria>
Running `/log-day` initiates a two-turn conversation that ends with both Jonas's and Farva's daily-log files written (or updated). Re-running later that day appends meals and overwrites scalar actuals — never losing prior entries. The chat shows a diff summary on re-run.
</success_criteria>

<output>
After completion, create `.planning/phases/03-slash-commands/03-02-log-day-SUMMARY.md`
</output>
