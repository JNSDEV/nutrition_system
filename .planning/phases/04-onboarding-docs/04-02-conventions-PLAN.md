---
phase: 04-onboarding-docs
plan: "02"
type: execute
wave: 1
depends_on: []
files_modified:
  - docs/conventions.md
autonomous: false
requirements:
  - DOC-02

must_haves:
  truths:
    - "A reader can find every file-path pattern in one place and know what writes/reads it"
    - "A reader knows the exact date format to use for daily and weekly files"
    - "A reader knows every frontmatter field used by durable knowledge files, progress files, daily-log files, and command files"
    - "A reader knows that Farva was formerly called Partner and how the name is resolved"
    - "A reader can follow the 4-step rename procedure to change a person's display name later"
    - "A reader knows the library:meals#{anchor} format and how to derive anchors from headings"
    - "A reader knows the weekly_kcal_adjustments schema shape and which command writes it"
    - "All seven D-07 sections present in locked order"
  artifacts:
    - path: "docs/conventions.md"
      provides: "Reference card for file paths, naming, frontmatter, date format, person resolution, rename procedure, library anchors, kcal-adjustment schema"
      contains: "file-path conventions, date format standard, frontmatter conventions, person-name resolution, rename procedure, library-anchor format, weekly_kcal_adjustments schema"
  key_links:
    - from: "docs/conventions.md"
      to: ".planning/phases/02-trackers-baselines/02-CONTEXT.md"
      via: "historical note on D-01/D-02/D-03 path conventions (attribution, not live link)"
      pattern: "farva.*daily.*YYYY-MM-DD"
    - from: "docs/conventions.md"
      to: ".claude/commands/README.md"
      via: "link in the command-file frontmatter subsection (D-07 section 3)"
      pattern: "commands/README"
---

<objective>
Create `docs/conventions.md` — the reference card for every convention a developer (future-Jonas) needs when adding files, creating logs, or modifying the system. This consolidates implicit knowledge from Phases 1–3 into a single readable document.

Purpose: Satisfy DOC-02 and ROADMAP Phase 4 success criterion 2. Support D-07 (locked outline) and D-08 (rename procedure).
Output: `docs/conventions.md` with 7 sections in D-07 locked order.
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/execute-plan.md
@$HOME/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/phases/04-onboarding-docs/04-CONTEXT.md
@.claude/commands/README.md

<!-- Key source material for section content (read before writing) -->
<!-- trackers/jonas/progress.md — for weekly_kcal_adjustments schema example -->
<!-- trackers/farva/progress.md — for frontmatter contract -->
<!-- templates/daily-log.md, templates/weekly-summary.md, templates/weekly-plan.md — for frontmatter fields -->
</context>

<tasks>

<task type="auto">
  <name>Task 1: Read source material for section content</name>
  <files>trackers/jonas/progress.md, trackers/farva/progress.md, templates/daily-log.md, templates/weekly-summary.md, templates/weekly-plan.md</files>
  <action>
Read the following files to extract the actual frontmatter fields and path shapes before writing conventions.md. Do not edit them — they are read-only inputs.

1. `trackers/jonas/progress.md` — extract all frontmatter field names and the weekly_kcal_adjustments schema if present
2. `trackers/farva/progress.md` — extract frontmatter field names
3. `templates/daily-log.md` — extract frontmatter field names
4. `templates/weekly-summary.md` — extract frontmatter field names
5. `templates/weekly-plan.md` — extract frontmatter field names

Note exact field names. These become the authoritative list for conventions.md section 3 (Frontmatter conventions).
  </action>
  <verify>
    <automated>
      test -f trackers/jonas/progress.md && echo "progress.md readable"
      test -f templates/daily-log.md && echo "daily-log.md readable"
    </automated>
  </verify>
  <done>Frontmatter field names extracted from all five source files and available for use in Task 2.</done>
</task>

<task type="auto">
  <name>Task 2: Create docs/conventions.md with all seven D-07 sections</name>
  <files>docs/conventions.md</files>
  <action>
Create the `docs/` directory if it does not exist, then create `docs/conventions.md`. Use the frontmatter gathered in Task 1 for section 3. Follow the D-07 locked section order exactly:

**File header:**
```markdown
# Conventions

Reference card for file paths, naming rules, frontmatter, date format, and person-name resolution.
```
No custom GSD frontmatter block needed (D-10 notes GitHub conventions for top-level files; same applies to docs/).

---

**Section 1 — File-path conventions**
Heading: `## 1. File-path conventions`

Every path pattern in a single table. Columns: Pattern | Written by | Read by.
Rows (one per pattern from Phase 2 D-02/D-03/D-05 and Phase 3 D-05):

