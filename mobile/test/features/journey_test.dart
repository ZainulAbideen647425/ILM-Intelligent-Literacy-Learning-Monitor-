// F2-TC-14..20: end-to-end teacher journey on a 390 x 844 phone (design size),
// fully offline with mock data.
import 'dart:io';

import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilm_mobile/app.dart';
import 'package:ilm_mobile/core/security/pin_service.dart';
import 'package:ilm_mobile/core/session/app_session.dart';
import 'package:ilm_mobile/data/auth_repository.dart';
import 'package:ilm_mobile/data/screening_repository.dart';
import 'package:ilm_mobile/features/child_session/child_session_screen.dart';
import 'package:ilm_mobile/features/register/class_register_screen.dart';
import 'package:ilm_mobile/shared/widgets/child_tile.dart';

void main() {
  late AppSession session;

  setUp(() {
    session = AppSession(
      auth: const MockAuthRepository(),
      pins: PinService(InMemoryPinStore()),
      // Same sample data as the app, read once from disk (see
      // InMemoryScreeningRepository for why assets are not used here).
      screening: InMemoryScreeningRepository([
        MockScreeningRepository.parseClass(
          File('assets/mock/class_3b.json').readAsStringSync(),
        ),
      ]),
    );
  });

  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(IlmApp(session: session));
    await tester.pumpAndSettle();
  }

  Future<void> typePin(WidgetTester tester, String pin) async {
    for (final d in pin.split('')) {
      await tester.tap(find.byKey(ValueKey('pin-key-$d')).last);
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  Future<void> signIn(
    WidgetTester tester, {
    String email = 'teacher@school.pk',
    String password = 'classroom1',
  }) async {
    await tester.enterText(find.byKey(const Key('email-field')), email);
    await tester.enterText(find.byKey(const Key('password-field')), password);
    await tester.tap(find.byKey(const Key('sign-in-button')));
    await tester.pumpAndSettle();
  }

  testWidgets('F2-TC-14 invalid sign-in shows a translated error', (
    tester,
  ) async {
    await pumpApp(tester);
    await signIn(tester, email: 'not-an-email');
    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(session.stage, SessionStage.signedOut);
  });

  testWidgets(
    'F2-TC-15 PIN set-up: mismatch restarts, match unlocks the register',
    (tester) async {
      await pumpApp(tester);
      await signIn(tester);
      expect(find.text('Create a 4-digit PIN'), findsOneWidget);

      await typePin(tester, '1234');
      expect(find.text('Enter the same PIN again'), findsOneWidget);
      await typePin(tester, '1235');
      expect(find.text('The PINs did not match. Try again.'), findsOneWidget);
      expect(find.text('Create a 4-digit PIN'), findsOneWidget);

      await typePin(tester, '1234');
      await typePin(tester, '1234');
      expect(find.byType(ClassRegisterScreen), findsOneWidget);
      expect(find.text('Class 3-B'), findsOneWidget);
      expect(find.text('7 saved offline'), findsOneWidget);
      expect(find.bySemanticsLabel('5 of 8 screened'), findsOneWidget);
    },
  );

  Future<void> toRegister(WidgetTester tester) async {
    await session.signIn('teacher@school.pk', 'classroom1');
    await session.createPin('1234');
    await pumpApp(tester);
    expect(find.byType(ClassRegisterScreen), findsOneWidget);
  }

  testWidgets('F2-TC-16 filters show the right tiles', (tester) async {
    await toRegister(tester);
    await tester.tap(find.text('Follow up · 2'));
    await tester.pumpAndSettle();
    expect(find.byType(ChildTile), findsNWidgets(2));
    expect(find.text('Areeba Khan'), findsOneWidget);

    await tester.tap(find.text('Not yet · 3'));
    await tester.pumpAndSettle();
    expect(find.byType(ChildTile), findsNWidgets(3));
    expect(find.text('Needs consent'), findsOneWidget);
  });

  testWidgets(
    'F2-TC-17 child mode cannot be left with back; teacher exits with PIN',
    (tester) async {
      await toRegister(tester);
      await tester.tap(find.byKey(const Key('start-next')));
      await tester.pumpAndSettle();
      expect(find.byType(ChildSessionScreen), findsOneWidget);
      expect(find.text('Hand the phone to Noor'), findsOneWidget);

      // System back is blocked and asks for the teacher PIN instead.
      await tester
          .state<NavigatorState>(find.byType(Navigator).first)
          .maybePop();
      await tester.pumpAndSettle();
      expect(find.byType(ChildSessionScreen), findsOneWidget);
      expect(find.text('Enter your PIN to leave the exercise'), findsOneWidget);

      await typePin(tester, '0000');
      expect(find.text('Wrong PIN. 4 tries left.'), findsOneWidget);
      expect(find.byType(ChildSessionScreen), findsOneWidget);

      await typePin(tester, '1234');
      expect(find.byType(ChildSessionScreen), findsNothing);
      expect(
        find.text('7 saved offline'),
        findsOneWidget,
        reason: 'exit does not save a session',
      );
    },
  );

  testWidgets('F2-TC-18 cancel keeps the child in the exercise', (
    tester,
  ) async {
    await toRegister(tester);
    await tester.tap(find.byKey(const Key('start-next')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('teacher-exit')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('cancel-exit')));
    await tester.pumpAndSettle();
    expect(find.byType(ChildSessionScreen), findsOneWidget);
  });

  testWidgets(
    'F2-TC-19 finishing all steps saves offline and moves to the next child',
    (tester) async {
      await toRegister(tester);
      await tester.tap(find.byKey(const Key('start-next')));
      await tester.pumpAndSettle();
      for (var i = 0; i < 6; i++) {
        await tester.tap(find.byKey(const Key('done')));
        await tester.pumpAndSettle();
      }
      expect(find.byType(ClassRegisterScreen), findsOneWidget);
      expect(find.text('8 saved offline'), findsOneWidget);
      expect(
        find.text('Saved on this phone. It will sync later.'),
        findsOneWidget,
      );
      expect(find.text('Start with Taha'), findsOneWidget);

      // Let the snackbar finish so no timers are left pending.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    },
  );

  testWidgets(
    'F2-TC-20 sign out, then sign in again asks for the PIN (lockout after 5)',
    (tester) async {
      await toRegister(tester);
      await tester.tap(find.byKey(const Key('sign-out')));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('sign-in-button')), findsOneWidget);

      await signIn(tester);
      expect(find.text('Enter your PIN'), findsOneWidget);
      for (var i = 0; i < 4; i++) {
        await typePin(tester, '9999');
      }
      expect(find.text('Wrong PIN. 1 tries left.'), findsOneWidget);
      await typePin(tester, '9999');
      expect(find.text('Too many tries. Wait 30 seconds.'), findsOneWidget);
      expect(session.stage, SessionStage.locked);
    },
  );

  testWidgets('register meets tap-target, label and contrast guidelines', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await toRegister(tester);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    await expectLater(tester, meetsGuideline(textContrastGuideline));
    handle.dispose();
  });

  testWidgets('PIN pad meets tap-target and label guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester);
    await signIn(tester);
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });

  testWidgets('register works in Urdu (RTL)', (tester) async {
    await toRegister(tester);
    await tester.tap(find.byKey(const Key('toggle-language')));
    await tester.pumpAndSettle();
    expect(find.text('شروع کریں: Noor'), findsOneWidget);
    final context = tester.element(find.byType(ClassRegisterScreen));
    expect(Directionality.of(context), TextDirection.rtl);
  });
}
