---
description: Create or update today's daily log for Jonas and Farva — meals, weight, training, and macros.
argument-hint:
---

You are executing the `/log-day` command. Follow these steps in order. Do not skip any step.

---

## Step 1 — Determine scope

Default date: today (system clock, ISO format YYYY-MM-DD). Default scope: both Jonas and Farva.

If the user specifies a date or person in their follow-up chat turn, adjust accordingly. Otherwise proceed with today and both people.

File paths:
- `trackers/jonas/daily/{today}.md`
- `trackers/farva/daily/{today}.md`

---

## Step 2 — Check whether files already exist

For each person, check whether their `trackers/{person}/daily/{today}.md` exists.

- **File does not exist:** this is a fresh log — proceed through all steps and create the file from `templates/daily-log.md`.
- **File already exists:** this is a re-run — collect new data through the same steps, then apply smart-merge rules in Step 7.

---

## Step 3 — Two-step MFP/Cronometer paste flow

Open with this chat turn (do not write any files yet):

> "Ready to log today for Jonas and Farva ({today}). Do you have MFP/Cronometer totals to paste for either person? You can paste now, say 'no' to skip, or give partial data — I'll fill in the rest from meal estimates."

Then in the same message, ask: "What did each of you eat today?" (You can combine both questions in one concise message to avoid two round trips.)

Wait for the user's reply before proceeding.

**Parsing MFP/Cronometer totals from the user's reply:**

Look for these patterns adjacent to a number:
- `kcal`, `calories`, `cal` → kcal value
- `protein`, `g protein`, `prot` → protein grams
- `carb`, `carbohydrate`, `carbs` → carb grams
- `fat`, `g fat` → fat grams

**Per-person attribution:** Attribute numbers to a person by name proximity (Jonas or Farva appearing nearby in the pasted text). If the paste contains no person names and looks like a single-person total, ask "which person is this for?" before proceeding.

**If the user says "no" or provides nothing:** leave `kcal_actual`, `protein_actual_g`, `carb_actual_g`, `fat_actual_g` as `null` — they can be filled on a later re-run.

**Partial data** (one person only) is fine: fill what you have; leave the other person's actuals as `null`.

---

## Step 4 — Conversational meal entry

Parse the meal items the user described in their reply to Step 3.

For each reported item, map it to the closest library anchor:

1. Read `library/meals.md` to find H2 or H3 headings.
2. Convert each heading to kebab-case. Match by name similarity.
3. Emit the locked line format:
   `- {Meal slot}: {meal_name} (library:meals#{anchor}) — {free-text deviation, optional}`
4. If no library match exists, prefix with `(off-library)`:
   `- {Meal slot}: (off-library) {free text description}`

**Meal slots:** Breakfast, Lunch, Dinner, Snacks (use the slot that fits the timing or what the user describes).

**Ambiguous anchors** (duplicate headings in library): first occurrence wins; flag in chat.

---

## Step 5 — Resolve CAL-02 targets

Read `library/cal-02-contract.md` for the locked schema. Then:

1. Read `library/calorie-targets.md` — formula for `base_kcal` (Jonas) and `kcal_total` (Farva).
2. Read `library/macro-templates.md` — macro archetype matching today's `session_type`.
3. Read `calendar/cycling-2026.md` — find today's row for Jonas: `session_type` and `training_est_kcal`.

**Jonas CAL-02 output for today:**
- `session_type`: from cycling-2026.md
- `base_kcal`: from calorie-targets.md formula
- `training_est_kcal`: from cycling-2026.md
- `kcal_total` = `base_kcal` + `training_est_kcal`
- `protein_g`, `carb_g`, `fat_g`: from macro-templates.md archetype matching `session_type`

**Farva CAL-02 output for today:**
- `kcal_total`, `protein_g`, `carb_g`, `fat_g`: from calorie-targets.md (Farva branch) and macro-templates.md

**Effective kcal target:** If `trackers/{person}/progress.md` contains a `weekly_kcal_adjustments` list, add the most recent entry's `delta_kcal_per_day` to `base_kcal`. If the list is absent or empty, treat the delta as 0.

