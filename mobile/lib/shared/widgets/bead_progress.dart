import 'package:material_ui/material_ui.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/tokens.g.dart';

/// Child-facing progress: a row of beads, no numbers and no score.
/// Finished beads cycle through the truck-art colours, the current bead is an
/// aubergine ring, and beads still to come are sand.
class BeadProgress extends StatelessWidget {
  const BeadProgress({
    super.key,
    required this.current,
    required this.total,
    this.beadSize = 20,
  }) : assert(total > 0 && current >= 0 && current < total);

  /// Zero-based index of the current step.
  final int current;
  final int total;
  final double beadSize;

  static const List<Color> _doneColors = [
    IlmColors.rose,
    IlmColors.peacock,
    IlmColors.marigold,
  ];

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Semantics(
      label: s.stepOf(current + 1, total),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < total; i++)
            Padding(
              padding: const EdgeInsetsDirectional.only(end: IlmSpace.sm),
              child: Container(
                key: ValueKey('bead-$i'),
                width: beadSize,
                height: beadSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i < current
                      ? _doneColors[i % _doneColors.length]
                      : i == current
                          ? IlmColors.white
                          : IlmColors.sand,
                  border: i == current
                      ? Border.all(color: IlmColors.aubergine, width: 3)
                      : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
