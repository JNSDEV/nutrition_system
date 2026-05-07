---
phase: 04-onboarding-docs
plan: "05"
type: execute
wave: 1
depends_on: []
files_modified:
  - .planning/PROJECT.md
  - .planning/REQUIREMENTS.md
  - .planning/ROADMAP.md
autonomous: true
requirements:
  - DOC-01
  - DOC-02

must_haves:
  truths:
    - "grep for 'Partner' (case-sensitive) in .planning/PROJECT.md, .planning/REQUIREMENTS.md, .planning/ROADMAP.md returns zero hits — except in the DOC-02 requirement text which is intentionally preserved per D-10"
    - "'partner/' path token in PROJECT.md no longer appears"
    - "PROJECT.md hybrid-kcal model paragraph reflects the locked Phase 1 model: MFP/Cronometer owns actuals, library formulas produce estimates, system stores both"
    - "Frozen .planning/phases/0[123]-* files are untouched after the sweep"
    - ".planning/REQUIREMENTS.md line 67 (TRK-02) reads 'trackers/farva/' not 'trackers/partner/'"
    - "ROADMAP.md Phase 1, Phase 2, Phase 5 success criteria use 'Farva' not 'Partner'"
  artifacts:
    - path: ".planning/PROJECT.md"
      provides: "Updated project overview with correct Farva references and fixed hybrid-kcal wording"
      contains: "trackers/farva/"
    - path: ".planning/REQUIREMENTS.md"
      provides: "TRK-02 updated to trackers/farva/"
      contains: "trackers/farva/"
    - path: ".planning/ROADMAP.md"
      provides: "Phase 1/2 success criteria updated from Partner to Farva"
      contains: "Farva"
  key_links:
    - from: ".planning/PROJECT.md"
      to: "trackers/farva/"
      via: "directory path reference on lines 128/182 (now farva not partner)"
      pattern: "trackers/farva"
---

<objective>
Perform the D-09 terminology cleanup sweep across three planning files: replace residual "Partner" with "Farva" and fix the hybrid-kcal model wording in PROJECT.md. This is a separate commit from the new-doc plans so the history is clean.

Purpose: Satisfy D-09. Removes stale placeholder terminology that was carried forward from Phases 1–2 before the display name was resolved. Does NOT touch frozen phase artifacts (.planning/phases/0[123]-*).
Output: Updated .planning/PROJECT.md, .planning/REQUIREMENTS.md, .planning/ROADMAP.md.
</objective>

<execution_context>
@$HOME/.claude/get-shit-done/workflows/execute-plan.md
@$HOME/.claude/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/REQUIREMENTS.md
@.planning/ROADMAP.md
@.planning/phases/04-onboarding-docs/04-CONTEXT.md
</context>

<tasks>

<task type="auto">
  <name>Task 1: Verify scope — grep before editing</name>
  <files></files>
  <action>
Before making any edits, run these grep commands and record the results. This establishes the baseline and confirms what needs to change.

```bash
# Find all Partner occurrences in the three target files
grep -n "Partner" .planning/PROJECT.md
grep -n "Partner" .planning/REQUIREMENTS.md
grep -n "ROADMAP.md lines to update (Phase 1/2/5 SCs)"
grep -n "Partner" .planning/ROADMAP.md

# Find partner/ path token in PROJECT.md
grep -n "partner/" .planning/PROJECT.md

# Verify frozen directories are NOT swept
grep -rn "Partner" .planning/phases/01-foundation/ 2>/dev/null | wc -l
grep -rn "Partner" .planning/phases/02-trackers-baselines/ 2>/dev/null | wc -l
grep -rn "Partner" .planning/phases/03-slash-commands/ 2>/dev/null | wc -l

# Check library/, calendar/, templates/, trackers/ for any residual Partner hits
grep -rn "Partner" library/ calendar/ templates/ trackers/ 2>/dev/null
```

If `library/`, `calendar/`, `templates/`, or `trackers/` return any hits, flag them in the SUMMARY (do not auto-fix — those would be unexpected and need manual review). Phase 4 only commits to fixing the three .planning/ files listed above.

The frozen directories (.planning/phases/0[123]-*) will likely have hits — that is expected and correct. Do NOT edit those files.

