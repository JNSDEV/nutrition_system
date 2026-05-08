---
phase: 02-trackers-baselines
plan: 02
type: execute
wave: 1
depends_on: []
files_modified:
  - trackers/farva/progress.md
  - trackers/farva/daily/.gitkeep
  - trackers/farva/weekly/.gitkeep
autonomous: true
requirements: [TRK-01, TRK-02]
must_haves:
  truths:
    - "User can open trackers/farva/progress.md and see starting weight 58 kg and target 53 kg ASAP"
    - "User can navigate into trackers/farva/daily/ and trackers/farva/weekly/ (they exist and are tracked)"
  artifacts:
    - path: "trackers/farva/progress.md"
      provides: "Farva slim baseline frontmatter (no Event, no training fields)"
      contains: "start_weight_kg: 58"
    - path: "trackers/farva/daily/.gitkeep"
      provides: "tracked empty daily/ directory"
    - path: "trackers/farva/weekly/.gitkeep"
      provides: "tracked empty weekly/ directory"
  key_links:
    - from: "trackers/farva/progress.md"
      to: "library/cal-02-contract.md"
      via: "person: farva → simpler CAL-02 output schema (D-17 Farva branch)"
      pattern: "person: farva"
---

<objective>
Create Farva's tracker scaffold: seeded `progress.md` with the slim frontmatter (D-06/D-07/D-08 — no Event section, no training fields, no protein floor, no secondary target) and tracked-but-empty `daily/` + `weekly/` subdirectories.

Purpose: TRK-02 — Farva is a consumer of the system, not training. Phase 3 commands write into her daily/weekly logs same as Jonas's, but with the simpler CAL-02 output schema.
Output: `trackers/farva/progress.md` + two `.gitkeep` files.

Note: Per D-01, directory is lowercase `farva/`, display title is `Farva`. ROADMAP's mention of `trackers/partner/` is superseded by D-01.
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
</context>

<tasks>

<task type="auto">
  <name>Task 1: Create trackers/farva/progress.md with slim locked frontmatter and body</name>
  <files>trackers/farva/progress.md</files>
  <read_first>
    - .planning/phases/02-trackers-baselines/02-CONTEXT.md (D-01 naming, D-06 slim shape, D-07 fields, D-08 seed values, frontmatter example lines 152–164)
    - .planning/phases/01-foundation/01-CONTEXT.md (D-03 frontmatter convention)
  </read_first>
  <action>
Create file `trackers/farva/progress.md` with EXACTLY this frontmatter (per D-06/D-07/D-08, copied verbatim from CONTEXT.md specifics — slim shape, NO event/training/protein-floor/secondary-target fields):

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

Below the frontmatter, write a short prose body:

1. `# Farva — Progress`

2. `## Targets` — short prose:
   - Primary: 53 kg ASAP (no fixed date — sustainable steady cut preferred over aggressive timeline)
   - No training-load fueling — Farva is a consumer of the planned meals, not training for an event

3. `## Notes` — single short paragraph: "Update this file only when targets shift. Running history (weekly weight averages, adherence) lives in `weekly/YYYY-Www.md` summaries."

DO NOT include:
- `## Event` section (D-06 — no event for Farva)
- `## Training` references in body
- Any of these frontmatter fields: `secondary_target_kg`, `secondary_target_date`, `event`, `event_window`, `protein_floor_g_per_day` (D-06/D-07 — Jonas-only fields)
  </action>
  <verify>
    <automated>test -f trackers/farva/progress.md && grep -q '^title: Farva — Progress$' trackers/farva/progress.md && grep -q '^category: tracker$' trackers/farva/progress.md && grep -q '^person: farva$' trackers/farva/progress.md && grep -q '^start_weight_kg: 58$' trackers/farva/progress.md && grep -q '^target_weight_kg: 53$' trackers/farva/progress.md && grep -q '^target_date: ASAP$' trackers/farva/progress.md && ! grep -q '^event:' trackers/farva/progress.md && ! grep -q '^secondary_target_kg:' trackers/farva/progress.md && ! grep -q '^protein_floor_g_per_day:' trackers/farva/progress.md && ! grep -q '^## Event$' trackers/farva/progress.md && grep -q '^## Targets$' trackers/farva/progress.md</automated>
  </verify>
  <acceptance_criteria>
    - File `trackers/farva/progress.md` exists at lowercase `farva/` path (NOT `partner/` or `Farva/`)
    - Frontmatter contains exactly: `title: Farva — Progress`, `category: tracker`, `person: farva`, `source: <discussion>`, `last_updated: 2026-05-05`, `start_weight_kg: 58`, `target_weight_kg: 53`, `target_date: ASAP`
    - Frontmatter does NOT contain: `event`, `event_window`, `secondary_target_kg`, `secondary_target_date`, `protein_floor_g_per_day`
    - Body contains H2 headings `## Targets`, `## Notes` (in that order)
    - Body does NOT contain `## Event` heading
  </acceptance_criteria>
  <done>File exists with slim frontmatter at lowercase `trackers/farva/progress.md` path; no Jonas-only fields present.</done>
</task>

<task type="auto">
  <name>Task 2: Create empty tracked daily/ and weekly/ subdirectories for Farva</name>
  <files>trackers/farva/daily/.gitkeep, trackers/farva/weekly/.gitkeep</files>
  <read_first>
    - .planning/phases/02-trackers-baselines/02-CONTEXT.md (D-02, D-03 — directory paths use `{person}` ∈ `{jonas, farva}`)
  </read_first>
  <action>
Create two empty placeholder files so the empty directories are tracked:

1. `trackers/farva/daily/.gitkeep` — empty file.
2. `trackers/farva/weekly/.gitkeep` — empty file.

Phase 3 `/log-day` and `/weekly-review` will write into these per D-02 / D-03. Phase 2 does NOT create any actual log files.
  </action>
  <verify>
    <automated>test -f trackers/farva/daily/.gitkeep && test -f trackers/farva/weekly/.gitkeep && test -d trackers/farva/daily && test -d trackers/farva/weekly</automated>
  </verify>
  <acceptance_criteria>
    - Directory `trackers/farva/daily/` exists (lowercase)
    - Directory `trackers/farva/weekly/` exists (lowercase)
    - File `trackers/farva/daily/.gitkeep` exists
    - File `trackers/farva/weekly/.gitkeep` exists
    - No other files inside either subdirectory
  </acceptance_criteria>
  <done>Both subdirectories tracked via `.gitkeep` placeholders.</done>
</task>

</tasks>

<verification>
- `trackers/farva/progress.md` parses as valid YAML frontmatter + Markdown body
- Slim shape enforced: no Event, no training, no Jonas-only fields
- Path is lowercase `farva/` (not `partner/`, not `Farva/`)
</verification>

<success_criteria>
ROADMAP success criterion #2 satisfied (re-mapped per D-01): User can open `trackers/farva/progress.md` and see starting weight 58 kg and target 53 kg.
</success_criteria>

<output>
After completion, create `.planning/phases/02-trackers-baselines/02-02-SUMMARY.md`.
</output>
