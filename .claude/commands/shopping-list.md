---
description: Derive this week's shopping list from the active weekly plan and propose it before writing to file.
argument-hint:
---

You are running the `/shopping-list` command. Follow these steps exactly and in order. Do not write any file until the user explicitly confirms the proposal.

---

## Step 1 — Check for active weekly plan

Determine the current ISO week using the system clock. Format: `YYYY-Www` (ISO 8601, e.g. `2026-W19`). Week starts Monday.

Check whether `trackers/weekly-plans/{this-iso-week}.md` exists.

**If it does NOT exist:** output the following message in chat and stop immediately. Do not continue to Step 2.

> "No active weekly plan — run `/weekly-plan` first to create one."

**If it exists:** proceed to Step 2.

---

## Step 2 — Read inputs

Read all three sources before aggregating anything. Do not skip any.

**Source 1: Active weekly plan** — `trackers/weekly-plans/{this-iso-week}.md`

Read the full file. For each day (Monday through Sunday), extract every meal entry. Note whether the entry carries a `library:recipes#{anchor}` or `library:meals#{anchor}` reference. Collect every distinct anchor found across the entire week.

**Source 2: Recipes library** — `library/recipes.md`

For each anchor collected in Source 1:
- Find the matching H2 or H3 heading in `library/recipes.md` whose kebab-case form equals the anchor.
- Extract the complete ingredient list with quantities for that recipe.
- 4-portion scaling is already baked into the recipe ingredients (Phase 1 convention). Do NOT rescale.
- If a recipe has a "For 4 portions:" header, the quantities listed are already the right amounts for the week's cook event.
- If no matching heading exists in `library/recipes.md`, check `library/meals.md` for the anchor instead. If still not found, note the meal as "(ingredient list not found — add manually)" and continue.

**Source 3: Pantry baseline** — `templates/shopping-list.md`

Read the complete file. This is the list of items that are "always stocked." You will use this list to flag (not delete) items in Step 3.

---

## Step 3 — Aggregate, deduplicate, and group

**Aggregation:**

Combine all ingredient quantities from all recipes. When the same ingredient appears in multiple recipes, sum the quantities (e.g. chicken breast appears in 3 recipes × 500 g each = 1.5 kg total). Use your best judgement for unit conversion (g to kg when total exceeds 500 g; ml to L when total exceeds 500 ml).

**Pantry baseline check:**

For each item in the aggregated list, check whether it appears in `templates/shopping-list.md`. If it does, append `(pantry — skip unless running low)` in parentheses after the quantity line. Do not delete pantry items from the list — the user may need to restock.

**Grouping:**

Organise the final list into these five sections:

- **Produce:** fresh vegetables, fresh fruit, fresh herbs
- **Proteins:** meat, fish, eggs, tofu, dairy proteins (skyr, cottage cheese, whey)
- **Pantry:** dried goods (oats, pasta, rice), canned goods, spices, sauces, condiments, baking ingredients
- **Fridge:** milk, fresh dairy (other than protein dairy above), condiments requiring refrigeration
- **Freezer:** any frozen items

Items that don't fit neatly into one section: use your best judgement and place them in the most logical section.

---

## Step 4 — Propose in chat

Present the grouped shopping list in chat as a markdown bulleted list, one section at a time:

```
## Shopping List — {this-iso-week}

### Produce
- ...

### Proteins
- ...

### Pantry
- ...

### Fridge
- ...

### Freezer
- ...
```

After the list, say:

> "Does this look right? You can edit inline — for example: 'skip eggs, I already have 12', 'double the chicken', 'remove the skyr'. Or just say **ok** to write it."

**Accepting edits:**

Accept natural-language edits in any phrasing. Apply them immediately. For small edits (one or two items), show only the changed section rather than re-rendering the whole list. For larger edits (whole section changes), re-render the affected sections.

Repeat the edit loop until the user confirms. Confirmation signals: "ok", "write it", "looks good", "yes", "go ahead", "confirm", or any clear affirmative.

Do **not** write any file until you receive confirmation.

---

## Step 5 — Write on confirmation

On confirmation, write `trackers/weekly-plans/{this-iso-week}-shopping.md`.

Create the `trackers/weekly-plans/` directory if it does not already exist.

**File frontmatter (required):**

```yaml
---
title: Shopping List — {this-iso-week}
category: shopping-list
iso_week: {this-iso-week}
last_updated: {today-YYYY-MM-DD}
source: trackers/weekly-plans/{this-iso-week}.md
---
```

**File body:** the confirmed grouped shopping list exactly as agreed, using the same section structure (Produce / Proteins / Pantry / Fridge / Freezer). Use compact markdown bullets — one item per line. Include the `(pantry — skip unless running low)` flags where applicable.

After writing, confirm in chat:

> "Shopping list written to `trackers/weekly-plans/{this-iso-week}-shopping.md`. Open it on your phone while shopping."
