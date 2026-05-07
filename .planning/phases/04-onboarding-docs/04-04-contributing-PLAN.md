---
phase: 04-onboarding-docs
plan: "04"
type: execute
wave: 1
depends_on: []
files_modified:
  - CONTRIBUTING.md
autonomous: true
requirements:
  - DOC-01

must_haves:
  truths:
    - "A reader knows exactly how to add a new meal or recipe to the library while keeping anchor links working"
    - "A reader knows what files to create/edit when adding a new slash command and what must be updated downstream"
    - "A reader knows where calorie-target thresholds live and which file is authoritative"
    - "The document is approximately one page — no more than strictly needed"
  artifacts:
    - path: "CONTRIBUTING.md"
      provides: "How-to guide for future-Jonas adding library content or new commands"
      contains: "add-a-meal section, add-a-slash-command section, update-calorie-target-rules section"
  key_links:
    - from: "CONTRIBUTING.md"
      to: ".claude/commands/README.md"
      via: "link in add-a-slash-command section (per D-12)"
      pattern: "commands/README"
    - from: "CONTRIBUTING.md"
      to: "library/calorie-targets.md"
      via: "link in update-calorie-target-rules section (per D-12)"
      pattern: "calorie-targets"
---

<objective>
Create top-level `CONTRIBUTING.md` — a short (~1 page) how-to for future-Jonas covering the three most likely maintenance tasks: adding library content, adding slash commands, and updating calorie-target rules.

Purpose: Satisfy D-12. Prevents future-Jonas from accidentally breaking anchor links or leaving README stale after adding new commands.
Output: `CONTRIBUTING.md` at the project root.
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/execute-plan.md
@$HOME/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/phases/04-onboarding-docs/04-CONTEXT.md
@.claude/commands/README.md
</context>

<tasks>

<task type="auto">
  <name>Task 1: Write CONTRIBUTING.md with three sections per D-12</name>
  <files>CONTRIBUTING.md</files>
  <action>
Create `CONTRIBUTING.md` at the project root. Three sections, ~1 page total. Follow D-12 content requirements exactly.

**Section 1 — Add a new meal or recipe to the library**

Heading: `## Add a new meal or recipe`

Steps:
1. Open `library/meals.md` (for meals) or `library/recipes.md` (for recipes).
2. Add an H2 or H3 heading for the new item. The heading text becomes the anchor: convert to kebab-case for `library:meals#{anchor}` references. Example: `## Baked Salmon with Sweet Potato` → anchor `baked-salmon-with-sweet-potato`.
3. Write the content under that heading (portions, macros-per-serving, preparation notes, etc.).
4. If any weekly plan already references this meal by anchor (e.g. in `trackers/weekly-plans/`), the new heading makes those references resolvable from the next command run onward.
5. Do NOT duplicate heading text — duplicate H2/H3 headings create ambiguous anchors (first occurrence wins per Phase 3 D-04). Check for existing headings before adding.
6. Update `last_updated` in the file's frontmatter to today.

Note: no rebuild step, no index to update, no code to change. The next slash command run picks up the new entry automatically via anchor resolution.

---

**Section 2 — Add a new slash command**

Heading: `## Add a new slash command`

Steps:
1. Create `.claude/commands/{name}.md` following the file-shape convention in [`.claude/commands/README.md`](.claude/commands/README.md). The body is the prompt the model receives at invocation time.
2. Frontmatter: `description` (one short sentence for /help), `argument-hint` (leave empty).
3. Add the new command to the command table in top-level `README.md` (Commands section, per D-03 section 4).
4. If the command introduces a new file-path pattern, document it in `docs/conventions.md` section 1 (file-path conventions table).
5. Add an entry to `.claude/commands/README.md` Command Index table.

The command is immediately available after the file is created — no registration or reload needed.

---

**Section 3 — Update calorie-target rules**

Heading: `## Update calorie-target rules`

Calorie-target thresholds and formulas live in [`library/calorie-targets.md`](library/calorie-targets.md). This file is the single authoritative source.

When to edit it:
- Jonas's or Farva's base kcal targets change (e.g. new training block, new weight tier)
- Adjustment rules change (e.g. different trigger thresholds for adding/reducing calories)

Note: `library/calorie-targets.md` thresholds override the Phase 3 D-21 adjustment defaults documented in `.claude/commands/README.md`. If you change thresholds here, the slash commands pick them up on the next run without any other file changes.

Do NOT edit the defaults in `.claude/commands/README.md` directly — that file documents the conventions, and calorie-targets.md is the runtime source.
  </action>
  <verify>
    <automated>
      test -f CONTRIBUTING.md && echo "EXISTS"
      grep -c "## Add a new meal" CONTRIBUTING.md
      grep -c "## Add a new slash command" CONTRIBUTING.md
      grep -c "## Update calorie" CONTRIBUTING.md
      grep -c "commands/README" CONTRIBUTING.md
      grep -c "calorie-targets" CONTRIBUTING.md
      grep -c "anchor\|kebab" CONTRIBUTING.md
      grep -c "Partner" CONTRIBUTING.md  # must be 0
    </automated>
  </verify>
  <done>
    CONTRIBUTING.md exists at project root. Three sections present: "Add a new meal or recipe", "Add a new slash command", "Update calorie-target rules". Section 1 explains anchor derivation from heading text, warns against duplicate headings. Section 2 links to .claude/commands/README.md, tells reader to update README.md command table and docs/conventions.md if new path pattern introduced. Section 3 links to library/calorie-targets.md as authoritative source, explains precedence over D-21 defaults. "Partner" does not appear.
  </done>
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
| T-04-04 | Information Disclosure | CONTRIBUTING.md | accept | No sensitive data; local contributing guide |
</threat_model>

<verification>
After task completes:

```bash
test -f CONTRIBUTING.md && echo "EXISTS"
grep -c "## Add a new meal" CONTRIBUTING.md       # 1
grep -c "## Add a new slash command" CONTRIBUTING.md  # 1
grep -c "## Update calorie" CONTRIBUTING.md       # 1
grep -c "commands/README" CONTRIBUTING.md         # >0 (link to conventions)
grep -c "calorie-targets" CONTRIBUTING.md         # >0 (link to authoritative source)
grep -c "Partner" CONTRIBUTING.md                 # 0
```
</verification>

<success_criteria>
- `CONTRIBUTING.md` exists at project root, approximately one page
- Three sections in D-12 order: add-a-meal, add-a-slash-command, update-calorie-target-rules
- Section 1: anchor derivation from heading text explained; duplicate-heading warning present
- Section 2: links to `.claude/commands/README.md`; README.md command table update mentioned; conventions.md update mentioned if new path pattern
- Section 3: links to `library/calorie-targets.md` as authoritative; explains precedence over D-21 defaults
- "Partner" does not appear in the file
</success_criteria>

<output>
After completion, create `.planning/phases/04-onboarding-docs/04-04-SUMMARY.md`
</output>
