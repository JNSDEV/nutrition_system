---
title: Phase 4 — Onboarding & Docs Context
category: planning
phase: 04
source: <discussion>
last_updated: 2026-05-07
---

# Phase 4: Onboarding & Docs - Context

**Gathered:** 2026-05-07
**Status:** Ready for planning

<domain>
## Phase Boundary

Make the repo legible for a first-time reader and clean up stale terminology now that v1 is structurally complete. The phase produces:

| File | Purpose |
|------|---------|
| `README.md` (top-level) | First contact: what this is, the daily/weekly loop, how to use the commands, quickstart week, mobile flow, ASCII folder tree |
| `docs/conventions.md` | Reference card: file paths, naming rules, frontmatter, ISO weeks, person-name resolution + rename procedure |
| `CHANGELOG.md` (top-level) | Milestone-level change log starting at v1.0 |
| `CONTRIBUTING.md` (top-level) | Notes for future-Jonas on adding new library content / new commands |

Plus a **terminology cleanup sweep** across PROJECT.md, REQUIREMENTS.md, and ROADMAP.md replacing residual `Partner` with `Farva`, and fixing the PROJECT.md hybrid-kcal wording carried forward from Phase 2.

**NOT in this phase:** Strava/MFP API, mobile sync mechanism beyond the existing chat-buffer pattern, per-recipe pre-computed kcal, multi-week planning, anything in REQUIREMENTS v2.

</domain>

<decisions>
## Implementation Decisions

