---
title: <Person> — <YYYY-MM-DD>
category: daily-log
person: jonas | farva
source: templates/daily-log.md
last_updated: <YYYY-MM-DD>
date: <YYYY-MM-DD>
weight_kg: <number or null>
kcal_estimate: <number or null>
kcal_actual: <number or null>
protein_estimate_g: <number or null>
protein_actual_g: <number or null>
carb_estimate_g: <number or null>
carb_actual_g: <number or null>
fat_estimate_g: <number or null>
fat_actual_g: <number or null>
---

# <Person> — <YYYY-MM-DD>

> Template usage: `/log-day` instantiates this file at `trackers/{person}/daily/YYYY-MM-DD.md`. Replace `<...>` placeholders. Optional sections (Training) stay blank for Farva.

## Meals

Convention (per D-12): each meal line cites a library reference plus optional free-text deviation.
Format: `- {Meal slot}: {meal_name} (library:meals#{anchor}) — {free-text deviation, optional}`
Off-library meals: prefix with `(off-library)` and use plain free text.

- Breakfast: <meal_name> (library:meals#<anchor>) — <free-text deviation, optional>
- Lunch: <meal_name> (library:meals#<anchor>) — <free-text deviation, optional>
- Dinner: <meal_name> (library:meals#<anchor>) — <free-text deviation, optional>
- Snacks: <meal_name> (library:meals#<anchor>) — <free-text deviation, optional>

## Training

<Jonas only — pulled from cycling-2026.md row for today's date; note any deviation from the planned session (skipped, shortened, intensity differed). Leave blank for Farva.>

## Notes

<Energy level, hunger pattern through the day, sleep, stress, free-text observations. Both Jonas and Farva.>
