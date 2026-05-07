---
title: Conventions
category: docs
last_updated: 2026-05-07
---

# Conventions

Reference card for file paths, naming rules, frontmatter, date format, and person-name resolution.

---

## 1. File-path conventions

Every path pattern in one place. `{person}` is always the lowercase directory token: `jonas` or `farva`.

| Pattern | Written by | Read by |
|---------|------------|---------|
| `trackers/{person}/daily/YYYY-MM-DD.md` | `/log-day` | `/weekly-review`, `/prep-today` |
| `trackers/{person}/weekly/YYYY-Www.md` | `/weekly-review` | `/weekly-review` |
| `trackers/weekly-plans/YYYY-Www.md` | `/weekly-plan` | `/prep-today`, `/shopping-list`, `/swap-meal` |
| `trackers/weekly-plans/YYYY-Www-shopping.md` | `/shopping-list` | human |
| `trackers/{person}/progress.md` | `/weekly-review` (adjustments only) | all commands |
| `library/*.md` | human (Claude edits via CONTRIBUTING.md) | all commands |
| `calendar/*.md` | human | `/prep-today`, `/log-day`, `/weekly-plan`, `/weekly-review`, `/swap-meal` |
| `templates/*.md` | human | `/log-day` (daily-log), `/weekly-review`, `/weekly-plan` |
| `.claude/commands/*.md` | human (per CONTRIBUTING.md) | Claude Code (slash command invocation) |
| `docs/*.md` | human (Claude edits via CONTRIBUTING.md) | human, Claude (reference) |

---

## 2. Date format standard

- **Dates:** `YYYY-MM-DD` (ISO 8601). Example: `2026-05-07`.
- **ISO weeks:** `YYYY-Www` using Python `%G-W%V`. Example: `2026-W19`. Week starts Monday per ISO 8601.
- Both formats appear in file paths and frontmatter fields.
- Never use locale-specific formats (`DD/MM/YYYY`, `MM/DD/YYYY`, etc.).

---

## 3. Frontmatter conventions

### 3.1 Durable knowledge files (`library/*.md`, `calendar/*.md`, `templates/*.md`)

| Field | Type | Description |
|-------|------|-------------|
| `title` | string | Human-readable file title |
| `category` | string | File category (e.g. `meals`, `rules`, `template`) |
| `source` | string | Origin of the content (e.g. `<discussion>`, source `.txt` filename) |
| `last_updated` | `YYYY-MM-DD` | Date of last edit |

Top-level files (`README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`) follow GitHub conventions — no custom frontmatter block required.

### 3.2 Person progress files (`trackers/{person}/progress.md`)

| Field | Type | Description |
|-------|------|-------------|
| `title` | string | `{Person} — Progress` |
| `category` | string | `tracker` |
| `person` | string | Directory token: `jonas` or `farva` |
| `source` | string | `<discussion>` |
| `last_updated` | `YYYY-MM-DD` | Overwritten on each `/weekly-review` run |
| `start_weight_kg` | number | Starting weight in kilograms |
| `target_weight_kg` | number | Current primary weight target — **never overwritten by adjustments** |
| `target_date` | `YYYY-MM-DD` or `ASAP` | Deadline for primary target — **never overwritten by adjustments** |
| `secondary_target_kg` | number | (Jonas only) Secondary weight milestone |
| `secondary_target_date` | string | (Jonas only) Deadline for secondary target |
| `event` | string | (Jonas only) Name of the key event |
| `event_window` | `YYYY-MM-DD..YYYY-MM-DD` | (Jonas only) Event date range |
| `protein_floor_g_per_day` | string | (Jonas only) Minimum daily protein in grams |
| `weekly_kcal_adjustments` | list | Additive kcal deltas applied by `/weekly-review`; schema in Section 7 |

### 3.3 Daily-log files (`trackers/{person}/daily/YYYY-MM-DD.md`) and weekly-summary files (`trackers/{person}/weekly/YYYY-Www.md`)

**Daily-log frontmatter** (instantiated by `/log-day` from `templates/daily-log.md`):

| Field | Type | Description |
|-------|------|-------------|
| `title` | string | `{Person} — {YYYY-MM-DD}` |
| `category` | string | `daily-log` |
| `person` | string | `jonas` or `farva` |
| `source` | string | `templates/daily-log.md` |
| `last_updated` | `YYYY-MM-DD` | Date of creation/last update |
| `date` | `YYYY-MM-DD` | Date of the log entry |
| `weight_kg` | number or null | Morning weight reading |
| `kcal_estimate` | number or null | Estimated kcal (from library / prep plan) |
| `kcal_actual` | number or null | Actual kcal (from MFP/Cronometer) |
| `protein_estimate_g` | number or null | Estimated protein in grams |
| `protein_actual_g` | number or null | Actual protein in grams |
| `carb_estimate_g` | number or null | Estimated carbs in grams |
| `carb_actual_g` | number or null | Actual carbs in grams |
| `fat_estimate_g` | number or null | Estimated fat in grams |
| `fat_actual_g` | number or null | Actual fat in grams |

