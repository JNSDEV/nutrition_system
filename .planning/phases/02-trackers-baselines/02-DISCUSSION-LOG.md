# Phase 2: Trackers & Baselines — Discussion Log

**Date:** 2026-05-05
**Mode:** discuss (default)

## Areas selected
1. progress.md shape
2. daily-log fields
3. weekly-summary + kcal-target contract
4. Partner display name + Phase 2 file conventions

## Q&A trail

### Conventions
- **Q:** Partner display name — keep "Partner" or use real first name? → **A:** Use real first name → **A2:** "Farva" → D-01
- **Q:** Daily log path — per-person or shared? → **A:** `trackers/{person}/daily/YYYY-MM-DD.md` → D-02
- **Q:** Weekly path — ISO week or date range? → **A:** `trackers/{person}/weekly/YYYY-Www.md` → D-03

### progress.md shape
- **Q:** Static baseline vs running history? → **A:** Static + targets only; history lives in weekly summaries → D-04
- **Q:** Jonas — dedicated Event section or just frontmatter field? → **A:** Dedicated `## Event` with build/peak/taper markers → D-05
- **Q:** Farva — mirror Jonas exactly or slimmer? → **A:** Slimmer, no event/training fields → D-06

### Daily-log
- **Q:** One shared template or per-person? → **A:** One shared (`templates/daily-log.md`) → D-09
- **Q:** Meal logging — library refs, free text, or strict library-only? → **A:** Library reference + free-text deviations → D-12
- **Q:** Where do kcal totals come from? → **A:** Computed by Claude (initial pick)
- **Follow-up clarification (Claude flagged conflict with PROJECT.md):** Reconcile with PROJECT.md "external app is calorie database" wording. → **A:** Hybrid — Claude estimates, MFP paste overrides → D-13 + deferred PROJECT.md update

### Weekly-summary + CAL-02
- **Q:** 7-day weight average source? → **A:** Computed from daily-log weight fields → D-15 (Weight section)
- **Q:** Adherence definition? → **A:** % of days within ±10% of kcal target → D-15 (Adherence section)
- **Q:** CAL-02 formula — where does it live? → **A:** `library/calorie-targets.md` is authoritative → D-16
- **Q:** Training-burn — additive or fused? → **A:** Additive (`base_kcal + training_est_kcal`); both exposed separately → D-18

## Deferred ideas surfaced
- PROJECT.md hybrid-kcal wording update (Phase 4)
- Pure-MFP fallback path
- Separate weight log file (rejected for v1)
- Plan-adherence metric (rejected for v1)
- Per-person daily-log templates (rejected for v1)

## Notes
- No scope creep attempts during the discussion; all questions stayed inside Phase 2's roadmap boundary.
- The hybrid kcal-source decision (D-13) creates a minor PROJECT.md inconsistency, captured as deferred work for Phase 4.
