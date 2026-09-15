// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'المسلم الذكي';

  @override
  String get appSubtitle => 'صَدَقَةٌ جَارِيَةٌ ... نَسْأَلُكُمُ الدُّعَاءَ';

  @override
  String get prayerTimes => 'مواقيت الصلاة';

  @override
  String get nextPrayer => 'الصلاة القادمة';

  @override
  String remainingTime(String prayerName) {
    return 'المتبقي على صلاة $prayerName';
  }

  @override
  String get fajr => 'الفجر';

  @override
  String get sunrise => 'الشروق';

  @override
  String get dhuhr => 'الظهر';

  @override
  String get asr => 'العصر';

  @override
  String get maghrib => 'المغرب';

  @override
  String get isha => 'العشاء';

  @override
  String get qibla => 'القبلة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get calculationMethod => 'طريقة الحساب';

  @override
  String get juristicMethod => 'المذهب الفقهي (العصر)';

  @override
  String get standardAsr => 'الجمهور (الشافعي والمالكي والحنبلي)';

  @override
  String get hanafiAsr => 'المذهب الحنفي';

  @override
  String get location => 'الموقع الجغرافي';

  @override
  String get autoLocation => 'التحديد التلقائي (GPS)';

  @override
  String get manualLocation => 'اختيار المدينة يدويًا';

  @override
  String get notifications => 'التنبيهات والأذان';

  @override
  String get fullAdhan => 'الأذان كاملًا';

  @override
  String get takbeerOnly => 'التكبير فقط';

  @override
  String get silentAlert => 'تنبيه صامت';

  @override
  String get exactAlarmPermission => 'إذن المنبه الدقيق';

  @override
  String get exactAlarmExplanation =>
      'يحتاج التطبيق إلى إذن المنبه الدقيق لتشغيل الأذان في موعده تمامًا حتى عند قفل الشاشة.';

  @override
  String get grantPermission => 'منح الإذن';

  @override
  String get offlineMode => 'وضع عدم الاتصال بالإنترنت';

  @override
  String qiblaDirection(String degrees) {
    return 'اتجاه القبلة: $degrees° من الشمال';
  }

  @override
  String get tasbihAlertVibration => 'تنبيه بالاهتزاز';

  @override
  String get tasbihAlertSound => 'تنبيه صوتي';

  @override
  String get tasbihAlertSoundAndVibration => 'تنبيه صوتي واهتزاز';

  @override
  String get tasbihAlertOff => 'التنبيه متوقف';
}
