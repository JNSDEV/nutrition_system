---
phase: 03-slash-commands
plan: "01"
type: execute
wave: 2
depends_on:
  - "03-00"
files_modified:
  - .claude/commands/prep-today.md
autonomous: true
requirements:
  - CMD-01

must_haves:
  truths:
    - "Running /prep-today produces a chat brief naming today's specific meal from the active weekly plan"
    - "The brief includes a portion split (Jonas vs Farva) with Heathland-build context if today is a training day"
    - "The brief includes a thaw/pull-from-fridge note for tomorrow"
    - "The brief includes a leftover note if today's dinner is from a previous batch"
    - "If no weekly plan exists for this ISO week, the command outputs 'run /weekly-plan first' and stops"
    - "The command never writes a file"
  artifacts:
    - path: ".claude/commands/prep-today.md"
      provides: "/prep-today slash command"
      contains: "description: , argument-hint:"
  key_links:
    - from: ".claude/commands/prep-today.md"
      to: "trackers/weekly-plans/{iso-week}.md"
      via: "reads active plan to identify today's meals"
      pattern: "weekly-plans"
    - from: ".claude/commands/prep-today.md"
      to: "calendar/cycling-2026.md"
      via: "reads today's session_type for training context"
      pattern: "cycling-2026"
---

<objective>
Create the `/prep-today` slash command file. When invoked, this command delivers a short, actionable cooking/portioning brief for today: what to cook, what to pull forward for tomorrow, how to split portions between Jonas and Farva given today's training load, and whether today's dinner draws from a prior batch.

Purpose: Eliminate the daily "what should I cook?" decision by surfacing the answer directly from the active weekly plan and library guidance.

Output: `.claude/commands/prep-today.md`
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
<!-- Key file shapes the executor needs. No exploration required. -->

From templates/daily-log.md:
Meal line format: `- {Meal slot}: {meal_name} (library:meals#{anchor}) — {free-text deviation, optional}`

From library/cal-02-contract.md:
Input: `{ date: ISO (YYYY-MM-DD), person: jonas | farva }`
Jonas output includes: `session_type`, `kcal_total`, `training_est_kcal`, `protein_g`, `carb_g`, `fat_g`
Farva output includes: `kcal_total`, `protein_g`, `carb_g`, `fat_g`

trackers/weekly-plans/YYYY-Www.md — active week's plan (read-only by this command)
calendar/cycling-2026.md — session_type + Est. kcal per date
library/cooking-rules.md — cooking guidance
library/portions.md — portioning guidance
library/training-nutrition.md — training-day fueling rules (for Jonas Heathland build)
</interfaces>

<tasks>

<task type="auto">
  <name>Task 1: Write .claude/commands/prep-today.md</name>
  <files>.claude/commands/prep-today.md</files>
  <action>
Create `.claude/commands/prep-today.md` with the following structure (per D-01, D-02 — no positional args):

**Frontmatter:**
```
---
description: Get today's cooking and portioning brief — what to cook, what to thaw, and how to split portions.
argument-hint:
---
```

**Prompt body** — this is the prompt the model sees at invocation. Write it as imperative instructions to Claude. Cover all of D-07, D-08, D-09:

1. **Determine today's ISO week** (YYYY-Www, system clock). Check whether `trackers/weekly-plans/{this-iso-week}.md` exists.
   - If it does NOT exist: output exactly "No weekly plan for this week — run `/weekly-plan` first." and stop. Do not improvise a plan (D-09).

2. **Read the active weekly plan** from `trackers/weekly-plans/{this-iso-week}.md`. Find today's entry (match by date or day-of-week).

3. **Read `calendar/cycling-2026.md`** for today's session_type and Est. kcal burn. Use the standard-week table for Mon–Sat, the Sunday-progression table for Sundays (per CAL-02 contract pattern). Cross-reference `library/training-nutrition.md` if today is a training day to note any fueling priority for Jonas's Heathland build.

4. **Read `library/cooking-rules.md`** and `library/portions.md` for portioning guidance.

