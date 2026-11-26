import 'package:material_ui/material_ui.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.g.dart';

enum IlmButtonVariant {
  /// Marigold fill, aubergine text (7.0:1). The one main action per screen.
  primary,

  /// White fill, aubergine outline and text.
  secondary,
}

/// Pill-shaped button from Direction B. Always at least 52 dp tall so it
/// clears the 48 dp minimum touch target.
class IlmButton extends StatelessWidget {
  const IlmButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = IlmButtonVariant.primary,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IlmButtonVariant variant;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == IlmButtonVariant.primary;
    final textStyle = Theme.of(context).textTheme.labelLarge!.copyWith(
      color: IlmColors.aubergine,
      fontVariations: Directionality.of(context) == TextDirection.rtl
          ? null
          : AppTheme.headingBold,
    );
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(
        Size(IlmSize.minTouchTarget, IlmSize.buttonHeight),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: IlmSpace.xl),
      ),
      shape: const WidgetStatePropertyAll(StadiumBorder()),
      backgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return IlmColors.sand;
        return isPrimary ? IlmColors.marigold : IlmColors.white;
      }),
      foregroundColor: const WidgetStatePropertyAll(IlmColors.aubergine),
      side: WidgetStatePropertyAll(
        isPrimary
            ? BorderSide.none
            : const BorderSide(color: IlmColors.aubergine, width: 1.5),
      ),
      elevation: const WidgetStatePropertyAll(0),
      textStyle: WidgetStatePropertyAll(textStyle),
    );

    final child = icon == null
        ? Text(label, style: textStyle, textAlign: TextAlign.center)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: IlmColors.aubergine),
              const SizedBox(width: IlmSpace.sm),
              Flexible(child: Text(label, style: textStyle)),
            ],
          );

    final button = ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: child,
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
