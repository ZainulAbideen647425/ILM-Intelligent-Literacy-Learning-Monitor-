// F1-TC-23..24 (updated in F2): app shell, language switch, right-to-left
// layout, and the component gallery kept for design reviews.
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilm_mobile/app.dart';
import 'package:ilm_mobile/core/security/pin_service.dart';
import 'package:ilm_mobile/core/session/app_session.dart';
import 'package:ilm_mobile/data/auth_repository.dart';
import 'package:ilm_mobile/data/screening_repository.dart';
import 'package:ilm_mobile/features/auth/sign_in_screen.dart';
import 'package:ilm_mobile/features/gallery/component_gallery_screen.dart';

import 'helpers.dart';

void main() {
  AppSession newSession() => AppSession(
    auth: const MockAuthRepository(),
    pins: PinService(InMemoryPinStore()),
    screening: MockScreeningRepository(),
  );

  testWidgets('F1-TC-23 app starts on sign-in in English (LTR)', (
    tester,
  ) async {
    await tester.pumpWidget(IlmApp(session: newSession()));
    await tester.pumpAndSettle();
    expect(find.byType(SignInScreen), findsOneWidget);
    final context = tester.element(find.byType(SignInScreen));
    expect(Directionality.of(context), TextDirection.ltr);
  });

  testWidgets('F1-TC-24 switching to Urdu flips the layout to RTL', (
    tester,
  ) async {
    await tester.pumpWidget(IlmApp(session: newSession()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('toggle-language')));
    await tester.pumpAndSettle();
    expect(find.text('سائن ان'), findsWidgets);
    final context = tester.element(find.byType(SignInScreen));
    expect(Directionality.of(context), TextDirection.rtl);
    expect(Theme.of(context).textTheme.bodyMedium!.fontFamily, 'Gulzar');
  });

  testWidgets('sign-in screen meets tap-target and label guidelines', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(IlmApp(session: newSession()));
    await tester.pumpAndSettle();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });

  testWidgets('component gallery renders every component', (tester) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.reset);
    await pumpIlm(tester, const ComponentGalleryScreen());
    expect(find.text('Component gallery'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
