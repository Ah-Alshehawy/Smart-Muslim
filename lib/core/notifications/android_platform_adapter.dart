import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'adhan_sound_resolver.dart';
import 'notification_scheduler.dart';
import 'notification_preferences.dart';
import '../utils/prayer_calculator.dart';

class AndroidPlatformAdapter implements NotificationScheduler {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    tz_data.initializeTimeZones();

    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (_) {
      try {
        tz.setLocalLocation(tz.getLocation('Africa/Cairo'));
      } catch (_) {
        // Fallback to UTC if timezone name is unrecognized
      }
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(initSettings);

    // Create high-importance deterministic notification channels for each sound
    final androidImpl = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      // 0. Clean up legacy channels to prevent Android OS from caching muted settings
      final legacyChannels = [
        'smart_muslim_channel_adhan_makkah_v2',
        'smart_muslim_channel_takbeer_v2',
        'smart_muslim_channel_chime_v2',
        'smart_muslim_channel_silent_v2',
        'smart_muslim_channel_adhan_makkah',
        'adhan_channel_id',
      ];
      for (final legacyId in legacyChannels) {
        try {
          await androidImpl.deleteNotificationChannel(legacyId);
        } catch (_) {}
      }

      // 1. Register sound-specific channels with ALARM audio attributes
      for (final sound in AdhanSoundResolver.availableSounds) {
        final channel = AndroidNotificationChannel(
          sound.androidChannelId,
          sound.androidChannelNameArabic,
          description: sound.androidChannelDescriptionArabic,
          importance: Importance.max,
          sound: RawResourceAndroidNotificationSound(sound.androidRawResourceName),
          playSound: true,
          enableVibration: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        );
        await androidImpl.createNotificationChannel(channel);
      }

      // 2. Register Silent Channel
      const silentChannel = AndroidNotificationChannel(
        AdhanSoundResolver.silentChannelId,
        AdhanSoundResolver.silentChannelNameArabic,
        description: AdhanSoundResolver.silentChannelDescriptionArabic,
        importance: Importance.high,
        playSound: false,
        enableVibration: true,
      );
      await androidImpl.createNotificationChannel(silentChannel);
    }

    _isInitialized = true;
  }

  @override
  Future<bool> checkAndRequestPermissions() async {
    final androidImpl = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl == null) return false;

    final granted = await androidImpl.requestNotificationsPermission();
    await androidImpl.requestExactAlarmsPermission();
    return granted ?? false;
  }

  @override
  Future<void> schedulePrayerNotifications({
    required double latitude,
    required double longitude,
    required AppCalculationMethod method,
    required AppJuristicMethod juristic,
    Set<String>? enabledPrayers,
    bool playAdhan = true,
  }) async {
    await initialize();
    await cancelAllNotifications();

    final prefs = await NotificationPreferences.load();
    if (!prefs.globalNotificationsEnabled) return;

    final now = DateTime.now();
    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      final date = now.add(Duration(days: dayOffset));
      final schedule = PrayerCalculatorService.calculateSchedule(
        latitude: latitude,
        longitude: longitude,
        date: date,
        method: method,
        juristic: juristic,
      );

      _schedulePrayerIfEnabled(
        dayOffset: dayOffset,
        prayerKey: 'fajr',
        title: 'صلاة الفجر',
        time: schedule.fajr,
        setting: prefs.getPrayer('fajr'),
      );

      _schedulePrayerIfEnabled(
        dayOffset: dayOffset,
        prayerKey: 'dhuhr',
        title: 'صلاة الظهر',
        time: schedule.dhuhr,
        setting: prefs.getPrayer('dhuhr'),
      );

      _schedulePrayerIfEnabled(
        dayOffset: dayOffset,
        prayerKey: 'asr',
        title: 'صلاة العصر',
        time: schedule.asr,
        setting: prefs.getPrayer('asr'),
      );

      _schedulePrayerIfEnabled(
        dayOffset: dayOffset,
        prayerKey: 'maghrib',
        title: 'صلاة المغرب',
        time: schedule.maghrib,
        setting: prefs.getPrayer('maghrib'),
      );

      _schedulePrayerIfEnabled(
        dayOffset: dayOffset,
        prayerKey: 'isha',
        title: 'صلاة العشاء',
        time: schedule.isha,
        setting: prefs.getPrayer('isha'),
      );
    }
  }

  void _schedulePrayerIfEnabled({
    required int dayOffset,
    required String prayerKey,
    required String title,
    required DateTime time,
    required SinglePrayerSetting setting,
  }) {
    if (!setting.notificationEnabled) return;

    // 1. Pre-prayer alert if enabled
    if (setting.prePrayerReminder && setting.prePrayerMinutes > 0) {
      final preTime = time.subtract(Duration(minutes: setting.prePrayerMinutes));
      if (preTime.isAfter(DateTime.now())) {
        final preId = dayOffset * 100 + _getPrayerIndex(prayerKey) * 10 + 1;
        _scheduleZonedNotification(
          id: preId,
          title: 'اقترب موعد $title',
          body: 'يتبقى ${setting.prePrayerMinutes} دقيقة على موعد الأذان',
          time: preTime,
          channelId: AdhanSoundResolver.silentChannelId,
          channelName: AdhanSoundResolver.silentChannelNameArabic,
          playSound: false,
          soundResource: null,
        );
      }
    }

    // 2. Main Adhan / Prayer Time Notification
    if (time.isAfter(DateTime.now())) {
      final mainId = dayOffset * 100 + _getPrayerIndex(prayerKey) * 10 + 2;

      final bool playSound = setting.adhanAudioEnabled;
      final AdhanSoundId selectedSound = !setting.isFullAdhan
          ? AdhanSoundId.takbeer
          : AdhanSoundResolver.resolve(setting.adhanSound);

      final String channelId = playSound
          ? selectedSound.androidChannelId
          : AdhanSoundResolver.silentChannelId;
      final String channelName = playSound
          ? selectedSound.androidChannelNameArabic
          : AdhanSoundResolver.silentChannelNameArabic;
      final String? soundResource = playSound
          ? selectedSound.androidRawResourceName
          : null;

      _scheduleZonedNotification(
        id: mainId,
        title: 'المسلم الذكي — $title',
        body: 'حان الآن موعد $title حسب التوقيت المحلي',
        time: time,
        channelId: channelId,
        channelName: channelName,
        playSound: playSound,
        soundResource: soundResource,
      );
    }
  }

  int _getPrayerIndex(String key) {
    switch (key.toLowerCase()) {
      case 'fajr':
        return 1;
      case 'dhuhr':
        return 2;
      case 'asr':
        return 3;
      case 'maghrib':
        return 4;
      case 'isha':
        return 5;
      default:
        return 0;
    }
  }

  void _scheduleZonedNotification({
    required int id,
    required String title,
    required String body,
    required DateTime time,
    required String channelId,
    required String channelName,
    required bool playSound,
    required String? soundResource,
  }) async {
    try {
      final tzTime = tz.TZDateTime.from(time, tz.local);

      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: 'إشعارات مواقيت الصلاة والأذان',
        importance: Importance.max,
        priority: Priority.max,
        playSound: playSound,
        sound: (playSound && soundResource != null)
            ? RawResourceAndroidNotificationSound(soundResource)
            : null,
        audioAttributesUsage: AudioAttributesUsage.alarm,
        category: AndroidNotificationCategory.alarm,
        fullScreenIntent: true,
        visibility: NotificationVisibility.public,
      );

      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        tzTime,
        NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      // Fallback for system timezone edge cases
    }
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}
