# Nutrition System

```
        ┌──────── plan (weekly) ──── /weekly-plan ──┐
        │                                            │
   adjust ◀── review ◀── log ◀── eat ◀── cook ──────┤
     │     /weekly-review  /log-day                  │
     │                                               │
     └──────────── prep (today) ── /prep-today ──────┘
```

## What this is

A markdown-only system that turns a shared meal library into a daily/weekly operating loop — for Jonas and Farva. Numbers (kcal, macros) come from MyFitnessPal or Cronometer, which you already trust. This system is the **plan, prep, prompt, and progress layer**: it tells Jonas exactly what to cook each morning, captures what was actually eaten each evening, reviews the week on Monday, and adjusts targets for next week — cook → eat → log → adjust without each step requiring fresh thought.

---

## Quickstart: your first week

| When | Command | What it does |
|------|---------|-------------|
| Sun evening | `/weekly-plan` | Plan next 7 days conversationally; writes `trackers/weekly-plans/YYYY-Www.md` |
| Sun evening | `/shopping-list` | Derive shopping list from the new plan |
| Mon morning | `/prep-today` | Today's cooking/portioning brief (chat-only) |
| Mon evening | `/log-day` | Log today's meals + weights + training |
| Mid-week | `/swap-meal` | Mid-day alternative if a meal won't fit (chat-only) |
| Following Mon | `/weekly-review` | 7-day review + optional kcal adjustment for next week |

---

## Six commands at a glance

| Command | Does what | Writes to |
|---------|-----------|-----------|
| `/weekly-plan` | Proposes next week's meal plan from library + cycling calendar | `trackers/weekly-plans/YYYY-Www.md` (on confirm) |
| `/shopping-list` | Derives shopping list from active weekly plan | `trackers/weekly-plans/YYYY-Www-shopping.md` (on confirm) |
| `/prep-today` | Today's cooking/portioning brief for Jonas and Farva | Chat-only, no file write |
| `/log-day` | Captures meals, weight, training, energy notes | `trackers/{person}/daily/YYYY-MM-DD.md` (smart-merge) |
| `/weekly-review` | 7-day weight avg, adherence, kcal/macro adjustment proposal | `trackers/{person}/weekly/YYYY-Www.md` |
| `/swap-meal` | Fit-remaining-macros alternative from library | Chat-only, no file write |

Full convention reference: [`.claude/commands/README.md`](.claude/commands/README.md)

---

## Logging from your phone

The system runs on your laptop. When you only have your phone, use Claude mobile chat as a capture buffer — reconcile on the laptop later.

**How it works:**

1. Open Claude on your phone.
2. Type `/log-day` (or just say "log today's meals").
3. Paste your MFP/Cronometer totals, or describe meals in free text:

   ```
   Breakfast: oats + protein powder ~450 kcal / 42g protein
   Lunch: rice + chicken breast 600 kcal / 55g protein
   Snack: apple + peanut butter 280 kcal
   Dinner: pasta bolognese ~750 kcal / 38g protein
   Weight this morning: 86.2 kg. Rest day, no training.
   ```

4. Claude captures and summarises the entry in chat. The phone session ends here.
5. Next time you open Claude on your laptop, run `/log-day` again. It reads any existing file for today and smart-merges the phone entry — no manual copy-paste needed.

`/log-day` is the command that pairs with this phone-buffer pattern. If the daily file already exists, it merges; if not, it creates from template.

---

## Folder structure

```
library/          # Durable knowledge — meals, recipes, calorie targets, cycling/training rules
calendar/         # Cycling-2026 calendar, session_type per date
templates/        # File-shape templates for daily logs, weekly plans, etc.
trackers/
  jonas/          # Daily logs, weekly summaries, progress.md (Heathland milestones)
  farva/          # Daily logs, weekly summaries, progress.md
  weekly-plans/   # Plans + shopping lists per ISO week
.claude/commands/ # 6 slash command prompt templates
docs/             # conventions.md and other reference docs
.planning/        # GSD workflow artifacts (PROJECT, ROADMAP, phase context)
```

---

## Where to look next

- [`docs/conventions.md`](docs/conventions.md) — file-naming rules, date format, frontmatter conventions, person-name resolution
- [`CHANGELOG.md`](CHANGELOG.md) — what shipped at each milestone
- [`CONTRIBUTING.md`](CONTRIBUTING.md) — adding meals, recipes, or new slash commands
- [`.planning/PROJECT.md`](.planning/PROJECT.md) — Jonas/Farva goals, cycling calendar, full operating-loop context
