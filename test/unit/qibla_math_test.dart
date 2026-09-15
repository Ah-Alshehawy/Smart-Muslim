import 'package:flutter_test/flutter_test.dart';
import 'package:smart_muslim/core/utils/qibla_math.dart';

void main() {
  group('Qibla Math Calculation Tests', () {
    test('1. Mathematical bearing: Cairo, Egypt should be approx 136.5 degrees', () {
      final bearing = QiblaMath.calculateQiblaBearing(30.0444, 31.2357);
      expect(bearing, closeTo(136.5, 1.5));
    });

    test('2. Mathematical bearing: Makkah itself should be 0 degrees', () {
      final bearing = QiblaMath.calculateQiblaBearing(21.4225, 39.8262);
      expect(bearing, closeTo(0.0, 2.0));
    });

    test('3. Mathematical bearing: London, UK should be approx 118.9 degrees', () {
      final bearing = QiblaMath.calculateQiblaBearing(51.5074, -0.1278);
      expect(bearing, closeTo(118.9, 1.5));
    });

    test('4. Mathematical bearing: New York, USA should be approx 58.5 degrees', () {
      final bearing = QiblaMath.calculateQiblaBearing(40.7128, -74.0060);
      expect(bearing, closeTo(58.5, 1.5));
    });

    test('5. Mathematical bearing: Tokyo, Japan should be approx 293.0 degrees', () {
      final bearing = QiblaMath.calculateQiblaBearing(35.6762, 139.6503);
      expect(bearing, closeTo(293.0, 2.0));
    });

    test('6. Location change recalculates Qibla bearing correctly', () {
      final cairoBearing = QiblaMath.calculateQiblaBearing(30.0444, 31.2357);
      final tokyoBearing = QiblaMath.calculateQiblaBearing(35.6762, 139.6503);
      expect(cairoBearing, isNot(equals(tokyoBearing)));
      expect((cairoBearing - tokyoBearing).abs() > 50, isTrue);
    });
  });

  group('Angular Normalization & Shortest Angle Tests', () {
    test('359° -> 1° should be +2° (clockwise shortest turn)', () {
      final delta = QiblaMath.calculateShortestAngle(1.0, 359.0);
      expect(delta, closeTo(2.0, 0.001));
    });

    test('1° -> 359° should be -2° (counter-clockwise shortest turn)', () {
      final delta = QiblaMath.calculateShortestAngle(359.0, 1.0);
      expect(delta, closeTo(-2.0, 0.001));
    });

    test('normalize360 normalizes negative and >360 angles', () {
      expect(QiblaMath.normalize360(-10.0), closeTo(350.0, 0.001));
      expect(QiblaMath.normalize360(370.0), closeTo(10.0, 0.001));
      expect(QiblaMath.normalize360(0.0), closeTo(0.0, 0.001));
      expect(QiblaMath.normalize360(360.0), closeTo(0.0, 0.001));
    });

    test('Magnetic Declination model produces valid angles', () {
      final cairoDec = QiblaMath.calculateMagneticDeclination(30.0444, 31.2357);
      expect(cairoDec, closeTo(5.0, 3.0)); // Cairo is East (+4° to +7°)

      final nyDec = QiblaMath.calculateMagneticDeclination(40.7128, -74.0060);
      expect(nyDec < 0, isTrue); // New York is West (-10° to -14°)
    });

    test('convertMagneticToTrueHeading properly adds declination', () {
      final trueHeading = QiblaMath.convertMagneticToTrueHeading(358.0, 4.0);
      expect(trueHeading, closeTo(2.0, 0.001));
    });
  });

  group('3D Tilt-Compensated Sensor Heading Tests', () {
    test('Flat phone pointing North (ax=0, ay=0, az=9.8, mx=0, my=20, mz=-40) -> 0°', () {
      final heading = QiblaMath.calculateTiltCompensatedHeading(
        ax: 0,
        ay: 0,
        az: 9.8,
        mx: 0,
        my: 20,
        mz: -40,
      );
      expect(heading, closeTo(0.0, 0.5));
    });

    test('Flat phone pointing East (ax=0, ay=0, az=9.8, mx=-20, my=0, mz=-40) -> 90°', () {
      final heading = QiblaMath.calculateTiltCompensatedHeading(
        ax: 0,
        ay: 0,
        az: 9.8,
        mx: -20,
        my: 0,
        mz: -40,
      );
      expect(heading, closeTo(90.0, 0.5));
    });

    test('Flat phone pointing South -> 180°', () {
      final heading = QiblaMath.calculateTiltCompensatedHeading(
        ax: 0,
        ay: 0,
        az: 9.8,
        mx: 0,
        my: -20,
        mz: -40,
      );
      expect(heading, closeTo(180.0, 0.5));
    });

    test('Flat phone pointing West -> 270°', () {
      final heading = QiblaMath.calculateTiltCompensatedHeading(
        ax: 0,
        ay: 0,
        az: 9.8,
        mx: 20,
        my: 0,
        mz: -40,
      );
      expect(heading, closeTo(270.0, 0.5));
    });

    test('Tilted/Rolled phone facing North preserves 0° heading without dip angle error', () {
      // 30 degree roll: ax = 4.9, ay = 0, az = 8.487, mx = -20.0, my = 20.0, mz = -34.64
      final heading = QiblaMath.calculateTiltCompensatedHeading(
        ax: 4.9,
        ay: 0.0,
        az: 8.487,
        mx: -20.0,
        my: 20.0,
        mz: -34.64,
      );
      expect(heading, closeTo(0.0, 1.0));
    });
  });

  group('Rotation Delta Matrix Tests (0°, 90°, 180°, 270°)', () {
    final angles = [0.0, 90.0, 180.0, 270.0];

    for (final qibla in angles) {
      for (final device in angles) {
        test('Qibla: $qibla°, Device: $device° produces expected shortest delta', () {
          final delta = QiblaMath.calculateRelativeQiblaAngle(
            qiblaBearing: qibla,
            trueHeading: device,
          );
          // Expected shortest difference
          double expected = (qibla - device) % 360.0;
          if (expected > 180.0) expected -= 360.0;
          if (expected < -180.0) expected += 360.0;
          expect(delta, closeTo(expected, 0.001));
          expect(delta >= -180.0 && delta <= 180.0, isTrue);
        });
      }
    }
  });
}
