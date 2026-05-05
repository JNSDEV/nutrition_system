# Phase 2: Trackers & Baselines - Context

**Gathered:** 2026-05-05
**Status:** Ready for planning

<domain>
## Phase Boundary

Scaffold the per-person tracker shape, seed both people's `progress.md` with real baselines, ship the daily-log + weekly-summary templates, and lock the CAL-02 contract that Phase 3 commands will consume to derive Jonas's daily kcal target from the cycling calendar.

Concretely, this phase delivers:
- `trackers/jonas/` — `progress.md` (seeded), `daily/` (empty), `weekly/` (empty)
- `trackers/farva/` — `progress.md` (seeded, slimmer), `daily/` (empty), `weekly/` (empty)
- `templates/daily-log.md` — one shared template (Jonas + Farva)
- `templates/weekly-summary.md` — one shared template
- A documented **CAL-02 contract** stub (kept in `02-CONTEXT.md` for now; Phase 3 commands implement it; Phase 4 docs publish it)

**NOT in this phase:** any slash command implementation (Phase 3), top-level README or docs/conventions.md (Phase 4), seeding any actual daily/weekly log files (those are filled in by `/log-day` and `/weekly-review` in Phase 3).

</domain>

<decisions>
## Implementation Decisions

### Conventions (foundational — affect every other decision)
- **D-01:** Partner's real first name is **Farva**. Directory is lowercase: `trackers/farva/`. Headings, prose, and `progress.md` `title:` use title-case **Farva**. Update PROJECT.md "Open: confirm partner's preferred display name (placeholder: Partner)" line to record this resolution.
- **D-02:** Daily log path = `trackers/{person}/daily/YYYY-MM-DD.md`. Per-person, one file per day. `{person}` ∈ `{jonas, farva}`. Phase 2 only creates the empty `daily/` directory; files are created by `/log-day` in Phase 3.
- **D-03:** Weekly summary path = `trackers/{person}/weekly/YYYY-Www.md` (ISO week, e.g. `2026-W19.md`). Computed from any date with standard ISO 8601 week numbering. Phase 2 only creates the empty `weekly/` directory.

### progress.md shape
- **D-04:** **Static baseline + targets.** Frontmatter holds the numbers; a short prose body holds context that doesn't change often. Running history lives in weekly summaries — `progress.md` is updated only when targets shift.
- **D-05:** Jonas's `progress.md` has a dedicated **`## Event`** section for Heathland 161 km gravel (2026-08-03/09), with explicit phase markers **build → peak → taper** mapped against `calendar/cycling-2026.md` weeks. Phase 3's `/weekly-review` reads this section to reason about training-load shifts.
- **D-06:** Farva's `progress.md` is **slimmer** — no `## Event` section, no training fields. Same frontmatter shell minus the event-specific fields. She's a consumer, not training.
- **D-07:** Frontmatter fields for `progress.md`:
  - **Both:** `title`, `category: tracker`, `person: jonas | farva`, `last_updated: 2026-05-05`, `start_weight_kg`, `target_weight_kg`, `target_date` (ISO date or `ASAP`)
  - **Jonas only (additional):** `secondary_target_kg`, `secondary_target_date` (e.g. `80 kg` / `ASAP`), `event`, `event_window` (e.g. `Heathland 161 km gravel` / `2026-08-03..2026-08-09`), `protein_floor_g_per_day: 150–180`
- **D-08:** Seed values (locked):
  - **Jonas:** start_weight_kg `87.9`, target_weight_kg `85`, target_date `2026-05-30`, secondary_target_kg `80`, secondary_target_date `ASAP`, event `Heathland 161 km gravel`, event_window `2026-08-03..2026-08-09`
  - **Farva:** start_weight_kg `58`, target_weight_kg `53`, target_date `ASAP`

