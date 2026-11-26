# Contributing to ILM

## Branches

- `main` is always releasable. No direct pushes.
- One branch per sprint phase or feature: `phase/f1-foundation`, `feature/<short-name>`, `fix/<short-name>`.

## Commits

[Conventional Commits](https://www.conventionalcommits.org/): `feat(mobile): …`, `fix(web): …`, `test: …`, `docs: …`, `ci: …`, `chore: …`.

## Pull requests

- Use the PR template; link the phase and its gate.
- CI must be green (tokens, format, analyze, tests, secret scan).
- One review from a team member in a different role.

## Design tokens

Edit `design/tokens.json` only, then run `python tools/gen_tokens.py`. Never edit `*.g.dart` or `tokens.css` by hand; CI fails if they drift.

## Language rules

Never label a child "dyslexic" or "weak". "Diagnosis" appears only in the screening disclaimer. No scores are shown to children. Tests enforce this.

## Data

Only invented sample data in the repo. Real child data never goes into Git.

## Running the mobile app

```bash
cd mobile
flutter pub get
flutter test
flutter run
```
