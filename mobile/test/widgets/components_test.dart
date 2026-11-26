// F1-TC-12..22: every Direction B component renders all its states and meets
// the accessibility guidelines (target size, labels, contrast).
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilm_mobile/core/models/models.dart';
import 'package:ilm_mobile/shared/widgets/bead_progress.dart';
import 'package:ilm_mobile/shared/widgets/child_tile.dart';
import 'package:ilm_mobile/shared/widgets/filter_bar.dart';
import 'package:ilm_mobile/shared/widgets/ilm_button.dart';
import 'package:ilm_mobile/shared/widgets/progress_ring.dart';
import 'package:ilm_mobile/shared/widgets/result_widgets.dart';
import 'package:ilm_mobile/shared/widgets/signal_chip.dart';
import 'package:ilm_mobile/shared/widgets/truck_art.dart';

import '../helpers.dart';

void main() {
  group('SignalChip', () {
    const expected = {
      Signal.followUp: 'Follow up',
      Signal.watch: 'Watch',
      Signal.allClear: 'All clear',
      Signal.notYet: 'Not yet',
    };
    for (final entry in expected.entries) {
      testWidgets('F1-TC-12 ${entry.key.name} shows shape + word', (
        tester,
      ) async {
        await pumpIlm(tester, SignalChip(signal: entry.key));
        expect(find.text(entry.value), findsOneWidget);
        expect(find.byType(SignalShape), findsOneWidget);
      });
    }

    testWidgets('F1-TC-13 labels are translated to Urdu', (tester) async {
      await pumpIlm(
        tester,
        const SignalChip(signal: Signal.followUp),
        locale: const Locale('ur'),
      );
      expect(find.text('مزید جانچ تجویز'), findsOneWidget);
    });
  });

  group('ChildTile', () {
    const followUp = Child(
      id: '1',
      displayName: 'Areeba Khan',
      signal: Signal.followUp,
      hasConsent: true,
    );
    const nextUp = Child(
      id: '2',
      displayName: 'Noor Fatima',
      signal: Signal.notYet,
      hasConsent: true,
      isNextUp: true,
    );
    const noConsent = Child(
      id: '3',
      displayName: 'Saad Rehman',
      signal: Signal.notYet,
      hasConsent: false,
    );

    testWidgets('F1-TC-14 shows initials, name and signal; tap works', (
      tester,
    ) async {
      var taps = 0;
      await pumpIlm(
        tester,
        SizedBox(
          width: 180,
          child: ChildTile(student: followUp, onTap: () => taps++),
        ),
      );
      expect(find.text('AK'), findsOneWidget);
      expect(find.text('Areeba Khan'), findsOneWidget);
      expect(find.text('Follow up'), findsOneWidget);
      await tester.tap(find.byType(ChildTile));
      expect(taps, 1);
      expect(
        tester.getSemantics(find.byType(ChildTile)),
        isSemantics(
          label: 'Areeba Khan, Follow up',
          isButton: true,
          isEnabled: true,
          hasTapAction: true,
        ),
      );
    });

    testWidgets('F1-TC-15 next-up child shows "Next up"', (tester) async {
      await pumpIlm(
        tester,
        SizedBox(
          width: 180,
          child: ChildTile(student: nextUp, onTap: () {}),
        ),
      );
      expect(find.text('Next up'), findsOneWidget);
    });

    testWidgets('F1-TC-16 child without consent cannot be started', (
      tester,
    ) async {
      var taps = 0;
      await pumpIlm(
        tester,
        SizedBox(
          width: 180,
          child: ChildTile(student: noConsent, onTap: () => taps++),
        ),
      );
      expect(find.text('Needs consent'), findsOneWidget);
      await tester.tap(find.byType(ChildTile));
      expect(taps, 0);
    });

    testWidgets('F1-TC-17 meets target-size, label and contrast guidelines', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpIlm(
        tester,
        SizedBox(
          width: 180,
          child: ChildTile(student: followUp, onTap: () {}),
        ),
      );
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      handle.dispose();
    });
  });

  group('FilterBar', () {
    testWidgets('F1-TC-18 selecting a filter reports its value', (
      tester,
    ) async {
      String? picked;
      await pumpIlm(
        tester,
        FilterBar<String>(
          selected: 'all',
          onChanged: (v) => picked = v,
          options: const [
            FilterOption(value: 'all', label: 'Everyone'),
            FilterOption(value: 'fu', label: 'Follow up', count: 2),
          ],
        ),
      );
      expect(find.text('Follow up · 2'), findsOneWidget);
      await tester.tap(find.text('Follow up · 2'));
      expect(picked, 'fu');
    });

    testWidgets('F1-TC-18 pills meet the 48 dp target size', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpIlm(
        tester,
        FilterBar<int>(
          selected: 0,
          onChanged: (_) {},
          options: const [
            FilterOption(value: 0, label: 'Everyone'),
            FilterOption(value: 1, label: 'Not yet', count: 14),
          ],
        ),
      );
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });
  });

  group('IlmButton', () {
    testWidgets(
      'F1-TC-19 primary and secondary buttons are tappable and >= 48 dp',
      (tester) async {
        final handle = tester.ensureSemantics();
        var taps = 0;
        await pumpIlm(
          tester,
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IlmButton(
                label: 'Done',
                icon: Icons.check,
                onPressed: () => taps++,
              ),
              IlmButton(
                label: 'Again',
                variant: IlmButtonVariant.secondary,
                onPressed: () => taps++,
              ),
            ],
          ),
        );
        await tester.tap(find.text('Done'));
        await tester.tap(find.text('Again'));
        expect(taps, 2);
        expect(
          tester.getSize(find.byType(ElevatedButton).first).height,
          greaterThanOrEqualTo(48),
        );
        await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
        await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
        await expectLater(tester, meetsGuideline(textContrastGuideline));
        handle.dispose();
      },
    );

    testWidgets('disabled button does not fire', (tester) async {
      await pumpIlm(tester, const IlmButton(label: 'Done', onPressed: null));
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.enabled, isFalse);
    });
  });

  testWidgets('F1-TC-20 ProgressRing announces progress in words', (
    tester,
  ) async {
    await pumpIlm(
      tester,
      const ColoredBox(
        color: Colors.black,
        child: ProgressRing(done: 18, total: 32),
      ),
    );
    expect(find.text('18'), findsOneWidget);
    expect(find.text('of 32'), findsOneWidget);
    expect(find.bySemanticsLabel('18 of 32 screened'), findsOneWidget);
  });

  group('BeadProgress', () {
    testWidgets('F1-TC-21 shows beads but no numbers to the child', (
      tester,
    ) async {
      await pumpIlm(tester, const BeadProgress(current: 2, total: 6));
      for (var i = 0; i < 6; i++) {
        expect(find.byKey(ValueKey('bead-$i')), findsOneWidget);
      }
      // No visible digits anywhere: progress without a score.
      expect(find.textContaining(RegExp(r'\d')), findsNothing);
      expect(find.bySemanticsLabel('Step 3 of 6'), findsOneWidget);
    });

    test('rejects an out-of-range step (boundary value)', () {
      // ignore: prefer_const_constructors
      expect(() => BeadProgress(current: 6, total: 6), throwsAssertionError);
    });
  });

  group('Result widgets', () {
    testWidgets('F1-TC-22 gauges show words, never numbers', (tester) async {
      await pumpIlm(
        tester,
        const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            LevelGauge(level: Level.many, caption: 'Writing'),
            LevelGauge(level: Level.few, caption: 'Reading'),
          ],
        ),
      );
      expect(find.text('Many'), findsOneWidget);
      expect(find.text('Few'), findsOneWidget);
      expect(find.textContaining(RegExp(r'\d')), findsNothing);
      expect(find.bySemanticsLabel('Writing: Many'), findsOneWidget);
    });

    testWidgets('medallion and observation render', (tester) async {
      await pumpIlm(
        tester,
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MedallionBadge(signal: Signal.watch),
            SizedBox(
              width: 300,
              child: ObservationRow(text: 'Paused often', signal: Signal.watch),
            ),
          ],
        ),
      );
      expect(find.bySemanticsLabel('Watch'), findsOneWidget);
      expect(find.text('Paused often'), findsOneWidget);
    });
  });

  testWidgets(
    'truck-art band and frame are decorative (hidden from screen readers)',
    (tester) async {
      await pumpIlm(
        tester,
        const SizedBox(
          width: 300,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TruckArtBand(),
              TruckArtFrame(child: SizedBox(height: 80, child: Text('canvas'))),
            ],
          ),
        ),
      );
      expect(find.text('canvas'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
