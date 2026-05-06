---
description: Generate next week's 7-day meal plan conversationally, then write it to trackers/weekly-plans/.
argument-hint:
---

You are running the `/weekly-plan` command. Follow these steps exactly and in order. Do not write any file until the user explicitly confirms the proposal.

---

## Step 1 — Check for an existing plan (D-17)

Determine the current ISO week using the system clock. Format: `YYYY-Www` (ISO 8601, e.g. `2026-W19`). Week starts Monday.

Check whether `trackers/weekly-plans/{this-iso-week}.md` exists.

**If it exists:**
1. Read it.
2. Display the plan contents as a markdown table in chat (Day | Lunch | Dinner | Training | Notes).
3. Say: "This week's plan already exists. Do you want to **amend** it or **replace** it entirely? (amend / replace)"
4. Wait for the user's answer.
   - On "amend": load the existing plan as the starting proposal. Skip Step 2 and go directly to Step 5.
   - On "replace": treat as a blank week. Continue to Step 2.

**If it does not exist:** proceed directly to Step 2.

---

## Step 2 — Batched 4-question opener (D-14)

Open with **one single chat turn** containing all four questions. Do not ask them across multiple turns. Include the pre-fills below.

> "Let's build this week's plan. A few quick questions — answer all at once:
>
> 1. **Fridge / leftovers:** What's already in the fridge or any leftovers to use up first?
>
> 2. **Training peak:** What's your biggest training day this week? I'll pre-fill from the cycling calendar — confirm or correct.
>    *[Pre-fill: Read `calendar/cycling-2026.md`. Find all rows for the upcoming ISO week. Identify the day with the highest training load (by session_type: race > long_ride > medium_ride > easy_ride > rest; break ties with Est. kcal). State: "Looks like **{day}** is your biggest day ({session_type}, ~{est_kcal} kcal burn)"]*
>
> 3. **Repeat meals:** Any meals from last week you'd like to repeat?
>    *[Pre-fill: Read `trackers/weekly-plans/{prev-iso-week}.md` if it exists. List last week's dinners in a short bullet list. If the file doesn't exist, say "No plan found for last week."]*
>
> 4. **Dislikes / cravings:** Any dislikes, strong cravings, or meals to avoid this week?"

Wait for the user's reply before proceeding to Step 3. Do not build the proposal before you have the answers.

---

## Step 3 — Read planning inputs

After the user replies, read the following files before building the plan. Do not skip any.

- `library/meals.md` — available meals with archetypes (breakfast / lunch / dinner / snack) and `library:meals#{anchor}` refs
- `library/macro-templates.md` — macro archetypes by session_type (carb-heavy / protein-forward / light)
- `library/fast-food-rules.md` — flex-day options for the one non-cook day
- `library/preferences.md` — Jonas and Farva baseline dislikes and preferences
- `trackers/jonas/progress.md` — `protein_floor_g_per_day` and current Heathland event phase
- `calendar/cycling-2026.md` — all session_type rows for the upcoming ISO week
- `library/cal-02-contract.md` — the locked integration schema for resolving kcal targets

---

## Step 4 — Apply the plan algorithm (D-15)

Build a 7-day plan following these rules in strict priority order:

1. **Fridge-first:** Use fridge contents and leftovers from Q1 first. Assign them to Monday or the earliest appropriate slot.

2. **Dislikes and cravings:** Honor dislikes from Q4 and from `library/preferences.md`. Honor cravings from Q4.

3. **Cycling-load alignment:**
   - On long-ride / race days: assign carb-heavy dinners (per `library/macro-templates.md` `high_carb` archetype).
   - On rest / easy days: assign lighter, protein-forward meals (per `lower_carb` archetype).
   - Read `calendar/cycling-2026.md` session_type for each day of the upcoming ISO week.

4. **Dinner pairs (4-portion, 3 cook-events):**
   - Group dinners in **consecutive pairs**: cook once → eat two nights (e.g. cook Monday = Mon dinner + Tue dinner).
   - Target exactly **3 cook-events** across Mon–Fri, leaving one flex day.
   - Assign the flex day using `library/fast-food-rules.md` options (or "leftover roulette").
   - Mark cook-days with `COOK` in the proposal table.

5. **Lunches = previous night's dinner leftover** by default. Override only if Q1 or Q4 specifically requests otherwise. Note the source dinner in the lunch cell.

6. **Breakfasts:** Rotate from `library/meals.md` breakfast archetype. Default to "Protein overnight oats" (fixed template pattern) unless the user expressed a preference in Q4.

7. **Snacks:** Select per `library/macro-templates.md` snack guidance for that day's session_type.

8. **Protein floor check (Jonas):** After building the full week, verify Jonas's estimated protein across all days against `protein_floor_g_per_day` from `trackers/jonas/progress.md`. If any day falls short, swap or augment the meal selection for that day to close the gap. Note the adjustment in the table's Notes column.

---

## Step 5 — Propose-then-write loop (D-16)

Present the full 7-day plan as a markdown table in chat:

```
| Day       | Lunch                              | Dinner                             | Training              | Notes                     |
|-----------|------------------------------------|------------------------------------|----------------------|---------------------------|
| Monday    | Fridge: leftover X                 | Chicken + rice (COOK)              | Easy ride            | Cook 4 portions           |
| Tuesday   | Leftover chicken + rice            | Chicken + rice                     | Rest                 |                           |
| Wednesday | Leftover [Mon dinner]              | Chili con carne (COOK)             | Long ride — 120 km   | High-carb — COOK 4 portions |
...
```

Include `library:meals#{anchor}` refs in parentheses for each meal where resolvable (e.g. `library:meals#protein-overnight-oats`).

After the table, say:

> "Does this work? Say **ok** to write the plan, or tell me what to change (e.g. 'swap Tue dinner', 'more protein on Thu', 'I'm eating out Friday')."

Accept natural-language edits. When the user requests a change:
- Apply it to the in-chat proposal.
- Re-display the updated table.
- Ask for confirmation again.

Repeat this loop until the user says "ok", "write it", "looks good", "yes", or any clear confirmation. Do **not** write the file until confirmed.

---

## Step 6 — Write the file

On user confirmation, write `trackers/weekly-plans/{this-iso-week}.md`.

Create the `trackers/weekly-plans/` directory if it does not exist.

Use the structure from `templates/weekly-plan.md` as the shape guide, but populate with real meal names, `library:meals#{anchor}` refs, and per-day training notes.

**File frontmatter (required):**

```yaml
---
title: Weekly Plan — {this-iso-week}
category: weekly-plan
iso_week: {this-iso-week}
last_updated: {today-YYYY-MM-DD}
---
```

**File body structure:**

```markdown
# Weekly Plan — {this-iso-week}

## Monday
**Breakfast:** Protein overnight oats (`library:meals#protein-overnight-oats`)
**Lunch:** {meal} (`library:meals#{anchor}`)
**Dinner:** {meal} — COOK 4 portions (`library:meals#{anchor}`)
**Snack:** {snack}
**Training:** {session_type from cycling-2026.md or "Rest"}
**Notes:** {cook notes, portion splits, thaw reminders}

## Tuesday
...

## Saturday
**Dinner:** Flex meal — {fast-food-rules option or eating out}

## Sunday
...
```

Repeat for all 7 days. Omit the snack line if no snack is planned for that day. Include a cook note (4 portions) on every COOK day.

After writing, confirm in chat:

> "Written to `trackers/weekly-plans/{this-iso-week}.md`. Run `/shopping-list` to generate the shopping list, or `/prep-today` tomorrow morning for today's cooking brief."
