import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/models/models.dart';
import '../../core/theme/tokens.g.dart';
import 'signal_chip.dart';

/// Round medallion that carries the result signal's shape on the result header.
class MedallionBadge extends StatelessWidget {
  const MedallionBadge({super.key, required this.signal, this.size = 64});

  final Signal signal;
  final double size;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Semantics(
      label: signal.label(s),
      excludeSemantics: true,
      child: Container(
        width: size,
        height: size,
        padding: EdgeInsets.all(size * 0.1),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: IlmColors.marigold,
        ),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: IlmColors.white,
            border: Border.all(color: signal.color, width: size * 0.06),
          ),
          child: SignalShape(signal: signal, size: size * 0.32),
        ),
      ),
    );
  }
}

/// Writing / reading gauge. Shows a word (Many / Some / Few), never a number.
class LevelGauge extends StatelessWidget {
  const LevelGauge({
    super.key,
    required this.level,
    required this.caption,
    this.size = 88,
  });

  final Level level;
  final String caption;
  final double size;

  Color get _color => switch (level) {
    Level.many => IlmColors.rose,
    Level.some => IlmColors.marigold,
    Level.few => IlmColors.peacock,
  };

  Color get _textColor => switch (level) {
    Level.many => IlmColors.rose,
    Level.some => IlmColors.marigoldText,
    Level.few => IlmColors.peacock,
  };

  double get _fraction => switch (level) {
    Level.many => 0.85,
    Level.some => 0.55,
    Level.few => 0.25,
  };

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final word = switch (level) {
      Level.many => s.levelMany,
      Level.some => s.levelSome,
      Level.few => s.levelFew,
    };
    final theme = Theme.of(context);
    return Semantics(
      label: '$caption: $word',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox.square(
            dimension: size,
            child: CustomPaint(
              painter: _GaugePainter(_fraction, _color),
              child: Center(
                child: Text(
                  word,
                  style: theme.textTheme.labelMedium!.copyWith(
                    color: _textColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: IlmSpace.sm),
          Text(caption, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter(this.fraction, this.color);

  final double fraction;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.shortestSide * 0.12;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    canvas.drawArc(
      rect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..color = IlmColors.sand
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * fraction,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.fraction != fraction || old.color != color;
}

/// One plain-language observation on the result screen.
class ObservationRow extends StatelessWidget {
  const ObservationRow({super.key, required this.text, required this.signal});

  final String text;
  final Signal signal;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: IlmSpace.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: SignalShape(signal: signal, size: 10),
          ),
          const SizedBox(width: IlmSpace.md),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
