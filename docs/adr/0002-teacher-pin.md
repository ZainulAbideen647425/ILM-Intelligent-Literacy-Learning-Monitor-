# ADR 0002 — Teacher PIN and child-mode lock

**Status:** Accepted (F2) · **Date:** 2026-11-27

## Context
One classroom phone is shared between a teacher and many children. Children must not see results or other children's data, and must not be able to leave an exercise.

## Decision
- 4-digit teacher PIN, set on first sign-in. Stored only as a salted, 10,000-round SHA-256 hash in `flutter_secure_storage` (AES-GCM, key in Android Keystore).
- 5 wrong tries lock the PIN for 30 seconds.
- Child mode uses `PopScope(canPop: false)`: back button and gestures open the teacher PIN dialog instead of leaving.
- Android auto-backup is disabled so keys and child data never leave the device.
- Minimum Android version 6.0 (API 23), required by `flutter_secure_storage`.

## Consequences
- A 4-digit PIN is a convenience lock, not a password; the lockout is what makes guessing impractical. The teacher account itself is protected by the backend password + JWT.
- Screen pinning (Android "app pinning") is recommended in the teacher manual for stronger child-mode lock; the app cannot enable it by itself.
