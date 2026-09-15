import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smart_muslim/core/notifications/adhan_sound_resolver.dart';
import 'package:smart_muslim/core/notifications/notification_preferences.dart';

void main() {
  group('Adhan Sound Resolver & Identity Tests', () {
    test('1. Sound ID mapping resolves deterministically to correct assets and raw resources', () {
      expect(AdhanSoundResolver.resolve('makkah'), equals(AdhanSoundId.makkah));
      expect(AdhanSoundResolver.resolve('takbeer'), equals(AdhanSoundId.takbeer));
      expect(AdhanSoundResolver.resolve('beep'), equals(AdhanSoundId.beep));

      // Unknown / legacy keys fall back gracefully to verified default without throwing
      expect(AdhanSoundResolver.resolve('madinah'), equals(AdhanSoundId.makkah));
      expect(AdhanSoundResolver.resolve('quds'), equals(AdhanSoundId.makkah));
      expect(AdhanSoundResolver.resolve(null), equals(AdhanSoundId.makkah));

      // Check asset paths
      expect(AdhanSoundResolver.getAssetPath('makkah'), equals('assets/audio/adhan.ogg'));
      expect(AdhanSoundResolver.getAssetPath('takbeer'), equals('assets/audio/takbeer.ogg'));
      expect(AdhanSoundResolver.getAssetPath('beep'), equals('assets/audio/tasbih_beep.wav'));

      // Check raw resource identifiers
      expect(AdhanSoundResolver.getAndroidRawResource('makkah'), equals('adhan'));
      expect(AdhanSoundResolver.getAndroidRawResource('takbeer'), equals('takbeer'));
      expect(AdhanSoundResolver.getAndroidRawResource('beep'), equals('tasbih_beep'));
    });

    test('2. Channel mapping assigns distinct channels per sound profile', () {
      final makkahChannel = AdhanSoundResolver.getChannelId(audioEnabled: true, soundKey: 'makkah');
      final takbeerChannel = AdhanSoundResolver.getChannelId(audioEnabled: true, soundKey: 'takbeer');
      final beepChannel = AdhanSoundResolver.getChannelId(audioEnabled: true, soundKey: 'beep');
      final silentChannel = AdhanSoundResolver.getChannelId(audioEnabled: false, soundKey: 'makkah');

      expect(makkahChannel, equals('smart_muslim_channel_adhan_makkah_v3'));
      expect(takbeerChannel, equals('smart_muslim_channel_takbeer_v3'));
      expect(beepChannel, equals('smart_muslim_channel_chime_v3'));
      expect(silentChannel, equals(AdhanSoundResolver.silentChannelId));

      // Distinct channels guarantee Android 8+ immutable channel sound works
      expect(makkahChannel != takbeerChannel, isTrue);
      expect(takbeerChannel != silentChannel, isTrue);
    });

    test('3. Per-Prayer independent sound mapping (Fajr, Dhuhr, Asr, Maghrib, Isha)', () {
      var config = NotificationPreferences.defaultConfig();

      // Configure each prayer with independent sound
      config = config.updatePrayer('fajr', config.getPrayer('fajr').copyWith(adhanSound: 'makkah'));
      config = config.updatePrayer('dhuhr', config.getPrayer('dhuhr').copyWith(adhanSound: 'takbeer'));
      config = config.updatePrayer('asr', config.getPrayer('asr').copyWith(adhanSound: 'beep'));
      config = config.updatePrayer('maghrib', config.getPrayer('maghrib').copyWith(adhanSound: 'makkah'));
      config = config.updatePrayer('isha', config.getPrayer('isha').copyWith(adhanSound: 'takbeer'));

      expect(config.getPrayer('fajr').adhanSound, equals('makkah'));
      expect(config.getPrayer('dhuhr').adhanSound, equals('takbeer'));
      expect(config.getPrayer('asr').adhanSound, equals('beep'));
      expect(config.getPrayer('maghrib').adhanSound, equals('makkah'));
      expect(config.getPrayer('isha').adhanSound, equals('takbeer'));

      // Verify each prayer resolves to its intended channel
      expect(
        AdhanSoundResolver.getChannelId(
          audioEnabled: config.getPrayer('fajr').adhanAudioEnabled,
          soundKey: config.getPrayer('fajr').adhanSound,
        ),
        equals('smart_muslim_channel_adhan_makkah_v3'),
      );

      expect(
        AdhanSoundResolver.getChannelId(
          audioEnabled: config.getPrayer('dhuhr').adhanAudioEnabled,
          soundKey: config.getPrayer('dhuhr').adhanSound,
        ),
        equals('smart_muslim_channel_takbeer_v3'),
      );

      expect(
        AdhanSoundResolver.getChannelId(
          audioEnabled: config.getPrayer('asr').adhanAudioEnabled,
          soundKey: config.getPrayer('asr').adhanSound,
        ),
        equals('smart_muslim_channel_chime_v3'),
      );
    });

    test('4. Settings persistence round-trip across app restarts', () async {
      SharedPreferences.setMockInitialValues({});

      var prefs = await NotificationPreferences.load();
      prefs = prefs.updatePrayer(
        'fajr',
        prefs.getPrayer('fajr').copyWith(
              adhanSound: 'takbeer',
              isFullAdhan: false,
              prePrayerReminder: true,
              prePrayerMinutes: 20,
            ),
      );
      await prefs.save();

      // Simulate app restart / re-loading preferences
      final reloaded = await NotificationPreferences.load();
      final fajr = reloaded.getPrayer('fajr');

      expect(fajr.adhanSound, equals('takbeer'));
      expect(fajr.isFullAdhan, isFalse);
      expect(fajr.prePrayerReminder, isTrue);
      expect(fajr.prePrayerMinutes, equals(20));
    });

    test('5. Disabled Adhan routes to silent channel without audio resource', () {
      final silentChannel = AdhanSoundResolver.getChannelId(
        audioEnabled: false,
        soundKey: 'makkah',
      );
      expect(silentChannel, equals(AdhanSoundResolver.silentChannelId));
    });
  });
}
