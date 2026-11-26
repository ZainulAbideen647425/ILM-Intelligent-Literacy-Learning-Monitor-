// F1-TC-01..04: token colour pairs meet WCAG 2.2 AA (ISO/IEC 40500:2025, SC 1.4.3).
import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ilm_mobile/core/theme/contrast.dart';
import 'package:ilm_mobile/core/theme/tokens.g.dart';

void main() {
  group('Contrast.ratio', () {
    test('F1-TC-01 black on white is 21:1 and is symmetric', () {
      const black = Color(0xFF000000);
      const white = Color(0xFFFFFFFF);
      expect(Contrast.ratio(black, white), closeTo(21, 0.01));
      expect(Contrast.ratio(white, black), closeTo(21, 0.01));
      expect(Contrast.ratio(white, white), closeTo(1, 0.001));
    });
  });

  group('Text colour pairs used in the app meet AA (4.5:1)', () {
    const backgrounds = {'cream': IlmColors.cream, 'white': IlmColors.white};
    const textColours = {
      'aubergine': IlmColors.aubergine,
      'inkMuted': IlmColors.inkMuted,
      'rose': IlmColors.rose,
      'peacock': IlmColors.peacock,
      'marigoldText': IlmColors.marigoldText,
    };

    for (final text in textColours.entries) {
      for (final bg in backgrounds.entries) {
        test('F1-TC-02 ${text.key} on ${bg.key}', () {
          expect(
            Contrast.ratio(text.value, bg.value),
            greaterThanOrEqualTo(Contrast.aaNormalText),
          );
        });
      }
    }

    test('F1-TC-03 aubergine text on marigold buttons', () {
      expect(
        Contrast.ratio(IlmColors.aubergine, IlmColors.marigold),
        greaterThanOrEqualTo(Contrast.aaNormalText),
      );
    });

    test('F1-TC-03 white text on dark fills (header, avatars)', () {
      for (final fill in [IlmColors.aubergine, IlmColors.rose, IlmColors.peacock]) {
        expect(
          Contrast.ratio(IlmColors.white, fill),
          greaterThanOrEqualTo(Contrast.aaNormalText),
        );
      }
    });
  });

  test('F1-TC-04 raw marigold is NOT safe for text on light backgrounds', () {
    // Documents why marigoldText exists. If this ever passes, the token
    // values changed and the design should be re-reviewed.
    expect(
      Contrast.ratio(IlmColors.marigold, IlmColors.cream),
      lessThan(Contrast.aaNormalText),
    );
  });
}
