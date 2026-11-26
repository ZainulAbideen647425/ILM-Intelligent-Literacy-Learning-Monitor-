import 'package:material_ui/material_ui.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/security/pin_service.dart';
import '../../core/session/app_session.dart';
import '../../core/theme/tokens.g.dart';
import '../../shared/widgets/pin_pad.dart';
import '../../shared/widgets/truck_art.dart';

enum PinMode { create, unlock }

/// Full-screen PIN: create (enter + confirm) on first sign-in, unlock after.
class PinScreen extends StatefulWidget {
  const PinScreen({super.key, required this.mode});

  final PinMode mode;

  @override
  State<PinScreen> createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final _pad = GlobalKey<PinPadState>();
  String? _firstEntry;
  String? _message;
  bool _messageIsError = false;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final theme = Theme.of(context);
    final title = widget.mode == PinMode.unlock
        ? s.enterPin
        : _firstEntry == null
            ? s.createPin
            : s.confirmPin;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: IlmColors.aubergine,
              width: double.infinity,
              padding: const EdgeInsets.all(IlmSpace.lg),
              child: Text(
                s.appName,
                style: theme.textTheme.headlineMedium!.copyWith(color: IlmColors.marigold),
              ),
            ),
            const TruckArtBand(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(IlmSpace.xl),
                child: PinEntry(
                  padKey: _pad,
                  title: title,
                  help: widget.mode == PinMode.create && _firstEntry == null ? s.createPinHelp : null,
                  message: _message,
                  messageIsError: _messageIsError,
                  onCompleted: (pin) => widget.mode == PinMode.create ? _onCreate(pin) : _onUnlock(pin),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onCreate(String pin) async {
    final s = AppStrings.of(context);
    if (_firstEntry == null) {
      setState(() {
        _firstEntry = pin;
        _message = null;
      });
      _pad.currentState?.clear();
      return;
    }
    if (pin != _firstEntry) {
      setState(() {
        _firstEntry = null;
        _message = s.pinMismatch;
        _messageIsError = true;
      });
      _pad.currentState?.clear();
      return;
    }
    await SessionScope.read(context).createPin(pin);
  }

  Future<void> _onUnlock(String pin) async {
    final session = SessionScope.read(context);
    final ok = await verifyPinWithFeedback(
      context: context,
      pins: session.pins,
      pin: pin,
      onMessage: (m) => setState(() {
        _message = m;
        _messageIsError = true;
      }),
    );
    if (!mounted) return;
    if (ok) {
      session.unlock();
    } else {
      _pad.currentState?.clear();
    }
  }
}

/// Shared check used by the unlock screen and the child-mode exit dialog.
Future<bool> verifyPinWithFeedback({
  required BuildContext context,
  required PinService pins,
  required String pin,
  required ValueChanged<String> onMessage,
}) async {
  final s = AppStrings.of(context);
  final result = await pins.verify(pin);
  switch (result.status) {
    case PinStatus.ok:
      return true;
    case PinStatus.wrong:
      onMessage(s.wrongPin(result.attemptsLeft));
    case PinStatus.locked:
      onMessage(s.pinLocked(result.lockRemaining.inSeconds.clamp(1, 999)));
  }
  return false;
}

/// Title, optional help line, feedback message and the pad.
class PinEntry extends StatelessWidget {
  const PinEntry({
    super.key,
    required this.padKey,
    required this.title,
    required this.onCompleted,
    this.help,
    this.message,
    this.messageIsError = false,
  });

  final GlobalKey<PinPadState> padKey;
  final String title;
  final String? help;
  final String? message;
  final bool messageIsError;
  final ValueChanged<String> onCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(title, key: const Key('pin-title'), style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
        if (help != null) ...[
          const SizedBox(height: IlmSpace.sm),
          Text(
            help!,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium!.copyWith(color: IlmColors.inkMuted),
          ),
        ],
        const SizedBox(height: IlmSpace.md),
        SizedBox(
          height: 52,
          child: message == null
              ? null
              : Semantics(
                  liveRegion: true,
                  child: Text(
                    message!,
                    key: const Key('pin-message'),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium!.copyWith(
                      color: messageIsError ? IlmColors.rose : IlmColors.peacock,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
        ),
        PinPad(key: padKey, onCompleted: onCompleted),
      ],
    );
  }
}
