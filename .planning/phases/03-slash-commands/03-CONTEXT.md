---
title: Phase 3 — Slash Commands Context
category: planning
phase: 03
source: <discussion>
last_updated: 2026-05-06
---

# Phase 3: Slash Commands - Context

**Gathered:** 2026-05-06
**Status:** Ready for planning

<domain>
## Phase Boundary

Implement six Claude Code slash commands as `.claude/commands/{name}.md` files. Each command reads from the durable knowledge base (`library/`, `calendar/`, `templates/`, `trackers/{person}/progress.md`) and either writes into per-person tracker files or proposes content in chat. The commands together form the daily/weekly operating loop:

| Command | Purpose | Touches |
|---------|---------|---------|
| `/prep-today` | Today's cooking/portioning brief | reads only — chat output |
| `/log-day` | Create or smart-merge today's daily log for both people | writes `trackers/{person}/daily/YYYY-MM-DD.md` |
| `/weekly-plan` | Generate next 7-day plan conversationally | writes `trackers/weekly-plans/YYYY-Www.md` |
| `/shopping-list` | Derive shopping list from active week | writes `trackers/weekly-plans/YYYY-Www-shopping.md` (propose first) |
| `/weekly-review` | Both people: 7-day weight avg, adherence, training, adjustment proposal | writes `trackers/{person}/weekly/YYYY-Www.md` |
| `/swap-meal` | Mid-day alternative meal that fits remaining macros | reads only — chat output |

**NOT in this phase:** top-level README and docs/conventions.md (Phase 4); Strava import, MFP API integration, recipe scaling beyond 4-portion (v2 deferred); custom UI of any kind.

</domain>

<decisions>
## Implementation Decisions

### Foundational (apply to all commands)
- **D-01:** Slash command files live at `.claude/commands/{name}.md`. The `.claude/commands/` directory does not exist yet — Phase 3 creates it. Each file is a markdown prompt template that becomes the command's prompt when invoked. Front-of-file frontmatter (Claude Code convention): `description`, optional `argument-hint`. Body is the prompt the model sees.
- **D-02:** **Conversational args, no positional structure.** Every command runs with no required arguments. Defaults: today, both people. Date / person / MFP-paste / preferences come from a follow-up chat turn when needed. Reasoning: most usage is on mobile; less typing wins. The `argument-hint` frontmatter field stays empty or notes "no args".
- **D-03:** **Mixed write-vs-propose by command type:**
  - **Write directly (smart-merge if file exists):** `/log-day`, `/weekly-review`
  - **Propose in chat then write on confirm:** `/weekly-plan`, `/shopping-list`
  - **Chat-only, no file write:** `/prep-today`, `/swap-meal`
  - Rationale: match write-behavior to undo cost. Logs are append-style and merge cleanly. Plans set the whole week — confirm before writing. Briefs and swaps are ephemeral.
- **D-04:** **Library-anchor resolution.** Commands that reference meals use the format `library:meals#{anchor}` (locked in Phase 2 D-12). Anchors are kebab-case derived from H2/H3 headings in `library/meals.md` (Phase 2 Claude's-Discretion). Commands that need to look up a meal by anchor: read `library/meals.md`, find the heading whose kebab-case equals the anchor, take that section's body. Ambiguous anchors (duplicate headings) → first occurrence wins; flag in chat.
- **D-05:** **Date semantics.** Default = today (system clock). All file paths use the conventions locked in Phase 2: daily logs at `trackers/{person}/daily/YYYY-MM-DD.md` (D-02), weekly summaries at `trackers/{person}/weekly/YYYY-Www.md` (D-03). Weekly plan files use the same ISO-week convention: `trackers/weekly-plans/YYYY-Www.md`. ISO week = Python `%G-W%V` (e.g. `2026-W19`).
- **D-06:** **Person identifiers** (Phase 2 D-01 carry-forward): directory tokens are lowercase `jonas` / `farva`; display names are title-case `Jonas` / `Farva` in prose, frontmatter, and chat output.

### /prep-today (CMD-01)
- **D-07:** **Scope:** today only. Reads the active week's plan from `trackers/weekly-plans/{current-iso-week}.md`, the cycling row for today from `calendar/cycling-2026.md` (for Jonas's training context), and `library/cooking-rules.md` + `library/portions.md` for portioning guidance.
- **D-08:** **Output:** chat-only. A short brief, structured as: (a) what to cook today (recipe name + library ref); (b) what to thaw / pull from fridge for tomorrow; (c) portion split (Jonas vs Farva, accounting for Heathland-build kcal needs from `library/training-nutrition.md` if applicable); (d) leftover note if today's dinner is from a previous cook batch (4-portion convention from Phase 2 D-09 reasoning).
- **D-09:** **No active plan handling:** if no `trackers/weekly-plans/{this-iso-week}.md` exists, output "No weekly plan for this week — run `/weekly-plan` first." in chat and exit. Do not improvise a plan.

