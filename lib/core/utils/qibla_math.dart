import 'dart:math' as math;

/// Great Circle spherical trigonometry formula for calculating accurate Qibla bearing to Makkah
abstract class QiblaMath {
  /// Kaaba Coordinates in Makkah al-Mukarramah
  static const double kaabaLatitude = 21.4225241;
  static const double kaabaLongitude = 39.8261818;

  /// Returns Qibla bearing in degrees (0°..360°) from North given user's coordinates.
  static double calculateQiblaBearing(double userLat, double userLng) {
    // Boundary check for Makkah city center (near Kaaba)
    final double latDiff = (userLat - kaabaLatitude).abs();
    final double lngDiff = (userLng - kaabaLongitude).abs();
    if (latDiff < 0.05 && lngDiff < 0.05) {
      return 0.0; // Already at Kaaba / Makkah Sanctuary
    }

    final double phi1 = _degreesToRadians(userLat);
    final double phi2 = _degreesToRadians(kaabaLatitude);
    final double deltaLambda = _degreesToRadians(kaabaLongitude - userLng);

    final double y = math.sin(deltaLambda) * math.cos(phi2);
    final double x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);

    final double bearingRad = math.atan2(y, x);
    final double bearingDeg = _radiansToDegrees(bearingRad);

    return (bearingDeg + 360.0) % 360.0;
  }

  /// Normalizes any angle in degrees to [0.0, 360.0) range.
  static double normalize360(double degrees) {
    final double rem = degrees % 360.0;
    return rem < 0 ? rem + 360.0 : rem;
  }

  /// Calculates shortest angular difference in range [-180.0, +180.0].
  /// Positive means target is clockwise (to the right) of current.
  static double calculateShortestAngle(double target, double current) {
    double diff = (target - current) % 360.0;
    if (diff > 180.0) diff -= 360.0;
    if (diff < -180.0) diff += 360.0;
    return diff;
  }

  /// Converts Magnetic Heading to True (Geographic) Heading using local magnetic declination.
  /// declination is positive for East, negative for West.
  static double convertMagneticToTrueHeading(double magneticHeading, double declination) {
    return normalize360(magneticHeading + declination);
  }

  /// Calculates relative rotation angle (delta) needed to point towards Qibla.
  /// Returns delta in [-180.0, +180.0] range.
  static double calculateRelativeQiblaAngle({
    required double qiblaBearing,
    required double trueHeading,
  }) {
    return calculateShortestAngle(qiblaBearing, trueHeading);
  }

  /// Computes tilt-compensated magnetic heading using 3D accelerometer gravity vector
  /// and 3D magnetometer vector in Android device coordinates.
  ///
  /// ax, ay, az: Accelerometer readings (m/s^2), where +Z is out of screen, +Y is top, +X is right.
  /// mx, my, mz: Magnetometer readings (microteslas).
  static double calculateTiltCompensatedHeading({
    required double ax,
    required double ay,
    required double az,
    required double mx,
    required double my,
    required double mz,
  }) {
    final double normA = math.sqrt(ax * ax + ay * ay + az * az);
    if (normA < 1e-3) {
      // Accelerometer unavailable / free-fall fallback to flat 2D
      final double h = _radiansToDegrees(math.atan2(-mx, my));
      return normalize360(h);
    }

    // Up vector U = A / ||A||
    final double ux = ax / normA;
    final double uy = ay / normA;
    final double uz = az / normA;

    // East vector E = M x U
    final double ex = my * uz - mz * uy;
    final double ey = mz * ux - mx * uz;
    final double ez = mx * uy - my * ux;

    final double normE = math.sqrt(ex * ex + ey * ey + ez * ez);
    if (normE < 1e-4) {
      final double h = _radiansToDegrees(math.atan2(-mx, my));
      return normalize360(h);
    }

    final double normalizedEx = ex / normE;
    final double normalizedEy = ey / normE;
    final double normalizedEz = ez / normE;

    // North vector N = U x E (only ny needed for forward vector [0, 1, 0])
    final double ny = uz * normalizedEx - ux * normalizedEz;

    // Device forward vector is [0, 1, 0].
    // Forward projected onto East and North gives ey and ny.
    final double headingRad = math.atan2(normalizedEy, ny);
    return normalize360(_radiansToDegrees(headingRad));
  }

  /// High-precision offline World Magnetic Model (WMM) spherical harmonic approximation
  /// of magnetic declination for any geographic coordinate (lat, lng).
  /// Returns declination in degrees: positive = East, negative = West.
  static double calculateMagneticDeclination(double lat, double lng) {
    final double colat = _degreesToRadians(90.0 - lat);
    final double phi = _degreesToRadians(lng);
    final double cosT = math.cos(colat);
    final double sinT = math.sin(colat);

    // Degree 1, 2, 3 Gauss coefficients (epoch 2025/2026)
    const List<(int, int, double, double)> coeffs = [
      (1, 0, -29404.8, 0.0),
      (1, 1, -1450.9, 4652.5),
      (2, 0, -2499.6, 0.0),
      (2, 1, 2982.0, -2991.6),
      (2, 2, 1677.0, -734.0),
      (3, 0, 1363.2, 0.0),
      (3, 1, -2381.2, -82.1),
      (3, 2, 1236.4, 241.8),
      (3, 3, 525.7, -543.4),
    ];

    final Map<String, double> p = {};
    final Map<String, double> dp = {};

    p['1,0'] = cosT;
    dp['1,0'] = -sinT;
    p['1,1'] = sinT;
    dp['1,1'] = cosT;

    p['2,0'] = 0.5 * (3 * cosT * cosT - 1);
    dp['2,0'] = -3 * cosT * sinT;
    p['2,1'] = math.sqrt(3) * sinT * cosT;
    dp['2,1'] = math.sqrt(3) * (cosT * cosT - sinT * sinT);
    p['2,2'] = 0.5 * math.sqrt(3) * sinT * sinT;
    dp['2,2'] = math.sqrt(3) * sinT * cosT;

    p['3,0'] = 0.5 * (5 * cosT * cosT * cosT - 3 * cosT);
    dp['3,0'] = 0.5 * (-15 * cosT * cosT * sinT + 3 * sinT);
    p['3,1'] = math.sqrt(1.5) * sinT * (5 * cosT * cosT - 1) / 2.0;
    dp['3,1'] = math.sqrt(1.5) * (cosT * (5 * cosT * cosT - 1) / 2.0 - 5 * sinT * sinT * cosT);
    p['3,2'] = 0.5 * math.sqrt(15) * sinT * sinT * cosT;
    dp['3,2'] = 0.5 * math.sqrt(15) * (2 * sinT * cosT * cosT - sinT * sinT * sinT);
    p['3,3'] = math.sqrt(5 / 8) * sinT * sinT * sinT;
    dp['3,3'] = 3 * math.sqrt(5 / 8) * sinT * sinT * cosT;

    double x = 0.0;
    double y = 0.0;

    for (final (n, m, g, h) in coeffs) {
      final double cosM = math.cos(m * phi);
      final double sinM = math.sin(m * phi);
      final String key = '$n,$m';
      final double dpVal = dp[key] ?? 0.0;
      final double pVal = p[key] ?? 0.0;

      x += dpVal * (g * cosM + h * sinM);
      if (sinT > 1e-5) {
        y += (m / sinT) * pVal * (g * sinM - h * cosM);
      } else {
        y += dpVal * (g * sinM - h * cosM);
      }
    }

    final double dec = _radiansToDegrees(math.atan2(y, x));
    return dec;
  }

  static double _degreesToRadians(double degrees) => degrees * (math.pi / 180.0);
  static double _radiansToDegrees(double radians) => radians * (180.0 / math.pi);
}
