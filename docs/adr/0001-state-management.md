# ADR 0001 — State management with Flutter's built-in ChangeNotifier

**Status:** Accepted (F2) · **Date:** 2026-11-27

## Context
The sprint plan asked the team to choose a state-management approach in F1 (Riverpod or Bloc were named as options). The app has two pieces of shared state: the teacher session (signed out → PIN → unlocked) and the class register.

## Decision
Use the Flutter SDK's own `ChangeNotifier` + `InheritedNotifier` (`SessionScope`) + `ListenableBuilder`. No third-party state package.

## Consequences
- No extra dependency to keep updated or audit (smaller attack surface, ISO/IEC 27001 secure-development control).
- Controllers are plain Dart classes, unit-tested without widgets (`session_test.dart`, `register_controller_test.dart`).
- If state grows (sync queue, results, referrals in F3–F4) and becomes hard to follow, revisit with Riverpod; the controllers can be wrapped without rewriting screens.
