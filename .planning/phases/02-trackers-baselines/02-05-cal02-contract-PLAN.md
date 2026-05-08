---
phase: 02-trackers-baselines
plan: 05
type: execute
wave: 1
depends_on: []
files_modified:
  - library/cal-02-contract.md
  - .planning/PROJECT.md
autonomous: true
requirements: [CAL-02]
must_haves:
  truths:
    - "User can open library/cal-02-contract.md and read the CAL-02 input/output schema for both jonas and farva (D-17)"
    - "Phase 3 commands can `read_first` library/cal-02-contract.md without parsing 02-CONTEXT.md (D-19)"
    - "PROJECT.md no longer carries the 'Open: confirm partner's preferred display name (placeholder: Partner)' line — it is replaced by a recorded resolution to Farva (D-01)"
  artifacts:
    - path: "library/cal-02-contract.md"
      provides: "CAL-02 integration contract (input/output schema, formula source pointers)"
      contains: "category: library"
    - path: ".planning/PROJECT.md"
      provides: "updated open-question line recording Farva resolution"
      contains: "Farva"
  key_links:
    - from: "library/cal-02-contract.md"
      to: "library/calorie-targets.md, library/macro-templates.md, calendar/cycling-2026.md"
      via: "named source-of-truth pointers in the contract body (D-17)"
      pattern: "library/calorie-targets.md"
---

<objective>
Create `library/cal-02-contract.md` as a standalone integration document that locks the CAL-02 input/output schema (D-17), the training-burn split (D-18), and pointers to the formula and macro source files (D-16, D-17). Phase 3 plans will `read_first` this file instead of parsing `02-CONTEXT.md`.

Also: update `.planning/PROJECT.md` to record the Farva resolution (D-01) — replace the "Open: confirm partner's preferred display name (placeholder: Partner)" line with a resolved decision pointing at trackers/farva/.

Purpose: CAL-02 — Phase 3's `/log-day`, `/weekly-plan`, `/weekly-review`, `/swap-meal` all consume this contract.
Output: `library/cal-02-contract.md` (new), `.planning/PROJECT.md` (1-line edit).
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
@library/calorie-targets.md
@library/macro-templates.md
@calendar/cycling-2026.md
</context>

<tasks>

<task type="auto">
  <name>Task 1: Create library/cal-02-contract.md with locked contract schema</name>
  <files>library/cal-02-contract.md</files>
  <read_first>
    - .planning/phases/02-trackers-baselines/02-CONTEXT.md (D-16 formula source, D-17 contract schema, D-18 training burn split, D-19 contract document spec, contract example body lines 221–238)
    - .planning/phases/01-foundation/01-CONTEXT.md (D-03 minimal 4-field frontmatter; D-19 mandates same minimal shape)
    - library/calorie-targets.md (formula source — confirm path)
    - library/macro-templates.md (macro archetype source — confirm path)
    - calendar/cycling-2026.md (session_type + Est. kcal column — confirm shape)
  </read_first>
  <action>
Create file `library/cal-02-contract.md` with EXACTLY this content (frontmatter is the minimal 4-field shape per D-19, body is the contract verbatim from CONTEXT.md D-17 + D-18, expanded with the field-level descriptions):

```markdown
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
```

Frontmatter MUST be exactly the 4 fields shown (D-19 explicit: "Same minimal 4-field shape as Phase 1"). Do NOT add `person`, `applies_to`, or any other fields.
  </action>
  <verify>
    <automated>test -f library/cal-02-contract.md && grep -q '^title: CAL-02 Contract — Daily Target Resolution$' library/cal-02-contract.md && grep -q '^category: library$' library/cal-02-contract.md && grep -q '^source: <discussion>$' library/cal-02-contract.md && grep -q '^last_updated: 2026-05-05$' library/cal-02-contract.md && grep -q '^## Input$' library/cal-02-contract.md && grep -q '^## Output (jonas)$' library/cal-02-contract.md && grep -q '^## Output (farva)$' library/cal-02-contract.md && grep -q 'library/calorie-targets.md' library/cal-02-contract.md && grep -q 'library/macro-templates.md' library/cal-02-contract.md && grep -q 'calendar/cycling-2026.md' library/cal-02-contract.md && grep -q 'base_kcal' library/cal-02-contract.md && grep -q 'training_est_kcal' library/cal-02-contract.md && grep -q 'kcal_total' library/cal-02-contract.md && grep -q 'HEATHLAND' library/cal-02-contract.md</automated>
  </verify>
  <acceptance_criteria>
    - File `library/cal-02-contract.md` exists
    - Frontmatter contains EXACTLY 4 fields: `title`, `category: library`, `source: <discussion>`, `last_updated: 2026-05-05` (no extras per D-19)
    - Body contains H2 headings: `## Input`, `## Output (jonas)`, `## Output (farva)`, `## Sources of truth`, `## Training burn handling (D-18)`, `## Marker tokens`, `## What this file is NOT`
    - Output schema names all required Jonas fields: `date`, `person`, `session_type`, `base_kcal`, `training_est_kcal`, `kcal_total`, `protein_g`, `carb_g`, `fat_g`
    - Output schema names all required Farva fields: `date`, `person`, `kcal_total`, `protein_g`, `carb_g`, `fat_g`
    - Body references `library/calorie-targets.md`, `library/macro-templates.md`, `calendar/cycling-2026.md` as named sources
    - Body names all four marker tokens: SPORTIVE, BENCHMARK, REHEARSAL, HEATHLAND
  </acceptance_criteria>
  <done>Contract file exists with the locked schema, ready for Phase 3 to `read_first`.</done>
