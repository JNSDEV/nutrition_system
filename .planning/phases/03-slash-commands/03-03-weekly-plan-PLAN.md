---
phase: 03-slash-commands
plan: "03"
type: execute
wave: 2
depends_on:
  - "03-00"
files_modified:
  - .claude/commands/weekly-plan.md
autonomous: true
requirements:
  - CMD-03

must_haves:
  truths:
    - "Running /weekly-plan opens with one batched chat turn asking 4 questions (fridge contents, training peak, repeat meals, dislikes)"
    - "The command proposes a 7-day plan as a markdown table before writing any file"
    - "The plan follows the dinners-first / 4-portion / consecutive-pair algorithm"
    - "The plan aligns heavier-carb recipes to long-ride days via cycling-2026.md"
    - "The user can amend the proposal conversationally before confirming"
    - "On confirm, the command writes trackers/weekly-plans/YYYY-Www.md using templates/weekly-plan.md shape"
    - "Re-running on an existing week asks amend-or-replace before proceeding"
  artifacts:
    - path: ".claude/commands/weekly-plan.md"
      provides: "/weekly-plan slash command"
      contains: "description: , argument-hint:"
  key_links:
    - from: ".claude/commands/weekly-plan.md"
      to: "trackers/weekly-plans/YYYY-Www.md"
      via: "writes on user confirm"
      pattern: "weekly-plans"
    - from: ".claude/commands/weekly-plan.md"
      to: "calendar/cycling-2026.md"
      via: "reads training load for cycling-load alignment"
      pattern: "cycling-2026"
    - from: ".claude/commands/weekly-plan.md"
      to: "library/meals.md"
      via: "selects meals for the 7-day plan"
      pattern: "library/meals"
---

<objective>
Create the `/weekly-plan` slash command file. This command drives the most complex conversational flow: a batched 4-question opener, a propose-then-write loop, cycling-load alignment, fridge/leftover integration, and an amend-or-replace guard for existing weeks.

Purpose: Turn weekly meal planning from a 20-minute deliberation into a single conversation that produces a ready-to-execute plan in `trackers/weekly-plans/`.

Output: `.claude/commands/weekly-plan.md`
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/execute-plan.md
@$HOME/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/phases/03-slash-commands/03-CONTEXT.md
@.claude/commands/README.md
@library/cal-02-contract.md
@templates/weekly-plan.md
</context>

<interfaces>
<!-- Key file shapes the executor needs. -->

From templates/weekly-plan.md (existing template shape):
  - Fixed breakfast daily: Protein overnight oats
  - Dinners in 4-portion cook pairs (e.g. Mon dinner cooked → Mon+Tue dinner)
  - Lunch = previous-day dinner leftover
  - Saturday flex: "Flex meal: chicken, beef, pasta, or eating out"
  The written trackers/weekly-plans/YYYY-Www.md should follow this structure
  but with real meal names, library anchors, and training notes per day.

ISO-week format: YYYY-Www (e.g. 2026-W19)
File to write: trackers/weekly-plans/YYYY-Www.md
Previous week file: trackers/weekly-plans/{prev-iso-week}.md (may or may not exist)

Plan algorithm (D-15):
  - 3 cook-events per week (consecutive pairs) + 1 flex day
  - Dinners first, lunches = day-prior leftovers, breakfasts rotate from library/meals.md "breakfast" archetype
  - Heavier-carb recipes on long-ride days (from cycling-2026.md session_type)
  - Lighter meals on rest days
  - Jonas protein_floor_g_per_day enforced per trackers/jonas/progress.md
</interfaces>

<tasks>

<task type="auto">
  <name>Task 1: Write .claude/commands/weekly-plan.md</name>
  <files>.claude/commands/weekly-plan.md</files>
  <action>
Create `.claude/commands/weekly-plan.md` with the following structure (per D-01, D-02):

**Frontmatter:**
```
---
description: Generate next week's 7-day meal plan conversationally, then write it to trackers/weekly-plans/.
argument-hint:
---
```

**Prompt body** — imperative instructions to Claude covering D-14, D-15, D-16, D-17:

---

**Step 1 — Check for existing plan (D-17)**
Determine this ISO week (YYYY-Www, system clock). Check whether `trackers/weekly-plans/{this-iso-week}.md` exists.
- **If it exists:** read it, display it in chat as a table, then ask: "This week's plan already exists. Do you want to amend it or replace it entirely? (amend / replace)" Wait for the answer. On "amend": load existing plan as the starting point for the proposal step. On "replace": start blank.
- **If it does not exist:** proceed directly to Step 2.

