import 'package:flutter/material.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/models/models.dart';
import '../../core/theme/tokens.g.dart';

/// Colour, text colour and label for each [Signal].
extension SignalStyle on Signal {
  /// Fill colour for shapes, borders and avatars.
  Color get color => switch (this) {
        Signal.followUp => IlmColors.rose,
        Signal.watch => IlmColors.marigold,
        Signal.allClear => IlmColors.peacock,
        Signal.notYet => IlmColors.inkMuted,
      };

  /// Text colour that meets WCAG AA on cream and white.
  Color get textColor => switch (this) {
        Signal.followUp => IlmColors.rose,
        Signal.watch => IlmColors.marigoldText,
        Signal.allClear => IlmColors.peacock,
        Signal.notYet => IlmColors.inkMuted,
      };

  String label(AppStrings s) => switch (this) {
        Signal.followUp => s.signalFollowUp,
        Signal.watch => s.signalWatch,
        Signal.allClear => s.signalAllClear,
        Signal.notYet => s.signalNotYet,
      };
}

/// The shape that carries a signal's meaning without colour:
/// filled square = follow up, half-filled circle = watch,
/// outlined circle = all clear, small dot = not yet.
class SignalShape extends StatelessWidget {
  const SignalShape({super.key, required this.signal, this.size = 14});

  final Signal signal;
  final double size;

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
        child: CustomPaint(
          size: Size.square(size),
          painter: _SignalShapePainter(signal),
        ),
      );
}

class _SignalShapePainter extends CustomPainter {
  _SignalShapePainter(this.signal);

  final Signal signal;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.shortestSide / 2;
    final fill = Paint()..color = signal.color;
    final stroke = Paint()
      ..color = signal.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.16;

    switch (signal) {
      case Signal.followUp:
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(size.shortestSide * 0.2)),
          fill,
        );
      case Signal.watch:
        final inner = radius - stroke.strokeWidth / 2;
        canvas.drawCircle(center, inner, stroke);
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: inner),
          -1.5708,
          3.1416,
          true,
          fill,
        );
      case Signal.allClear:
        canvas.drawCircle(center, radius - stroke.strokeWidth / 2, stroke);
      case Signal.notYet:
        canvas.drawCircle(center, radius * 0.35, fill);
    }
  }

  @override
  bool shouldRepaint(_SignalShapePainter old) => old.signal != signal;
}

/// Compact label: shape + word, e.g. "■ Follow up".
class SignalChip extends StatelessWidget {
  const SignalChip({super.key, required this.signal, this.dense = false});

  final Signal signal;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final style = (dense
            ? Theme.of(context).textTheme.bodySmall
            : Theme.of(context).textTheme.labelMedium)!
        .copyWith(color: signal.textColor, fontWeight: FontWeight.w700);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SignalShape(signal: signal, size: dense ? 10 : 14),
        const SizedBox(width: IlmSpace.xs + 2),
        Flexible(child: Text(signal.label(s), style: style)),
      ],
    );
  }
}