### Foundational
- **D-01:** **README opens with the operating-loop diagram** (cook → eat → log → adjust). The first content the reader sees is the loop, not a problem statement and not a quickstart. Reasoning: loop is the system's whole shape; once it clicks, everything else makes sense.
- **D-02:** **README and `docs/conventions.md` are split by purpose, not by detail level.** README = how-to-use (loop, commands, mobile flow, quickstart week, folder tree). `docs/conventions.md` = where-things-live (file paths, naming rules, frontmatter conventions, ISO weeks, person-name resolution + override procedure). Overlap is allowed only when needed for orientation; details live in conventions.
- **D-03:** **README structure (locked order):**
  1. Operating-loop diagram (D-01)
  2. One short paragraph: what this is + why (decision-fatigue framing from PROJECT.md)
  3. Quickstart week — Mon–Sun walkthrough showing which command runs when (D-04)
  4. Six commands at a glance (table; brief link to `.claude/commands/README.md` for the deep ref — do not duplicate)
  5. Mobile-buffer flow with worked example (D-06)
  6. Folder tree (ASCII, D-05)
  7. Where to look next (link to `docs/conventions.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `.planning/PROJECT.md`)
- **D-04:** **Quickstart week IS in README**, not a separate file. Format: 7-row table or bulleted Mon–Sun, naming the command for each event (e.g. "Sunday evening — `/weekly-plan`; Mon morning — `/prep-today`; Mon evening — `/log-day`; Wed — `/swap-meal` if needed; following Mon — `/weekly-review`"). Specific enough that a reader can mimic it the first week.
- **D-05:** **ASCII folder tree IS in README**, top-level only (one nesting level deep, with one-line descriptions). Example shape:
  ```
  library/         # Durable knowledge — meals, recipes, calorie targets, cycling/training rules
  calendar/        # Cycling-2026 calendar, session_type per date
  templates/       # File-shape templates for daily logs, weekly plans, etc.
  trackers/        # Per-person living state
    jonas/         # Daily logs, weekly summaries, progress.md (Heathland milestones)
    farva/         # Daily logs, weekly summaries, progress.md
    weekly-plans/  # Plans + shopping lists per ISO week
  .claude/commands/# 6 slash command prompt templates
  docs/            # conventions.md and other reference docs
  .planning/       # GSD workflow artifacts (PROJECT, ROADMAP, phase context)
  ```
- **D-06:** **Mobile-buffer flow uses the worked-example pattern** (~10 lines). Shows: open Claude mobile chat → type `/log-day` → paste MFP/Cronometer totals or "ate X for lunch" → chat retains the message → next time at the laptop, run `/log-day` again to reconcile (Phase 3 D-12 smart-merge handles it). Specifically names which slash command pairs with the buffer pattern.

### `docs/conventions.md` content (locked outline)
- **D-07:** **conventions.md sections (locked order):**
  1. **File-path conventions** — every path pattern in one place: `trackers/{person}/daily/YYYY-MM-DD.md`, `trackers/{person}/weekly/YYYY-Www.md`, `trackers/weekly-plans/YYYY-Www.md`, `trackers/weekly-plans/YYYY-Www-shopping.md`, `library/*.md`, `calendar/*.md`, `templates/*.md`, `.claude/commands/*.md`. One row per pattern with what writes/reads it.
  2. **Date format standard** — `YYYY-MM-DD` for dates; `YYYY-Www` for ISO weeks (Python `%G-W%V`). Single source.
  3. **Frontmatter conventions** — `title`, `category`, `last_updated`, `source` (durable knowledge files); per-person `progress.md` frontmatter contract from Phase 2 D-07; daily-log / weekly-summary / weekly-plan frontmatter from Phase 2 templates; `.claude/commands/*.md` use Claude Code's `description` + `argument-hint`.
  4. **Person-name resolution** — current resolution: directory token `jonas` / `farva`; display name `Jonas` / `Farva`. Historical note: "Partner" was the placeholder during Phases 1–2; resolved to "Farva" in Phase 2 D-01.
  5. **Rename procedure** (D-08) — concrete how-to for renaming `farva` → something else later.
  6. **Library-anchor format** — `library:meals#{anchor}` pattern from Phase 3 D-04, kebab-case from H2/H3.
  7. **`weekly_kcal_adjustments` schema** — additive frontmatter list in `progress.md` from Phase 3 D-22 (resolved by planner).
- **D-08:** **Rename procedure for the partner display name** (in `docs/conventions.md`):
  1. Update `display_name` in `trackers/{old}/progress.md` frontmatter.
  2. Rename directory: `git mv trackers/{old}/ trackers/{new}/`.
  3. Grep-replace `{Old display}` → `{New display}` in `library/`, `calendar/`, prose docs (NOT in historical `.planning/` artifacts — those are frozen).
  4. No code changes needed (markdown-only system); next slash-command run picks up the new name.

### Terminology cleanup sweep
- **D-09:** **In-scope edits to existing files** (one cleanup commit, separate from new doc files):
  - `.planning/PROJECT.md` lines 128, 182 — `partner/` → `farva/` (paths) and "Partner" → "Farva" (display).
  - `.planning/PROJECT.md` hybrid-kcal model wording — replace stale phrasing with the locked Phase 1 model: kcal/macro numbers come from MFP/Cronometer (actuals) + library formulas (estimates); the system stores both, never recomputes the external app's number.
  - `.planning/REQUIREMENTS.md` line 67 — `Partner` → `Farva`. Also flip DOC-01/DOC-02 to `[x]` once Phase 4 ships.
  - `.planning/ROADMAP.md` Phase 1/2/5 success-criteria mentions of "Partner" → "Farva".
  - **Frozen — do NOT edit:** `.planning/phases/01-*`, `02-*`, `03-*` artifacts (CONTEXT.md, PLAN.md, SUMMARY.md, MANIFEST.md, VERIFICATION.md, DISCUSSION-LOG.md). Those are historical record.
- **D-10:** **REQUIREMENTS.md DOC-01/DOC-02 wording stays as-written.** The "placeholder Partner — overridable" wording in DOC-02 is now historically accurate (Partner WAS the placeholder; Farva IS the override). Do not rewrite it; conventions.md handles the explanation.

### CHANGELOG.md and CONTRIBUTING.md
- **D-11:** **CHANGELOG.md** uses Keep-a-Changelog-style format. v1.0 is the first entry, retroactively summarizing what shipped in Phases 1–4: "knowledge base migrated from .txt", "per-person trackers + Farva baseline", "6 slash commands", "onboarding docs". Future entries are added per milestone, not per phase.
- **D-12:** **CONTRIBUTING.md** is short (~1 page). Three sections: (a) "Add a new meal/recipe to the library" — heading anchor convention so `library:meals#{anchor}` keeps working. (b) "Add a new slash command" — point at `.claude/commands/README.md` for the convention; note that any new command must be added to top-level README's command table and to conventions.md if it touches a new path pattern. (c) "Update calorie-target rules" — point at `library/calorie-targets.md`; thresholds in that file are authoritative over Phase 3 D-21 defaults.

### Claude's Discretion (planner picks)
- Exact prose wording, tone, and section copy — keep concise; the system is markdown-as-instructions, not a marketing doc.
- ASCII art for the operating-loop diagram (D-01) — boxes-and-arrows or a simple cycle; planner picks.
- Whether the quickstart week (D-04) is a 7-row markdown table or a 7-bullet list.
- Whether `CHANGELOG.md` v1.0 entry is split into "Added / Changed / Removed" or one combined "Added" block.
- File ordering of new top-level files (`README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`) — alphabetical or thematic; doesn't matter functionally.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project intent & requirements
- `.planning/PROJECT.md` — system overview, Jonas/Farva goals, Heathland event, hybrid-kcal model (note: hybrid-kcal wording will be edited per D-09)
- `.planning/REQUIREMENTS.md` — DOC-01, DOC-02 in scope; CHANGELOG.md / CONTRIBUTING.md are decisions (D-11/D-12), not requirements (no new requirement IDs needed; they're documentation companions)
- `.planning/ROADMAP.md` — Phase 4 success criteria 1–2

### Inputs to read for content (not edited)
- `.claude/commands/README.md` — Phase 3 conventions; the top-level README links here, does not duplicate
- `library/cal-02-contract.md` — referenced in conventions.md frontmatter section
- `templates/daily-log.md`, `templates/weekly-summary.md`, `templates/weekly-plan.md`, `templates/shopping-list.md` — referenced in conventions.md frontmatter section
- `trackers/jonas/progress.md`, `trackers/farva/progress.md` — referenced for `weekly_kcal_adjustments` schema
- `.planning/phases/01-foundation/01-CONTEXT.md` — library-anchor and frontmatter conventions
- `.planning/phases/02-trackers-baselines/02-CONTEXT.md` — file-path conventions D-02..D-05, person-resolution D-01, frontmatter D-07
- `.planning/phases/03-slash-commands/03-CONTEXT.md` — D-04 library-anchor format, D-22 (resolved) weekly_kcal_adjustments schema
- `.planning/phases/03-slash-commands/03-MANIFEST.md` — D-22 resolution detail

### Inputs to edit (terminology cleanup, D-09)
- `.planning/PROJECT.md` (lines 128, 182, plus hybrid-kcal model paragraph)
- `.planning/REQUIREMENTS.md` (line 67; DOC-01/DOC-02 checkbox after phase ships)
- `.planning/ROADMAP.md` (Phase 1/2/5 success-criteria "Partner" → "Farva")

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- All convention info already exists in prior `.planning/phases/0X-*-CONTEXT.md` files — Phase 4 surfaces and consolidates, does not invent.
- `.claude/commands/README.md` (Phase 3) covers the slash-command convention layer. The top-level README links to it.

### Established Patterns
- Markdown-only system (CLAUDE.md). Phase 4 follows: pure file creation/edit, no code, no tests, no CI.
- Frontmatter convention from Phase 1: `title` / `category` / `source` / `last_updated`. Top-level files (README/CHANGELOG/CONTRIBUTING) follow GitHub conventions instead — no custom frontmatter required.

### Integration Points
- `docs/conventions.md` codifies what was implicit before; if any future phase introduces a new file-path pattern, conventions.md must be updated (CONTRIBUTING.md D-12 mentions this).
- `CHANGELOG.md` v1.0 entry references milestone artifacts; future milestones append.

</code_context>

<specifics>
## Specific Ideas

### Quickstart-week table shape (D-04 hint)

| When | Command | What it does |
|------|---------|-------------|
| Sun evening | `/weekly-plan` | Plan next 7 days conversationally; writes `trackers/weekly-plans/YYYY-Www.md` |
| Sun evening | `/shopping-list` | Derive shopping list from the new plan |
| Mon morning | `/prep-today` | Today's cooking/portioning brief (chat-only) |
| Mon evening | `/log-day` | Log today's meals + weights + training |
| Mid-week | `/swap-meal` | Mid-day alternative if a meal won't fit (chat-only) |
| Following Mon | `/weekly-review` | 7-day review + optional kcal adjustment for next week |

Planner can rephrase but should keep this 6-row pattern.

### Cleanup-edit grep patterns (D-09 hint)

- Find: `Partner` (case-sensitive) in PROJECT.md, REQUIREMENTS.md, ROADMAP.md only.
- Find: `partner/` (path) in PROJECT.md only.
- **Do NOT** sweep `.planning/phases/0[123]-*/` — those are frozen historical artifacts.
- **Do NOT** sweep `library/`, `calendar/`, `templates/`, `trackers/` — those should already be `Farva`/`farva` from Phases 1–2 (verify via grep before commit; flag any hits found).

### Operating-loop diagram (D-01 hint)

ASCII cycle, ~6 lines:
```
        ┌──────── plan (weekly) ────────┐
        │                                │
   adjust ◀── review ◀── log ◀── eat ◀── cook ──┐
        │                                        │
        └─────── prep (today) ───────────────────┘
```

Planner picks the exact rendering — boxes, plain arrows, or fancy box-drawing — but the loop must show: plan → cook → eat → log → review → adjust → (back to plan), with `/prep-today` as the daily entry.

### CHANGELOG.md v1.0 entry shape (D-11 hint)

```markdown
## [1.0.0] - 2026-MM-DD

### Added
- Knowledge base in `library/` (meals, recipes, portions, cooking-rules, calorie-targets, …)
- Cycling calendar in `calendar/cycling-2026.md` driving Jonas's daily kcal targets
- File-shape templates in `templates/`
- Per-person trackers in `trackers/jonas/` and `trackers/farva/` with progress.md baselines
- Six slash commands: /prep-today, /log-day, /weekly-plan, /shopping-list, /weekly-review, /swap-meal
- Top-level onboarding docs (README, CHANGELOG, CONTRIBUTING) + `docs/conventions.md`
```

</specifics>

<deferred>
## Deferred Ideas

- **GIF / video walkthrough** of the loop — markdown-only system; out of scope.
- **Mobile sync beyond chat buffer** (Obsidian / iCloud / iA Writer) — v2 per PROJECT.md.
- **Per-phase changelog granularity** — D-11 is per-milestone. If users want plan-level history, point them at git log + `.planning/phases/`.
- **Auto-generated docs from `.planning/`** — could derive parts of conventions.md programmatically; rejected (no build step, manual is fine for v1).
- **Translated docs** — English only.
- **Architecture decision records (ADRs) extracted from `.planning/`** — interesting but not v1.

</deferred>

---

*Phase: 04-onboarding-docs*
*Context gathered: 2026-05-07*
