import 'package:material_ui/material_ui.dart';

import '../../core/theme/tokens.g.dart';

class FilterOption<T> {
  const FilterOption({required this.value, required this.label, this.count});

  final T value;
  final String label;
  final int? count;
}

/// Pill filters for the class register (Everyone / Follow up / Not yet).
/// Selected = aubergine fill with white text.
class FilterBar<T> extends StatelessWidget {
  const FilterBar({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  final List<FilterOption<T>> options;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelMedium!;
    return Wrap(
      spacing: IlmSpace.sm,
      runSpacing: IlmSpace.sm,
      children: [
        for (final option in options)
          _FilterPill(
            label: option.count == null
                ? option.label
                : '${option.label} · ${option.count}',
            selected: option.value == selected,
            textStyle: textStyle,
            onTap: () => onChanged(option.value),
          ),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.textStyle,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final TextStyle textStyle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: Material(
        color: selected ? IlmColors.aubergine : IlmColors.white,
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? IlmColors.aubergine : IlmColors.sand,
            width: 1.5,
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: IlmSize.minTouchTarget,
              minWidth: IlmSize.minTouchTarget,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: IlmSpace.lg),
              child: Center(
                widthFactor: 1,
                child: Text(
                  label,
                  style: textStyle.copyWith(
                    color: selected ? IlmColors.white : IlmColors.aubergine,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
