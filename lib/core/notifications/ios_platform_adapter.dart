import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'notification_scheduler.dart';
import '../utils/prayer_calculator.dart';

class IosPlatformAdapter implements NotificationScheduler {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    tz_data.initializeTimeZones();

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(iOS: iosSettings);
    await _notificationsPlugin.initialize(initSettings);
    _isInitialized = true;
  }

  @override
  Future<bool> checkAndRequestPermissions() async {
    final iosImpl = _notificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (iosImpl == null) return false;

    final granted = await iosImpl.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
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

    final allowed = enabledPrayers ?? const {'fajr', 'dhuhr', 'asr', 'maghrib', 'isha'};

    // iOS local notification limit is 64. Pre-schedule 10 days x 5 prayers = 50 notifications.
    final now = DateTime.now();
    for (int dayOffset = 0; dayOffset < 10; dayOffset++) {
      final date = now.add(Duration(days: dayOffset));
      final schedule = PrayerCalculatorService.calculateSchedule(
        latitude: latitude,
        longitude: longitude,
        date: date,
        method: method,
        juristic: juristic,
      );

      if (allowed.contains('fajr')) _scheduleSingleZoned(id: dayOffset * 10 + 1, title: 'صلاة الفجر', time: schedule.fajr);
      if (allowed.contains('dhuhr')) _scheduleSingleZoned(id: dayOffset * 10 + 2, title: 'صلاة الظهر', time: schedule.dhuhr);
      if (allowed.contains('asr')) _scheduleSingleZoned(id: dayOffset * 10 + 3, title: 'صلاة العصر', time: schedule.asr);
      if (allowed.contains('maghrib')) _scheduleSingleZoned(id: dayOffset * 10 + 4, title: 'صلاة المغرب', time: schedule.maghrib);
      if (allowed.contains('isha')) _scheduleSingleZoned(id: dayOffset * 10 + 5, title: 'صلاة العشاء', time: schedule.isha);
    }
  }

  void _scheduleSingleZoned({required int id, required String title, required DateTime time}) async {
    if (time.isBefore(DateTime.now())) return;

    try {
      final tzTime = tz.TZDateTime.from(time, tz.local);

      await _notificationsPlugin.zonedSchedule(
        id,
        'المسلم الذكي',
        'حان الآن موعد $title',
        tzTime,
        const NotificationDetails(
          iOS: DarwinNotificationDetails(
            sound: 'adhan_snippet.caf',
            presentAlert: true,
            presentSound: true,
          ),
        ),
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
