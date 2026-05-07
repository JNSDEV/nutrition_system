---
title: Macro Templates
category: library
source: 12_macro_templates.txt
last_updated: 2026-05-07
---

# Macro Templates

## Session-Type Mapping

Maps each calendar Session label to a `session_type` token, an archetype token, and the macro template to apply.

| Calendar Session label | session_type | archetype | Macro template |
|------------------------|--------------|-----------|----------------|
| `OFF` | `rest` | `lower_carb` | Rest Day Template |
| `Z1 commute (both legs)` | `easy_ride` | `lower_carb` | Rest Day Template |
| `Z2 Zwift indoor` | `medium_ride` | `moderate_carb` | 60 min Z2 Template |
| `Fasted Z2 (75 min) + Z1 commute home` | `medium_ride` | `moderate_carb` | 60 min Z2 Template |
| `Strength (full body)` | `strength` | `lower_carb` | Rest Day Template |
| `Intensity (VO2 / Threshold, alt.)` | `intensity` | `high_carb` | SST / Tempo Template |
| `Long Z2 outdoor (variable)` | `long_ride` | `high_carb` | Long Z2 Template |
| Any Sunday long ride (km distances, recovery or progression) | `long_ride` | `high_carb` | Long Z2 Template |
| Any row with `SPORTIVE` marker | `long_ride+SPORTIVE` | `high_carb` | Long Z2 Template |
| Any row with `BENCHMARK` marker | `long_ride+BENCHMARK` | `high_carb` | Long Z2 Template |
| Any row with `REHEARSAL` marker | `long_ride+REHEARSAL` | `high_carb` | Long Z2 Template |
| Any row with `HEATHLAND` marker | `long_ride+HEATHLAND` | `high_carb` | Long Z2 Template |

**Archetype tokens:**
- `lower_carb` — protein-forward, moderate kcal, lower carbohydrate
- `moderate_carb` — balanced, mid-range kcal
- `high_carb` — carb-heavy, elevated kcal, fueling for significant training load

**Resolution procedure for commands:**
1. Read today's row from `calendar/cycling-2026.md` (`Session` column).
2. Find the matching row in the table above.
3. Use the `archetype` token to select the macro template heading below.
4. For Jonas: apply that template's ranges; for Farva: always use Standard Cut Day or Lighter Day regardless of Jonas's session_type.

---

## Jonas

### Rest Day Template

**archetype:** lower_carb

- Calories: 2000-2200
- Protein: 150-180 g
- Carbs: 150-220 g
- Fat: 50-70 g

### 60 min Z2 Template

**archetype:** moderate_carb

- Calories: 2200-2400
- Protein: 150-180 g
- Carbs: 220-280 g
- Fat: 45-70 g

### SST / Tempo Template

**archetype:** high_carb

- Calories: 2300-2600
- Protein: 150-180 g
- Carbs: 250-320 g
- Fat: 45-70 g

### Long Z2 Template

**archetype:** high_carb

- Calories: 2400-2800
- Protein: 150-180 g
- Carbs: 280-380 g
- Fat: 45-75 g

---

## Farva

### Standard Cut Day

- Calories: 1400-1600
- Protein: 90-115 g
- Carbs: 120-180 g
- Fat: 35-55 g

### Lighter Day

- Calories: 1300-1450
- Protein: 90-110 g
- Carbs: 100-150 g
- Fat: 30-50 g
