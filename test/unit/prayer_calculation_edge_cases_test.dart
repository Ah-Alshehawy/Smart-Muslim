import 'package:flutter_test/flutter_test.dart';
import 'package:smart_muslim/core/utils/prayer_calculator.dart';

void main() {
  group('Prayer Calculator Edge Cases & Boundary Tests', () {
    const cairoLat = 30.0444;
    const cairoLon = 31.2357;

    test('Midnight boundary: After Isha time, next prayer is tomorrow Fajr', () {
      final baseDate = DateTime(2026, 8, 24);
      final lateNightTime = DateTime(2026, 8, 24, 23, 45);

      final schedule = PrayerCalculatorService.calculateSchedule(
        latitude: cairoLat,
        longitude: cairoLon,
        date: baseDate,
        currentTime: lateNightTime,
        method: AppCalculationMethod.egyptian,
        juristic: AppJuristicMethod.standard,
      );

      expect(schedule.nextPrayerName, equals('fajr'));
      expect(schedule.nextPrayerTime.isAfter(lateNightTime), isTrue);
      expect(schedule.timeRemaining.inMinutes, greaterThan(0));
    });

    test('Pre-Fajr early morning: At 02:00 AM, next prayer is today Fajr', () {
      final baseDate = DateTime(2026, 8, 24);
      final earlyMorningTime = DateTime(2026, 8, 24, 2, 0);

      final schedule = PrayerCalculatorService.calculateSchedule(
        latitude: cairoLat,
        longitude: cairoLon,
        date: baseDate,
        currentTime: earlyMorningTime,
        method: AppCalculationMethod.egyptian,
        juristic: AppJuristicMethod.standard,
      );

      expect(schedule.nextPrayerName, equals('fajr'));
      expect(schedule.nextPrayerTime, equals(schedule.fajr));
      expect(schedule.timeRemaining.inMinutes, greaterThan(0));
    });

    test('Midday Dhuhr transition: Between Dhuhr and Asr, next prayer is Asr', () {
      final baseDate = DateTime(2026, 8, 24);
      final middaySchedule = PrayerCalculatorService.calculateSchedule(
        latitude: cairoLat,
        longitude: cairoLon,
        date: baseDate,
        method: AppCalculationMethod.egyptian,
      );

      final timeAfterDhuhr = middaySchedule.dhuhr.add(const Duration(minutes: 15));

      final schedule = PrayerCalculatorService.calculateSchedule(
        latitude: cairoLat,
        longitude: cairoLon,
        date: baseDate,
        currentTime: timeAfterDhuhr,
        method: AppCalculationMethod.egyptian,
      );

      expect(schedule.nextPrayerName, equals('asr'));
      expect(schedule.nextPrayerTime, equals(schedule.asr));
    });

    test('Manual minute adjustments are applied accurately', () {
      final testDate = DateTime(2026, 8, 24);

      final baseSchedule = PrayerCalculatorService.calculateSchedule(
        latitude: cairoLat,
        longitude: cairoLon,
        date: testDate,
        method: AppCalculationMethod.egyptian,
      );

      const adjustments = PrayerAdjustments(
        fajr: 3,
        maghrib: 2,
        isha: -4,
      );

      final adjustedSchedule = PrayerCalculatorService.calculateSchedule(
        latitude: cairoLat,
        longitude: cairoLon,
        date: testDate,
        method: AppCalculationMethod.egyptian,
        adjustments: adjustments,
      );

      expect(
        adjustedSchedule.fajr.difference(baseSchedule.fajr).inMinutes,
        equals(3),
      );
      expect(
        adjustedSchedule.maghrib.difference(baseSchedule.maghrib).inMinutes,
        equals(2),
      );
      expect(
        adjustedSchedule.isha.difference(baseSchedule.isha).inMinutes,
        equals(-4),
      );
    });

    test('Extreme high-latitude location (Reykjavik, Iceland) calculates valid non-crashing schedule', () {
      final testDate = DateTime(2026, 6, 21);
      final schedule = PrayerCalculatorService.calculateSchedule(
        latitude: 64.1466,
        longitude: -21.9426,
        date: testDate,
        method: AppCalculationMethod.muslimWorldLeague,
        highLatitudeRule: AppHighLatitudeRule.twilightAngle,
      );

      expect(schedule.fajr.isBefore(schedule.sunrise), isTrue);
      expect(schedule.sunrise.isBefore(schedule.dhuhr), isTrue);
      expect(schedule.dhuhr.isBefore(schedule.maghrib), isTrue);
    });
  });
}