| Pattern | Written by | Read by |
|---------|-----------|---------|
| `trackers/{person}/daily/YYYY-MM-DD.md` | `/log-day` | `/weekly-review`, `/prep-today` |
| `trackers/{person}/weekly/YYYY-Www.md` | `/weekly-review` | `/weekly-review` |
| `trackers/weekly-plans/YYYY-Www.md` | `/weekly-plan` | `/prep-today`, `/shopping-list`, `/swap-meal` |
| `trackers/weekly-plans/YYYY-Www-shopping.md` | `/shopping-list` | human |
| `trackers/{person}/progress.md` | `/weekly-review` (adjustments only) | all commands |
| `library/*.md` | human (Claude edits via CONTRIBUTING.md) | all commands |
| `calendar/*.md` | human | `/prep-today`, `/log-day`, `/weekly-plan`, `/weekly-review`, `/swap-meal` |
| `templates/*.md` | human | `/log-day` (daily-log), `/weekly-review`, `/weekly-plan` |
| `.claude/commands/*.md` | human (per CONTRIBUTING.md) | Claude Code (slash command invocation) |

`{person}` is always the lowercase directory token: `jonas` or `farva`.

---

**Section 2 — Date format standard**
Heading: `## 2. Date format standard`

- Dates: `YYYY-MM-DD` (ISO 8601). Example: `2026-05-07`.
- ISO weeks: `YYYY-Www` using Python `%G-W%V`. Example: `2026-W19`. Week starts Monday per ISO 8601.
- Both formats are used in file paths and in frontmatter fields.
- Never use locale-specific formats (DD/MM/YYYY, etc.).

---

**Section 3 — Frontmatter conventions**
Heading: `## 3. Frontmatter conventions`

Four subsections, one per file type. Use the actual field names extracted in Task 1:

**3.1 Durable knowledge files (`library/*.md`)**
Fields: `title`, `category`, `source`, `last_updated`. Brief description of each.

**3.2 Person progress files (`trackers/{person}/progress.md`)**
Fields from the actual progress.md files read in Task 1. Explicitly include `weekly_kcal_adjustments` (schema in section 7). Note that `last_updated` is overwritten on each `/weekly-review` run.

**3.3 Daily-log and weekly-summary files**
Fields from `templates/daily-log.md` and `templates/weekly-summary.md`. Note that these are instantiated from templates by `/log-day` and `/weekly-review` respectively.

**3.4 Slash command files (`.claude/commands/*.md`)**
Fields: `description` (one short sentence for /help), `argument-hint` (always left empty — see `.claude/commands/README.md`). Link: [`.claude/commands/README.md`](.claude/commands/README.md).

---

**Section 4 — Person-name resolution**
Heading: `## 4. Person-name resolution`

| Context | Jonas | Farva |
|---------|-------|-------|
| Directory token | `jonas` | `farva` |
| Display name in prose, headings, frontmatter | `Jonas` | `Farva` |

Historical note: "Partner" was the placeholder used during Phases 1–2. It was resolved to "Farva" in Phase 2 D-01. The REQUIREMENTS.md DOC-02 wording retains "Partner — overridable" as a historically accurate description of that resolution; it does not need to be changed (per D-10). All active files use `farva`/`Farva`.

---

**Section 5 — Rename procedure (D-08)**
Heading: `## 5. Rename procedure`

Concrete 4-step how-to for renaming `farva` → a new name later:

1. Update `display_name` in `trackers/farva/progress.md` frontmatter to the new display name.
2. Rename the directory: `git mv trackers/farva/ trackers/{new}/`
3. Grep-replace all occurrences of the old display name (e.g. `Farva`) → new display name in `library/`, `calendar/`, prose docs (README.md, docs/conventions.md, CONTRIBUTING.md, CHANGELOG.md). Command: `grep -rl "Farva" library/ calendar/ README.md docs/ CONTRIBUTING.md CHANGELOG.md | xargs sed -i '' 's/Farva/NewName/g'`
4. Do NOT edit `.planning/phases/` — those are frozen historical artifacts.

Note: No code changes needed (markdown-only system). The next slash-command run picks up the new directory name automatically via the `{person}` path token.

---

**Section 6 — Library-anchor format**
Heading: `## 6. Library-anchor format`

Format: `library:meals#{anchor}`

Anchor derivation: take any H2 or H3 heading in `library/meals.md`, convert to kebab-case (lowercase, spaces → hyphens, remove special characters). Example: `## Chicken & Rice Bowl` → anchor `chicken-rice-bowl`.

Resolution procedure (for slash commands):
1. Read `library/meals.md`
2. Find the H2/H3 heading whose kebab-case equals the anchor
3. Take that section's body as the meal definition
4. Ambiguous anchors (duplicate headings): first occurrence wins; flag in chat
5. Unresolvable anchor: prefix meal line with `(off-library)` and continue

Source: Phase 3 D-04.

---

**Section 7 — `weekly_kcal_adjustments` schema**
Heading: `## 7. weekly_kcal_adjustments schema`

This additive frontmatter list lives in `trackers/{person}/progress.md`. It is written by `/weekly-review` when an adjustment is applied.

