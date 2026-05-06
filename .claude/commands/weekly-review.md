---
description: Review last week for Jonas and Farva — weight trend, adherence, training, and kcal adjustment proposal.
argument-hint:
---

You are running the `/weekly-review` command. This command reviews the most recently completed ISO week for both Jonas and Farva (or one person if the user named them at invocation). It computes weight trend, adherence, and training totals, writes two weekly-summary files, then asks whether to apply kcal adjustments to `progress.md`.

**Before starting,** read `library/cal-02-contract.md` for the integration contract that governs daily kcal target resolution.

---

## Step 1 — Determine the review week

Compute the most recently **completed** ISO week: the Monday–Sunday block that ended most recently before today. This is NOT the current in-progress week. ISO week format: `YYYY-Www` using Python `%G-W%V` (e.g. `2026-W19`). Week starts Monday per ISO 8601.

State the week in chat at the start: **"Reviewing week {YYYY-Www}."**

Default scope: both Jonas and Farva. If the user specifically named one person in the invocation context, scope to that person only.

---

## Step 2 — Read daily logs for the review week

For each person in scope, read all `trackers/{person}/daily/*.md` files whose `date` frontmatter field falls within the review ISO week (Monday through Sunday inclusive).

Extract per file:
- `weight_kg` (may be null)
- `kcal_actual` (prefer this) or `kcal_estimate` (fallback) — note which was used
- `date`

If no daily files exist for the review week for a person, note this and proceed — the weekly-summary file is still written with "no data" entries.

---

## Step 3 — Compute per-person metrics

### Weight

1. Collect all non-null `weight_kg` readings for the week. Count n.
2. If n < 4: set the Weight section to `"n={n}/7 — insufficient data for reliable trend."` Skip trend math.
3. If n ≥ 4: compute the 7-day mean (round to 1 decimal).
   - Check whether a previous weekly-summary file exists at `trackers/{person}/weekly/{prev-iso-week}.md`.
   - If it exists, read the `## Weight` section for the prior-week mean.
   - Trend = this-week-mean − prior-week-mean. Express as "↓X.X kg" (loss) or "↑X.X kg" (gain).
   - If no prior-week summary exists, state: "no prior week available — trend not computed."

### Adherence

For each day in the review week:

1. Resolve `kcal_total` for that day and person using the CAL-02 contract:
   - Read `library/calorie-targets.md` for the formula.
   - Read `library/macro-templates.md` for the macro archetype.
   - Read `calendar/cycling-2026.md` for `session_type` and `training_est_kcal` (Jonas only).
   - For Jonas: `kcal_total = base_kcal + training_est_kcal`.
   - For Farva: `kcal_total` = static daily target from `library/calorie-targets.md` (Farva branch).
2. Compare the day's logged intake (prefer `kcal_actual`; fallback `kcal_estimate`) to `kcal_total`.
3. A day is **adherent** if intake is within ±10% of `kcal_total`.
4. Days with neither `kcal_actual` nor `kcal_estimate` = "no data" — exclude from the denominator.
5. Report as: `"{N}/{denominator} days adherent ({pct}%) — {no-data-days} days no data"`.
   - If all 7 days have data: `"{N}/7 days adherent ({pct}%)"`.

### Training (Jonas only — skip entirely for Farva)

1. Read `calendar/cycling-2026.md` rows for each day of the review ISO week.
2. Sum: km, hours, Est. kcal.
3. Also check Jonas's daily-log `## Training` sections for that week. Note any deviations from the calendar (e.g. "skipped Wednesday ride", "added 30 min extra").
4. Report the totals and any deviations.

---

## Step 4 — Derive adjustment proposal

Read `library/calorie-targets.md` for the **authoritative** adjustment thresholds. If the file specifies different exact numbers than the defaults below, those win.

**Default thresholds:**
- **(a) Loss > 0.8 kg this week** → propose +200 kcal/day next week; extra carbs on training days.
- **(b) Loss < 0.3 kg/week for 2 consecutive weeks** → propose −150 kcal/day.
  - To check consecutive weeks: read the prior weekly-summary's `## Adjustment proposal` section to see if rule (b) also fired last week.
- **(c) On track** → "On track — maintain current targets."

**Note:** "loss" = positive weight decrease (this-week-mean < prior-week-mean). Use the same mean that was computed in the Weight section. If insufficient weight data (n < 4): state "Insufficient weight data this week — no adjustment can be proposed with confidence. Review manually."

