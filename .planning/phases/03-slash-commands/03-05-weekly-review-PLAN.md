---
phase: 03-slash-commands
plan: "05"
type: execute
wave: 2
depends_on:
  - "03-00"
files_modified:
  - .claude/commands/weekly-review.md
autonomous: true
requirements:
  - CMD-05

must_haves:
  truths:
    - "Running /weekly-review writes weekly-summary files for both Jonas and Farva"
    - "Each file contains 7-day weight average, adherence %, training totals (Jonas only), and an adjustment proposal"
    - "The adjustment proposal applies the three rules from library/calorie-targets.md (>0.8 kg, <0.3 kg x2, on-track)"
    - "After writing, the command asks in chat whether to apply each person's adjustment to progress.md"
    - "On 'yes', the command appends a weekly_kcal_adjustments entry to progress.md frontmatter and records the applied adjustment in the weekly-summary file"
    - "The weekly-summary file is written even when <4 weight readings exist (with 'insufficient data' flag)"
    - "Farva's file has no Training section; her adjustment proposal is shorter"
  artifacts:
    - path: ".claude/commands/weekly-review.md"
      provides: "/weekly-review slash command"
      contains: "description: , argument-hint:"
  key_links:
    - from: ".claude/commands/weekly-review.md"
      to: "trackers/{person}/daily/*.md"
      via: "reads weight_kg and kcal_actual from each daily file in the completed ISO week"
      pattern: "trackers.*daily"
    - from: ".claude/commands/weekly-review.md"
      to: "trackers/{person}/weekly/YYYY-Www.md"
      via: "writes weekly-summary file"
      pattern: "trackers.*weekly"
    - from: ".claude/commands/weekly-review.md"
      to: "trackers/{person}/progress.md"
      via: "appends weekly_kcal_adjustments entry on 'yes'"
      pattern: "progress.md"
    - from: ".claude/commands/weekly-review.md"
      to: "library/calorie-targets.md"
      via: "reads adjustment rules and kcal formula"
      pattern: "calorie-targets"
---

<objective>
Create the `/weekly-review` slash command file. This is the most calculation-heavy command: it reads all daily logs for the most recently completed ISO week, computes averages and adherence, applies adjustment rules, writes two weekly-summary files, and then asks whether to apply each adjustment to progress.md.

Purpose: Close the weekly feedback loop — one command reviews what happened, proposes what to change, and (with confirmation) writes the adjustment so next week's targets are current.

Output: `.claude/commands/weekly-review.md`

Note on D-22 decision (resolved by planner): When an adjustment is applied to `progress.md`, append to a `weekly_kcal_adjustments` list in the frontmatter (schema documented in `.claude/commands/README.md`). Do not overwrite `target_weight_kg` or `target_date` — those are milestone goals, not weekly levers. The delta is additive on top of `base_kcal` from the CAL-02 formula.
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/execute-plan.md
@$HOME/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/phases/03-slash-commands/03-CONTEXT.md
@.claude/commands/README.md
@library/cal-02-contract.md
@templates/weekly-summary.md
</context>

<interfaces>
<!-- Key file shapes the executor needs. -->

From templates/weekly-summary.md frontmatter:
  title, category, person, source, last_updated, iso_week

Sections: ## Weight, ## Adherence, ## Training (Jonas only), ## Adjustment proposal

Weight rule: mean of weight_kg from daily files. If n < 4: "n=X/7 — insufficient data for trend". Else compute trend = this-week-mean − previous-week-mean.

Adherence rule: for each day, prefer kcal_actual over kcal_estimate. Day adherent if within ±10% of CAL-02 kcal_total for that day. Days with neither = "no data", excluded from denominator.

Training (Jonas only): sum km/hours/training_est_kcal from cycling-2026.md rows for the ISO week.

Adjustment rules (D-21):
  (a) loss > 0.8 kg this week → +200 kcal/day next week (carb-loaded on training days)
  (b) loss < 0.3 kg/week for 2 consecutive weeks → −150 kcal/day
  (c) on track → maintain ("on track — propose no change")
  If library/calorie-targets.md specifies different exact thresholds, those win.

D-22 adjustment field schema (per README.md):
  weekly_kcal_adjustments:
    - week: YYYY-Www
      delta_kcal_per_day: +200
      reason: ">0.8 kg/wk loss — adding carbs on training days"
      applied: YYYY-MM-DD

