import 'package:material_ui/material_ui.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/models/models.dart';
import '../../core/theme/tokens.g.dart';
import 'signal_chip.dart';

/// Child card in the class register: initials avatar, name and signal.
///
/// * Follow up children get a rose border.
/// * The next child to screen gets a dashed border and a "Next up" label.
/// * Children without consent show "Needs consent" and cannot be started.
class ChildTile extends StatelessWidget {
  const ChildTile({super.key, required this.student, this.onTap});

  final Child student;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final theme = Theme.of(context);
    final status = !student.hasConsent
        ? Text(
            s.needsConsent,
            style: theme.textTheme.bodySmall!.copyWith(
              color: IlmColors.rose,
              fontWeight: FontWeight.w700,
            ),
          )
        : student.hasPendingSession
        ? Text(
            s.awaitingResult,
            style: theme.textTheme.bodySmall!.copyWith(
              color: IlmColors.inkMuted,
              fontWeight: FontWeight.w700,
            ),
          )
        : student.isNextUp
        ? Text(
            s.nextUp,
            style: theme.textTheme.bodySmall!.copyWith(
              color: IlmColors.inkMuted,
              fontWeight: FontWeight.w700,
            ),
          )
        : SignalChip(signal: student.signal, dense: true);

    final statusLabel = !student.hasConsent
        ? s.needsConsent
        : student.hasPendingSession
        ? s.awaitingResult
        : student.isNextUp
        ? s.nextUp
        : student.signal.label(s);

    final content = Padding(
      padding: const EdgeInsets.all(IlmSpace.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _Avatar(student: student),
          const SizedBox(height: IlmSpace.sm),
          Text(
            student.displayName,
            style: theme.textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: IlmSpace.xs),
          status,
        ],
      ),
    );

    final highlighted = student.signal == Signal.followUp && student.hasConsent;
    final enabled = student.hasConsent && onTap != null;

    return Semantics(
      button: enabled,
      enabled: enabled,
      label: '${student.displayName}, $statusLabel',
      onTap: enabled ? onTap : null,
      excludeSemantics: true,
      child: CustomPaint(
        foregroundPainter: student.isNextUp ? _DashedBorderPainter() : null,
        child: Material(
          color: student.hasConsent ? IlmColors.white : IlmColors.cream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(IlmRadius.md),
            side: highlighted
                ? const BorderSide(color: IlmColors.rose, width: 2)
                : student.isNextUp
                ? BorderSide.none
                : const BorderSide(color: IlmColors.sand),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? onTap : null,
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: IlmSize.minTouchTarget,
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.student});

  final Child student;

  @override
  Widget build(BuildContext context) {
    final background = student.signal == Signal.notYet
        ? IlmColors.sand
        : student.signal.color;
    final foreground =
        student.signal == Signal.notYet || student.signal == Signal.watch
        ? IlmColors.aubergine
        : IlmColors.white;
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Text(
        student.initials,
        textDirection: TextDirection.ltr,
        style: TextStyle(
          fontFamily: IlmFonts.body,
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: foreground,
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = IlmColors.aubergine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(0.75),
          const Radius.circular(IlmRadius.md),
        ),
      );
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 6), paint);
        distance += 10;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) => false;
}
