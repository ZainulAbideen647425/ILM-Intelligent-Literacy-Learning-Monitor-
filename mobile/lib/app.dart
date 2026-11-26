import 'package:material_ui/material_ui.dart';
import 'package:cupertino_ui/cupertino_ui.dart'
    show GlobalCupertinoLocalizations;
import 'package:flutter_localizations/flutter_localizations.dart'
    show GlobalWidgetsLocalizations;

import 'core/l10n/app_strings.dart';
import 'core/security/pin_service.dart';
import 'core/session/app_session.dart';
import 'core/theme/app_theme.dart';
import 'data/auth_repository.dart';
import 'data/screening_repository.dart';
import 'features/auth/pin_screen.dart';
import 'features/auth/sign_in_screen.dart';
import 'features/register/class_register_screen.dart';

/// Root widget. Holds the current language (Urdu switches the whole app to
/// right-to-left with Gulzar) and the session, which decides the home screen.
class IlmApp extends StatefulWidget {
  const IlmApp({
    super.key,
    this.initialLocale = const Locale('en'),
    this.session,
  });

  final Locale initialLocale;

  /// Injected in tests; production builds the real dependencies.
  final AppSession? session;

  @override
  State<IlmApp> createState() => _IlmAppState();
}

class _IlmAppState extends State<IlmApp> {
  late Locale _locale = widget.initialLocale;
  late final AppSession _session = widget.session ??
      AppSession(
        auth: const MockAuthRepository(),
        pins: PinService(SecurePinStore()),
        screening: MockScreeningRepository(),
      );

  @override
  void dispose() {
    if (widget.session == null) _session.dispose();
    super.dispose();
  }

  void _toggleLocale() => setState(() {
        _locale = _locale.languageCode == 'ur' ? const Locale('en') : const Locale('ur');
      });

  @override
  Widget build(BuildContext context) {
    return SessionScope(
      session: _session,
      child: MaterialApp(
        title: 'ILM',
        debugShowCheckedModeBanner: false,
        locale: _locale,
        supportedLocales: AppStrings.supportedLocales,
        localizationsDelegates: const [
          AppStrings.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: AppTheme.light(locale: _locale),
        home: _Home(onToggleLanguage: _toggleLocale),
      ),
    );
  }
}

class _Home extends StatelessWidget {
  const _Home({required this.onToggleLanguage});

  final VoidCallback onToggleLanguage;

  @override
  Widget build(BuildContext context) {
    final session = SessionScope.of(context);
    return switch (session.stage) {
      SessionStage.signedOut => SignInScreen(onToggleLanguage: onToggleLanguage),
      SessionStage.createPin => const PinScreen(key: ValueKey('pin-create'), mode: PinMode.create),
      SessionStage.locked => const PinScreen(key: ValueKey('pin-unlock'), mode: PinMode.unlock),
      SessionStage.unlocked => ClassRegisterScreen(onToggleLanguage: onToggleLanguage),
    };
  }
}
