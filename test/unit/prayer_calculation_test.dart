import 'package:flutter_test/flutter_test.dart';
import 'package:smart_muslim/core/utils/prayer_calculator.dart';

void main() {
  group('Prayer Calculator Astronomical Tests', () {
    test('Calculate schedule for Cairo, Egypt on fixed date', () {
      final testDate = DateTime(2026, 8, 24);
      final schedule = PrayerCalculatorService.calculateSchedule(
        latitude: 30.0444,
        longitude: 31.2357,
        date: testDate,
        method: AppCalculationMethod.egyptian,
        juristic: AppJuristicMethod.standard,
      );

      expect(schedule.fajr.isBefore(schedule.sunrise), isTrue);
      expect(schedule.sunrise.isBefore(schedule.dhuhr), isTrue);
      expect(schedule.dhuhr.isBefore(schedule.asr), isTrue);
      expect(schedule.asr.isBefore(schedule.maghrib), isTrue);
      expect(schedule.maghrib.isBefore(schedule.isha), isTrue);
    });

    test('Calculate schedule for Makkah Al-Mukarramah using Umm Al-Qura', () {
      final testDate = DateTime(2026, 9, 2);
      final schedule = PrayerCalculatorService.calculateSchedule(
        latitude: 21.4225,
        longitude: 39.8262,
        date: testDate,
        method: AppCalculationMethod.ummAlQura,
        juristic: AppJuristicMethod.standard,
      );

      expect(schedule.fajr.isBefore(schedule.sunrise), isTrue);
      expect(schedule.sunrise.isBefore(schedule.dhuhr), isTrue);
      expect(schedule.dhuhr.isBefore(schedule.asr), isTrue);
      expect(schedule.asr.isBefore(schedule.maghrib), isTrue);
      expect(schedule.maghrib.isBefore(schedule.isha), isTrue);
    });

    test('Hanafi Asr should be strictly after Standard Asr', () {
      final testDate = DateTime(2026, 8, 24);

      final standardSchedule = PrayerCalculatorService.calculateSchedule(
        latitude: 30.0444,
        longitude: 31.2357,
        date: testDate,
        method: AppCalculationMethod.egyptian,
        juristic: AppJuristicMethod.standard,
      );

      final hanafiSchedule = PrayerCalculatorService.calculateSchedule(
        latitude: 30.0444,
        longitude: 31.2357,
        date: testDate,
        method: AppCalculationMethod.egyptian,
        juristic: AppJuristicMethod.hanafi,
      );

      expect(hanafiSchedule.asr.isAfter(standardSchedule.asr), isTrue);
    });

    test('High Latitude calculations for London/Oslo with rule', () {
      final testDate = DateTime(2026, 6, 21); // Summer solstice
      final schedule = PrayerCalculatorService.calculateSchedule(
        latitude: 51.5074,
        longitude: -0.1278,
        date: testDate,
        method: AppCalculationMethod.muslimWorldLeague,
        highLatitudeRule: AppHighLatitudeRule.seventhOfTheNight,
      );

      expect(schedule.fajr.isBefore(schedule.sunrise), isTrue);
      expect(schedule.maghrib.isBefore(schedule.isha), isTrue);
    });
    test('France (UOIF) uses 12° twilight angles, not zero', () {
      final schedule = PrayerCalculatorService.calculateSchedule(
        latitude: 48.8566,
        longitude: 2.3522,
        date: DateTime(2026, 3, 20),
        method: AppCalculationMethod.france,
        juristic: AppJuristicMethod.standard,
      );

      // With 0° angles Fajr collapses onto sunrise and Isha onto Maghrib.
      expect(schedule.sunrise.difference(schedule.fajr).inMinutes, greaterThan(45));
      expect(schedule.isha.difference(schedule.maghrib).inMinutes, greaterThan(45));
    });
  });
}