progress.md Phase 2 frontmatter fields to preserve (DO NOT overwrite):
  start_weight_kg, target_weight_kg, target_date, secondary_target_kg,
  secondary_target_date, event, event_window, protein_floor_g_per_day
  (update only: last_updated, weekly_kcal_adjustments)

ISO week reviewed = the most recently COMPLETED ISO week (i.e. last Monday–Sunday block, not the current in-progress week).
</interfaces>

<tasks>

<task type="auto">
  <name>Task 1: Write .claude/commands/weekly-review.md</name>
  <files>.claude/commands/weekly-review.md</files>
  <action>
Create `.claude/commands/weekly-review.md` with the following structure (per D-01, D-02):

**Frontmatter:**
```
---
description: Review last week for Jonas and Farva — weight trend, adherence, training, and kcal adjustment proposal.
argument-hint:
---
```

**Prompt body** — imperative instructions to Claude covering D-20, D-21, D-22:

---

**Step 1 — Determine the review week (D-21)**
Compute the most recently completed ISO week: the Monday–Sunday block that ended most recently before today. This is NOT the current in-progress week. State the ISO week (YYYY-Www) in chat at the start: "Reviewing week {YYYY-Www}."

Default: both Jonas and Farva. If the user specifically named one person in the invocation context, scope to that person only.

**Step 2 — Read daily logs for the review week**
For each person, read all `trackers/{person}/daily/*.md` files whose `date` frontmatter field falls within the review ISO week (Monday through Sunday inclusive).

Extract per file:
- `weight_kg` (may be null)
- `kcal_actual` (prefer this) or `kcal_estimate` (fallback) — note which was used
- `date`

**Step 3 — Compute per-person metrics (D-21)**

**Weight:**
- Collect all non-null `weight_kg` readings. Count n.
- If n < 4: set the Weight section to "n={n}/7 — insufficient data for reliable trend."
- If n >= 4: compute 7-day mean. Also read the prior-week mean from the previous weekly-summary file (`trackers/{person}/weekly/{prev-iso-week}.md`) if it exists. Trend = this-week-mean − prior-week-mean. Express as "↓X.X kg" or "↑X.X kg".

**Adherence:**
- For each day in the review week: resolve `kcal_total` for that day using the CAL-02 contract (read `library/cal-02-contract.md` schema, then `library/calorie-targets.md` formula + `library/macro-templates.md` + `calendar/cycling-2026.md`).
- Day is adherent if `kcal_actual` (or `kcal_estimate` if no actual) is within ±10% of `kcal_total`.
- Days with neither actual nor estimate: "no data" — exclude from denominator.
- Report as: "{N}/7 days adherent ({pct}%)" or "{N}/{denominator} days adherent (N days no data)".

**Training (Jonas only):**
- Read `calendar/cycling-2026.md` rows for each day of the review ISO week.
- Sum: km, hours, Est. kcal.
- Note any deviations from Jonas's daily log `## Training` sections.

**Step 4 — Derive adjustment proposal (D-21)**
Read `library/calorie-targets.md` for the authoritative adjustment thresholds. If the file specifies different exact numbers than the defaults below, those win. Defaults:
- (a) weight loss > 0.8 kg this week → +200 kcal/day next week; extra carbs on training days.
- (b) weight loss < 0.3 kg/week for 2 consecutive weeks → −150 kcal/day. To check for 2 consecutive weeks: read the prior weekly-summary's `## Adjustment proposal` section to see if the same rule fired last week.
- (c) On track → "On track — maintain current targets."
- For Farva: apply only rules (a)/(b)/(c) on her targets. No training coupling. Proposal is shorter (no training-day carb detail).
- Proposal must be prose with the *why*, not just a number (per Phase 2 D-15). Example: "Weight ↓0.6 kg this week vs −0.3 kg/wk target rate → losing too fast. Suggest +100 kcal/day from carbs on long-ride days to protect Heathland build. Hold protein floor at 150–180 g."
- Reference the specific rule you applied (e.g. ">0.8 kg/wk loss = add kcal").

**Step 5 — Write both weekly-summary files (D-20)**
For each person, write `trackers/{person}/weekly/{review-iso-week}.md` using the `templates/weekly-summary.md` shape.

Frontmatter:
```yaml
---
title: {Person} — Week {review-iso-week}
category: weekly-summary
person: {person}
source: templates/weekly-summary.md
last_updated: {today}
iso_week: {review-iso-week}
---
```

