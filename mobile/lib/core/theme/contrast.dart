import 'dart:math' as math;

import 'package:flutter/painting.dart';

/// WCAG 2.2 (ISO/IEC 40500:2025) contrast helpers.
abstract final class Contrast {
  /// Minimum ratio for normal text, success criterion 1.4.3 (AA).
  static const double aaNormalText = 4.5;

  /// Minimum ratio for large text and UI components (1.4.3 / 1.4.11, AA).
  static const double aaLargeTextOrUi = 3.0;

  /// Relative luminance as defined by WCAG.
  static double luminance(Color color) {
    double channel(double c) => c <= 0.03928
        ? c / 12.92
        : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
    final r = channel(_component(color, 16));
    final g = channel(_component(color, 8));
    final b = channel(_component(color, 0));
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  /// Contrast ratio between two opaque colours (1.0 to 21.0).
  static double ratio(Color a, Color b) {
    final la = luminance(a);
    final lb = luminance(b);
    final lighter = math.max(la, lb);
    final darker = math.min(la, lb);
    return (lighter + 0.05) / (darker + 0.05);
  }

  // Reads one 8-bit channel from the 32-bit ARGB value.
  static double _component(Color c, int shift) =>
      ((c.toARGB32() >> shift) & 0xFF) / 255.0;
}
