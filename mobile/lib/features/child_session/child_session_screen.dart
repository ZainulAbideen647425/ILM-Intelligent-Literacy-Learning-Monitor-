import 'package:material_ui/material_ui.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/models/models.dart';
import '../../core/session/app_session.dart';
import '../../core/theme/tokens.g.dart';
import '../../shared/widgets/bead_progress.dart';
import '../../shared/widgets/ilm_button.dart';
import '../../shared/widgets/pin_pad.dart';
import '../../shared/widgets/truck_art.dart';
import '../auth/pin_screen.dart';

/// Child mode. The system back button and gestures cannot leave this screen;
/// only the teacher can, with the PIN (lock icon, top corner).
///
/// F2 delivers the locked shell and step flow. F3 fills each step with the
/// real writing canvas and reading recorder.
class ChildSessionScreen extends StatefulWidget {
  const ChildSessionScreen({super.key, required this.student, this.steps = 6});

  final Child student;
  final int steps;

  @override
  State<ChildSessionScreen> createState() => _ChildSessionScreenState();
}

class _ChildSessionScreenState extends State<ChildSessionScreen> {
  int _step = 0;

  void _next() {
    if (_step < widget.steps - 1) {
      setState(() => _step++);
    } else {
      Navigator.of(context).pop(true);
    }
  }

  Future<void> _requestExit() async {
    final exit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _TeacherExitDialog(),
    );
    if (exit == true && mounted) Navigator.of(context).pop(false);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _requestExit();
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(IlmSpace.lg),
            child: Column(
              children: [
                Row(
                  children: [
                    BeadProgress(current: _step, total: widget.steps),
                    const Spacer(),
                    IconButton(
                      key: const Key('teacher-exit'),
                      tooltip: s.teacherExit,
                      icon: const Icon(Icons.lock_outline, color: IlmColors.inkMuted),
                      onPressed: _requestExit,
                    ),
                  ],
                ),
                const SizedBox(height: IlmSpace.md),
                Text(
                  s.handTo(widget.student.firstName),
                  key: const Key('hand-to'),
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: IlmSpace.md),
                Expanded(
                  child: TruckArtFrame(
                    child: Align(
                      alignment: AlignmentDirectional.bottomStart,
                      child: Padding(
                        padding: const EdgeInsets.all(IlmSpace.md),
                        child: Text(
                          s.useYourFinger,
                          style: theme.textTheme.bodySmall!.copyWith(color: IlmColors.inkMuted),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: IlmSpace.lg),
                Row(
                  children: [
                    Expanded(
                      child: IlmButton(
                        key: const Key('again'),
                        label: s.again,
                        variant: IlmButtonVariant.secondary,
                        onPressed: () {},
                      ),
                    ),
                    const SizedBox(width: IlmSpace.md),
                    Expanded(
                      child: IlmButton(
                        key: const Key('done'),
                        label: s.done,
                        icon: Icons.check,
                        onPressed: _next,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TeacherExitDialog extends StatefulWidget {
  const _TeacherExitDialog();

  @override
  State<_TeacherExitDialog> createState() => _TeacherExitDialogState();
}

class _TeacherExitDialogState extends State<_TeacherExitDialog> {
  final _pad = GlobalKey<PinPadState>();
  String? _message;

  Future<void> _check(String pin) async {
    final ok = await verifyPinWithFeedback(
      context: context,
      pins: SessionScope.read(context).pins,
      pin: pin,
      onMessage: (m) => setState(() => _message = m),
    );
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop(true);
    } else {
      _pad.currentState?.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Dialog(
      backgroundColor: IlmColors.cream,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(IlmSpace.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PinEntry(
              padKey: _pad,
              title: s.exitChildMode,
              message: _message,
              messageIsError: true,
              onCompleted: _check,
            ),
            const SizedBox(height: IlmSpace.md),
            TextButton(
              key: const Key('cancel-exit'),
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(s.cancel),
            ),
          ],
        ),
      ),
    );
  }
}
