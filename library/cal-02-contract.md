---
title: CAL-02 Contract — Daily Target Resolution
category: library
source: <discussion>
last_updated: 2026-05-05
---

# CAL-02 Contract

The CAL-02 contract describes how slash commands resolve a daily kcal/macro target for a given person on a given date, by combining `library/calorie-targets.md` (formula), `library/macro-templates.md` (macro archetypes), and `calendar/cycling-2026.md` (training session + estimated burn).

This file is the **integration contract**. Phase 3 commands (`/log-day`, `/weekly-plan`, `/swap-meal`, `/weekly-review`) `read_first` this file. They read the formula at runtime from `library/calorie-targets.md` — this contract only locks the schema.

## Input

```
{ date: ISO (YYYY-MM-DD), person: jonas | farva }
```

## Output (jonas)

```
{
  date:               ISO (YYYY-MM-DD),
  person:             "jonas",
  session_type:       string lifted from cycling-2026.md (e.g. "endurance ride", "rest", "long ride")
                      — plus marker tokens "SPORTIVE" / "BENCHMARK" / "REHEARSAL" / "HEATHLAND" if present on that date,
  base_kcal:          integer — Jonas's training-agnostic daily target,
                      derived from current weight + targets in trackers/jonas/progress.md
                      via the formula in library/calorie-targets.md,
  training_est_kcal:  integer — from cycling-2026.md "Est. kcal" column for today's row,
  kcal_total:         integer = base_kcal + training_est_kcal,
  protein_g:          integer — from library/macro-templates.md archetype matching session_type,
  carb_g:             integer — same source,
  fat_g:              integer — same source
}
```

## Output (farva)

```
{
  date:        ISO (YYYY-MM-DD),
  person:      "farva",
  kcal_total:  integer — static daily target from library/calorie-targets.md (Farva branch),
  protein_g:   integer,
  carb_g:      integer,
  fat_g:       integer
}
```

No training fields for Farva (D-06 — she's a consumer, not training).

## Sources of truth

- **Formula:** `library/calorie-targets.md` — authoritative for both `base_kcal` (Jonas) and `kcal_total` (Farva). Phase 3 reads this at runtime.
- **Macros:** `library/macro-templates.md` — authoritative for macro archetypes per session_type. Phase 3 reads at runtime and matches archetype by `session_type`.
- **Calendar:** `calendar/cycling-2026.md` — authoritative for `session_type` and `training_est_kcal` per date. Day-of-week → standard-week table; Sunday → Sunday-progression table by date range (per Phase 1 D-08).

## Training burn handling (D-18)

`kcal_total = base_kcal + training_est_kcal` — both fields exposed separately so `/log-day` and `/weekly-review` can:
- show the breakdown to the user, and
- reason about training-fueling for the Heathland event per `library/training-nutrition.md`.

## Marker tokens

When a date row in `calendar/cycling-2026.md` carries one of `SPORTIVE`, `BENCHMARK`, `REHEARSAL`, `HEATHLAND`, the marker is included in `session_type` as an additional token (per Phase 1 D-09 — markers preserved verbatim). Phase 3 commands key off these for load-shape decisions.

## What this file is NOT

- Not the formula itself — that lives in `library/calorie-targets.md`.
- Not the macro tables — those live in `library/macro-templates.md`.
- Not implementation — Phase 2 only locks the contract shape; Phase 3 commands implement.
