# F1 Gate Report — Setup, tokens, component library

**Phase:** F1 (Days 1–2) · **Branch:** `phase/f1-foundation` · **Result:** ✅ Automated gate passed; manual device checks pending

## Exit criteria

| Criterion | Evidence | Status |
| --- | --- | --- |
| Component library merged | All Direction B components in `mobile/lib/shared/widgets/`, shown on the component gallery screen | ✅ |
| CI green | Tokens in sync, `dart format`, `flutter analyze --fatal-infos` (0 issues), 51 tests, gitleaks | ✅ |
| Contrast fixes for marigold agreed | `marigoldText` #8A5A00 (5.4:1 on cream) for small "Watch" text; aubergine on marigold buttons (7.0:1); F1-TC-02..04 | ✅ |
| Current platform baseline | Migrated to the standalone `material_ui` / `cupertino_ui` packages with the official `dart fix` (Flutter 3.47+) | ✅ |

## Test results (CI, Flutter 3.50.1 stable)

| Level | Tests | Result |
| --- | --- | --- |
| Unit (contrast, strings, models, mock data) | 27 | ✅ all pass |
| Widget + accessibility guidelines (tap target, labels, text contrast) | 21 | ✅ all pass |
| App shell (LTR/RTL, language switch) | 3 | ✅ all pass |
| **Total** | **51** | **✅ 51/51** |

Line coverage: **96.0%** (559/582 lines).

## ISO/IEC 25010:2023 evidence at this gate

| Characteristic | Evidence |
| --- | --- |
| Interaction capability | WCAG 2.2 AA contrast for every token text pair; 48 dp targets; screen-reader labels on interactive components; Urdu RTL |
| Safety | Language-rule test blocks "dyslexic"/"weak" labels; children see no numbers (bead progress, gauges) |
| Maintainability | Single token source with generated Dart/CSS and drift check; lint + format enforced |
| Flexibility | UI depends on a repository interface; mock data follows `docs/api-contract.yaml` |
| Security | gitleaks secret scan; only invented sample data in the repo |

## Not yet done (carried to the F2 gate)

- Manual TalkBack pass and font scale 200% on a low-end Android device (needs a physical device; Android platform folder is added in F2).
- Golden (visual regression) tests: added once the screens stabilise in F2–F4.

## Incidents

None open.