IMPORTANT: DOC-02 in REQUIREMENTS.md contains "placeholder "Partner" — overridable" — this is intentionally preserved per D-10. Do NOT change this line.
  </action>
  <verify>
    <automated>grep -n "Partner" .planning/PROJECT.md .planning/REQUIREMENTS.md .planning/ROADMAP.md</automated>
  </verify>
  <done>Baseline Partner occurrences recorded. Knows exactly which lines need editing in each file. Frozen directories confirmed as out of scope.</done>
</task>

<task type="auto">
  <name>Task 2: Apply D-09 edits to PROJECT.md, REQUIREMENTS.md, ROADMAP.md</name>
  <files>.planning/PROJECT.md, .planning/REQUIREMENTS.md, .planning/ROADMAP.md</files>
  <action>
Apply the D-09 edits to the three target files. Read each file in full before editing.

**Edit 1: .planning/PROJECT.md**

Target occurrences (from Task 1 grep results):
- Line 128 area: `partner/` path token inside the source-material code block → change `partner/` to `farva/`
- Line 182 area: `Partner` in the Open Questions section ("Partner's preferred display name in files") — change to `Farva's preferred display name is Farva (resolved Phase 2 D-01)` or simply remove the open question since it is resolved.
- The `## Users` table on line ~27: "Partner" in the Person column and prose — change to "Farva". Also update "Partner's daily log" prose in the same section.
- The `## Goals & Constraints` section "Partner" sub-heading → "Farva". Body references to "Partner" → "Farva".
- The `## Core Value` line "Jonas and Partner" → "Jonas and Farva".
- Any other "Partner" occurrence in regular prose.

**Hybrid-kcal wording fix:**
Find the paragraph in PROJECT.md that describes the hybrid-kcal model (likely in `## What This Is` section, the sentence starting "Numbers (kcal/macros) come from an external app..."). Replace with the locked Phase 1 model wording:

> Numbers (kcal/macros) come from an external app (MyFitnessPal / Cronometer) that the user already trusts. The markdown system stores both actuals (from MFP/Cronometer) and estimates (from library formulas); it never recomputes the external app's number.

The current text says "the markdown system is the plan, prep, prompt, and progress layer — not the calorie database." Keep that sentence but ADD the clarifying sentence about actuals vs estimates before or after it, making the hybrid model explicit.

