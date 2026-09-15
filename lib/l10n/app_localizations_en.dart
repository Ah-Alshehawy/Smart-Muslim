// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Smart Muslim';

  @override
  String get appSubtitle =>
      'Ongoing Charity (Sadaqah Jariyah) ... We ask for your prayers';

  @override
  String get prayerTimes => 'Prayer Times';

  @override
  String get nextPrayer => 'Next Prayer';

  @override
  String remainingTime(String prayerName) {
    return 'Time remaining until $prayerName';
  }

  @override
  String get fajr => 'Fajr';

  @override
  String get sunrise => 'Sunrise';

  @override
  String get dhuhr => 'Dhuhr';

  @override
  String get asr => 'Asr';

  @override
  String get maghrib => 'Maghrib';

  @override
  String get isha => 'Isha';

  @override
  String get qibla => 'Qibla';

  @override
  String get settings => 'Settings';

  @override
  String get calculationMethod => 'Calculation Method';

  @override
  String get juristicMethod => 'Juristic Method (Asr)';

  @override
  String get standardAsr => 'Standard (Shafi\'i, Maliki, Hanbali)';

  @override
  String get hanafiAsr => 'Hanafi';

  @override
  String get location => 'Location';

  @override
  String get autoLocation => 'Auto GPS Location';

  @override
  String get manualLocation => 'Select City Manually';

  @override
  String get notifications => 'Notifications & Adhan';

  @override
  String get fullAdhan => 'Full Adhan';

  @override
  String get takbeerOnly => 'Takbeer Only';

  @override
  String get silentAlert => 'Silent Alert';

  @override
  String get exactAlarmPermission => 'Exact Alarm Permission';

  @override
  String get exactAlarmExplanation =>
      'Exact alarm permission is required to play Adhan alerts on time even when your device is locked.';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get offlineMode => 'Offline Mode Active';

  @override
  String qiblaDirection(String degrees) {
    return 'Qibla Direction: $degrees° from North';
  }

  @override
  String get tasbihAlertVibration => 'Vibration Alert';

  @override
  String get tasbihAlertSound => 'Sound Alert';

  @override
  String get tasbihAlertSoundAndVibration => 'Sound and Vibration Alert';

  @override
  String get tasbihAlertOff => 'Alerts Disabled';
}
