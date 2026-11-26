import 'package:material_ui/material_ui.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/security/pin_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.g.dart';

/// Large-key number pad with 4 dots. Calls [onCompleted] when 4 digits are
/// entered; the parent decides what happens and calls [PinPadState.clear].
///
/// Digits are always laid out left-to-right (0-9 keypad convention), even in
/// Urdu, so muscle memory matches a phone dialler.
class PinPad extends StatefulWidget {
  const PinPad({super.key, required this.onCompleted, this.enabled = true});

  final ValueChanged<String> onCompleted;
  final bool enabled;

  @override
  State<PinPad> createState() => PinPadState();
}

class PinPadState extends State<PinPad> {
  String _digits = '';

  void clear() => setState(() => _digits = '');

  void _press(String digit) {
    if (!widget.enabled || _digits.length >= PinService.pinLength) return;
    setState(() => _digits += digit);
    if (_digits.length == PinService.pinLength) {
      widget.onCompleted(_digits);
    }
  }

  void _delete() {
    if (!widget.enabled || _digits.isEmpty) return;
    setState(() => _digits = _digits.substring(0, _digits.length - 1));
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    Widget key(String digit) => _PadKey(
          key: ValueKey('pin-key-$digit'),
          label: digit,
          semanticLabel: digit,
          enabled: widget.enabled,
          onTap: () => _press(digit),
        );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Semantics(
            label: s.pinDigitsEntered(_digits.length),
            liveRegion: true,
            excludeSemantics: true,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < PinService.pinLength; i++)
                  Container(
                    key: ValueKey('pin-dot-$i'),
                    width: 18,
                    height: 18,
                    margin: const EdgeInsets.symmetric(horizontal: IlmSpace.sm),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i < _digits.length ? IlmColors.aubergine : IlmColors.white,
                      border: Border.all(color: IlmColors.aubergine, width: 2),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: IlmSpace.xl),
          for (final row in const [
            ['1', '2', '3'],
            ['4', '5', '6'],
            ['7', '8', '9'],
          ])
            Row(mainAxisSize: MainAxisSize.min, children: [for (final d in row) key(d)]),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(width: _PadKey.size + IlmSpace.md),
              key('0'),
              _PadKey(
                key: const ValueKey('pin-key-delete'),
                icon: Icons.backspace_outlined,
                semanticLabel: s.deleteDigit,
                enabled: widget.enabled,
                onTap: _delete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PadKey extends StatelessWidget {
  const _PadKey({
    super.key,
    this.label,
    this.icon,
    required this.semanticLabel,
    required this.enabled,
    required this.onTap,
  });

  static const double size = 72;

  final String? label;
  final IconData? icon;
  final String semanticLabel;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(IlmSpace.md / 2),
      child: Semantics(
        button: true,
        enabled: enabled,
        label: semanticLabel,
        onTap: enabled ? onTap : null,
        excludeSemantics: true,
        child: Material(
          color: enabled ? IlmColors.white : IlmColors.sand,
          shape: const CircleBorder(side: BorderSide(color: IlmColors.sand)),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: enabled ? onTap : null,
            child: SizedBox.square(
              dimension: size,
              child: Center(
                child: label != null
                    ? Text(
                        label!,
                        style: const TextStyle(
                          fontFamily: IlmFonts.heading,
                          fontVariations: AppTheme.headingBold,
                          fontSize: 28,
                          color: IlmColors.aubergine,
                        ),
                      )
                    : Icon(icon, color: IlmColors.aubergine),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
