# Smart Muslim — Platform & Background Constraints Specification

## 1. Modular Platform Abstraction Architecture

To handle Android and iOS platform variations, background policies, and battery optimizations without scattering platform-specific code, Smart Muslim isolates notification scheduling into a clean abstraction layer:

```text
+-----------------------------------------------------------------------------------+
|                            Prayer Calculation Engine                              |
+-----------------------------------------------------------------------------------+
                                          |
                                          v
+-----------------------------------------------------------------------------------+
|                             Prayer Schedule Manager                               |
+-----------------------------------------------------------------------------------+
                                          |
                                          v
+-----------------------------------------------------------------------------------+
|                          Notification Scheduler Service                           |
+-----------------------------------------------------------------------------------+
                                          |
         +--------------------------------+--------------------------------+
         |                                                                 |
         v                                                                 v
+----------------------------------+             +----------------------------------+
|     Android Platform Adapter     |             |       iOS Platform Adapter       |
+----------------------------------+             +----------------------------------+
| - Exact Alarm Permission Checker |             | - UNUserNotificationCenter       |
| - BroadcastReceivers (Boot/Time) |             | - Rolling Schedule (64 Limit)    |
| - Doze Mode / AlarmManager       |             | - Audio Limit (<30s Sound File)  |
| - System Notifications / Audio   |             | - App Foreground / Sound Sync    |
+----------------------------------+             +----------------------------------+
         |                                                                 |
         +--------------------------------+--------------------------------+
                                          |
                                          v
+-----------------------------------------------------------------------------------+
|                   Rescheduling Manager & Recovery Framework                       |
|   (Triggers: Boot, Time Change, Timezone Change, App Open, Location Shift)        |
+-----------------------------------------------------------------------------------+
```

---

## 2. Android Background Execution Architecture

### 2.1 Exact Alarm Permission Matrix (`SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM`)
- **Android 12 (API 31) & 13 (API 33)**: `SCHEDULE_EXACT_ALARM` is granted by default, but can be revoked by the user in system settings (`Alarm & Reminders`).
- **Android 14 (API 34) & Android 15/16 (API 35+)**: `SCHEDULE_EXACT_ALARM` is **DENIED BY DEFAULT** for newly installed apps unless explicitly requested or granted by the user.
- **Play Store Policy Compliance**: `USE_EXACT_ALARM` is strictly audited by Google Play for Alarm/Timer/Calendar apps. Smart Muslim will:
  1. Primary Path: Use `AlarmManager.setExactAndAllowWhileIdle()` when exact alarm permission is granted.
  2. Fallback Path: If `canScheduleExactAlarms()` returns `false`, fall back gracefully to `AlarmManager.setAndAllowWhileIdle()` (inexact window) or prompt the user with clear, non-intrusive UI explaining why exact alarm permission is recommended for Adhan timings.
  3. Permission Revocation Handling: Check permission state before every schedule operation. Never crash if permission is denied.

### 2.2 System Event & Reschedule Receivers
Android system broadcasts trigger automatic rescheduling via `ReschedulingManager`:
- `android.intent.action.BOOT_COMPLETED`
- `android.intent.action.MY_PACKAGE_REPLACED`
- `android.intent.action.TIME_SET`
- `android.intent.action.TIMEZONE_CHANGED`

### 2.3 Doze Mode & Battery Optimization
- On Doze mode (`dumpsys deviceidle`), standard timers are deferred. Using `setExactAndAllowWhileIdle()` guarantees execution within a narrow window.
- UI explicitly guides users on OEM-specific battery savers (Xiaomi MIUI/HyperOS, Samsung OneUI, Huawei EMUI, OPPO ColorOS) to whitelist Smart Muslim for uninterrupted Adhan alerts.

### 2.4 Audio Playback & Foreground Services
- **System Notification Audio**: Primary default. Short Adhan notification sound played via Android Notification Channel (`AudioAttributes.USAGE_NOTIFICATION_RINGTONE`).
- **Full Adhan Audio Option**: When full Adhan audio is enabled by the user, a dedicated Android Service is bound with short-lived execution or notification audio focus management compliant with Android 14+ foreground service types (`mediaPlayback` or notification ringtone).

---

## 3. iOS Background & Notification Architecture

### 3.1 `UNUserNotificationCenter` Local Notifications
- iOS strictly enforces local notification scheduling through `UNUserNotificationCenter`.
- **System Limit**: iOS caps scheduled local notifications to **64 items** per app.
- **Rolling Scheduler Implementation**:
  - Smart Muslim pre-schedules 5 daily prayers + Sunrise for 10 days in advance (\(6 \times 10 = 60\) notification requests).
  - Every time the app enters the foreground, or when location/calculation settings are altered, `RollingScheduler` clears obsolete pending requests and reschedules a fresh 10-day window.

### 3.2 Sound Files & Audio Constraints on iOS
- **Local Notification Sound File Limit**: iOS local notification sound files (`.caf`, `.aiff`, `.wav`) **MUST BE LESS THAN 30 SECONDS IN DURATION**.
- **Full Adhan vs Notification Sound**:
  - System Notification (Background/Locked): iOS plays a high-quality 29-second Takbeer / Adhan audio snippet embedded in the app bundle.
  - In-App / Foreground Adhan: If the app is active or opened from the notification, the full 2-3 minute Adhan audio plays via `just_audio` player engine.
  - Transparent UX: The app settings screen explicitly clarifies for iOS users the difference between the 30s local notification alert and full in-app Adhan playback.

---

## 4. Platform Abstraction Layer Components

1. `PrayerCalculationEngine`: On-device `adhan` library wrapper computing astronomical times.
2. `PrayerScheduleManager`: Computes daily prayer timelines based on user location and calculation parameters.
3. `NotificationScheduler`: Abstract interface (`scheduleNotification`, `cancelAllNotifications`, `getPendingNotifications`).
4. `AndroidPlatformAdapter`: Implements `NotificationScheduler` for Android using `flutter_local_notifications` + `AlarmManager`.
5. `IosPlatformAdapter`: Implements `NotificationScheduler` for iOS using `UNUserNotificationCenter`.
6. `PermissionManager`: Checks and requests location, notification (`POST_NOTIFICATIONS`), and exact alarm permissions.
7. `ReschedulingManager`: Listens to boot, time, timezone, location change, and setting updates to trigger schedule recalculations.
8. `FailureRecovery`: Log fallback mechanisms ensuring failure in one notification slot does not break future prayer alerts.
