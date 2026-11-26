# F2 — Test Case Specification (Login, PIN, class register)

| ID | Requirement / characteristic (ISO/IEC 25010) | Technique | Automated in |
| --- | --- | --- | --- |
| F2-TC-01 | PIN is exactly 4 ASCII digits (security) | Boundary values (3/4/5 digits), invalid partitions | `test/core/pin_service_test.dart` |
| F2-TC-02 | Correct PIN unlocks, wrong PIN is rejected | Equivalence partitioning | `test/core/pin_service_test.dart` |
| F2-TC-03 | PIN never stored in plain text (security) | Inspection of stored values | `test/core/pin_service_test.dart` |
| F2-TC-04 | Hash is salted per device | Comparison | `test/core/pin_service_test.dart` |
| F2-TC-05 | 5th wrong try locks for 30 s; correct PIN refused while locked | Boundary values, state transition | `test/core/pin_service_test.dart` |
| F2-TC-06 | Lock expires after 30 s (29 s vs 31 s) | Boundary values, fake clock | `test/core/pin_service_test.dart` |
| F2-TC-07 | Correct PIN resets the counter | State transition | `test/core/pin_service_test.dart` |
| F2-TC-08 | Sign-in validation: email format, 7 vs 8-char password | Equivalence partitioning, boundary values | `test/core/session_test.dart` |
| F2-TC-09 | First sign-in: signed out → create PIN → unlocked | State transition | `test/core/session_test.dart` |
| F2-TC-10 | Later sign-in → unlock; lock; sign out | State transition | `test/core/session_test.dart` |
| F2-TC-11 | Register filters: everyone / follow up / not yet | Equivalence partitioning | `test/features/register_controller_test.dart` |
| F2-TC-12 | Next child never lacks consent (safety) | Decision table | `test/features/register_controller_test.dart` |
| F2-TC-13 | Finished session saved offline; next-up moves on; ends when all done | State transition | `test/features/register_controller_test.dart` |
| F2-TC-14 | Invalid sign-in shows a translated error | Use case | `test/features/journey_test.dart` |
| F2-TC-15 | PIN set-up mismatch restarts; match opens the register | Use case | `test/features/journey_test.dart` |
| F2-TC-16 | Filter pills show the right tiles | Use case | `test/features/journey_test.dart` |
| F2-TC-17 | Back cannot leave child mode; teacher exits with PIN; wrong PIN refused (security, safety) | State transition | `test/features/journey_test.dart` |
| F2-TC-18 | Cancel keeps the child in the exercise | Use case | `test/features/journey_test.dart` |
| F2-TC-19 | Finishing a session saves offline and moves to the next child | Use case | `test/features/journey_test.dart` |
| F2-TC-20 | Sign out, sign in again → PIN unlock; lockout after 5 tries | Use case, boundary | `test/features/journey_test.dart` |

Also automated: tap-target, label and text-contrast guidelines on the sign-in, PIN and register screens; register in Urdu (RTL). All journey tests run at 390 × 844, the design's phone size.

Manual at the gate: TalkBack pass and font scale 200% on a low-end Android phone using the debug APK from CI.