5. **Output a chat brief** structured as four labelled sections:

   **(a) What to cook today**
   Name the recipe(s) for today's dinner (and any other cook-from-scratch meal). Include the `library:meals#{anchor}` reference. Note if this is a 4-portion cook (feeds Mon+Tue dinner, or similar pair).

   **(b) What to thaw / pull from fridge for tomorrow**
   Based on tomorrow's entry in the weekly plan. If tomorrow's meal is from today's batch (leftover), state that. If it requires a separate thaw (e.g. frozen protein), name it specifically.

   **(c) Portion split: Jonas vs Farva**
   Use today's CAL-02 resolved targets (read `library/calorie-targets.md` formula + `library/macro-templates.md` archetype matching today's session_type). State Jonas's portion and Farva's portion for dinner in plain terms (e.g. "Jonas: 550 g chicken rice bowl; Farva: 400 g"). If today is a training day for Jonas, note the carb or protein priority from `library/training-nutrition.md`. Reference `protein_floor_g_per_day` from `trackers/jonas/progress.md` if applicable.

   **(d) Leftover note**
   If today's lunch or dinner is drawn from a previous-day batch (i.e. the weekly plan shows "leftover [X]"), confirm the batch was cooked and state what portion is remaining. If no leftover is involved, omit this section.

Keep the brief scannable on mobile: short sentences, no paragraph walls. Use bold labels for the four sections.
  </action>
  <verify>
File exists at `.claude/commands/prep-today.md`. Check frontmatter fields present: `grep -c "description:\|argument-hint:" .claude/commands/prep-today.md` returns 2. Check key decision touchpoints present: `grep -c "weekly-plans\|cooking-rules\|portions\|training-nutrition\|weekly-plan first" .claude/commands/prep-today.md` returns 5 or more.
  </verify>
  <done>`.claude/commands/prep-today.md` exists with correct Claude Code frontmatter, no positional args (D-02), reads the active weekly plan (D-07), outputs a 4-section brief (D-08), and handles the missing-plan case with the exact prescribed message (D-09).</done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>Created `.claude/commands/prep-today.md` — a slash command that reads the active weekly plan and cycling calendar to produce a cooking/portioning brief.</what-built>
  <how-to-verify>
Manually read `.claude/commands/prep-today.md` and confirm:
1. Frontmatter has `description:` and `argument-hint:` (argument-hint is empty, per D-02).
2. Prompt body instructs Claude to check for `trackers/weekly-plans/{iso-week}.md` and output "run `/weekly-plan` first" if missing (D-09).
3. Prompt body includes the four sections: cook today / thaw for tomorrow / portion split / leftover note (D-08).
4. Portion split section references `library/calorie-targets.md`, `library/macro-templates.md`, and `library/training-nutrition.md` (D-08 Heathland context).
5. File reads from `library/cooking-rules.md` and `library/portions.md` (D-07).
6. No file-write instruction anywhere — this command is chat-only (D-03).
  </how-to-verify>
  <resume-signal>Type "approved" or describe what is missing or incorrect.</resume-signal>
</task>

</tasks>

<verification>
- `.claude/commands/prep-today.md` exists
- Implements D-07 (reads weekly plan + cycling calendar + cooking-rules + portions)
- Implements D-08 (4-section brief with portion split and Heathland context)
- Implements D-09 (no-plan guard with exact prescribed message)
- Chat-only output — no file write (D-03)
- ROADMAP success criterion 1 satisfied: user gets a cooking/portioning brief naming specific meals with portions split for Jonas vs Farva
</verification>

<success_criteria>
Running `/prep-today` in a session with an active weekly plan produces a cooking brief with four labelled sections, portion numbers for both Jonas and Farva, and a training-day note when applicable. Running it with no active plan outputs the prescribed fallback message and nothing else.
</success_criteria>

<output>
After completion, create `.planning/phases/03-slash-commands/03-01-prep-today-SUMMARY.md`
</output>