Sections:
- `## Weight` — mean, n, trend (or insufficient-data flag)
- `## Adherence` — adherence count and %
- `## Training` — Jonas only; blank/omitted for Farva
- `## Adjustment proposal` — prose proposal (not yet applied)

Write both files even if data is sparse. The file always gets written; data quality is noted within the relevant section.

**Step 6 — Ask to apply adjustments (D-22)**
After writing both files, present the two proposals in one chat turn and ask:
> "Here are this week's adjustment proposals:
> - **Jonas:** {proposal summary}. Apply to `trackers/jonas/progress.md`? [yes / no / edit]
> - **Farva:** {proposal summary}. Apply to `trackers/farva/progress.md`? [yes / no / edit]"

Wait for two answers (one per person; can be given in one reply).

**On "yes" for a person:**
1. Read `trackers/{person}/progress.md`.
2. Append to (or create) the `weekly_kcal_adjustments` list in frontmatter:
   ```yaml
   - week: {review-iso-week}
     delta_kcal_per_day: {+200 or -150 or 0}
     reason: "{the rule that fired, in short}"
     applied: {today}
   ```
3. Update `last_updated` to today. Preserve ALL other frontmatter fields untouched.
4. Update the `## Adjustment proposal` section in the just-written weekly-summary to append a line: "(Applied {today}: {delta} kcal/day added to progress.md.)"

**On "no" / "edit" / no rule fired:**
Do nothing further. The adjustment proposal remains as advisory prose in the weekly-summary only.

Confirm in chat which files were written and which adjustments (if any) were applied.
  </action>
  <verify>
File exists at `.claude/commands/weekly-review.md`.
`grep -c "argument-hint:\|weekly_kcal_adjustments\|±10%\|Adjustment proposal\|insufficient data\|completed ISO week\|progress.md" .claude/commands/weekly-review.md`
Should return 5 or more distinct matches.
  </verify>
  <done>`.claude/commands/weekly-review.md` exists with correct frontmatter, computes weight/adherence/training metrics per D-21, writes both weekly-summary files per D-20, proposes adjustment in chat and applies to progress.md on confirm per D-22, using the `weekly_kcal_adjustments` field schema (D-22 planner decision).</done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>Created `.claude/commands/weekly-review.md` — the weekly review command that computes metrics, writes summaries, and optionally applies kcal adjustments to progress.md.</what-built>
  <how-to-verify>
Manually read `.claude/commands/weekly-review.md` and confirm:
1. Frontmatter: `description:` present; `argument-hint:` empty (D-02).
2. Reviews the most recently COMPLETED ISO week, not the current in-progress week (D-21).
3. Weight: computes 7-day mean; flags n < 4 as "insufficient data"; computes trend vs prior week (D-21).
4. Adherence: prefers kcal_actual over kcal_estimate; uses ±10% band against CAL-02 daily target; excludes no-data days from denominator (D-21).
5. Training section is Jonas-only; Farva's file has no Training section (D-20).
6. Adjustment proposal is prose with "why", references the specific rule from library/calorie-targets.md (D-21).
7. Writes both files before asking about applying adjustments (D-20).
8. Batched confirmation ask in one chat turn (D-22).
9. On "yes": appends `weekly_kcal_adjustments` entry to progress.md frontmatter without overwriting target_weight_kg or target_date (D-22).
10. On "yes": records the applied adjustment in the weekly-summary's Adjustment proposal section (D-22).
  </how-to-verify>
  <resume-signal>Type "approved" or describe what is missing or incorrect.</resume-signal>
</task>

</tasks>

<verification>
- `.claude/commands/weekly-review.md` exists
- D-20: both weekly-summary files written; Farva's has no Training section; files written even with sparse data
- D-21: 7-day weight mean + trend, adherence % with ±10% band + no-data exclusion, training totals (Jonas), three-rule adjustment logic
- D-22: batched confirmation ask; on "yes": appends weekly_kcal_adjustments to progress.md (preserving all other fields) + records in weekly-summary; on "no": advisory prose only
- ROADMAP success criterion 5 satisfied: 7-day weight avg, trend vs target, adherence summary, adjustment grounded in established rules
</verification>

<success_criteria>
Running `/weekly-review` identifies the most recently completed ISO week, reads all daily logs for both people, computes and writes two weekly-summary files, then asks whether to apply each adjustment. On "yes", progress.md gains a `weekly_kcal_adjustments` entry and the weekly-summary records the applied change.
</success_criteria>

<output>
After completion, create `.planning/phases/03-slash-commands/03-05-weekly-review-SUMMARY.md`
</output>