**Weekly-summary frontmatter** (instantiated by `/weekly-review` from `templates/weekly-summary.md`):

| Field | Type | Description |
|-------|------|-------------|
| `title` | string | `{Person} — Week {YYYY-Www}` |
| `category` | string | `weekly-summary` |
| `person` | string | `jonas` or `farva` |
| `source` | string | `templates/weekly-summary.md` |
| `last_updated` | `YYYY-MM-DD` | Date of creation/last update |
| `iso_week` | `YYYY-Www` | ISO week identifier |

### 3.4 Slash command files (`.claude/commands/*.md`)

| Field | Type | Description |
|-------|------|-------------|
| `description` | string | One short sentence shown by `/help` |
| `argument-hint` | (empty) | Always left empty — no positional args |

See [`.claude/commands/README.md`](.claude/commands/README.md) for the full command-authoring convention, including the write-vs-propose-vs-chat matrix and the conversational-args principle.

---

## 4. Person-name resolution

| Context | Jonas | Farva |
|---------|-------|-------|
| Directory token | `jonas` | `farva` |
| Display name in prose, headings, frontmatter | `Jonas` | `Farva` |

**Historical note:** "Partner" was the placeholder used during Phases 1–2. It was resolved to "Farva" in Phase 2 D-01. The `REQUIREMENTS.md` DOC-02 wording retains "Partner — overridable" as a historically accurate description of that resolution; it does not need to be changed (per D-10). All active files use `farva`/`Farva`.

---

## 5. Rename procedure

Concrete 4-step procedure for renaming `farva` to a new name later:

1. Update `display_name` in `trackers/farva/progress.md` frontmatter to the new display name.
2. Rename the directory: `git mv trackers/farva/ trackers/{new}/`
3. Grep-replace the old display name (`Farva`) with the new display name in `library/`, `calendar/`, and prose docs (`README.md`, `docs/conventions.md`, `CONTRIBUTING.md`, `CHANGELOG.md`):
   ```bash
   grep -rl "Farva" library/ calendar/ README.md docs/ CONTRIBUTING.md CHANGELOG.md | xargs sed -i '' 's/Farva/NewName/g'
   ```
4. Do NOT edit `.planning/phases/` — those are frozen historical artifacts. No code changes are needed (markdown-only system). The next slash-command invocation picks up the new directory name automatically via the `{person}` path token.

---

## 6. Library-anchor format

References to meals and recipes use the format:

```
library:meals#{anchor}
library:recipes#{anchor}
```

**Anchor derivation:** take the H2 or H3 heading in `library/meals.md`, convert to kebab-case: lowercase, spaces → hyphens, special characters removed. Example: `## Chicken & Rice Bowl` → anchor `chicken-rice-bowl`.

**Resolution procedure** (for slash commands):

1. Read `library/meals.md`.
2. Find the H2 or H3 heading whose kebab-case form equals the anchor.
3. Take that section's body as the meal definition.
4. Ambiguous anchors (duplicate headings): first occurrence wins; flag the ambiguity in chat.
5. Unresolvable anchor: prefix the meal line with `(off-library)` and continue.

Source: Phase 3 D-04 (`.claude/commands/README.md` Section 4).

---

## 7. `weekly_kcal_adjustments` schema

This additive frontmatter list lives in `trackers/{person}/progress.md`. It is written by `/weekly-review` when an adjustment is applied.

```yaml
weekly_kcal_adjustments:
  - week: YYYY-Www            # ISO week this adjustment applies to
    delta_kcal_per_day: +200  # additive on top of base_kcal from CAL-02 formula; use negative for reduction
    reason: ">0.8 kg/wk loss — adding carbs on training days"
    applied: YYYY-MM-DD       # date the review was run
```

**Semantics:**

- The most recent entry's `delta_kcal_per_day` is additive on top of `base_kcal` from the CAL-02 formula.
- Multiple entries are preserved in order — the history is self-documenting.
- This does NOT overwrite `target_weight_kg` or `target_date` (those are milestone goals, not weekly levers).
- If the list is absent or empty, treat the delta as 0.

Source: Phase 3 D-22, resolved in `03-MANIFEST.md`.
