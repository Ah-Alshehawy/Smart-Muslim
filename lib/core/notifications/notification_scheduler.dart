import 'dart:io';
import 'package:flutter/foundation.dart';
import '../utils/prayer_calculator.dart';
import 'android_platform_adapter.dart';
import 'ios_platform_adapter.dart';

abstract class NotificationScheduler {
  Future<void> initialize();
  Future<bool> checkAndRequestPermissions();
  Future<void> schedulePrayerNotifications({
    required double latitude,
    required double longitude,
    required AppCalculationMethod method,
    required AppJuristicMethod juristic,
    Set<String>? enabledPrayers,
    bool playAdhan = true,
  });
  Future<void> cancelAllNotifications();
}

class NotificationSchedulerFactory {
  static NotificationScheduler createAdapter() {
    if (kIsWeb) {
      return NoOpPlatformAdapter();
    }
    if (Platform.isAndroid) {
      return AndroidPlatformAdapter();
    } else if (Platform.isIOS) {
      return IosPlatformAdapter();
    }
    return NoOpPlatformAdapter();
  }
}

class NoOpPlatformAdapter implements NotificationScheduler {
  @override
  Future<void> initialize() async {}

  @override
  Future<bool> checkAndRequestPermissions() async => false;

  @override
  Future<void> schedulePrayerNotifications({
    required double latitude,
    required double longitude,
    required AppCalculationMethod method,
    required AppJuristicMethod juristic,
    Set<String>? enabledPrayers,
    bool playAdhan = true,
  }) async {}

  @override
  Future<void> cancelAllNotifications() async {}
}
