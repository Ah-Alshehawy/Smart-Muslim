import 'package:adhan/adhan.dart';

enum AppCalculationMethod {
  egyptian,
  ummAlQura,
  muslimWorldLeague,
  karachi,
  dubai,
  qatar,
  kuwait,
  northAmerica,
  singapore,
  turkey,
  tehran,
  france,
}

enum AppJuristicMethod {
  standard, // Shafi'i, Maliki, Hanbali
  hanafi,
}

enum AppHighLatitudeRule {
  middleOfTheNight,
  seventhOfTheNight,
  twilightAngle,
}

class PrayerAdjustments {
  final int fajr;
  final int sunrise;
  final int dhuhr;
  final int asr;
  final int maghrib;
  final int isha;

  const PrayerAdjustments({
    this.fajr = 0,
    this.sunrise = 0,
    this.dhuhr = 0,
    this.asr = 0,
    this.maghrib = 0,
    this.isha = 0,
  });

  Map<String, int> toMap() => {
        'fajr': fajr,
        'sunrise': sunrise,
        'dhuhr': dhuhr,
        'asr': asr,
        'maghrib': maghrib,
        'isha': isha,
      };

  factory PrayerAdjustments.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const PrayerAdjustments();
    return PrayerAdjustments(
      fajr: map['fajr'] as int? ?? 0,
      sunrise: map['sunrise'] as int? ?? 0,
      dhuhr: map['dhuhr'] as int? ?? 0,
      asr: map['asr'] as int? ?? 0,
      maghrib: map['maghrib'] as int? ?? 0,
      isha: map['isha'] as int? ?? 0,
    );
  }
}

class PrayerScheduleResult {
  final DateTime fajr;
  final DateTime sunrise;
  final DateTime dhuhr;
  final DateTime asr;
  final DateTime maghrib;
  final DateTime isha;
  final String nextPrayerName;
  final DateTime nextPrayerTime;
  final Duration timeRemaining;

  const PrayerScheduleResult({
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.nextPrayerName,
    required this.nextPrayerTime,
    required this.timeRemaining,
  });
}

class PrayerCalculatorService {
  static PrayerScheduleResult calculateSchedule({
    required double latitude,
    required double longitude,
    required DateTime date,
    DateTime? currentTime,
    AppCalculationMethod method = AppCalculationMethod.egyptian,
    AppJuristicMethod juristic = AppJuristicMethod.standard,
    AppHighLatitudeRule highLatitudeRule = AppHighLatitudeRule.middleOfTheNight,
    PrayerAdjustments adjustments = const PrayerAdjustments(),
  }) {
    final coordinates = Coordinates(latitude, longitude);
    final dateComponents = DateComponents.from(date);

    final calculationParameters = _mapCalculationParameters(method);
    calculationParameters.madhab = juristic == AppJuristicMethod.hanafi
        ? Madhab.hanafi
        : Madhab.shafi;

    // High Latitude Rule
    switch (highLatitudeRule) {
      case AppHighLatitudeRule.middleOfTheNight:
        calculationParameters.highLatitudeRule = HighLatitudeRule.middle_of_the_night;
        break;
      case AppHighLatitudeRule.seventhOfTheNight:
        calculationParameters.highLatitudeRule = HighLatitudeRule.seventh_of_the_night;
        break;
      case AppHighLatitudeRule.twilightAngle:
        calculationParameters.highLatitudeRule = HighLatitudeRule.twilight_angle;
        break;
    }

    // Apply manual minute adjustments if configured
    calculationParameters.adjustments.fajr = adjustments.fajr;
    calculationParameters.adjustments.sunrise = adjustments.sunrise;
    calculationParameters.adjustments.dhuhr = adjustments.dhuhr;
    calculationParameters.adjustments.asr = adjustments.asr;
    calculationParameters.adjustments.maghrib = adjustments.maghrib;
    calculationParameters.adjustments.isha = adjustments.isha;

    final prayerTimes = PrayerTimes(coordinates, dateComponents, calculationParameters);

    final fajr = prayerTimes.fajr;
    final sunrise = prayerTimes.sunrise;
    final dhuhr = prayerTimes.dhuhr;
    final asr = prayerTimes.asr;
    final maghrib = prayerTimes.maghrib;
    final isha = prayerTimes.isha;

    final now = currentTime ?? DateTime.now();
    String nextName = 'fajr';
    DateTime nextTime = fajr;

    if (now.isBefore(fajr)) {
      nextName = 'fajr';
      nextTime = fajr;
    } else if (now.isBefore(sunrise)) {
      nextName = 'sunrise';
      nextTime = sunrise;
    } else if (now.isBefore(dhuhr)) {
      nextName = 'dhuhr';
      nextTime = dhuhr;
    } else if (now.isBefore(asr)) {
      nextName = 'asr';
      nextTime = asr;
    } else if (now.isBefore(maghrib)) {
      nextName = 'maghrib';
      nextTime = maghrib;
    } else if (now.isBefore(isha)) {
      nextName = 'isha';
      nextTime = isha;
    } else {
      // Next is tomorrow's Fajr
      final tomorrow = date.add(const Duration(days: 1));
      final tomorrowTimes = PrayerTimes(
        coordinates,
        DateComponents.from(tomorrow),
        calculationParameters,
      );
      nextName = 'fajr';
      nextTime = tomorrowTimes.fajr;
    }

    final duration = nextTime.difference(now);

    return PrayerScheduleResult(
      fajr: fajr,
      sunrise: sunrise,
      dhuhr: dhuhr,
      asr: asr,
      maghrib: maghrib,
      isha: isha,
      nextPrayerName: nextName,
      nextPrayerTime: nextTime,
      timeRemaining: duration.isNegative ? Duration.zero : duration,
    );
  }

