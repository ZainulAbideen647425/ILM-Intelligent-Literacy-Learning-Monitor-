# Frontend Test Plan — 2-Week Sprint

Follows the structure of ISO/IEC/IEEE 29119-3 (test documentation), kept short for a three-person student team.

## 1. Scope

The ILM frontend: the Flutter teacher/child app (`mobile/`) and the admin web dashboard (`backend/dashboard/`), built against mock data that follows `docs/api-contract.yaml`. The backend, ML inference and real child data are out of scope for this sprint.

## 2. Quality model

Acceptance criteria are written against ISO/IEC 25010:2023 (product quality) and, for usability sessions, ISO 9241-11:2018 (effectiveness, efficiency, satisfaction). Accessibility targets WCAG 2.2 AA (ISO/IEC 40500:2025).

## 3. Test levels and tools

| Level | Tool | Runs |
| --- | --- | --- |
| Unit / widget | `flutter_test`, pytest | Every push (CI) |
| Accessibility (automated) | Flutter `meetsGuideline` (tap target, labels, text contrast); axe-core for web | Every push (CI) |
| Integration / E2E | Flutter `integration_test`; Playwright for web | From F2 / F5 |
| Static analysis | `flutter analyze`, `dart format`, gitleaks | Every push (CI) |
| Manual | TalkBack, font scale 200%, low-end device, usability sessions | At each gate |

## 4. Test design techniques (ISO/IEC/IEEE 29119-4)

Equivalence partitioning (signals, consent states, filters), boundary values (PIN length and attempts, bead index, progress 0 / total), state transitions (child-mode lock, offline → synced) and use-case tests for the journeys.

## 5. Gates

Each phase (F1–F6) ends with a gate. A gate passes when every exit criterion in the sprint plan is met, CI is green and no P1/P2 incident is open. Results go in `docs/testing/F<n>-gate-report.md`.

## 6. Incidents

GitHub issues labelled `bug` and `P1`–`P4`. P1 = blocks a journey or exposes child data; P2 = wrong result or accessibility blocker; P3 = visual or minor; P4 = cosmetic.

## 7. Test data

Only invented sample names in `mobile/assets/mock/`. Real child data is never committed (gitleaks + review).