</task>

<task type="auto">
  <name>Task 2: Update PROJECT.md to record Farva resolution (D-01)</name>
  <files>.planning/PROJECT.md</files>
  <read_first>
    - .planning/phases/02-trackers-baselines/02-CONTEXT.md (D-01 — directory lowercase `farva/`, display title-case `Farva`, mandate to update PROJECT.md "Open: confirm partner's preferred display name (placeholder: Partner)" line)
    - .planning/PROJECT.md (locate the open-question line; do NOT modify any other content)
  </read_first>
  <action>
1. Read `.planning/PROJECT.md` to locate the line containing "Open: confirm partner's preferred display name" (or any line containing "placeholder: Partner" — the wording may differ slightly).

2. Use Edit to replace that line with a resolved-decision line. Suggested replacement (use this verbatim if the line you find matches the CONTEXT.md quote; otherwise adapt to match the surrounding list/table format):

   - If the line is in a Markdown bullet list, replace with:
     `- **Resolved (Phase 2, D-01):** Partner's display name is **Farva**. Tracker directory is lowercase `trackers/farva/`; headings and prose use title-case **Farva**.`

   - If the line is in a "Key Decisions" or "Open Questions" table row, adapt to the table column shape (e.g. a row marking the question as Resolved with the resolution text above).

   - If the line literally reads "Open: confirm partner's preferred display name (placeholder: Partner)" with no surrounding bullet/table prefix, replace with:
     `Resolved (Phase 2, D-01): Partner's display name is Farva. Tracker directory is lowercase trackers/farva/; headings and prose use title-case Farva.`

3. Do NOT touch any other content in PROJECT.md. Do NOT renumber sections. Do NOT update any other open questions, decisions, or descriptions.

4. The "PROJECT.md update for hybrid kcal model" item is explicitly deferred to Phase 4 (per CONTEXT.md `<deferred>` section) — do NOT change PROJECT.md's "the markdown system is not the calorie database" wording in this plan.

5. After the edit, run `git diff --shortstat .planning/PROJECT.md` to confirm exactly one line changed (expect output like `1 file changed, 1 insertion(+), 1 deletion(-)`). If the shortstat shows more than 1 insertion or 1 deletion, revert and retry — the edit must be surgical.
  </action>
  <verify>
    <automated>grep -q 'Farva' .planning/PROJECT.md && ! grep -q 'placeholder: Partner' .planning/PROJECT.md && ! grep -q 'confirm partner.s preferred display name' .planning/PROJECT.md && grep -q 'D-01\|Phase 2' .planning/PROJECT.md && git diff --shortstat .planning/PROJECT.md | grep -qE '1 insertion\(\+\), 1 deletion\(-\)'</automated>
  </verify>
  <acceptance_criteria>
    - `.planning/PROJECT.md` contains the string `Farva`
    - `.planning/PROJECT.md` no longer contains the string `placeholder: Partner`
    - `.planning/PROJECT.md` no longer contains the open-question phrasing "confirm partner's preferred display name"
    - The replacement references the resolution (mentions D-01 or Phase 2 to establish provenance)
    - `git diff --shortstat .planning/PROJECT.md` reports exactly `1 insertion(+), 1 deletion(-)` — no other lines modified
  </acceptance_criteria>
  <done>The open-question line is replaced with a recorded resolution; no other PROJECT.md content touched.</done>
</task>

</tasks>

<verification>
- `library/cal-02-contract.md` is a self-contained read for Phase 3 — does not require reading 02-CONTEXT.md
- Frontmatter is the minimal 4-field shape (D-19)
- Both Jonas and Farva output schemas are present and complete
- PROJECT.md updated in exactly one place; no scope creep into other PROJECT.md sections
</verification>

<success_criteria>
ROADMAP success criterion #5 enabled: A slash command (Phase 3) can read this contract document and `cycling-2026.md` together to resolve today's session_type + estimated kcal burn for Jonas's daily target. CAL-02 traceability requirement satisfied.
</success_criteria>

<output>
After completion, create `.planning/phases/02-trackers-baselines/02-05-SUMMARY.md`.
</output>