  static CalculationParameters _mapCalculationParameters(AppCalculationMethod method) {
    switch (method) {
      case AppCalculationMethod.egyptian:
        return CalculationMethod.egyptian.getParameters();
      case AppCalculationMethod.ummAlQura:
        return CalculationMethod.umm_al_qura.getParameters();
      case AppCalculationMethod.muslimWorldLeague:
        return CalculationMethod.muslim_world_league.getParameters();
      case AppCalculationMethod.karachi:
        return CalculationMethod.karachi.getParameters();
      case AppCalculationMethod.dubai:
        return CalculationMethod.dubai.getParameters();
      case AppCalculationMethod.qatar:
        return CalculationMethod.qatar.getParameters();
      case AppCalculationMethod.kuwait:
        return CalculationMethod.kuwait.getParameters();
      case AppCalculationMethod.northAmerica:
        return CalculationMethod.north_america.getParameters();
      case AppCalculationMethod.singapore:
        return CalculationMethod.singapore.getParameters();
      case AppCalculationMethod.turkey:
        return CalculationMethod.turkey.getParameters();
      case AppCalculationMethod.tehran:
        return CalculationMethod.tehran.getParameters();
      case AppCalculationMethod.france:
        return CalculationMethod.other.getParameters();
    }
  }

  static String getMethodDisplayName(AppCalculationMethod method) {
    switch (method) {
      case AppCalculationMethod.egyptian:
        return 'الهيئة العامة المصرية للمساحة';
      case AppCalculationMethod.ummAlQura:
        return 'أم القرى (مكة المكرمة)';
      case AppCalculationMethod.muslimWorldLeague:
        return 'رابطة العالم الإسلامي';
      case AppCalculationMethod.karachi:
        return 'جامعة العلوم الإسلامية بكراتشي';
      case AppCalculationMethod.dubai:
        return 'دائرة الشؤون الإسلامية بدبي';
      case AppCalculationMethod.qatar:
        return 'وزارة الأوقاف والشؤون الإسلامية بقطر';
      case AppCalculationMethod.kuwait:
        return 'وزارة الأوقاف والشؤون الإسلامية بالكويت';
      case AppCalculationMethod.northAmerica:
        return 'الجمعية الإسلامية لشمال أمريكا (ISNA)';
      case AppCalculationMethod.singapore:
        return 'المجلس الإسلامي السنغافوري (MUIS)';
      case AppCalculationMethod.turkey:
        return 'رئاسة الشؤون الدينية بتركيا (Diyanet)';
      case AppCalculationMethod.tehran:
        return 'معهد الجيوفيزياء بجامعة طهران';
      case AppCalculationMethod.france:
        return 'اتحاد المنظمات الإسلامية بفرنسا (UOIF)';
    }
  }
}
