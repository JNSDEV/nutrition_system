# Slash Commands: Shared Conventions

This file is a reference for command authors and future maintainers. It is NOT itself a slash command. Every `.claude/commands/{name}.md` file must conform to the conventions documented here.

---

## 1. File-Shape Convention (D-01)

Each `.claude/commands/{name}.md` file uses Claude Code's frontmatter convention:

```
---
description: One short sentence describing the command for /help.
argument-hint:
---

<prompt body the model sees when the command is invoked>
```

`argument-hint` is always left empty (see Section 2).

The body of the file is the prompt the model receives at invocation time. It should be self-contained: include all necessary instructions, read paths, and behavior rules the model needs to complete the command without consulting CONTEXT.md.

---

## 2. Conversational-Args Principle (D-02)

No command requires positional arguments. Defaults are:
- **Date:** today (system clock)
- **People:** both Jonas and Farva

Date, person, MFP/Cronometer paste, and preferences come from a follow-up chat turn when needed.

**Rationale:** Most usage is on mobile — fewer typed args wins. The `argument-hint` frontmatter field stays empty or, at most, notes "no args needed".

---

## 3. Write-vs-Propose-vs-Chat Matrix (D-03)

| Command | Behavior |
|---------|----------|
| `/log-day` | Write directly; smart-merge if file already exists |
| `/weekly-review` | Write directly; then propose adjustment in chat |
| `/weekly-plan` | Propose in chat, write on user confirm |
| `/shopping-list` | Propose in chat, write on user confirm |
| `/prep-today` | Chat-only, no file write |
| `/swap-meal` | Chat-only, no file write |

**Rationale:** Match write-behavior to undo cost. Logs are append-style and merge cleanly. Plans set the whole week — confirm before writing. Briefs and swaps are ephemeral.

---

## 4. Library-Anchor Resolution (D-04)

Meal and recipe references use the format `library:meals#{anchor}` (locked in Phase 2 D-12).

**Resolution procedure:**
1. Read `library/meals.md`
2. Find the H2 or H3 heading whose kebab-case form equals the anchor
3. Take that section's body as the meal definition

**Ambiguous anchors** (duplicate headings) → first occurrence wins; flag the ambiguity in chat.

**Unresolvable references** → prefix meal line with `(off-library)` and continue.

---

## 5. Date Semantics (D-05)

Default date = today (system clock). All file paths follow Phase 2 conventions:

| File type | Path pattern |
|-----------|-------------|
| Daily logs | `trackers/{person}/daily/YYYY-MM-DD.md` |
| Weekly summaries | `trackers/{person}/weekly/YYYY-Www.md` |
| Weekly plans | `trackers/weekly-plans/YYYY-Www.md` |
| Shopping lists | `trackers/weekly-plans/YYYY-Www-shopping.md` |

**ISO week format:** `YYYY-Www` using Python `%G-W%V` (e.g. `2026-W19`). Week starts Monday per ISO 8601.

Phase 3 introduces the `trackers/weekly-plans/` directory. Commands that write weekly plans create this directory if it does not exist.

---

## 6. Person Identifiers (D-06)

| Context | Jonas | Farva |
|---------|-------|-------|
| Directory tokens | `jonas` | `farva` |
| Display names in prose and chat | `Jonas` | `Farva` |
| Frontmatter values | `Jonas` | `Farva` |

Never use "Partner" in Phase 3 command files (see Section 9 for ROADMAP note).

---

## 7. CAL-02 Contract (Commands That Touch kcal Targets)

Every command that resolves "today's kcal target" MUST read `library/cal-02-contract.md` first for the locked schema. Then read:

1. `library/calorie-targets.md` — formula
2. `library/macro-templates.md` — macro archetypes by session type
3. `calendar/cycling-2026.md` — session type + estimated kcal burn for the relevant date

Commands affected: `/prep-today`, `/log-day`, `/weekly-plan`, `/weekly-review`, `/swap-meal`.

The CAL-02 contract defines the integration object shape — do not derive "today's target" from any other path.

---

## 8. D-22 Decision: Recording Applied Adjustments in progress.md

When `/weekly-review` applies a kcal adjustment, it appends an entry to a `weekly_kcal_adjustments` list in `trackers/{person}/progress.md` frontmatter.

**Schema:**
```yaml
weekly_kcal_adjustments:
  - week: YYYY-Www
    delta_kcal_per_day: +200    # or -150, or 0
    reason: ">0.8 kg/wk loss — adding carbs on training days"
    applied: YYYY-MM-DD
```

**Semantics:**
- The most recent entry's `delta_kcal_per_day` is **additive** on top of `base_kcal` from the CAL-02 formula
- This does NOT overwrite `target_weight_kg` or `target_date` (those are milestone goals, not weekly levers)
- This does NOT require touching `library/calorie-targets.md` (the formula stays durable and person-agnostic)
- Multiple adjustments are preserved in order — the history is self-documenting
- `last_updated` in `progress.md` is always updated to the application date

**Commands that compute "this week's effective target"** add the most recent entry's `delta_kcal_per_day` to the `base_kcal` from the CAL-02 resolution. If `weekly_kcal_adjustments` is absent or empty, treat the delta as 0.

**Adjustment rules (for /weekly-review):**
```
if weekly_weight_delta > 0.8 kg lost → propose +200 kcal/day next week (extra carbs on training days)
if weekly_weight_delta < 0.3 kg lost for 2 consecutive weeks → propose −150 kcal/day
otherwise → maintain (proposal = "on track")
```

If `library/calorie-targets.md` specifies different exact thresholds, those win over the defaults above.

---

## 9. ROADMAP Display-Name Note

`ROADMAP.md` still references "Partner" in Phase 3 success criteria (historical placeholder). The canonical name is `farva` (directory) / `Farva` (display), per Phase 2 D-01. **Phase 4 docs sweep will update ROADMAP.md** — it is not in scope for Phase 3. Command files must use `farva`/`Farva`, never "Partner".

---

## 10. Empty-State Behavior

| Command | Missing precondition | Required behavior |
|---------|---------------------|-------------------|
| `/prep-today` | No active weekly plan for this ISO week | Chat: "No weekly plan for this week — run `/weekly-plan` first." Then exit; do not improvise. |
| `/log-day` | First run of the day (no file exists) | Fresh template instantiation from `templates/daily-log.md` |
| `/weekly-plan` | Plan already exists for this ISO week | Chat: show existing plan, ask "amend this plan or replace?" |
| `/shopping-list` | No active weekly plan for this ISO week | Chat error: "No active weekly plan — run `/weekly-plan` first." |
| `/weekly-review` | Fewer than 4 weight readings in the week | Set `## Weight` to "n=X/7 — insufficient data for trend"; skip trend math; still write the file |
| `/swap-meal` | No daily log yet for today | Chat: "No logged meals yet today — what was your remaining macro budget intent?" |

---

## Command Index

| File | Command | Requirements |
|------|---------|-------------|
| `prep-today.md` | `/prep-today` | CMD-01 |
| `log-day.md` | `/log-day` | CMD-02 |
| `weekly-plan.md` | `/weekly-plan` | CMD-03 |
| `shopping-list.md` | `/shopping-list` | CMD-04 |
| `weekly-review.md` | `/weekly-review` | CMD-05 |
| `swap-meal.md` | `/swap-meal` | CMD-06 |

---

*Phase: 03-slash-commands*
*Last updated: 2026-05-06*
*Source decisions: D-01 through D-06, D-22 (03-CONTEXT.md + 03-MANIFEST.md)*
