import 'package:flutter/widgets.dart';

/// All user-facing text in English and Urdu.
///
/// Language rules (from the Direction B design):
/// * Never label a child "dyslexic" or "weak".
/// * "Diagnosis" appears only in the screening disclaimer.
/// * No scores are shown to children.
///
/// `test/core/app_strings_test.dart` enforces these rules and checks that
/// both languages have the same keys.
class AppStrings {
  const AppStrings(this.locale);

  final Locale locale;

  static const List<Locale> supportedLocales = [Locale('en'), Locale('ur')];

  static const LocalizationsDelegate<AppStrings> delegate =
      _AppStringsDelegate();

  static AppStrings of(BuildContext context) {
    final strings = Localizations.of<AppStrings>(context, AppStrings);
    assert(strings != null, 'AppStrings.delegate is missing from the app.');
    return strings!;
  }

  /// Keys whose text may contain the word "diagnosis".
  static const Set<String> disclaimerKeys = {'screeningNotDiagnosis'};

  static const Map<String, Map<String, String>> values = {
    'en': {
      'appName': 'ILM',
      'appTagline': 'Intelligent Literacy & Learning Monitor',
      'signalFollowUp': 'Follow up',
      'signalWatch': 'Watch',
      'signalAllClear': 'All clear',
      'signalNotYet': 'Not yet',
      'filterEveryone': 'Everyone',
      'needsConsent': 'Needs consent',
      'nextUp': 'Next up',
      'savedOffline': 'saved offline',
      'ofTotal': 'of',
      'startWith': 'Start with',
      'writeThis': 'Write this',
      'useYourFinger': 'Use your finger',
      'again': 'Again',
      'done': 'Done',
      'playSound': 'Play the sound',
      'teacherOnly': 'Teacher only',
      'screeningNotDiagnosis':
          'Worth a closer look by a specialist. A screening, not a diagnosis.',
      'writing': 'Writing',
      'reading': 'Reading',
      'levelMany': 'Many',
      'levelSome': 'Some',
      'levelFew': 'Few',
      'addToReferralList': 'Add to referral list',
      'rescreenLater': 'Rescreen later',
      'addNote': 'Add a note',
      'stepOf': 'Step {current} of {total}',
      'screenedProgress': '{done} of {total} screened',
      'componentGallery': 'Component gallery',
    },
    'ur': {
      'appName': 'علم',
      'appTagline': 'ذہین خواندگی اور تعلیمی نگرانی',
      'signalFollowUp': 'مزید جانچ تجویز',
      'signalWatch': 'نظر رکھیں',
      'signalAllClear': 'سب ٹھیک',
      'signalNotYet': 'ابھی نہیں',
      'filterEveryone': 'سب بچے',
      'needsConsent': 'اجازت درکار',
      'nextUp': 'اگلی باری',
      'savedOffline': 'آف لائن محفوظ',
      'ofTotal': 'میں سے',
      'startWith': 'شروع کریں:',
      'writeThis': 'یہ لکھیں',
      'useYourFinger': 'اپنی انگلی سے لکھیں',
      'again': 'دوبارہ',
      'done': 'مکمل',
      'playSound': 'آواز سنیں',
      'teacherOnly': 'صرف استاد کے لیے',
      'screeningNotDiagnosis':
          'ماہر سے مزید جانچ مناسب ہے۔ یہ اسکریننگ ہے، تشخیص نہیں۔',
      'writing': 'لکھائی',
      'reading': 'پڑھائی',
      'levelMany': 'زیادہ',
      'levelSome': 'کچھ',
      'levelFew': 'کم',
      'addToReferralList': 'ریفرل فہرست میں شامل کریں',
      'rescreenLater': 'بعد میں دوبارہ جانچ',
      'addNote': 'نوٹ لکھیں',
      'stepOf': 'مرحلہ {current} از {total}',
      'screenedProgress': '{total} میں سے {done} کی جانچ مکمل',
      'componentGallery': 'اجزاء کی نمائش',
    },
  };

  bool get isUrdu => locale.languageCode == 'ur';

  String text(String key, [Map<String, Object> args = const {}]) {
    final table = values[locale.languageCode] ?? values['en']!;
    var result = table[key] ?? values['en']![key] ?? key;
    args.forEach((name, value) {
      result = result.replaceAll('{$name}', '$value');
    });
    return result;
  }

  String get appName => text('appName');
  String get appTagline => text('appTagline');
  String get signalFollowUp => text('signalFollowUp');
  String get signalWatch => text('signalWatch');
  String get signalAllClear => text('signalAllClear');
  String get signalNotYet => text('signalNotYet');
  String get filterEveryone => text('filterEveryone');
  String get needsConsent => text('needsConsent');
  String get nextUp => text('nextUp');
  String get savedOffline => text('savedOffline');
  String get ofTotal => text('ofTotal');
  String get startWith => text('startWith');
  String get writeThis => text('writeThis');
  String get useYourFinger => text('useYourFinger');
  String get again => text('again');
  String get done => text('done');
  String get playSound => text('playSound');
  String get teacherOnly => text('teacherOnly');
  String get screeningNotDiagnosis => text('screeningNotDiagnosis');
  String get writing => text('writing');
  String get reading => text('reading');
  String get levelMany => text('levelMany');
  String get levelSome => text('levelSome');
  String get levelFew => text('levelFew');
  String get addToReferralList => text('addToReferralList');
  String get rescreenLater => text('rescreenLater');
  String get addNote => text('addNote');
  String get componentGallery => text('componentGallery');

  String stepOf(int current, int total) =>
      text('stepOf', {'current': current, 'total': total});

  String screenedProgress(int done, int total) =>
      text('screenedProgress', {'done': done, 'total': total});
}

class _AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const _AppStringsDelegate();

  @override
  bool isSupported(Locale locale) => AppStrings.supportedLocales.any(
    (l) => l.languageCode == locale.languageCode,
  );

  @override
  Future<AppStrings> load(Locale locale) async => AppStrings(locale);

  @override
  bool shouldReload(_AppStringsDelegate old) => false;
}