### Daily-log template
- **D-09:** **One shared template** at `templates/daily-log.md` — both `trackers/jonas/daily/*.md` and `trackers/farva/daily/*.md` are instantiated from it. Optional fields stay blank for Farva.
- **D-10:** Frontmatter (locked): `date`, `person: jonas | farva`, `category: daily-log`, `weight_kg` (nullable).
- **D-11:** Body sections (locked order): `## Meals`, `## Training` (Jonas only — Farva leaves blank), `## Notes` (energy / hunger / free-text).
- **D-12:** **Meal logging convention:** each meal line cites a library reference plus free-text deviations.
  Format: `- {meal_name} (library:meals#{anchor}) — {free-text deviation, optional}`
  Example: `- Breakfast: Oats + whey (library:meals#oats-whey-bowl) — added 1 banana`
  When no library match exists, use plain free text and prefix with `(off-library)`.
- **D-13:** **Hybrid kcal source.** Daily log carries TWO totals fields and the contract is "actual wins":
  - `kcal_estimate` — Claude-computed from library refs (sum of `library:meals#…` kcals + adjustments). Best-effort.
  - `kcal_actual` — user pastes the day's MFP/Cronometer total. If present, this is authoritative for the day.
  - Same shape for protein/carb/fat: `protein_estimate_g` / `protein_actual_g`, etc.
  - Adherence (D-15) and weekly summary (D-14, D-15) prefer `*_actual_*` and fall back to `*_estimate_*` when missing.
  - **PROJECT.md needs an update** to reflect this hybrid model — currently says "the markdown system is not the calorie database". Flag for Phase 4 docs (recorded in `<deferred>` below).

### Weekly-summary template
- **D-14:** `templates/weekly-summary.md` is **one shared template** (same pattern as daily-log).
- **D-15:** Body sections (locked):
  - `## Weight` — 7-day average from daily-log `weight_kg` fields (missing days drop out of the average; minimum 4 of 7 readings needed for the average to be meaningful — flag otherwise). Trend vs. target weight.
  - `## Adherence` — % of days within **±10%** of that day's kcal target. Uses `kcal_actual` if present, else `kcal_estimate`. Days with neither = "no data" and don't count toward adherence denominator.
  - `## Training` — Jonas only: km, hours, est. kcal sum from cycling-2026.md rows for the week.
  - `## Adjustment proposal` — concrete kcal/macro change for next week, grounded in the rules in `library/calorie-targets.md`. Prose, not just a number — explain the *why* (e.g. "weight ↓0.6 kg this week vs target of −0.3 kg, suggest +100 kcal carbs on long-ride days").

