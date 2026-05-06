---
title: Phase 3 — Slash Commands Discussion Log
category: planning
phase: 03
last_updated: 2026-05-06
---

# Phase 3: Slash Commands — Discussion Log

**Audience:** human reference (audits, retrospectives). Not consumed by downstream agents — they read CONTEXT.md.

**Date:** 2026-05-06
**Phase:** 03 — Slash Commands

## Areas Selected for Discussion

User selected (multiSelect):
1. Command args & MFP-paste flow
2. Write-vs-propose behavior
3. /weekly-plan generation strategy
4. /weekly-review adjustment voice

(Plus a final consolidating ask on `/shopping-list` output and `/swap-meal` scope.)

---

## Area 1 — Command args & MFP-paste flow

### Q1: Argument style
- **Options:** Conversational no-args | Optional structured args | Free-text after command
- **Selected:** Conversational, no positional args
- **Captured as:** D-02

### Q2: MFP/Cronometer paste flow for /log-day
- **Options:** Two-step (chat turn after) | Inline paste in same prompt | Defer to manual edit
- **Selected:** Two-step: first chat turn after /log-day
- **Captured as:** D-11

### Q3: Re-run behavior on same day
- **Options:** Smart merge | Append-only | Prompt to overwrite vs merge
- **Selected:** Smart merge (Recommended)
- **Captured as:** D-12, plus the smart-merge cheatsheet table in `<specifics>`

---

## Area 2 — Write-vs-propose behavior

### Q1: Write-or-propose behavior across commands
- **Options:** Mixed by command type | Always write directly | Always propose first
- **Selected:** Mixed by command type (Recommended)
- **Captured as:** D-03 (with the per-command split: write directly = log-day + weekly-review; propose-then-confirm = weekly-plan + shopping-list; chat-only = prep-today + swap-meal)

---

## Area 3 — /weekly-plan generation strategy

### Q1: Generation strategy
- **Options:** Cycling-aware rotation with conversational tweaks | Pure rotation | Conversational from scratch
- **Selected:** Conversational from scratch
- **Captured as:** D-14, D-15

### Q2: How many chat turns of questions before proposing
- **Options:** 3–4 questions batched | One open prompt | Step-by-step
- **Selected:** 3–4 questions, batched (Recommended)
- **Captured as:** D-14 (with the four locked topics: fridge/leftovers, training peak, repeat-cravings, dislikes-this-week)

### Q3: Where does /weekly-plan output land
- **Options:** trackers/weekly-plans/YYYY-Www.md | Per-person weekly-plans | Single rolling file
- **Selected:** trackers/weekly-plans/YYYY-Www.md (Recommended)
- **Captured as:** D-16, plus the new path convention in `<code_context>` integration points

---

## Area 4 — /weekly-review adjustment voice

### Q1: What does /weekly-review do with the proposed adjustment
- **Options:** Propose only — manual accept | Propose + ask in chat to apply | Auto-apply if rule fires
- **Selected:** Propose + ask in chat to apply
- **Captured as:** D-22

### Q2: /weekly-review scope (who does it cover by default)
- **Options:** Both people, two summary files | Jonas-only by default, Farva on ask | Always interactive
- **Selected:** Both people, two summary files (Recommended)
- **Captured as:** D-20, D-21 (per-person computation), D-22 (batched apply ask)

---

## Final consolidating ask

### Q: /shopping-list output destination + /swap-meal scope
- **Options:** Recommended defaults | Shopping in chat only | Both write files no chat preview
- **Selected:** Recommended defaults
- **Captured as:** D-18, D-19 (shopping-list propose-then-write to `trackers/weekly-plans/YYYY-Www-shopping.md`); D-23, D-24 (swap-meal chat-only, no file mutation)

---

## Deferred Ideas Raised

Captured in CONTEXT.md `<deferred>` section:
- Linking commands together
- Mobile MFP API integration (v2)
- Multi-week planning
- Per-meal kcal/macro pre-computation in library
- Auto-apply weekly-review adjustment
- /swap-meal writing to daily log directly
- Missed-day backfill via positional args
- Phase 4 docs sweep for stale `partner/` wording on PROJECT.md/REQUIREMENTS.md (carry-forward from Phase 2)

## Claude's Discretion Items

Captured in CONTEXT.md `<decisions>` § Claude's Discretion:
- Exact wording of each command's prompt body
- Phrasing of the /weekly-plan 4-question opener
- MFP-paste parsing heuristics
- Iteration UX for propose-then-write commands
- Per-week kcal-target field shape in progress.md (planner decides)
- Chat-output formatting conventions

---

*Discussion completed 2026-05-06. CONTEXT.md is the canonical record.*
