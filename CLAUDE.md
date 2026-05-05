<!-- GSD:project-start source:PROJECT.md -->
## Project

**Nutrition System**

A `.planning/`-style markdown system where:

- **Shared library** holds the durable knowledge (meals, recipes, portions, cooking rules, preferences, training-nutrition guidance) — already drafted in `01_*.txt` … `15_*.txt` and to be migrated into structured `library/`.
- **Per-person trackers** capture daily logs, weekly summaries, and progress for Jonas and Partner separately.
- **Slash commands** drive the loop on demand: weekly planning, prep guidance, meal swaps, daily logging, weekly review.
- **Claude reads & writes the files** on the laptop. Phone usage is via Claude mobile chat as a buffer (notes / pasted entries → reconciled later on laptop) — proper sync-to-mobile is an open question, deliberately deferred.

Numbers (kcal/macros) come from an external app (MyFitnessPal / Cronometer) that the user already trusts. The markdown system is the **plan, prep, prompt, and progress layer** — not the calorie database.

**Core Value:** **Reduce decision fatigue and keep both Jonas and Partner consistently on plan, week after week, by guiding cook → eat → log → adjust without each step requiring fresh thought.**

If only one thing works: a daily prompt that tells Jonas exactly what to cook/thaw/portion today for both of them — and a weekly review that adjusts targets based on the past week's weight and training load.
<!-- GSD:project-end -->

<!-- GSD:stack-start source:STACK.md -->
## Technology Stack

Technology stack not yet documented. Will populate after codebase mapping or first phase.
<!-- GSD:stack-end -->

<!-- GSD:conventions-start source:CONVENTIONS.md -->
## Conventions

Conventions not yet established. Will populate as patterns emerge during development.
<!-- GSD:conventions-end -->

<!-- GSD:architecture-start source:ARCHITECTURE.md -->
## Architecture

Architecture not yet mapped. Follow existing patterns found in the codebase.
<!-- GSD:architecture-end -->

<!-- GSD:skills-start source:skills/ -->
## Project Skills

No project skills found. Add skills to any of: `.claude/skills/`, `.agents/skills/`, `.cursor/skills/`, `.github/skills/`, or `.codex/skills/` with a `SKILL.md` index file.
<!-- GSD:skills-end -->

<!-- GSD:workflow-start source:GSD defaults -->
## GSD Workflow Enforcement

Before using Edit, Write, or other file-changing tools, start work through a GSD command so planning artifacts and execution context stay in sync.

Use these entry points:
- `/gsd-quick` for small fixes, doc updates, and ad-hoc tasks
- `/gsd-debug` for investigation and bug fixing
- `/gsd-execute-phase` for planned phase work

Do not make direct repo edits outside a GSD workflow unless the user explicitly asks to bypass it.
<!-- GSD:workflow-end -->



<!-- GSD:profile-start -->
## Developer Profile

> Profile not yet configured. Run `/gsd-profile-user` to generate your developer profile.
> This section is managed by `generate-claude-profile` -- do not edit manually.
<!-- GSD:profile-end -->
