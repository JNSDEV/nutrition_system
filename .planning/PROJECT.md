# Nutrition System

A markdown-first context system (GSD-style) that turns Jonas's existing nutrition knowledge base into a working daily/weekly operating loop — for him and his partner — covering calorie tracking, meal-prep guidance, and progress against weight + cycling goals.

## What This Is

A `.planning/`-style markdown system where:

- **Shared library** holds the durable knowledge (meals, recipes, portions, cooking rules, preferences, training-nutrition guidance) — already drafted in `01_*.txt` … `15_*.txt` and to be migrated into structured `library/`.
- **Per-person trackers** capture daily logs, weekly summaries, and progress for Jonas and Partner separately.
- **Slash commands** drive the loop on demand: weekly planning, prep guidance, meal swaps, daily logging, weekly review.
- **Claude reads & writes the files** on the laptop. Phone usage is via Claude mobile chat as a buffer (notes / pasted entries → reconciled later on laptop) — proper sync-to-mobile is an open question, deliberately deferred.

Numbers (kcal/macros) come from an external app (MyFitnessPal / Cronometer) that the user already trusts. The markdown system is the **plan, prep, prompt, and progress layer** — not the calorie database.

## Core Value

**Reduce decision fatigue and keep both Jonas and Partner consistently on plan, week after week, by guiding cook → eat → log → adjust without each step requiring fresh thought.**

If only one thing works: a daily prompt that tells Jonas exactly what to cook/thaw/portion today for both of them — and a weekly review that adjusts targets based on the past week's weight and training load.

## Users

| Person | Role | Tracking |
|--------|------|----------|
| Jonas | Owner / operator | Full: calories, macros, weight, training load, adherence |
| Partner | Consumer | Receives weekly meal plan + her own daily tracker; doesn't edit markdown |

Partner's daily log is filled in by Jonas (or by her, simply, if she wants to). System must keep her flow trivially light — no jargon, no required Claude interaction.

> Open: confirm partner's preferred display name (placeholder: "Partner").

## Goals & Constraints

### Jonas
- **Weight:** 87.9 kg → **85 kg by 2026-05-30** → **80 kg ASAP** after that.
- **Performance constraint:** maintain cycling form across a structured May–August 2026 block culminating in **Heathland 161 km gravel (Aug 3–9)**.
- Protein floor: 150–180 g/day regardless of training load.

### Partner
- **Weight:** 58 kg → **53 kg ASAP**.
- Standard cut day 1400–1600 kcal; protein 90–115 g.
- Adjustments based on weekly average weight, not daily scale.

### Adjustment rules (already established)
- If weight drops > ~0.8 kg/week → add calories.
- If weight drops < ~0.3 kg/week for 2 weeks → reduce slightly.
- Use weekly average.

## Cycling Calendar (drives Jonas's daily kcal target)

Standard week (May 11 → Aug 2026):

| Day | Session | Duration | Est. kcal |
|-----|---------|----------|-----------|
| Mon | Z1 commute (both legs) | ~50 min | 250–300 |
| Tue | Intensity (VO2 / Threshold, alt.) | 60–75 min | 700–800 |
| Wed | Z2 Zwift indoor | 45–60 min | 450–500 |
| Thu | OFF | — | 0 |
| Fri | Fasted Z2 (75 min) + Z1 commute home | ~100 min | 750–850 |
| Sat | Strength (full body) | 45–60 min | 250–350 |
| Sun | Long Z2 outdoor (variable) | varies | see below |

Sunday long-ride progression:

| Week | Long ride | Est. kcal |
|------|-----------|-----------|
| May 11–17 | 70 km / 2:50 | 1,500 |
| May 18–24 | 85 km / 3:30 | 1,800 |
| **May 25–31** | **105 km gravel SPORTIVE** | 2,500 |
| Jun 1–7 | 60 km recovery | 1,300 |
| Jun 8–14 | 95 km | 2,000 |
| Jun 15–21 | 110 km | 2,400 |
| Jun 22–28 | 80 km recovery | 1,700 |
| **Jun 29–Jul 5** | **180 km road BENCHMARK** | 3,500 |
| Jul 6–12 | 100 km gravel | 2,300 |
| **Jul 13–19** | **140 km gravel REHEARSAL** | 3,200 |
| Jul 20–26 | 90 km recovery | 2,000 |
| Jul 27–Aug 2 | 60 km taper | 1,300 |
| **Aug 3–9** | **HEATHLAND 161 km gravel (event)** | 3,800 |

The system must read the current week's row and use it to set Jonas's daily kcal target (Sunday especially).

## Operating Loop

