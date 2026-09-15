import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'المسلم الذكي'**
  String get appName;

  /// No description provided for @appSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'صَدَقَةٌ جَارِيَةٌ ... نَسْأَلُكُمُ الدُّعَاءَ'**
  String get appSubtitle;

  /// No description provided for @prayerTimes.
  ///
  /// In ar, this message translates to:
  /// **'مواقيت الصلاة'**
  String get prayerTimes;

  /// No description provided for @nextPrayer.
  ///
  /// In ar, this message translates to:
  /// **'الصلاة القادمة'**
  String get nextPrayer;

  /// No description provided for @remainingTime.
  ///
  /// In ar, this message translates to:
  /// **'المتبقي على صلاة {prayerName}'**
  String remainingTime(String prayerName);

  /// No description provided for @fajr.
  ///
  /// In ar, this message translates to:
  /// **'الفجر'**
  String get fajr;

  /// No description provided for @sunrise.
  ///
  /// In ar, this message translates to:
  /// **'الشروق'**
  String get sunrise;

  /// No description provided for @dhuhr.
  ///
  /// In ar, this message translates to:
  /// **'الظهر'**
  String get dhuhr;

  /// No description provided for @asr.
  ///
  /// In ar, this message translates to:
  /// **'العصر'**
  String get asr;

  /// No description provided for @maghrib.
  ///
  /// In ar, this message translates to:
  /// **'المغرب'**
  String get maghrib;

  /// No description provided for @isha.
  ///
  /// In ar, this message translates to:
  /// **'العشاء'**
  String get isha;

  /// No description provided for @qibla.
  ///
  /// In ar, this message translates to:
  /// **'القبلة'**
  String get qibla;

  /// No description provided for @settings.
  ///
  /// In ar, this message translates to:
  /// **'الإعدادات'**
  String get settings;

  /// No description provided for @calculationMethod.
  ///
  /// In ar, this message translates to:
  /// **'طريقة الحساب'**
  String get calculationMethod;

  /// No description provided for @juristicMethod.
  ///
  /// In ar, this message translates to:
  /// **'المذهب الفقهي (العصر)'**
  String get juristicMethod;

  /// No description provided for @standardAsr.
  ///
  /// In ar, this message translates to:
  /// **'الجمهور (الشافعي والمالكي والحنبلي)'**
  String get standardAsr;

  /// No description provided for @hanafiAsr.
  ///
  /// In ar, this message translates to:
  /// **'المذهب الحنفي'**
  String get hanafiAsr;

  /// No description provided for @location.
  ///
  /// In ar, this message translates to:
  /// **'الموقع الجغرافي'**
  String get location;

  /// No description provided for @autoLocation.
  ///
  /// In ar, this message translates to:
  /// **'التحديد التلقائي (GPS)'**
  String get autoLocation;

  /// No description provided for @manualLocation.
  ///
  /// In ar, this message translates to:
  /// **'اختيار المدينة يدويًا'**
  String get manualLocation;

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات والأذان'**
  String get notifications;

  /// No description provided for @fullAdhan.
  ///
  /// In ar, this message translates to:
  /// **'الأذان كاملًا'**
  String get fullAdhan;

  /// No description provided for @takbeerOnly.
  ///
  /// In ar, this message translates to:
  /// **'التكبير فقط'**
  String get takbeerOnly;

  /// No description provided for @silentAlert.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه صامت'**
  String get silentAlert;

  /// No description provided for @exactAlarmPermission.
  ///
  /// In ar, this message translates to:
  /// **'إذن المنبه الدقيق'**
  String get exactAlarmPermission;

  /// No description provided for @exactAlarmExplanation.
  ///
  /// In ar, this message translates to:
  /// **'يحتاج التطبيق إلى إذن المنبه الدقيق لتشغيل الأذان في موعده تمامًا حتى عند قفل الشاشة.'**
  String get exactAlarmExplanation;

  /// No description provided for @grantPermission.
  ///
  /// In ar, this message translates to:
  /// **'منح الإذن'**
  String get grantPermission;

  /// No description provided for @offlineMode.
  ///
  /// In ar, this message translates to:
  /// **'وضع عدم الاتصال بالإنترنت'**
  String get offlineMode;

  /// No description provided for @qiblaDirection.
  ///
  /// In ar, this message translates to:
  /// **'اتجاه القبلة: {degrees}° من الشمال'**
  String qiblaDirection(String degrees);

  /// No description provided for @tasbihAlertVibration.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه بالاهتزاز'**
  String get tasbihAlertVibration;

  /// No description provided for @tasbihAlertSound.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه صوتي'**
  String get tasbihAlertSound;

  /// No description provided for @tasbihAlertSoundAndVibration.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه صوتي واهتزاز'**
  String get tasbihAlertSoundAndVibration;

  /// No description provided for @tasbihAlertOff.
  ///
  /// In ar, this message translates to:
  /// **'التنبيه متوقف'**
  String get tasbihAlertOff;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
