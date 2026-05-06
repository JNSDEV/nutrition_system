---
description: Get a mid-day meal alternative from the library that fits your remaining macros.
argument-hint:
---

You are running the `/swap-meal` command. This is a **chat-only** command — you will read files and return options in chat. You will **not write any file** under any circumstances (D-24).

---

## Step 1 — Identify person and meal slot

Read the user's message for person and slot context:

- If the user names a person ("swap Jonas's lunch", "for Farva"): scope to that person.
- If a meal slot is named (breakfast / lunch / dinner / snack): use it.
- If **both** person and slot are missing: ask once — "Who is the swap for, and which meal slot? (e.g. 'Jonas, lunch')"
- If only person is missing: ask "Who is the swap for — Jonas or Farva?"
- If only slot is missing: ask "Which meal slot — breakfast, lunch, dinner, or snack?"

Keep clarification to **one question** if possible.

Once you have both person and slot, continue to Step 2.

---

## Step 2 — Read today's daily log

Today's date: use the system clock (YYYY-MM-DD format).

Read: `trackers/{person}/daily/{today}.md`

**If the file does not exist:**
Say: "No logged meals yet today for {Person}. What was your remaining macro budget intent? (e.g. 'about 600 kcal, high protein')"
Wait for the user's reply and use their stated intent as the remaining budget for Step 4. Skip Steps 3 and 4's subtraction — use their stated values directly.

**If the file exists:**
1. Find the `## Meals` section.
2. For each meal line already logged, extract the `library:meals#{anchor}` reference.
3. Read `library/meals.md` and find the heading matching each anchor (kebab-case H2/H3). Take that section's estimated macros: `kcal`, `protein_g`, `carb_g`, `fat_g`.
4. Sum all logged meals: `sum_logged_kcal`, `sum_logged_protein_g`, `sum_logged_carb_g`, `sum_logged_fat_g`.

If a meal line has no library anchor (e.g. `(off-library)`), use any inline macro estimate if present, or treat that meal's contribution as 0 and note it in chat.

---

## Step 3 — Resolve today's CAL-02 target

Read `library/cal-02-contract.md` for the integration schema. Then resolve for today:

1. **`library/calorie-targets.md`** — derive `base_kcal` for this person using their current weight and targets from `trackers/{person}/progress.md`. Apply any `weekly_kcal_adjustments` delta (most recent entry's `delta_kcal_per_day`) if the field exists and is non-empty; otherwise delta = 0.
2. **`library/macro-templates.md`** — find the macro archetype matching `session_type`.
3. **`calendar/cycling-2026.md`** — for Jonas only: find today's row, extract `session_type` and `training_est_kcal`. For Farva: skip calendar; `training_est_kcal = 0`.

Compute:
- Jonas: `kcal_total = base_kcal + training_est_kcal`; `protein_g`, `carb_g`, `fat_g` from macro archetype.
- Farva: `kcal_total` from `library/calorie-targets.md` (Farva branch); `protein_g`, `carb_g`, `fat_g` from archetype for her static target.

---

## Step 4 — Compute remaining macro budget

```
remaining_kcal     = kcal_total      − sum_logged_kcal
remaining_protein  = protein_g       − sum_logged_protein_g
remaining_carb     = carb_g          − sum_logged_carb_g
remaining_fat      = fat_g           − sum_logged_fat_g
```

State the remaining budget in chat **before** showing options:
> "Remaining budget for {Person}: ~{remaining_kcal} kcal | {remaining_protein}g protein | {remaining_carb}g carb | {remaining_fat}g fat."

---

## Step 5 — Search library/meals.md for alternatives

Read `library/meals.md` in full. Filter candidate meals by all of the following:

1. **Same archetype** as the meal slot (breakfast / lunch / dinner / snack). If the slot is dinner and fewer than two dinner-only meals fit, expand to include substantial lunches as a fallback.
2. **Macro fit**: `meal_kcal ≤ remaining_kcal × 1.10` (10% tolerance). The meal should broadly fit the remaining protein, carb, and fat budget too — flag if significantly skewed.
3. **Not the meal being swapped**: do not suggest the same meal the user already has planned for that slot (if it's identifiable from the daily log or from the user's message).
4. **Jonas protein floor** (Jonas only): check `trackers/jonas/progress.md` for `protein_floor_g_per_day`. If the candidate meal's protein is so low that the day's total would fall below that floor, skip or flag it. Skip this check for Farva.

From the qualifying candidates, select **1–3 options** that offer the best macro fit. Prefer variety — don't list three near-identical meals.

**If fewer than 1 option fits within the 10% tolerance:**
Relax tolerance to 20% (`meal_kcal ≤ remaining_kcal × 1.20`), re-scan, and note:
> "Tight budget — closest option is slightly over, but it's the best available match."

**If still no match:** say so clearly and suggest the user run `/weekly-plan` to reassess the day.

---

## Step 6 — Present options and close

Show the 1–3 options as a numbered list. For each option:

```
1. **{Meal Name}** (`library:meals#{anchor}`)
   Macros: ~{kcal} kcal | {protein_g}g protein | {carb_g}g carb | {fat_g}g fat
   Fit note: {one sentence — e.g. "High-protein, ~500 kcal — fits your remaining budget with ~80 kcal to spare."}
```

Close with:
> "Pick one and log it: tell me which you chose and I'll run `/log-day`'s smart-merge to update your daily log, or edit `trackers/{person}/daily/{today}.md` manually."

**Do not write any file. Do not make any further changes. This command ends here.**
