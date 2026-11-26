# F2 Gate Report — Teacher login, PIN and class register

**Phase:** F2 (Days 3–4) · **Branch:** `phase/f2-register` · **Result:** ✅ Automated gate passed; manual device checks pending

## Exit criteria

| Criterion | Evidence | Status |
| --- | --- | --- |
| Sign-in → PIN → register → start child works offline on mock data | Journey tests F2-TC-14..20 at the design size (390 × 844) | ✅ |
| Child mode cannot be escaped without the teacher PIN | F2-TC-17 (system back opens the PIN dialog; wrong PIN refused), F2-TC-18 | ✅ |
| PIN stored securely with lockout | Salted 10k-round SHA-256 in flutter_secure_storage; lock after 5 tries for 30 s (F2-TC-01..07); ADR 0002 | ✅ |
| No open P1/P2 bugs | Two layout overflows (tiles, header) found by tests and fixed in this phase | ✅ |
| Installable build for device testing | CI builds `ilm-debug-apk` on every push (Android 6.0+, backups off) | ✅ |
| Flow demoed on a low-end Android device | Needs a physical phone — use the CI APK | ⏳ |

## Test results (CI, Flutter 3.50.1 stable)

| Level | Tests | Result |
| --- | --- | --- |
| Unit (PIN, session, register, strings, contrast, models) | 59 | ✅ |
| Widget + accessibility guidelines | 21 | ✅ |
| Journeys (end-to-end teacher flows, 390 × 844) | 11 | ✅ |
| **Total** | **91** | **✅ 91/91** |

Line coverage: **96.0%** (1166/1215). `flutter analyze --fatal-infos`: 0 issues.

## Defects found and fixed during the gate

| ID | Found by | Description | Fix |
| --- | --- | --- | --- |
| F2-D1 | Gallery + journey tests | Child tiles overflowed when names or status wrapped (fixed-height grid) — would also happen in Urdu Nastaliq | Content-sized `TileRows` |
| F2-D2 | Journey tests | Register header overflowed with wide text | Saved-offline count wraps/ellipsises |
| F2-D3 | Journey tests | Asset-bundle cache hangs widget tests across test cases | Journeys use `InMemoryScreeningRepository` |

## Manual checks still to run (team, on a phone)

- TalkBack: register tiles read "name, status"; PIN keys read their digits; dots announce "n of 4 digits entered".
- Font scale 200%: register and PIN screens still usable.
- Android app pinning with child mode (recommended in the teacher manual).