**Step 2 — Batched 4-question opener (D-14)**
Open with one single chat turn containing all four questions:
> "Let's build this week's plan. A few quick questions — answer all at once:
> 1. What's in the fridge / any leftovers to use up first?
> 2. What's your biggest training day this week? (I'll pre-fill from the cycling calendar — confirm or correct.)
>    [Pre-fill: read `calendar/cycling-2026.md` for the upcoming ISO week; identify the highest-load day by session_type or Est. kcal. State it here.]
> 3. Any meals from last week you want to repeat?
>    [Pre-fill: if `trackers/weekly-plans/{prev-iso-week}.md` exists, list last week's dinners here.]
> 4. Any dislikes, cravings, or meals to avoid this week?"

Wait for the user's reply before building the proposal.

**Step 3 — Read planning inputs**
After the user replies, read:
- `library/meals.md` — available meals with archetypes (breakfast / lunch / dinner / snack)
- `library/macro-templates.md` — macro archetypes by session_type
- `library/fast-food-rules.md` — flex-day options
- `library/preferences.md` — baseline dislikes and preferences
- `trackers/jonas/progress.md` — protein_floor_g_per_day and Heathland event phase
- `calendar/cycling-2026.md` — all session_type rows for the upcoming ISO week

**Step 4 — Apply plan algorithm (D-15)**
Build a 7-day plan following these rules in priority order:
1. Use fridge/leftovers from Q1 first — assign them to Monday or the earliest relevant slot.
2. Honor dislikes from Q4 and preferences file; honor cravings from Q4.
3. Align carb-heavy dinners (per `library/macro-templates.md`) to the long-ride/peak training day. Align lighter meals (protein-forward, lower carb) to rest days.
4. Group dinners in consecutive pairs: cook once → eat two nights. Target 3 cook-events for the week. Assign one flex day (per `library/fast-food-rules.md`).
5. Lunches default to previous-night's dinner leftover. Override only if Q1 or Q4 specifically requests otherwise.
6. Breakfasts rotate from `library/meals.md` breakfast archetype. Default: Protein overnight oats (per the established weekly-plan template pattern) unless the user specified a preference.
7. Snacks per `library/macro-templates.md` for that day's session_type.
8. Verify Jonas's protein floor across all days (protein_floor_g_per_day from progress.md). Adjust meal selections if any day falls short.

**Step 5 — Propose-then-write loop (D-16)**
Present the full week as a markdown table in chat:
| Day | Lunch | Dinner | Training | Notes |
|-----|-------|--------|----------|-------|
(one row per day; include library:meals#{anchor} references; flag cook-days with "COOK")

Then say: "Does this work? Say 'ok' to write it, or tell me what to change (e.g. 'swap Tue dinner', 'more protein Thu')."

Accept natural-language edits. Amend the proposal inline and re-show the updated table. Repeat until the user says "ok" / "write it" / "looks good" or equivalent.

**Step 6 — Write the file**
On confirm, write `trackers/weekly-plans/{this-iso-week}.md`. Create the `trackers/weekly-plans/` directory if it does not exist.

Use the structure from `templates/weekly-plan.md` as the shape guide, but populate with real meal names and `library:meals#{anchor}` refs. Add frontmatter:
```yaml
---
title: Weekly Plan — {this-iso-week}
category: weekly-plan
iso_week: {this-iso-week}
last_updated: {today}
---
```

Confirm in chat: "Written to `trackers/weekly-plans/{this-iso-week}.md`. Run `/shopping-list` to generate the shopping list."
  </action>
  <verify>
File exists at `.claude/commands/weekly-plan.md`.
`grep -c "argument-hint:\|amend or replace\|4 questions\|consecutive\|propose\|COOK\|weekly-plans" .claude/commands/weekly-plan.md`
Should return 5 or more distinct matches.
  </verify>
  <done>`.claude/commands/weekly-plan.md` exists with correct frontmatter, implements the batched 4-question opener (D-14), dinners-first / consecutive-pairs / cycling-load algorithm (D-15), propose-then-write loop with natural-language amendments (D-16), and amend-or-replace guard for existing weeks (D-17).</done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>Created `.claude/commands/weekly-plan.md` — the weekly planning command with conversational 4-question opener and propose-then-write loop.</what-built>
  <how-to-verify>
Manually read `.claude/commands/weekly-plan.md` and confirm:
1. Frontmatter: `description:` present; `argument-hint:` empty (D-02).
2. Amend-or-replace guard for existing plans is the first step (D-17).
3. Batched 4-question opener in one chat turn — all four topics present: fridge/leftovers, training peak (with pre-fill from cycling-2026.md), repeat meals (with pre-fill from prior week), dislikes/cravings (D-14).
4. Plan algorithm includes: consecutive dinner pairs (3 cook-events), cycling-load alignment, leftover lunches, protein floor check for Jonas (D-15).
5. Proposal shown as a markdown table before writing (D-16).
6. Command accepts natural-language amendments and re-shows table.
7. File write only occurs on "ok" / confirm — not before.
8. File path written: `trackers/weekly-plans/{iso-week}.md` with frontmatter.
  </how-to-verify>
  <resume-signal>Type "approved" or describe what is missing or incorrect.</resume-signal>
</task>

</tasks>

<verification>
- `.claude/commands/weekly-plan.md` exists
- D-14: single batched 4-question opener with cycling-calendar pre-fill for Q2 and prior-week pre-fill for Q3
- D-15: dinners-first algorithm with consecutive pairs, cycling-load alignment, protein-floor check
- D-16: propose-then-write; natural-language amendment loop; write only on confirm
- D-17: amend-or-replace guard for existing week
- ROADMAP success criterion 3 satisfied: 7-day meal plan from library/meals.md respecting 4-portion convention and cycling load
</verification>

<success_criteria>
Running `/weekly-plan` opens with one batched turn, receives one reply, then proposes a full 7-day table. The user can amend conversationally. On "ok", the file is written to `trackers/weekly-plans/YYYY-Www.md`. Re-running when a plan exists asks amend-or-replace before proceeding.
</success_criteria>

<output>
After completion, create `.planning/phases/03-slash-commands/03-03-weekly-plan-SUMMARY.md`
</output>
