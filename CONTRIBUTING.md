# Contributing

Notes for future-Jonas on the three most likely maintenance tasks.

---

## Add a new meal or recipe

1. Open `library/meals.md` (for meals) or `library/recipes.md` (for recipes).
2. Add an H2 or H3 heading for the new item. The heading text becomes the anchor used in `library:meals#{anchor}` references: convert to kebab-case. Example: `## Baked Salmon with Sweet Potato` → anchor `baked-salmon-with-sweet-potato`.
3. Write the content under that heading (portions, macros-per-serving, preparation notes, etc.).
4. Before adding, grep for the heading text — duplicate H2/H3 headings create ambiguous anchors; first occurrence wins (Phase 3 D-04). Do not add a heading that already exists.
5. If any weekly plan in `trackers/weekly-plans/` already references this meal by anchor, the new heading makes those references resolvable from the next command run onward.
6. Update `last_updated` in the file's frontmatter to today.

No rebuild step, no index to regenerate. The next slash command run picks up the new entry automatically via anchor resolution.

---

## Add a new slash command

1. Create `.claude/commands/{name}.md`. See [`.claude/commands/README.md`](.claude/commands/README.md) for the exact file-shape convention (frontmatter, body structure, write-vs-chat behavior matrix).
2. Frontmatter: set `description` to one short sentence (shown by `/help`); leave `argument-hint` empty.
3. Add the new command to the Commands table in top-level `README.md` (one row: command name, what it does, write/chat behavior).
4. Add a row to the Command Index table in `.claude/commands/README.md`.
5. If the command introduces a new file-path pattern (a path it reads or writes that is not already in `docs/conventions.md` Section 1), add that pattern to the file-path conventions table there.

The command is available immediately after the file is created — no registration or reload needed.

---

## Update calorie-target rules

All kcal thresholds and formulas live in [`library/calorie-targets.md`](library/calorie-targets.md). That file is the single authoritative source.

Edit it when:
- Jonas's or Farva's base kcal targets change (new training block, new weight tier)
- Adjustment trigger thresholds change (e.g. the loss-rate bands that prompt adding or reducing calories)

The thresholds in `library/calorie-targets.md` override the D-21 adjustment defaults documented in `.claude/commands/README.md`. Changing thresholds here takes effect on the next slash command run without touching any other file.

Do NOT edit the defaults in `.claude/commands/README.md` directly — that file documents conventions; `calorie-targets.md` is the runtime source.
