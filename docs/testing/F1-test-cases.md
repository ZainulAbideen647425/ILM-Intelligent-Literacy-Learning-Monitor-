# F1 — Test Case Specification (Setup, tokens, components)

| ID | Requirement / characteristic (ISO/IEC 25010) | Technique | Automated in |
| --- | --- | --- | --- |
| F1-TC-01 | Contrast formula correct | Known values | `test/core/contrast_test.dart` |
| F1-TC-02 | All text colours ≥ 4.5:1 on cream/white (interaction capability, WCAG 1.4.3) | Pairwise combinations | `test/core/contrast_test.dart` |
| F1-TC-03 | Text on marigold buttons and dark fills ≥ 4.5:1 | Pairwise combinations | `test/core/contrast_test.dart` |
| F1-TC-04 | Raw marigold never used as small text (documents the design fix) | Negative test | `test/core/contrast_test.dart` |
| F1-TC-05 | Urdu and English have the same keys | Set comparison | `test/core/app_strings_test.dart` |
| F1-TC-06 | No empty strings | Exhaustive | `test/core/app_strings_test.dart` |
| F1-TC-07 | Placeholders match across languages | Exhaustive | `test/core/app_strings_test.dart` |
| F1-TC-08 | No "dyslexic"/"weak" labels; "diagnosis" only in the disclaimer (safety) | Keyword scan | `test/core/app_strings_test.dart` |
| F1-TC-09 | Mock class loads and matches the API contract (flexibility) | Use case | `test/data/mock_repository_test.dart` |
| F1-TC-10 | Unknown class id rejected | Invalid partition | `test/data/mock_repository_test.dart` |
| F1-TC-11 | Unknown signal value rejected | Invalid partition | `test/data/mock_repository_test.dart` |
| F1-TC-12 | Each signal shows shape + word (no colour-only meaning) | Equivalence partitioning (4 signals) | `test/widgets/components_test.dart` |
| F1-TC-13 | Signal labels translate to Urdu | Use case | `test/widgets/components_test.dart` |
| F1-TC-14 | Child tile: initials, name, signal, tap, screen-reader label | Use case | `test/widgets/components_test.dart` |
| F1-TC-15 | Next-up child shows "Next up" | Equivalence partitioning | `test/widgets/components_test.dart` |
| F1-TC-16 | Child without consent cannot be started (safety) | Equivalence partitioning | `test/widgets/components_test.dart` |
| F1-TC-17 | Child tile meets tap-target, label and contrast guidelines | Accessibility guideline | `test/widgets/components_test.dart` |
| F1-TC-18 | Filters report selection; pills ≥ 48 dp | Use case + guideline | `test/widgets/components_test.dart` |
| F1-TC-19 | Buttons tappable, ≥ 48 dp, contrast OK; disabled does nothing | Equivalence partitioning | `test/widgets/components_test.dart` |
| F1-TC-20 | Progress ring announces progress in words | Use case | `test/widgets/components_test.dart` |
| F1-TC-21 | Bead progress shows no numbers to the child; out-of-range step rejected | Boundary value | `test/widgets/components_test.dart` |
| F1-TC-22 | Gauges show words, never numbers | Use case | `test/widgets/components_test.dart` |
| F1-TC-23 | App starts in English, left-to-right | Use case | `test/widget_test.dart` |
| F1-TC-24 | Urdu switches to right-to-left with Gulzar | State transition | `test/widget_test.dart` |

Manual checks at the gate: TalkBack reading order on the gallery, font scale 200%, Nastaliq rendering on a low-end Android phone.
