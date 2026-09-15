import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SinglePrayerSetting {
  final bool notificationEnabled;
  final bool prePrayerReminder;
  final int prePrayerMinutes;
  final bool adhanAudioEnabled;
  final String adhanSound; // 'makkah', 'madinah', 'quds', 'takbeer', 'beep'
  final bool isFullAdhan;
  final bool iqamaReminder;
  final int iqamaDelayMinutes;
  final int silenceDurationMinutes; // 0 = OFF, 5, 10, 15, 30

  const SinglePrayerSetting({
    this.notificationEnabled = true,
    this.prePrayerReminder = false,
    this.prePrayerMinutes = 15,
    this.adhanAudioEnabled = true,
    this.adhanSound = 'makkah',
    this.isFullAdhan = true,
    this.iqamaReminder = false,
    this.iqamaDelayMinutes = 15,
    this.silenceDurationMinutes = 0,
  });

  Map<String, dynamic> toJson() => {
        'notificationEnabled': notificationEnabled,
        'prePrayerReminder': prePrayerReminder,
        'prePrayerMinutes': prePrayerMinutes,
        'adhanAudioEnabled': adhanAudioEnabled,
        'adhanSound': adhanSound,
        'isFullAdhan': isFullAdhan,
        'iqamaReminder': iqamaReminder,
        'iqamaDelayMinutes': iqamaDelayMinutes,
        'silenceDurationMinutes': silenceDurationMinutes,
      };

  factory SinglePrayerSetting.fromJson(Map<String, dynamic> json) {
    return SinglePrayerSetting(
      notificationEnabled: json['notificationEnabled'] as bool? ?? true,
      prePrayerReminder: json['prePrayerReminder'] as bool? ?? false,
      prePrayerMinutes: json['prePrayerMinutes'] as int? ?? 15,
      adhanAudioEnabled: json['adhanAudioEnabled'] as bool? ?? true,
      adhanSound: json['adhanSound'] as String? ?? 'makkah',
      isFullAdhan: json['isFullAdhan'] as bool? ?? true,
      iqamaReminder: json['iqamaReminder'] as bool? ?? false,
      iqamaDelayMinutes: json['iqamaDelayMinutes'] as int? ?? 15,
      silenceDurationMinutes: json['silenceDurationMinutes'] as int? ?? 0,
    );
  }

  SinglePrayerSetting copyWith({
    bool? notificationEnabled,
    bool? prePrayerReminder,
    int? prePrayerMinutes,
    bool? adhanAudioEnabled,
    String? adhanSound,
    bool? isFullAdhan,
    bool? iqamaReminder,
    int? iqamaDelayMinutes,
    int? silenceDurationMinutes,
  }) {
    return SinglePrayerSetting(
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      prePrayerReminder: prePrayerReminder ?? this.prePrayerReminder,
      prePrayerMinutes: prePrayerMinutes ?? this.prePrayerMinutes,
      adhanAudioEnabled: adhanAudioEnabled ?? this.adhanAudioEnabled,
      adhanSound: adhanSound ?? this.adhanSound,
      isFullAdhan: isFullAdhan ?? this.isFullAdhan,
      iqamaReminder: iqamaReminder ?? this.iqamaReminder,
      iqamaDelayMinutes: iqamaDelayMinutes ?? this.iqamaDelayMinutes,
      silenceDurationMinutes: silenceDurationMinutes ?? this.silenceDurationMinutes,
    );
  }
}

/// Comprehensive, Persistent, Per-Prayer Notification Preferences
class NotificationPreferences {
  static const String _prefsKey = 'smart_muslim_prayer_notifications_config';

  final Map<String, SinglePrayerSetting> prayers;
  final bool globalNotificationsEnabled;
  final int globalSilenceMinutes;

  const NotificationPreferences({
    required this.prayers,
    this.globalNotificationsEnabled = true,
    this.globalSilenceMinutes = 0,
  });

  factory NotificationPreferences.defaultConfig() {
    return const NotificationPreferences(
      prayers: {
        'fajr': SinglePrayerSetting(adhanSound: 'makkah', isFullAdhan: true),
        'dhuhr': SinglePrayerSetting(adhanSound: 'makkah', isFullAdhan: true),
        'asr': SinglePrayerSetting(adhanSound: 'takbeer', isFullAdhan: false),
        'maghrib': SinglePrayerSetting(adhanSound: 'madinah', isFullAdhan: true),
        'isha': SinglePrayerSetting(adhanSound: 'makkah', isFullAdhan: true),
      },
      globalNotificationsEnabled: true,
      globalSilenceMinutes: 0,
    );
  }

  static Future<NotificationPreferences> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return NotificationPreferences.defaultConfig();

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final rawPrayers = map['prayers'] as Map<String, dynamic>? ?? {};
      final prayers = <String, SinglePrayerSetting>{};

      for (final key in ['fajr', 'dhuhr', 'asr', 'maghrib', 'isha']) {
        if (rawPrayers.containsKey(key)) {
          prayers[key] = SinglePrayerSetting.fromJson(rawPrayers[key] as Map<String, dynamic>);
        } else {
          prayers[key] = const SinglePrayerSetting();
        }
      }

      return NotificationPreferences(
        prayers: prayers,
        globalNotificationsEnabled: map['globalNotificationsEnabled'] as bool? ?? true,
        globalSilenceMinutes: map['globalSilenceMinutes'] as int? ?? 0,
      );
    } catch (_) {
      return NotificationPreferences.defaultConfig();
    }
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    final map = {
      'globalNotificationsEnabled': globalNotificationsEnabled,
      'globalSilenceMinutes': globalSilenceMinutes,
      'prayers': prayers.map((k, v) => MapEntry(k, v.toJson())),
    };
    await prefs.setString(_prefsKey, jsonEncode(map));
  }

  SinglePrayerSetting getPrayer(String prayerKey) {
    return prayers[prayerKey.toLowerCase()] ?? const SinglePrayerSetting();
  }

  NotificationPreferences updatePrayer(String prayerKey, SinglePrayerSetting setting) {
    final updated = Map<String, SinglePrayerSetting>.from(prayers);
    updated[prayerKey.toLowerCase()] = setting;
    return NotificationPreferences(
      prayers: updated,
      globalNotificationsEnabled: globalNotificationsEnabled,
      globalSilenceMinutes: globalSilenceMinutes,
    );
  }
}
