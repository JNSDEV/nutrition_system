---
phase: 02-trackers-baselines
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - trackers/jonas/progress.md
  - trackers/jonas/daily/.gitkeep
  - trackers/jonas/weekly/.gitkeep
autonomous: true
requirements: [TRK-01, TRK-02]
must_haves:
  truths:
    - "User can open trackers/jonas/progress.md and see starting weight 87.9 kg, target 85 kg by 2026-05-30, secondary target 80 kg ASAP, and the Heathland event 2026-08-03/09"
    - "User can navigate into trackers/jonas/daily/ and trackers/jonas/weekly/ directories (they exist and are tracked)"
  artifacts:
    - path: "trackers/jonas/progress.md"
      provides: "Jonas baseline frontmatter + Event section"
      contains: "start_weight_kg: 87.9"
    - path: "trackers/jonas/daily/.gitkeep"
      provides: "tracked empty daily/ directory"
    - path: "trackers/jonas/weekly/.gitkeep"
      provides: "tracked empty weekly/ directory"
  key_links:
    - from: "trackers/jonas/progress.md ## Event section"
      to: "calendar/cycling-2026.md"
      via: "build → peak → taper phase markers grounded in BENCHMARK/SPORTIVE/HEATHLAND tokens"
      pattern: "Heathland"
---

<objective>
Create Jonas's tracker scaffold: seeded `progress.md` with locked frontmatter (D-07/D-08), an `## Event` section mapping Heathland phases to cycling-2026.md weeks (D-05), and tracked-but-empty `daily/` + `weekly/` subdirectories.

Purpose: TRK-01 — per-person tracker with real baselines. Phase 3 commands (`/log-day`, `/weekly-review`) read this file to derive Jonas's daily kcal target and reason about training load.
Output: `trackers/jonas/progress.md` + two `.gitkeep` files.
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/execute-plan.md
@$HOME/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/ROADMAP.md
@.planning/STATE.md
@.planning/phases/02-trackers-baselines/02-CONTEXT.md
@.planning/phases/01-foundation/01-CONTEXT.md
@calendar/cycling-2026.md
</context>

<tasks>

<task type="auto">
  <name>Task 1: Create trackers/jonas/progress.md with locked frontmatter and body</name>
  <files>trackers/jonas/progress.md</files>
  <read_first>
    - .planning/phases/02-trackers-baselines/02-CONTEXT.md (D-04, D-05, D-07, D-08, and frontmatter example lines 134–151)
    - calendar/cycling-2026.md (to identify weeks containing BENCHMARK / SPORTIVE / HEATHLAND tokens for the Event section phase mapping)
    - .planning/phases/01-foundation/01-CONTEXT.md (D-03 frontmatter convention carries forward)
  </read_first>
  <action>
Create file `trackers/jonas/progress.md` with EXACTLY this frontmatter (per D-07/D-08, copied verbatim from CONTEXT.md specifics — note `protein_floor_g_per_day` uses an en-dash U+2013, not a hyphen):

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

