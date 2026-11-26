import 'package:material_ui/material_ui.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/session/app_session.dart';
import '../../core/theme/tokens.g.dart';
import '../../shared/widgets/ilm_button.dart';
import '../../shared/widgets/truck_art.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, this.onToggleLanguage});

  final VoidCallback? onToggleLanguage;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  String? _errorKey;
  bool _busy = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _busy = true;
      _errorKey = null;
    });
    final error = await SessionScope.read(context).signIn(_email.text, _password.text);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _errorKey = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final theme = Theme.of(context);
    InputDecoration field(String label) => InputDecoration(
          labelText: label,
          filled: true,
          fillColor: IlmColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(IlmRadius.md),
          ),
        );

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: IlmColors.aubergine,
              padding: const EdgeInsets.fromLTRB(IlmSpace.xl, IlmSpace.xl, IlmSpace.md, IlmSpace.lg),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.appName,
                          style: theme.textTheme.displaySmall!.copyWith(color: IlmColors.marigold),
                        ),
                        Text(
                          s.appTagline,
                          style: theme.textTheme.bodyMedium!.copyWith(color: IlmColors.white),
                        ),
                      ],
                    ),
                  ),
                  LanguageButton(onPressed: widget.onToggleLanguage),
                ],
              ),
            ),
            const TruckArtBand(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(IlmSpace.xl),
                children: [
                  Text(s.signIn, style: theme.textTheme.headlineSmall),
                  const SizedBox(height: IlmSpace.lg),
                  TextField(
                    key: const Key('email-field'),
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                    autofillHints: const [AutofillHints.email],
                    decoration: field(s.email),
                  ),
                  const SizedBox(height: IlmSpace.md),
                  TextField(
                    key: const Key('password-field'),
                    controller: _password,
                    obscureText: true,
                    textDirection: TextDirection.ltr,
                    autofillHints: const [AutofillHints.password],
                    decoration: field(s.password),
                    onSubmitted: (_) => _submit(),
                  ),
                  if (_errorKey != null) ...[
                    const SizedBox(height: IlmSpace.md),
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        s.text(_errorKey!),
                        key: const Key('sign-in-error'),
                        style: theme.textTheme.bodyMedium!.copyWith(color: IlmColors.rose),
                      ),
                    ),
                  ],
                  const SizedBox(height: IlmSpace.xl),
                  IlmButton(
                    key: const Key('sign-in-button'),
                    label: s.signIn,
                    onPressed: _busy ? null : _submit,
                  ),
                  const SizedBox(height: IlmSpace.lg),
                  Text(
                    s.signInHint,
                    style: theme.textTheme.bodySmall!.copyWith(color: IlmColors.inkMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "اردو" / "English" switch used on teacher screens.
class LanguageButton extends StatelessWidget {
  const LanguageButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return TextButton(
      key: const Key('toggle-language'),
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: IlmColors.white,
        minimumSize: const Size(IlmSize.minTouchTarget, IlmSize.minTouchTarget),
      ),
      child: Text(
        s.isUrdu ? 'English' : 'اردو',
        style: TextStyle(
          fontFamily: s.isUrdu ? IlmFonts.body : IlmFonts.urdu,
          fontSize: 16,
          color: IlmColors.white,
        ),
      ),
    );
  }
}