**PRESERVE: DO NOT CHANGE:**
- The resolved-name callout already in PROJECT.md: `> Resolved (Phase 2, D-01): Partner's display name is **Farva**.`
  Actually, this callout references "Partner's display name is Farva" which is fine as a historical note. Leave it, but check the sentence reads correctly in context. If it says "Partner's display name is Farva" — this is fine (it's explaining the resolution). Do not change it.
- The `## Key Decisions` table entry "Partner = consumer only" — this is a historical decision label; change "Partner" → "Farva" here too for consistency since it is in the live project overview (not a frozen artifact).

---

**Edit 2: .planning/REQUIREMENTS.md**

- TRK-02 line (~line 22): `trackers/partner/` → `trackers/farva/`. Also update the prose "User can find a `trackers/partner/` directory" → "User can find a `trackers/farva/` directory".
- Traceability table (~line 67): TRK-02 notes row — if it says "trackers/partner/" update to "trackers/farva/".
- **PRESERVE DOC-02 wording:** The line "how partner's display name is resolved (placeholder "Partner" — overridable)" is intentionally kept per D-10. Do NOT change it.
- Do NOT change CMD-01 and CMD-02 requirement texts that say "Jonas vs Partner" or "Jonas and Partner" — actually check: if these say "Partner" they should be updated to "Farva" since they are active requirements (not frozen). Update them.

---

**Edit 3: .planning/ROADMAP.md**

Target: Phase 1 and Phase 2 success criteria that reference "Partner".
- Phase 1 SC-2: "User can open `trackers/farva/progress.md`..." — check if this already says farva or still says partner.
- Phase 2 SC-2: likely says "trackers/partner/" → change to "trackers/farva/".
- Phase 3 success criteria: `.claude/commands/README.md` section 9 already notes these will be updated in Phase 4. Update "Partner" → "Farva" in Phase 3 SC-1 ("Jonas vs Partner") and SC-2 ("Jonas and Partner").
- Phase 5 (if it exists): scan for "Partner" and update.
- The Overview paragraph and phase descriptions: scan and update any "Partner" occurrences.
- **PRESERVE:** Phase 1 checkboxes, plan lists, and plan file names — do not alter those. Only update prose success-criteria text.

After all edits, run the verification grep before committing.
  </action>
  <verify>
    <automated>
      # After edits: Partner hits in target files (DOC-02 line is expected exception)
      grep -n "Partner" .planning/PROJECT.md
      grep -n "Partner" .planning/ROADMAP.md
      # REQUIREMENTS.md: only DOC-02 line should remain
      grep -n "Partner" .planning/REQUIREMENTS.md

      # Farva is now present in all three
      grep -c "Farva\|farva" .planning/PROJECT.md
      grep -c "Farva\|farva" .planning/REQUIREMENTS.md
      grep -c "Farva\|farva" .planning/ROADMAP.md

      # Hybrid-kcal wording update present
      grep -c "actuals.*MFP\|MFP.*actuals\|estimates.*library\|library.*estimates\|stores both" .planning/PROJECT.md

      # Frozen phase directories untouched (counts should be unchanged from Task 1 baseline)
      grep -rn "Partner" .planning/phases/01-foundation/ 2>/dev/null | wc -l
      grep -rn "Partner" .planning/phases/02-trackers-baselines/ 2>/dev/null | wc -l
      grep -rn "Partner" .planning/phases/03-slash-commands/ 2>/dev/null | wc -l

      # partner/ path token gone from PROJECT.md
      grep -c "partner/" .planning/PROJECT.md  # must be 0
    </automated>
  </verify>
  <done>
    .planning/PROJECT.md: all "Partner" replaced with "Farva"/"farva" in regular prose; partner/ path token replaced with farva/; hybrid-kcal paragraph updated to reflect actuals-from-MFP + estimates-from-library model. .planning/REQUIREMENTS.md: TRK-02 updated to trackers/farva/; DOC-02 wording preserved. .planning/ROADMAP.md: Phase 1/2/3 success criteria updated from "Partner" to "Farva"; Overview paragraph updated. Frozen .planning/phases/0[123]-* files not modified. grep -c "partner/" .planning/PROJECT.md returns 0.
  </done>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| none | Pure markdown edits on local files; no code, no external calls |

## STRIDE Threat Register

| Threat ID | Category | Component | Disposition | Mitigation Plan |
|-----------|----------|-----------|-------------|-----------------|
| T-04-05 | Tampering | .planning/phases/0[123]-* | mitigate | Explicit frozen-directory check in Task 1; Task 2 action forbids edits to those paths |
</threat_model>

<verification>
Final verification after both tasks:

```bash
# TARGET FILES: residual Partner hits (DOC-02 line is the only allowed exception)
echo "=== PROJECT.md Partner hits (expect 0) ==="
grep -v "placeholder.*Partner\|Partner.*placeholder\|overridable" .planning/PROJECT.md | grep -c "Partner" || echo "0"

echo "=== REQUIREMENTS.md Partner hits (DOC-02 line expected, rest = 0) ==="
grep -n "Partner" .planning/REQUIREMENTS.md

echo "=== ROADMAP.md Partner hits (expect 0) ==="
grep -c "Partner" .planning/ROADMAP.md || echo "0"

# partner/ path token gone
echo "=== partner/ path token in PROJECT.md (expect 0) ==="
grep -c "partner/" .planning/PROJECT.md || echo "0"

# Frozen directories untouched
echo "=== Frozen phase file counts unchanged ==="
grep -rl "Partner" .planning/phases/01-foundation/ .planning/phases/02-trackers-baselines/ .planning/phases/03-slash-commands/ 2>/dev/null | wc -l
```
</verification>

<success_criteria>
- `.planning/PROJECT.md`: zero "Partner" occurrences in regular prose; `partner/` path token gone; hybrid-kcal paragraph explicitly states actuals come from MFP/Cronometer and estimates from library formulas
- `.planning/REQUIREMENTS.md`: TRK-02 reads `trackers/farva/`; DOC-02 wording preserved unchanged (per D-10)
- `.planning/ROADMAP.md`: Phase 1, 2, 3 success criteria use "Farva" not "Partner"
- `.planning/phases/01-*`, `02-*`, `03-*` files: NOT modified — git diff on those paths shows no changes
- `grep -c "partner/" .planning/PROJECT.md` returns 0
</success_criteria>

<output>
After completion, create `.planning/phases/04-onboarding-docs/04-05-SUMMARY.md`
</output>