### /log-day (CMD-02)
- **D-10:** **Scope:** today, both people. No args. Writes `trackers/jonas/daily/YYYY-MM-DD.md` and `trackers/farva/daily/YYYY-MM-DD.md` from `templates/daily-log.md`. If today's file exists for either person, smart-merge (D-12 below).
- **D-11:** **Two-step MFP/Cronometer paste flow.** First chat turn after `/log-day`: Claude greets, asks "any MFP/Cronometer totals to log for either person?" User can paste a block (free-text — Claude parses kcal/protein/carb/fat numbers per person), say "no, will paste later", or include partial data. Claude:
  - Computes `kcal_estimate` (and macro estimates) from meal lines using `library:meals#{anchor}` lookups.
  - Fills `kcal_actual` (and macro actuals) from parsed paste if present.
  - Leaves actual fields `null` if no paste — they can be filled by a later `/log-day` re-run.
- **D-12:** **Smart merge on re-run** (same day). If `trackers/{person}/daily/{today}.md` already exists:
  - Read it, parse frontmatter and body.
  - **Append** new meal lines to `## Meals` (don't dedupe automatically — same meal twice is plausibly two real eating events; user removes manually if it's a typo).
  - **Overwrite** scalar frontmatter fields if a new value is supplied: `weight_kg`, `kcal_actual`, `protein_actual_g`, `carb_actual_g`, `fat_actual_g`. (Estimates recompute from updated meal list.)
  - **Append** to `## Notes` and `## Training` rather than overwrite.
  - Update `last_updated` to today.
  - Show a one-line diff summary in chat (e.g. "Jonas: +2 meals, kcal_actual 1800→2400. Farva: +1 meal.").
- **D-13:** **Conversational meal entry.** Claude asks "what did each of you eat today?" if no inline content was supplied. User answers in free text; Claude maps each item to the closest `library:meals#{anchor}` (best-effort) and emits the locked line format from Phase 2 D-12. If no library match exists, prefix with `(off-library)`.