Below the frontmatter, write a short prose body (per D-04 — static context that doesn't change often) with these sections in this order:

1. `# Jonas — Progress`

2. `## Targets` — short prose restating the two weight targets and the protein floor:
   - Primary: 85 kg by 2026-05-30
   - Secondary: 80 kg ASAP after primary
   - Protein floor: 150–180 g/day (sustains lean mass through cut + Heathland build)

3. `## Event` — the Heathland 161 km gravel section (D-05). Derive build/peak/taper mapping from `calendar/cycling-2026.md` Sunday progression (D-05 + Discretion note in CONTEXT.md):
   - Identify the week containing `HEATHLAND` token → that week is **peak** (race week, 2026-08-03..09)
   - Weeks containing `SPORTIVE` or `BENCHMARK` tokens before peak → **build** signals
   - The 1–2 weeks immediately before HEATHLAND week → **taper**
   - All other weeks from now (2026-05-05) up to first build marker → general **base/build**
   Write this as a short bulleted mapping, e.g.:
   - **Build:** weeks May 11 – Jul 13 (includes BENCHMARK/SPORTIVE markers per cycling-2026.md)
   - **Peak:** week containing HEATHLAND (Aug 3–9 — race week)
   - **Taper:** week(s) immediately preceding peak (Jul 27 – Aug 2)
   Use the actual week-range strings as they appear in cycling-2026.md Sunday progression rows. If a marker token is ambiguous (more than one BENCHMARK/SPORTIVE), include all in the build range. Add a one-line note: "Phases derived from cycling-2026.md Sunday progression — BENCHMARK/SPORTIVE → build, HEATHLAND week → peak, week(s) before HEATHLAND → taper."

4. `## Notes` — a single short paragraph: "Update this file only when targets shift. Running history (weekly weight averages, adherence, training totals) lives in `weekly/YYYY-Www.md` summaries."

Do NOT add any fields, sections, or content beyond the above. Do NOT include `kcal` or macro targets here — those are derived at runtime via the CAL-02 contract (D-16).
  </action>
  <verify>
    <automated>test -f trackers/jonas/progress.md && grep -q '^start_weight_kg: 87.9$' trackers/jonas/progress.md && grep -q '^target_weight_kg: 85$' trackers/jonas/progress.md && grep -q '^target_date: 2026-05-30$' trackers/jonas/progress.md && grep -q '^secondary_target_kg: 80$' trackers/jonas/progress.md && grep -q '^secondary_target_date: ASAP$' trackers/jonas/progress.md && grep -q '^event: Heathland 161 km gravel$' trackers/jonas/progress.md && grep -q '^event_window: 2026-08-03..2026-08-09$' trackers/jonas/progress.md && grep -q '^protein_floor_g_per_day: 150–180$' trackers/jonas/progress.md && grep -q '^last_updated: 2026-05-05$' trackers/jonas/progress.md && grep -q '^source: <discussion>$' trackers/jonas/progress.md && grep -q '^category: tracker$' trackers/jonas/progress.md && grep -q '^person: jonas$' trackers/jonas/progress.md && grep -q '^## Event$' trackers/jonas/progress.md && grep -q '^## Targets$' trackers/jonas/progress.md</automated>
  </verify>
  <acceptance_criteria>
    - File `trackers/jonas/progress.md` exists
    - Frontmatter contains exactly: `title: Jonas — Progress`, `category: tracker`, `person: jonas`, `source: <discussion>`, `last_updated: 2026-05-05`, `start_weight_kg: 87.9`, `target_weight_kg: 85`, `target_date: 2026-05-30`, `secondary_target_kg: 80`, `secondary_target_date: ASAP`, `event: Heathland 161 km gravel`, `event_window: 2026-08-03..2026-08-09`, `protein_floor_g_per_day: 150–180`
    - Body contains H2 headings `## Targets`, `## Event`, `## Notes` in that order
    - `## Event` section mentions "Build", "Peak", "Taper" and references HEATHLAND, BENCHMARK, or SPORTIVE
  </acceptance_criteria>
  <done>File exists with locked frontmatter values verbatim and body sections present in correct order.</done>
</task>

<task type="auto">
  <name>Task 2: Create empty tracked daily/ and weekly/ subdirectories</name>
  <files>trackers/jonas/daily/.gitkeep, trackers/jonas/weekly/.gitkeep</files>
  <read_first>
    - .planning/phases/02-trackers-baselines/02-CONTEXT.md (D-02, D-03 — directory paths)
  </read_first>
  <action>
Create two empty placeholder files so the empty directories are tracked:

1. `trackers/jonas/daily/.gitkeep` — empty file (0 bytes is fine).
2. `trackers/jonas/weekly/.gitkeep` — empty file.

These directories must exist as Phase 3 `/log-day` and `/weekly-review` will write into them per D-02 (`trackers/{person}/daily/YYYY-MM-DD.md`) and D-03 (`trackers/{person}/weekly/YYYY-Www.md`). Phase 2 does NOT create any actual log files.
  </action>
  <verify>
    <automated>test -f trackers/jonas/daily/.gitkeep && test -f trackers/jonas/weekly/.gitkeep && test -d trackers/jonas/daily && test -d trackers/jonas/weekly</automated>
  </verify>
  <acceptance_criteria>
    - Directory `trackers/jonas/daily/` exists
    - Directory `trackers/jonas/weekly/` exists
    - File `trackers/jonas/daily/.gitkeep` exists
    - File `trackers/jonas/weekly/.gitkeep` exists
    - No other files inside `trackers/jonas/daily/` or `trackers/jonas/weekly/`
  </acceptance_criteria>
  <done>Both subdirectories tracked via `.gitkeep` placeholders, no actual log files present.</done>
</task>

</tasks>

<verification>
- `trackers/jonas/progress.md` parses as valid YAML frontmatter + Markdown body
- All locked values from D-08 (Jonas seed values) appear verbatim in frontmatter
- `## Event` section grounds build/peak/taper in actual cycling-2026.md tokens (not invented)
- `daily/` and `weekly/` directories exist and are tracked but empty
</verification>

<success_criteria>
ROADMAP success criterion #1 satisfied: User can open `trackers/jonas/progress.md` and see starting weight 87.9 kg, targets (85 kg by 2026-05-30, then 80 kg), and the Heathland event (2026-08-03/09).
</success_criteria>

<output>
After completion, create `.planning/phases/02-trackers-baselines/02-01-SUMMARY.md`.
</output>
