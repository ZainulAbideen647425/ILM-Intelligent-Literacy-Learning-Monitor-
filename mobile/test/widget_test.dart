// F1-TC-23..24: app shell, language switch and right-to-left layout.
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilm_mobile/app.dart';
import 'package:ilm_mobile/features/gallery/component_gallery_screen.dart';

void main() {
  testWidgets('F1-TC-23 app starts on the component gallery in English (LTR)', (
    tester,
  ) async {
    await tester.pumpWidget(const IlmApp());
    await tester.pumpAndSettle();
    expect(find.byType(ComponentGalleryScreen), findsOneWidget);
    expect(find.text('Component gallery'), findsOneWidget);
    final context = tester.element(find.byType(ComponentGalleryScreen));
    expect(Directionality.of(context), TextDirection.ltr);
  });

  testWidgets('F1-TC-24 switching to Urdu flips the layout to RTL', (
    tester,
  ) async {
    await tester.pumpWidget(const IlmApp());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('toggle-language')));
    await tester.pumpAndSettle();
    expect(find.text('اجزاء کی نمائش'), findsOneWidget);
    final context = tester.element(find.byType(ComponentGalleryScreen));
    expect(Directionality.of(context), TextDirection.rtl);
    expect(Theme.of(context).textTheme.bodyMedium!.fontFamily, 'Gulzar');
  });

  testWidgets('gallery meets tap-target and label guidelines', (tester) async {
    final handle = tester.ensureSemantics();
    await tester.pumpWidget(const IlmApp());
    await tester.pumpAndSettle();
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    handle.dispose();
  });
}