### /weekly-plan (CMD-03)
- **D-14:** **Conversational from scratch.** Run `/weekly-plan` with no args. Claude opens with one **batched** chat turn covering 4 questions:
  1. What's already in the fridge / leftovers to use up?
  2. Training peak this week — and the peak day specifically? (Claude pre-fills a guess from `calendar/cycling-2026.md` for the upcoming ISO week; user confirms or corrects.)
  3. Any meals you want to repeat from a recent week? (Claude can list last week's meals from `trackers/weekly-plans/{prev-iso-week}.md` if it exists.)
  4. Any dislikes / cravings / "don't want this week"?
- **D-15:** **Plan algorithm** (after the batched answer):
  - Default 7-day shape: dinners-first (the 4-portion engine), then lunches (often = previous-day dinner leftover), then breakfasts (rotating from `library/meals.md` "breakfast" archetype), then snacks per `library/macro-templates.md`.
  - Group dinners in **consecutive pairs** to honor 4 portions = 2 dinners for both people (e.g. cook Mon = eat Mon+Tue dinner). 3 cook-events per week + 1 flex day (e.g. fast-food per `library/fast-food-rules.md` or "leftover roulette").
  - **Cycling-load alignment:** heavier-carb recipes (per `library/macro-templates.md`) on long-ride days; lighter on rest days; protein floor enforced for Jonas per his `progress.md` `protein_floor_g_per_day` field.
  - Use fridge/leftovers from Q1 first; honor cravings from Q3; avoid dislikes from Q4.
- **D-16:** **Propose-then-write flow.** After computing the plan, Claude shows the full week in chat as a markdown table (day | meals | training | notes). User responds with "ok" / "swap Tue dinner" / "more protein on Thu" etc. Iterate inline until user says "ok / write it". Then write `trackers/weekly-plans/{this-iso-week}.md` (creating `trackers/weekly-plans/` directory if needed) using the file shape from `templates/weekly-plan.md` (already migrated in Phase 1).
- **D-17:** **Re-run on existing week:** if `trackers/weekly-plans/{this-iso-week}.md` already exists, Claude shows it in chat and asks "amend this plan or replace?" Amend = same conversational flow, but pre-load existing as the starting point. Replace = start blank.

### /shopping-list (CMD-04)
- **D-18:** **Reads** the active week's plan from `trackers/weekly-plans/{this-iso-week}.md`. **Errors** to chat with "no active weekly plan — run `/weekly-plan` first" if missing. Walks each meal's `library:recipes#{anchor}` (or `library:meals#{anchor}`) to extract ingredients; aggregates quantities; subtracts pantry baseline from `templates/shopping-list.md` (the migrated Phase 1 pantry template). 4-portion scaling already baked into recipe ingredients (Phase 1 convention).
- **D-19:** **Propose-then-write.** Claude shows the aggregated list in chat (grouped by store section: produce / proteins / pantry / fridge / freezer). User can edit ("skip eggs, already have 12") inline. On confirm, writes `trackers/weekly-plans/{this-iso-week}-shopping.md` so the user can re-open it on phone while shopping.

### /weekly-review (CMD-05)
- **D-20:** **Scope:** both people by default, two output files. Writes `trackers/jonas/weekly/{this-iso-week}.md` and `trackers/farva/weekly/{this-iso-week}.md` from `templates/weekly-summary.md` (Phase 2 D-14). Each file's adjustment-proposal section is sized to that person's evidence (Farva slim per Phase 2 D-06 — no Training section; her Adjustment proposal is shorter).
- **D-21:** **Computation** (per person, for the most recent **completed** ISO week — i.e. the week ending most recently, not the current in-progress week):
  - **Weight:** read `weight_kg` from each `trackers/{person}/daily/*.md` whose `date` falls in that ISO week. Compute mean. If fewer than 4 readings present, set `## Weight` to "n=X/7 — insufficient data for trend" and skip trend math. Else compute trend = (this-week-mean − previous-week-mean) / 1 week.
  - **Adherence:** read `kcal_actual` (else `kcal_estimate`) from each daily file. Read that day's kcal target via the CAL-02 contract (`library/cal-02-contract.md` — already locked in Phase 2 D-19; commands resolve it at runtime per `library/calorie-targets.md`). Day counts as adherent if within ±10% of target. Days with neither actual nor estimate = "no data", excluded from denominator.
  - **Training (Jonas only):** sum km / hours / `training_est_kcal` from cycling-2026.md rows for that ISO week.
  - **Adjustment proposal:** apply the rules from `library/calorie-targets.md`. v1 explicit rules: (a) **drop > 0.8 kg in one week** → propose +200 kcal/day next week (carb-loaded on training days); (b) **drop < 0.3 kg/week for 2 consecutive weeks** → propose −150 kcal/day; (c) **on track** → maintain. Always prose with the *why* (Phase 2 D-15), not just a number. For Farva, only rule (a)/(b)/(c) on her targets — no training-coupling.
- **D-22:** **Propose + ask in chat to apply.** After writing both weekly-summary files, Claude shows each adjustment proposal in chat with "apply Jonas's adjustment to next week's targets in `trackers/jonas/progress.md`? [yes / no / edit]" and same for Farva. Batched into one ask with two answers. On "yes": surgically update the relevant frontmatter fields in `progress.md` (`target_weight_kg`, `target_date`, or add a per-week kcal-target field — to be decided in planner based on what `library/calorie-targets.md` actually drives) AND record the change in the just-written weekly-summary's `## Adjustment proposal` section (so the file is self-documenting of what was applied). On "no" / "edit" / no rule fired: do nothing further; the proposal stays in the weekly-summary as advisory prose.

### /swap-meal (CMD-06)
- **D-23:** **Scope:** chat-only. Run `/swap-meal` with no args. Claude reads today's daily-log file for whichever person the user references in chat ("swap Jonas's lunch"; if neither is named, asks). Identifies the meal slot (or asks). Reads remaining macros for the day = (today's CAL-02 target) − (sum of already-logged meals' estimates). Searches `library/meals.md` for an alternative meal in the same archetype (lunch/dinner/etc.) whose macros fit the remaining budget per `library/macro-templates.md`. Returns 1–3 options in chat with library refs. User picks → user manually edits the daily-log meal line (or re-runs `/log-day` with the swap as a fresh entry — smart-merge handles it).
- **D-24:** **No file mutation.** Reasoning: mid-day swaps are exploratory; `/log-day`'s smart-merge already handles eventual logging cleanly.

### Claude's Discretion
- Exact wording / structure of each command's prompt template body (the prompt the model sees when the command runs). Frontmatter `description` field should be a single short sentence; Claude picks the wording.
- Exact phrasing of the batched 4-question opener for `/weekly-plan` (D-14). The four topics are locked; the words aren't.
- How `/log-day` parses pasted MFP/Cronometer blocks (D-11) — heuristic: look for `kcal`/`calories`, `protein`/`g protein`, `carb`/`carbohydrate`, `fat` adjacent to a number; per-person attribution by name proximity. Edge cases (single combined paste with no name, ambiguous numbers) → ask in chat.
- Exact iteration UX for `/weekly-plan` propose-then-write (D-16) and `/shopping-list` (D-19). Commands should accept natural-language edits, not require structured replies.
- Per-week kcal-target field shape in `progress.md` if `/weekly-review` D-22 actually applies an adjustment — planner decides whether to add a new field, replace `target_weight_kg`, or just bump the formula in `library/calorie-targets.md`. The planner should pick once and apply consistently.
- Color / formatting conventions for chat output (tables vs lists vs bullets) — keep readable on both desktop and Claude mobile.

</decisions>

<canonical_refs>
## Canonical References

**Downstream agents MUST read these before planning or implementing.**

### Project intent & requirements
- `.planning/PROJECT.md` — system overview, Jonas/Farva goals, Heathland event, hybrid kcal model
- `.planning/REQUIREMENTS.md` — atomic requirements CMD-01..06 in scope for this phase
- `.planning/ROADMAP.md` — Phase 3 success criteria 1–6

### Phase 1 inputs (knowledge base — already in repo)
- `library/meals.md` — meal anchors for `library:meals#{anchor}` lookups (D-04)
- `library/recipes.md` — recipe ingredients for `/shopping-list` aggregation (D-18)
- `library/calorie-targets.md` — formula source consumed at runtime by every command that touches kcal targets (D-21)
- `library/macro-templates.md` — macro archetypes by session_type (D-15, D-21, D-23)
- `library/cooking-rules.md` — cooking guidance for `/prep-today` brief (D-07)
- `library/portions.md` — portioning guidance for `/prep-today` (D-07)
- `library/training-nutrition.md` — training-day fueling rules (D-08, D-15)
- `library/fast-food-rules.md` — flex-day options (D-15)
- `library/preferences.md` — dislike/preference baseline for `/weekly-plan` (D-14 Q4)
- `library/daily-structure.md` — meal-slot layout (breakfast/lunch/dinner/snacks)
- `calendar/cycling-2026.md` — session_type + Est. kcal source per date (D-08, D-15, D-21)

### Phase 2 inputs
- `library/cal-02-contract.md` — locked I/O schema; commands resolve "today's target" via this contract (D-21)
- `templates/daily-log.md` — file shape for `/log-day` (D-10)
- `templates/weekly-summary.md` — file shape for `/weekly-review` (D-20)
- `templates/weekly-plan.md` — file shape for `/weekly-plan` outputs (D-16)
- `templates/shopping-list.md` — pantry baseline for `/shopping-list` (D-18)
- `trackers/jonas/progress.md` — Jonas baseline + Heathland event context (D-08, D-22)
- `trackers/farva/progress.md` — Farva baseline (D-22)
- `.planning/phases/02-trackers-baselines/02-CONTEXT.md` — D-01..D-19 (Farva naming, file path conventions, hybrid kcal model, CAL-02 contract)

### Out-of-scope but referenced
- `.claude/commands/` directory — Claude Code slash command convention. Phase 3 creates it; Phase 4 docs publish how to use it (`README.md`).

</canonical_refs>

<code_context>
## Existing Code Insights

### Reusable Assets
- All knowledge files in `library/`, `calendar/cycling-2026.md`, `templates/*.md` (Phase 1 + 2). Commands read these but do not modify them.
- `library/cal-02-contract.md` (Phase 2) is the single integration document — every command that touches "today's target" resolves it through the contract pattern (read calendar row → read calorie-targets.md formula → read macro-templates.md archetype → emit structured object).

### Established Patterns
- Markdown-only system, no code, no tests, no CI (CLAUDE.md). Phase 3 commands are markdown prompt templates — still pure file creation, no executable code.
- Frontmatter convention from Phase 1 (`title`, `category`, `source`, `last_updated`) — slash command files use Claude Code's own convention (`description`, optional `argument-hint`) instead, since the file IS the prompt the model sees.
- File-path conventions: `trackers/{person}/daily/YYYY-MM-DD.md`, `trackers/{person}/weekly/YYYY-Www.md`, plus this phase introduces `trackers/weekly-plans/YYYY-Www.md` and `trackers/weekly-plans/YYYY-Www-shopping.md`.

### Integration Points
- `/log-day` MUST conform to `templates/daily-log.md` shape (Phase 2 D-10..D-13).
- `/weekly-review` MUST conform to `templates/weekly-summary.md` shape (Phase 2 D-14, D-15).
- All commands that resolve "today's target" MUST read `library/cal-02-contract.md` first to honor the locked schema.
- `/weekly-review`'s D-22 application path mutates `trackers/{person}/progress.md` — must update `last_updated` and preserve all other locked Phase 2 frontmatter fields (D-07).

</code_context>

<specifics>
## Specific Ideas

### Slash command file shape (locked per D-01)

Each `.claude/commands/{name}.md` file uses Claude Code's frontmatter convention:

```markdown
---
description: One short sentence describing the command for /help.
argument-hint:
---

<prompt body the model sees when the command is invoked>
```

`argument-hint` stays empty per D-02 (conversational, no positional args).

### File-path conventions introduced in Phase 3

- `trackers/weekly-plans/YYYY-Www.md` — one weekly plan file per ISO week (D-16)
- `trackers/weekly-plans/YYYY-Www-shopping.md` — derived shopping list (D-19)
- `.claude/commands/{name}.md` — six command files (D-01)

### Smart-merge cheatsheet for /log-day (D-12)

| Field type | On re-run with new value |
|------------|--------------------------|
| `## Meals` lines | Append (no auto-dedup) |
| `## Notes` text | Append |
| `## Training` text (Jonas) | Append |
| `weight_kg` (frontmatter) | Overwrite if non-null supplied |
| `kcal_actual`, `protein_actual_g`, `carb_actual_g`, `fat_actual_g` | Overwrite if supplied |
| `kcal_estimate` and macro estimates | Recompute from updated meal list |
| `last_updated` | Always update to today |
| All other frontmatter | Untouched |

### Adjustment-rule defaults for /weekly-review (D-21)

```
if delta_weight_kg_this_week >  0.8 → +200 kcal/day next week (extra carbs on training days)
if delta_weight_kg_this_week < 0.3 for 2 consecutive weeks → −150 kcal/day
otherwise → maintain (proposal = "on track")
```

These thresholds derive from PROJECT.md / `library/calorie-targets.md`. If the library file specifies different exact numbers when planner reads it, those win — this section is a default for when the file doesn't yet name them.

### Empty-state behavior matrix

| Command | If precondition missing |
|---------|-------------------------|
| `/prep-today` | No active weekly plan → chat "run /weekly-plan first" (D-09) |
| `/log-day` | First run of the day → fresh template instantiation (D-10) |
| `/weekly-plan` | Plan already exists → "amend or replace?" (D-17) |
| `/shopping-list` | No active weekly plan → chat error (D-18) |
| `/weekly-review` | <4 weight readings → "insufficient data" in `## Weight`, still write the file (D-21) |
| `/swap-meal` | No daily log yet today → chat "no logged meals — what was your remaining macro budget intent?" |

</specifics>

<deferred>
## Deferred Ideas

- **Linking commands** (`/log-day` automatically calls `/swap-meal` if a meal is off-plan, etc.) — rejected for v1, each command stays single-purpose.
- **Mobile MFP API integration** — v2 deferred per PROJECT.md / REQUIREMENTS.md. v1 keeps the paste-into-chat pattern.
- **Multi-week meal planning** (plan 2 weeks at once for travel etc.) — v2.
- **Per-meal kcal/macro pre-computation in library/meals.md** — currently estimates rely on Claude's runtime read of meals + recipes; if that proves slow or inconsistent, v2 could pre-compute and cache in frontmatter.
- **Auto-apply weekly-review adjustment without confirmation** — rejected (D-22 requires confirmation). Reconsider if the confirmation step proves redundant after several weeks of use.
- **`/swap-meal` writing to the daily log directly** — rejected (D-24). Reconsider if smart-merge re-run friction proves real.
- **Slash command for missed-day backfill** (`/log-day yesterday`) — D-02 says no positional args, so this would need to be a chat-turn follow-up: `/log-day` → "actually log yesterday" → Claude resolves date and writes. Working as designed; flag if backfill becomes a frequent flow.
- **PROJECT.md hybrid-kcal model wording update + stale `partner/` references on PROJECT.md lines 128/182 and REQUIREMENTS.md line 67** — Phase 4 docs sweep (carried forward from Phase 2 deferred + Phase 2 verifier observation).

</deferred>

---

*Phase: 03-slash-commands*
*Context gathered: 2026-05-06*
