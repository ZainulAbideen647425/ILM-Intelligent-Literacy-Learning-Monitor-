import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/l10n/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/gallery/component_gallery_screen.dart';

/// Root widget. Holds the current language; Urdu switches the whole app to
/// right-to-left with Gulzar (Nastaliq) text.
class IlmApp extends StatefulWidget {
  const IlmApp({super.key, this.initialLocale = const Locale('en')});

  final Locale initialLocale;

  @override
  State<IlmApp> createState() => _IlmAppState();
}

class _IlmAppState extends State<IlmApp> {
  late Locale _locale = widget.initialLocale;

  void _toggleLocale() => setState(() {
        _locale = _locale.languageCode == 'ur'
            ? const Locale('en')
            : const Locale('ur');
      });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
      home: ComponentGalleryScreen(onToggleLanguage: _toggleLocale),
    );
  }
}