```yaml
weekly_kcal_adjustments:
  - week: YYYY-Www            # ISO week this adjustment applies to
    delta_kcal_per_day: +200  # additive on top of base_kcal from CAL-02 formula; use negative for reduction
    reason: ">0.8 kg/wk loss — adding carbs on training days"
    applied: YYYY-MM-DD       # date the review was run
```

Semantics:
- The most recent entry's `delta_kcal_per_day` is additive on top of `base_kcal` from the CAL-02 formula
- Multiple entries are preserved in order — the history is self-documenting
- This does NOT overwrite `target_weight_kg` or `target_date` (those are milestone goals)
- If the list is absent or empty, treat the delta as 0

Source: Phase 3 D-22 (resolved in 03-MANIFEST.md).
  </action>
  <verify>
    <automated>
      # File exists
      test -f docs/conventions.md && echo "EXISTS"
      # All 7 section headings present
      grep -c "^## [1-7]\." docs/conventions.md
      # Key patterns documented
      grep -c "YYYY-MM-DD" docs/conventions.md
      grep -c "YYYY-Www" docs/conventions.md
      grep -c "weekly_kcal_adjustments" docs/conventions.md
      grep -c "library:meals#" docs/conventions.md
      grep -c "farva" docs/conventions.md
      grep -c "git mv" docs/conventions.md
      # No "Partner" used as current name (only in historical note)
      grep -v "placeholder\|historical\|Phase 2\|Partner.*overridable\|overridable.*Partner\|resolved.*Farva\|Farva.*resolved" docs/conventions.md | grep -c "Partner" || echo "CLEAN"
    </automated>
  </verify>
  <done>
    docs/conventions.md created. 7 sections present in D-07 locked order. File-path table has all 9 path patterns. Date format section names both YYYY-MM-DD and YYYY-Www with the Python format string. Frontmatter section covers all four file types. Person-name section has historical note about Partner placeholder. Rename procedure has 4 concrete steps including the grep-replace command. Library-anchor section names the format, derivation, and 5-step resolution. weekly_kcal_adjustments section has complete YAML schema with field annotations.
  </done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>docs/conventions.md with 7 sections per D-07 locked order</what-built>
  <how-to-verify>
    Open docs/conventions.md and verify:
    1. Section 1 (file paths): all path patterns listed with writer/reader columns — confirm trackers/{person}/daily/YYYY-MM-DD.md is present
    2. Section 2 (date format): YYYY-MM-DD and YYYY-Www both documented; Python %G-W%V mentioned
    3. Section 3 (frontmatter): four subsections covering library files, progress.md, daily-log/weekly-summary, and command files
    4. Section 4 (person-name): jonas/farva table present; historical "Partner" note accurate
    5. Section 5 (rename procedure): 4 concrete steps; step 3 includes the grep-replace command; step 4 says NOT to touch .planning/phases/
    6. Section 6 (library-anchor): format "library:meals#{anchor}" present; kebab-case derivation explained
    7. Section 7 (weekly_kcal_adjustments): YAML schema block present with all four fields annotated
  </how-to-verify>
  <resume-signal>Type "approved" or describe any issues to fix</resume-signal>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| none | Pure markdown creation; no code, no inputs, no external calls |

## STRIDE Threat Register

| Threat ID | Category | Component | Disposition | Mitigation Plan |
|-----------|----------|-----------|-------------|-----------------|
| T-04-02 | Information Disclosure | docs/conventions.md | accept | No sensitive data; local markdown only |
</threat_model>

<verification>
After Task 2 completes, run:

```bash
# File exists
test -f docs/conventions.md && echo "EXISTS"

# Exactly 7 numbered sections
grep -c "^## [1-7]\." docs/conventions.md

# Critical content present (each must be > 0)
grep -c "YYYY-MM-DD" docs/conventions.md
grep -c "YYYY-Www" docs/conventions.md
grep -c "weekly_kcal_adjustments" docs/conventions.md
grep -c "library:meals#" docs/conventions.md
grep -c "git mv" docs/conventions.md
```
</verification>

<success_criteria>
- `docs/conventions.md` exists
- 7 sections present in D-07 locked order
- Section 1: file-path table with all path patterns and writer/reader columns
- Section 2: YYYY-MM-DD and YYYY-Www documented with Python format string
- Section 3: four frontmatter subsections using actual field names from source files
- Section 4: jonas/farva table with historical Partner note (per D-10)
- Section 5: 4-step rename procedure with concrete grep-replace command (per D-08)
- Section 6: library:meals#{anchor} format and 5-step resolution procedure
- Section 7: weekly_kcal_adjustments YAML schema with all four fields
- ROADMAP Phase 4 SC-2 satisfied
</success_criteria>

<output>
After completion, create `.planning/phases/04-onboarding-docs/04-02-SUMMARY.md`
</output>
