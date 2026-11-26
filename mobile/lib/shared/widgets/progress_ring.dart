import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/tokens.g.dart';

/// Class progress ring, e.g. "18 of 32" with a marigold arc.
/// Designed to sit on the aubergine class header.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.done,
    required this.total,
    this.size = 72,
  }) : assert(total >= 0 && done >= 0 && done <= total);

  final int done;
  final int total;
  final double size;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final fraction = total == 0 ? 0.0 : done / total;
    return Semantics(
      label: s.screenedProgress(done, total),
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _RingPainter(fraction),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$done',
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                    fontFamily: IlmFonts.heading,
                    fontVariations: [FontVariation('wght', 700)],
                    fontSize: 22,
                    height: 1,
                    color: IlmColors.white,
                  ),
                ),
                Text(
                  '${s.ofTotal} $total',
                  style: const TextStyle(
                    fontFamily: IlmFonts.body,
                    fontSize: 11,
                    height: 1.2,
                    color: IlmColors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.fraction);

  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 7.0;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final track = Paint()
      ..color = IlmColors.white.withAlpha(46)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final arc = Paint()
      ..color = IlmColors.marigold
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = stroke;
    canvas.drawArc(rect, 0, math.pi * 2, false, track);
    if (fraction > 0) {
      canvas.drawArc(rect, -math.pi / 2, math.pi * 2 * fraction, false, arc);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.fraction != fraction;
}