**Computing `kcal_estimate`:** Sum estimated kcal from each meal's library anchor. If a library anchor has no kcal data, note "estimate unavailable for {meal}" in the `## Notes` section. Leave `kcal_estimate` as `null` if no estimates are available.

Similarly compute `protein_estimate_g`, `carb_estimate_g`, `fat_estimate_g` from meal anchors where data is available.

---

## Step 6 — Auto-suggest Training section (Jonas only)

For Jonas's file, populate `## Training` with the cycling-2026.md row for today:
- Session type
- Planned km / hours (if present in the row)
- Estimated kcal burn

Append this note: "Edit this section if the actual session differed from the plan."

For Farva's file, leave `## Training` blank.

---

## Step 7 — Write the files

### New file (no existing file for this person today)

Instantiate `templates/daily-log.md`. Replace all `<...>` placeholders:

**Frontmatter fields to fill:**
- `title`: `{Person} — {today}` (e.g. `Jonas — 2026-05-06`)
- `person`: `jonas` or `farva`
- `last_updated`: today
- `date`: today
- `weight_kg`: from user's reply if provided, else `null`
- `kcal_estimate`: computed in Step 5, else `null`
- `kcal_actual`: from MFP/Cronometer paste if provided, else `null`
- `protein_estimate_g`, `carb_estimate_g`, `fat_estimate_g`: computed in Step 5, else `null`
- `protein_actual_g`, `carb_actual_g`, `fat_actual_g`: from paste if provided, else `null`

**Body sections to fill:**
- `## Meals`: one line per meal per D-12 format (from Step 4)
- `## Training`: auto-suggested from cycling-2026.md (Jonas); blank (Farva) — per Step 6
- `## Notes`: any free-text the user included; otherwise leave the template placeholder

### Re-run — smart-merge (file already exists for this person today)

Read the existing file. Parse its frontmatter and body. Apply these rules exactly:

| Field | Rule |
|-------|------|
| `## Meals` lines | **Append** new lines. Do NOT deduplicate — the same meal appearing twice is plausibly two eating events; the user removes manually if it was a typo. |
| `## Notes` text | **Append** new text below any existing content. |
| `## Training` text (Jonas) | **Append** new text below existing content. |
| `weight_kg` | **Overwrite** if a new non-null value is supplied in this session. Leave unchanged if none supplied. |
| `kcal_actual`, `protein_actual_g`, `carb_actual_g`, `fat_actual_g` | **Overwrite** if supplied in this session (from MFP/Cronometer paste). Leave unchanged if none supplied. |
| `kcal_estimate`, `protein_estimate_g`, `carb_estimate_g`, `fat_estimate_g` | **Recompute** from the full updated meal list (including previously existing meals + newly appended meals). |
| `last_updated` | **Always update** to today. |
| All other frontmatter fields | **Leave untouched.** |

After writing, show a one-line diff summary in chat. Examples:
- "Jonas: +2 meals, kcal_actual null → 2400. Farva: +1 meal."
- "Jonas: weight_kg updated 83.2 → 83.0, kcal_actual null → 2150. Farva: no changes."
- "Jonas: +1 meal appended. Farva: kcal_actual null → 1650, +1 meal."

Adapt the summary to what actually changed in this session.

---

## File paths (both written in one invocation)

- `trackers/jonas/daily/{today}.md`
- `trackers/farva/daily/{today}.md`

Both `trackers/jonas/daily/` and `trackers/farva/daily/` directories already exist — do not recreate them.

---

## Reference files used by this command

- `templates/daily-log.md` — file shape to instantiate for new logs
- `library/cal-02-contract.md` — locked schema for resolving daily kcal/macro targets
- `library/calorie-targets.md` — kcal formula for Jonas and Farva
- `library/macro-templates.md` — macro archetypes by session type
- `library/meals.md` — meal anchors for `library:meals#{anchor}` lookups
- `calendar/cycling-2026.md` — Jonas's training calendar (session type + Est. kcal per date)
- `trackers/jonas/progress.md` — Jonas baseline + weekly kcal adjustment history
- `trackers/farva/progress.md` — Farva baseline + weekly kcal adjustment history
