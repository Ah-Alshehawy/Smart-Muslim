import 'package:flutter_test/flutter_test.dart';
import 'package:smart_muslim/core/notifications/notification_preferences.dart';

void main() {
  group('Notification Preferences Unit Tests', () {
    test('Default configurations initialize with 5 prayers and full Adhan', () {
      final config = NotificationPreferences.defaultConfig();
      expect(config.globalNotificationsEnabled, isTrue);
      expect(config.globalSilenceMinutes, equals(0));
      expect(config.prayers.length, equals(5));

      final fajr = config.getPrayer('fajr');
      expect(fajr.notificationEnabled, isTrue);
      expect(fajr.adhanAudioEnabled, isTrue);
      expect(fajr.adhanSound, equals('makkah'));
    });

    test('SinglePrayerSetting JSON serialization roundtrip', () {
      const setting = SinglePrayerSetting(
        notificationEnabled: true,
        prePrayerReminder: true,
        prePrayerMinutes: 10,
        adhanAudioEnabled: true,
        adhanSound: 'madinah',
        isFullAdhan: false,
        iqamaReminder: true,
        iqamaDelayMinutes: 20,
        silenceDurationMinutes: 15,
      );

      final json = setting.toJson();
      final restored = SinglePrayerSetting.fromJson(json);

      expect(restored.notificationEnabled, equals(setting.notificationEnabled));
      expect(restored.prePrayerReminder, equals(setting.prePrayerReminder));
      expect(restored.prePrayerMinutes, equals(setting.prePrayerMinutes));
      expect(restored.adhanAudioEnabled, equals(setting.adhanAudioEnabled));
      expect(restored.adhanSound, equals(setting.adhanSound));
      expect(restored.isFullAdhan, equals(setting.isFullAdhan));
      expect(restored.iqamaReminder, equals(setting.iqamaReminder));
      expect(restored.iqamaDelayMinutes, equals(setting.iqamaDelayMinutes));
      expect(restored.silenceDurationMinutes, equals(setting.silenceDurationMinutes));
    });

    test('updatePrayer returns new instance without mutating original', () {
      final config = NotificationPreferences.defaultConfig();
      final updated = config.updatePrayer(
        'asr',
        const SinglePrayerSetting(adhanSound: 'takbeer', isFullAdhan: false),
      );

      expect(config.getPrayer('asr').adhanSound, equals('takbeer'));
      expect(updated.getPrayer('asr').adhanSound, equals('takbeer'));
      expect(updated.getPrayer('asr').isFullAdhan, isFalse);
    });
  });
}
