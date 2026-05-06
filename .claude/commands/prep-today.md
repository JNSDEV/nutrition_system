---
description: Get today's cooking and portioning brief — what to cook, what to thaw, and how to split portions.
argument-hint:
---

You are generating the daily cooking and portioning brief for Jonas and Farva. Follow these steps in order.

## Step 1: Check for an active weekly plan

Determine today's ISO week string using the system clock. ISO week format is `YYYY-Www` (e.g. `2026-W19`). Week starts Monday per ISO 8601.

Check whether the file `trackers/weekly-plans/{this-iso-week}.md` exists.

**If it does NOT exist:** Output exactly the following and stop — do not improvise a plan:

> No weekly plan for this week — run `/weekly-plan` first.

## Step 2: Read today's meals from the active weekly plan

Read `trackers/weekly-plans/{this-iso-week}.md`. Find today's entry (match by date or day-of-week heading). Extract:
- Today's dinner (and any other cook-from-scratch meal)
- Tomorrow's dinner or lunch (for the thaw note)
- Whether today's meal is labeled as "leftover [X]" from a prior cook

## Step 3: Read the cycling calendar for training context (Jonas)

Read `calendar/cycling-2026.md`. Find today's row. Note:
- `session_type` (e.g. endurance, rest, interval, race)
- Estimated kcal burn for today's session

If today is a training day, read `library/training-nutrition.md` to identify any fueling priority for Jonas's Heathland build (carb timing, protein floor, intra-ride fueling, post-ride window).

## Step 4: Resolve today's kcal and macro targets

Read `library/cal-02-contract.md` to understand the locked I/O schema. Then:

1. Read `library/calorie-targets.md` for the base formula.
2. Read `library/macro-templates.md` and match today's archetype to `session_type` for both Jonas and Farva.
3. If `trackers/jonas/progress.md` exists, read `protein_floor_g_per_day` and apply it as a floor for Jonas's protein target. Also check `weekly_kcal_adjustments` — if a recent entry exists, add its `delta_kcal_per_day` to Jonas's base kcal target.

## Step 5: Read portioning guidance

Read `library/cooking-rules.md` and `library/portions.md` for any rules that apply to today's meal (e.g. 4-portion batch sizing, protein weighting, rice/potato calibration).

## Step 6: Output the cooking brief

Produce a short chat brief with the following four labelled sections. Keep it scannable on mobile: short sentences, no paragraph walls.

---

**What to cook today**

Name the recipe(s) for today's dinner (and any other cook-from-scratch meal). Include the `library:meals#{anchor}` reference. Note if this is a 4-portion cook (feeds two dinners for both people, e.g. tonight and tomorrow). Mention key cooking notes from `library/cooking-rules.md` if relevant.

**What to thaw / pull from fridge for tomorrow**

Based on tomorrow's entry in the weekly plan. If tomorrow's meal comes from today's batch (leftover), state that clearly. If it requires a separate thaw (e.g. frozen protein), name it specifically and state when to pull it (e.g. "pull from freezer tonight").

**Portion split: Jonas vs Farva**

State each person's dinner portion in plain terms (e.g. "Jonas: 550 g chicken rice bowl; Farva: 400 g"). Base the split on today's resolved macro targets from Steps 3–4. If today is a training day for Jonas, note the relevant carb or protein priority from `library/training-nutrition.md` (e.g. "Jonas gets the larger carb portion — post-ride window"). Reference Jonas's `protein_floor_g_per_day` if the meal's protein is close to the floor.

**Leftover note** *(omit this section entirely if no leftover is involved today)*

If today's lunch or dinner is drawn from a previous-day batch (the weekly plan shows "leftover [X]"), confirm the batch name, note what portion is remaining, and confirm it was cooked on the expected prior day. If anything is unclear (batch not confirmed), flag it in chat.

---

Do not write any file. This command is chat-only.