### CAL-02 contract (the Phase 3 integration contract)
- **D-16:** **Source of truth for the formula:** `library/calorie-targets.md` (already migrated in Phase 1). Phase 3 commands read this file at runtime to know the formula. Phase 2 does NOT implement the formula — it only locks the **contract shape** so Phase 3 can build against it.
- **D-17:** **Contract:**
  - **Input:** ISO date (e.g. `2026-05-05`) + person (`jonas` | `farva`).
  - **Output (Jonas):** structured object/dict with these fields:
    - `date` (ISO)
    - `person: jonas`
    - `session_type` (string lifted from cycling-2026.md, e.g. `endurance ride`, `rest`, `long ride`, plus marker tokens `SPORTIVE` / `BENCHMARK` / `REHEARSAL` / `HEATHLAND` if present)
    - `base_kcal` (integer — Jonas's training-agnostic daily target derived from current weight + targets in `progress.md`)
    - `training_est_kcal` (integer — from cycling-2026.md "Est. kcal" column for today's row)
    - `kcal_total` = `base_kcal + training_est_kcal`
    - `protein_g`, `carb_g`, `fat_g` (integers — from `library/macro-templates.md` archetype matching session_type)
  - **Output (Farva):** simpler — `{ date, person: farva, kcal_total, protein_g, carb_g, fat_g }`. No training fields. Formula in `library/calorie-targets.md` should provide a static daily target for her until she opts into anything else.
- **D-18:** **Training burn handling:** `kcal_total = base_kcal + training_est_kcal`. Both fields exposed separately so `/log-day` and `/weekly-review` can show the breakdown and reason about training-fueling for Heathland (per `library/training-nutrition.md`).
- **D-19:** Phase 2 **records this contract verbatim** in a new file `library/cal-02-contract.md` so Phase 3 plans can `read_first` it without parsing this CONTEXT.md. Frontmatter: `category: library`, `source: <discussion>`. Same minimal 4-field shape as Phase 1 (D-03 from Phase 1 CONTEXT).

### Claude's Discretion
- Exact wording of section descriptions in the daily-log/weekly-summary template body (the field names and section headings are locked above; prose hints/placeholders inside sections are Claude's call).
- Exact ISO-week computation: use Python's `%G-W%V` semantics (matches `date +%G-W%V` on most Unix). If a tool implementation differs, document at use-site.
- Anchors for `library:meals#{anchor}` — generate kebab-case from H2/H3 headings in `library/meals.md`. If anchors are ambiguous (duplicate headings), Claude picks deterministically (first occurrence) and flags in plan.
- Exact "build / peak / taper" mapping in Jonas's `progress.md ## Event` section — derive from cycling-2026.md by week: weeks containing `BENCHMARK` or `SPORTIVE` ≈ build/peak signals, week containing `HEATHLAND` = peak, weeks immediately before = taper. Final mapping is Claude's call as long as it's grounded in the cycling-2026.md tokens.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project intent & requirements
- `.planning/PROJECT.md` — system overview, Jonas/Farva goals, Heathland event, hybrid kcal note (PROJECT.md needs an update — see `<deferred>`)
- `.planning/REQUIREMENTS.md` — atomic requirements TRK-01..04, CAL-02 in scope for this phase
- `.planning/ROADMAP.md` — Phase 2 success criteria 1–5

### Phase 1 inputs (all already in repo)
- `library/calorie-targets.md` — formula source for CAL-02 (D-16)
- `library/macro-templates.md` — macro archetypes by session type (D-17)
- `library/meals.md` — meal anchors for `library:meals#{anchor}` references (D-12)
- `library/training-nutrition.md` — training-fueling rules (D-18)
- `calendar/cycling-2026.md` — session_type + Est. kcal source per date (D-17)
- `library/README.md` — orientation; will need a forward-pointer added once trackers/ exists (Phase 4 docs detail will revisit)
- `.planning/phases/01-foundation/01-CONTEXT.md` — Phase 1 frontmatter shape (D-03..D-05) and naming conventions carry forward

### Out of scope but referenced
- Phase 3 commands (`/log-day`, `/weekly-plan`, `/prep-today`, `/swap-meal`, `/weekly-review`, `/shopping-list`) consume the CAL-02 contract (D-17) and the daily-log/weekly-summary templates — do NOT pre-create command stubs in Phase 2.
- Phase 4 docs publish the CAL-02 contract publicly and update PROJECT.md to reflect the hybrid kcal model.

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- All knowledge files (`library/*.md`, `calendar/cycling-2026.md`, `templates/*.md`) are already in place from Phase 1 — Phase 2 only adds tracker scaffolding and two new templates.
- Phase 1's frontmatter convention (4 fields: `title`, `category`, `source`, `last_updated`) extends naturally — Phase 2 adds `category: tracker` and `category: daily-log` / `category: weekly-summary`.

### Established Patterns
- Markdown-only system, no code, no tests, no CI (per CLAUDE.md). Phase 2 is also pure file creation.
- Verbatim-with-minimal-touch migration rule (Phase 1 D-01) does NOT apply here — Phase 2 templates and progress.md are authored fresh from this discussion, not migrated from `.txt`.

### Integration Points
- `trackers/{person}/daily/*.md` files (Phase 3 outputs) MUST conform to `templates/daily-log.md` shape (D-09..D-13).
- `trackers/{person}/weekly/*.md` files (Phase 3 outputs) MUST conform to `templates/weekly-summary.md` shape (D-14, D-15).
- Phase 3 commands MUST honor the CAL-02 contract output schema (D-17) — `library/cal-02-contract.md` is the integration document.

</code_context>

<specifics>
## Specific Ideas

- progress.md frontmatter example (Jonas, locked per D-07/D-08):
  ```yaml
  ---
  title: Jonas — Progress
  category: tracker
  person: jonas
  source: <discussion>
  last_updated: 2026-05-05
  start_weight_kg: 87.9
  target_weight_kg: 85
  target_date: 2026-05-30
  secondary_target_kg: 80
  secondary_target_date: ASAP
  event: Heathland 161 km gravel
  event_window: 2026-08-03..2026-08-09
  protein_floor_g_per_day: 150–180
  ---
  ```
- progress.md frontmatter example (Farva, locked per D-07/D-08):
  ```yaml
  ---
  title: Farva — Progress
  category: tracker
  person: farva
  source: <discussion>
  last_updated: 2026-05-05
  start_weight_kg: 58
  target_weight_kg: 53
  target_date: ASAP
  ---
  ```
- daily-log skeleton (locked per D-09..D-13):
  ```markdown
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

  ## Meals
  - Breakfast: <meal_name> (library:meals#<anchor>) — <free-text deviation, optional>
  - Lunch: …
  - Dinner: …
  - Snacks: …

  ## Training
  <Jonas only — pulled from cycling-2026.md row for today; free-text deviations from plan>

  ## Notes
  <energy / hunger / free-text>
  ```
- weekly-summary skeleton (locked per D-14/D-15):
  ```markdown
  ---
  title: <Person> — Week <YYYY-Www>
  category: weekly-summary
  person: jonas | farva
  source: templates/weekly-summary.md
  last_updated: <YYYY-MM-DD>
  iso_week: <YYYY-Www>
  ---

  ## Weight
  - 7-day average: <kg> (n=<readings>/7)
  - Trend vs target: <kg/week toward/away from target>

  ## Adherence
  - <%>% of days within ±10% of kcal target (n=<days with data>/7)

  ## Training
  <Jonas only — km, hours, est. kcal totals from cycling-2026.md>

  ## Adjustment proposal
  <Prose grounded in library/calorie-targets.md rules — concrete kcal/macro shift for next week + the why>
  ```
- CAL-02 contract document (`library/cal-02-contract.md`) example body:
  ```markdown
  ---
  title: CAL-02 Contract — Daily Target Resolution
  category: library
  source: <discussion>
  last_updated: 2026-05-05
  ---

  # CAL-02 Contract

  Input:  { date: ISO, person: jonas | farva }
  Output (jonas): { date, person, session_type, base_kcal, training_est_kcal, kcal_total, protein_g, carb_g, fat_g }
  Output (farva): { date, person, kcal_total, protein_g, carb_g, fat_g }
  Formula source: library/calorie-targets.md (authoritative)
  Macro source:   library/macro-templates.md (archetype by session_type)
  Calendar source: calendar/cycling-2026.md (session_type + training_est_kcal column)
  ```

</specifics>

<deferred>
## Deferred Ideas

- **PROJECT.md update for hybrid kcal model** — D-13 establishes that the markdown system carries `kcal_estimate` (computed) alongside `kcal_actual` (MFP paste). PROJECT.md currently says "the markdown system is not the calorie database". Update wording to reflect hybrid in Phase 4 docs work.
- **Pure-MFP fallback for the truly improvised day** — if a daily log has no library refs at all, kcal_estimate is null and adherence falls back entirely to kcal_actual. Working as designed; flag if this happens often enough to warrant rethinking D-12.
- **Mobile-logging buffer reconciliation** — out of scope; deferred to v2 per PROJECT.md.
- **Body-measurement tracking** (waist/hip/etc.) — out of scope; deferred to v2 per PROJECT.md.
- **Separate weight log file** — rejected (D-15 reads daily-log `weight_kg`). Reconsider if missing-day rate makes weekly averages noisy.
- **Plan-adherence metric** (% of planned meals actually eaten) — rejected for v1 (D-15 uses kcal-target adherence only). Reconsider if Phase 3 weekly-review proves kcal-only adherence too coarse.
- **Per-person daily-log templates** — rejected (D-09 locks one shared template). Reconsider if optional Jonas-only fields create real friction for Farva.

</deferred>

---

*Phase: 02-trackers-baselines*
*Context gathered: 2026-05-05*
