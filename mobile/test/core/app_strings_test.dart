// F1-TC-05..08: localisation completeness and the Direction B language rules.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilm_mobile/core/l10n/app_strings.dart';

void main() {
  final en = AppStrings.values['en']!;
  final ur = AppStrings.values['ur']!;

  test('F1-TC-05 English and Urdu have exactly the same keys', () {
    expect(ur.keys.toSet(), equals(en.keys.toSet()));
  });

  test('F1-TC-06 no string is empty in either language', () {
    for (final table in [en, ur]) {
      for (final entry in table.entries) {
        expect(entry.value.trim(), isNotEmpty, reason: entry.key);
      }
    }
  });

  test('F1-TC-07 placeholders match between languages', () {
    final placeholder = RegExp(r'\{(\w+)\}');
    for (final key in en.keys) {
      Set<String> names(String s) =>
          placeholder.allMatches(s).map((m) => m.group(1)!).toSet();
      expect(names(ur[key]!), equals(names(en[key]!)), reason: key);
    }
  });

  group('F1-TC-08 language rules: screening, not diagnosis', () {
    // Labels that must never describe a child.
    const bannedEverywhere = ['dyslexi', 'weak', 'disabled', 'ڈسلیکس', 'کمزور'];
    const diagnosisWords = ['diagnos', 'تشخیص'];

    for (final lang in AppStrings.values.keys) {
      test('$lang has no banned labels', () {
        AppStrings.values[lang]!.forEach((key, value) {
          final lower = value.toLowerCase();
          for (final word in bannedEverywhere) {
            expect(lower.contains(word), isFalse,
                reason: '$lang.$key contains "$word"');
          }
          if (!AppStrings.disclaimerKeys.contains(key)) {
            for (final word in diagnosisWords) {
              expect(lower.contains(word), isFalse,
                  reason: '$lang.$key contains "$word"');
            }
          }
        });
      });
    }
  });

  test('placeholders are filled', () {
    const s = AppStrings(Locale('en'));
    expect(s.stepOf(3, 6), 'Step 3 of 6');
    expect(s.screenedProgress(18, 32), '18 of 32 screened');
  });

  test('unknown locale falls back to English', () {
    const s = AppStrings(Locale('fr'));
    expect(s.done, 'Done');
  });
}