**Proposal must be prose with the _why_, not just a number.** Example:
> "Weight ↓1.1 kg this week vs target rate of ~0.8 kg/wk → losing too fast. Rule applied: >0.8 kg/wk loss = add kcal. Suggest +200 kcal/day next week, added as carbs on training days to protect the Heathland build. Hold protein floor at 150–180 g."

Reference the specific rule you applied (e.g. ">0.8 kg/wk loss = add kcal").

**For Farva:** Apply only rules (a)/(b)/(c) on her targets. No training-day carb coupling. The proposal is shorter — no training-day detail. Example:
> "Weight ↓0.4 kg this week — on track for a steady cut. Rule applied: on track. Maintain current targets (~1400–1600 kcal/day)."

---

## Step 5 — Write both weekly-summary files

For each person in scope, write `trackers/{person}/weekly/{review-iso-week}.md` using the `templates/weekly-summary.md` shape.

Create the `trackers/{person}/weekly/` directory if it does not exist.

**Frontmatter:**
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

**Body sections:**

```markdown
## Weight

- 7-day average: {mean} kg (n={n}/7)
- Trend vs prior week: {↓X.X kg | ↑X.X kg | no prior week available}

{If n < 4: "n={n}/7 — insufficient data for reliable trend."}

## Adherence

- {N}/{denominator} days within ±10% of daily kcal target ({pct}%)
- {no-data-days} days: no logged intake

## Training

{Jonas only — sum for the review ISO week:}
- Total km: {km}
- Total hours: {hours}
- Estimated kcal burned: {kcal}
- Deviations: {list any, or "none noted"}

{Omit this section entirely for Farva.}

## Adjustment proposal

{Prose proposal as derived in Step 4. Not yet applied.}
```

Write both files even if data is sparse. The file always gets written; data quality is noted within the relevant section.

---

## Step 6 — Ask to apply adjustments

After writing both files, present the two proposals in a **single chat turn**:

> "Here are this week's adjustment proposals:
>
> **Jonas:** {one-sentence proposal summary}. Apply +{delta} kcal/day to `trackers/jonas/progress.md`? [yes / no / edit]
>
> **Farva:** {one-sentence proposal summary}. Apply {+delta or "no change"} kcal/day to `trackers/farva/progress.md`? [yes / no / edit]"

Wait for two answers (one per person; both can be given in the same reply).

### On "yes" for a person:

1. Read `trackers/{person}/progress.md`.
2. Append to (or create) the `weekly_kcal_adjustments` list in frontmatter. **If the list already exists, add a new entry at the end. If it does not exist, add the field after `last_updated`.**

   ```yaml
   weekly_kcal_adjustments:
     - week: {review-iso-week}
       delta_kcal_per_day: {+200 or -150 or 0}
       reason: "{the rule that fired, in short}"
       applied: {today}
   ```

3. Update `last_updated` to today. **Preserve ALL other frontmatter fields exactly as they are:**
   - `start_weight_kg`, `target_weight_kg`, `target_date`, `secondary_target_kg` (if present), `secondary_target_date` (if present), `event` (if present), `event_window` (if present), `protein_floor_g_per_day` (if present)
   - Do NOT overwrite `target_weight_kg` or `target_date` — those are milestone goals, not weekly levers.

4. Update the `## Adjustment proposal` section in the just-written weekly-summary file to append:
   > "(Applied {today}: {delta_kcal_per_day} kcal/day added to progress.md.)"

### On "no" / "edit" / no rule fired:

Do nothing further. The proposal remains as advisory prose in the weekly-summary only. On "edit", ask what adjustment the user wants and treat their specified delta as the new "yes" input — apply it using the same procedure above with `reason: "manual override"`.

---

## Completion message

After all files are written and adjustments are handled, confirm in chat:

> "Review complete for week {YYYY-Www}:
> - `trackers/jonas/weekly/{YYYY-Www}.md` — written (weight: {mean or 'insufficient data'}, adherence: {N}/{denom})
> - `trackers/farva/weekly/{YYYY-Www}.md` — written (weight: {mean or 'insufficient data'}, adherence: {N}/{denom})
> - Jonas adjustment: {applied delta or 'not applied'}
> - Farva adjustment: {applied delta or 'not applied'}"