| Cadence | Output |
|---------|--------|
| Daily morning | `/prep-today` → what to cook/thaw/portion for both, today |
| Daily evening | `/log-day` → meals, weight, training, energy/hunger notes |
| Weekly (flexible day) | `/weekly-plan` → next week's meal plan from library + cycling row |
| Weekly | `/shopping-list` → derived from plan + pantry baseline |
| Weekly | `/weekly-review` → 7-day avg weight, adherence, suggested kcal/macro adjustments |
| Ad-hoc | `/swap-meal` → swap planned meal for an alternative that fits remaining macros |

All commands are file-backed: they read the shared library + current trackers and write into the appropriate dated files.

## Day-1 Slash Commands

`/log-day`, `/weekly-plan`, `/shopping-list`, `/weekly-review`, `/swap-meal`, `/prep-today`.

## Source Material (to be migrated)

The 15 existing `*.txt` files in repo root contain the full knowledge base. Migration target:

```
library/
  goals.md                ← 01
  daily-structure.md      ← 02
  meals.md                ← 03
  recipes.md              ← 04
  portions.md             ← 05
  cooking-rules.md        ← 06
  preferences.md          ← 07
  training-nutrition.md   ← 08
  calorie-targets.md      ← 09
  macro-templates.md      ← 12
  fast-food-rules.md      ← 15
templates/
  weekly-plan.md          ← 10
  weekly-tracker.md       ← 11
  meal-prep-planner.md    ← 13
  shopping-list.md        ← 14
trackers/
  jonas/
    daily/YYYY-MM-DD.md
    weekly/YYYY-Www.md
    progress.md           ← weight series, weekly avgs
  partner/
    daily/YYYY-MM-DD.md
    weekly/YYYY-Www.md
    progress.md
calendar/
  cycling-2026.md         ← the table above, single source of truth
```

The `*.txt` originals get archived (not deleted) for traceability.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Migrate the 15 `*.txt` files into structured `library/` and `templates/` directories
- [ ] Set up per-person tracker scaffolding (`trackers/jonas/`, `trackers/partner/`) with daily/weekly/progress files
- [ ] Establish the cycling calendar (`calendar/cycling-2026.md`) as the single source of truth for Jonas's daily kcal target
- [ ] Implement `/prep-today` — daily cooking/portioning nudge for both users
- [ ] Implement `/log-day` — capture meals, weight, training into today's daily log
- [ ] Implement `/weekly-plan` — generate next week's meal plan from library + current cycling row
- [ ] Implement `/shopping-list` — derive shopping list from active weekly plan
- [ ] Implement `/weekly-review` — 7-day weight avg, adherence, kcal/macro adjustment suggestions
- [ ] Implement `/swap-meal` — fit-remaining-macros alternative from library
- [ ] Seed Jonas + Partner baselines (weights, targets, dates) into `progress.md` files
- [ ] Document mobile-logging workaround in `README.md` (chat-with-Claude buffer pattern)

### Out of Scope (v1)

- Any custom app, web UI, mobile UI — markdown-only.
- Building a foods/ingredients calorie database — external app handles this.
- Auto-syncing markdown to/from phone — deferred; user logs on laptop in v1.
- Recipe scaling beyond the 2-person / 4-portion convention already in place.
- Photo-based meal logging.
- Integrations with Strava / Garmin / fitness APIs — cycling calendar is hand-edited from the table.

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Markdown context system (not app) | Wants GSD-style; zero build/host overhead; both can edit if needed | — Pending |
| External app owns kcal/macro numbers | User already trusts MFP/Cronometer; not rebuilding a foods DB | — Pending |
| Two separate trackers, shared library | Different targets, different cycling load; library is shared | — Pending |
| Weekly playbook + daily nudges | Sunday plan sets the week; daily view fights drift | — Pending |
| Partner = consumer only | Lower friction, higher adherence; system must stay readable for her | — Pending |
| Generate weekly artifacts via Claude on demand | No tooling to maintain; templates exist as fallback | — Pending |
| Flexible review cadence (no fixed day) | User prefers not to lock a day | — Pending |
| Cycling calendar is hand-curated source of truth | No fitness-API integration in v1 | — Pending |

## Open Questions

- Partner's preferred display name in files (placeholder: "Partner")
- Mobile logging mechanism — chat-with-Claude buffer is the v1 stopgap; revisit after a few weeks of real use (Obsidian sync? iCloud + iA Writer?)
- Whether to track body measurements (waist) in addition to weight — defer until first weekly review

## Evolution

This document evolves at phase transitions and milestone boundaries.

**After each phase transition** (via `/gsd-transition`):
1. Requirements invalidated? → Move to Out of Scope with reason
2. Requirements validated? → Move to Validated with phase reference
3. New requirements emerged? → Add to Active
4. Decisions to log? → Add to Key Decisions
5. "What This Is" still accurate? → Update if drifted

**After each milestone** (via `/gsd-complete-milestone`):
1. Full review of all sections
2. Core Value check — still the right priority?
3. Audit Out of Scope — reasons still valid?
4. Update Context with current state

---
*Last updated: 2026-05-05 after initialization*
