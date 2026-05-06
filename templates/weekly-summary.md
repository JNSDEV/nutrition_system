---
title: <Person> — Week <YYYY-Www>
category: weekly-summary
person: jonas | farva
source: templates/weekly-summary.md
last_updated: <YYYY-MM-DD>
iso_week: <YYYY-Www>
---

# <Person> — Week <YYYY-Www>

> Template usage: `/weekly-review` instantiates this file at `trackers/{person}/weekly/YYYY-Www.md` (ISO week, e.g. `2026-W19.md`). Section `## Training` stays blank for Farva.

## Weight

- 7-day average: <kg> (n=<readings>/7)
- Trend vs target: <kg this week, +/- vs target rate>

Rule (per D-15): average computed from daily-log `weight_kg` fields. Missing days drop out. If fewer than 4 of 7 readings, flag the average as "low confidence — n<4".

## Adherence

- <percent>% of days within ±10% of that day's kcal target (n=<days with data>/7)

Rule (per D-15): for each day, prefer `kcal_actual` over `kcal_estimate`. Days with neither = "no data" and don't count toward the denominator. ±10% band applied to that day's CAL-02-resolved kcal target.

## Training

<Jonas only — totals from cycling-2026.md rows for the ISO week: km, hours, est. kcal sum. Note any deviations logged in daily `## Training` sections. Leave blank for Farva.>

## Adjustment proposal

<Concrete kcal/macro shift for next week, plus the *why* — grounded in the rules in `library/calorie-targets.md`. Prose, not just a number.

Example shape: "Weight ↓0.6 kg this week vs target rate of −0.3 kg/wk → losing too fast. Suggest +100 kcal/day from carbs on long-ride days (Sun, Wed) to protect Heathland build. Hold protein floor at 150–180 g."

Reference the specific rule from `library/calorie-targets.md` you applied (e.g. ">0.8 kg/wk loss = add kcal" / "<0.3 kg/wk loss × 2 weeks = reduce kcal").>
