---
title: Library
category: library
source: <discussion>
last_updated: 2026-05-05
---

# Library

This file is the entry point to the durable knowledge base. It indexes every
file in `library/` and `templates/`, and explains how the four content areas
(library, templates, trackers, slash commands) fit together.

## What's here

### library/ — durable knowledge (read-only by commands)

- goals.md — Weight, performance, and behaviour targets for Jonas and Farva
- daily-structure.md — Default breakfast / lunch / dinner shape and cook-once-eat-twice rhythm
- meals.md — Catalogue of recurring meals grouped by breakfast, lunch, and dinner
- recipes.md — Per-meal ingredient quantities split by Jonas vs Farva portions
- portions.md — Raw-weight portion guidelines per protein and carb source
- cooking-rules.md — Equipment-specific rules (airfryer, whey handling, food safety)
- preferences.md — Preferred and avoided foods, flavours, and meal styles
- training-nutrition.md — Fuelling rules per ride duration and intensity zone
- calorie-targets.md — Daily kcal and protein targets per training-load category
- macro-templates.md — Calorie + protein/carb/fat splits per day type
- fast-food-rules.md — Damage-control rules for restaurants and takeout

### templates/ — forms commands fill in

- weekly-plan.md — Blank Mon–Sun meal plan for two people with cook-portion notes
- weekly-tracker.md — Per-day log fields (weight, training, sleep, hunger, energy, notes)
- meal-prep-planner.md — Sunday/Wednesday cook-and-portion checklist
- shopping-list.md — Weekly grocery list grouped by category with default quantities

## How this fits

- **library/** = durable knowledge. Slash commands read it; humans edit it directly when knowledge changes.
- **templates/** = blank forms. Slash commands (Phase 3) clone these and fill them in for a specific week or day.
- **trackers/** = per-person logs (Phase 2 — Jonas and Farva each get a `daily/`, `weekly/`, and `progress.md`). Slash commands write here.
- **calendar/cycling-2026.md** = single source of truth for Jonas's training load. Phase 2 commands resolve "today's row" to set Jonas's daily kcal target.
- **Slash commands** (Phase 3) read library + calendar + trackers, and write into trackers. The six commands are: `/prep-today`, `/log-day`, `/weekly-plan`, `/shopping-list`, `/weekly-review`, `/swap-meal`.

## What's next

A top-level `README.md` (Phase 4) will explain the full daily/weekly operating
loop and the mobile-logging pattern. This file stays narrowly focused on the
content layout.
