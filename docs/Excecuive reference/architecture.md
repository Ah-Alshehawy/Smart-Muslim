# Smart Muslim — Software Architecture & Design Blueprint

## 1. Architectural Pattern: Modular Clean Architecture + Feature-First

Smart Muslim is built using **Clean Architecture** combined with a **Feature-First Modular System**. This guarantees decoupling between business logic, UI components, data sources, and OS-level platform channels.

```text
smart_muslim/
│
├── apps/
│   └── mobile/                # Flutter Entry Point & App Configuration
│
├── core/                      # Foundation Modules (Zero Feature Dependencies)
│   ├── core_ui/               # Design System, Typography, Colors, Themes, Common Widgets
│   ├── core_localization/     # Localization (Ar/En), RTL Layout Utilities, Translations
│   ├── core_network/          # HTTP Client, Data Download Managers, Offline Caching
│   ├── core_storage/          # Secure Storage, Key-Value Store, SQLite Engine (Drift)
│   ├── core_location/         # Location Services, GPS Provider, Geocoding
│   ├── core_notifications/    # Android & iOS Native Notification Scheduler & Adhan Audio
│   └── core_utils/            # Extension Methods, Date/Hijri Utilities, Error Handling
│
└── features/                  # Domain-Specific Feature Modules
    ├── prayer/                # Phase 1: Prayer Times, Adhan Settings, Qibla Compass
    │   ├── data/              # Repositories, Calculation Engines, Local Cache
    │   ├── domain/            # Prayer Entities, Calculation Use Cases, Qibla Math
    │   └── presentation/      # BLoCs / Controllers, Screens, Widgets
    │
    ├── quran/                 # Phase 2: Mushaf, Ayah Data, Audio Recitation, Tafsir Hooks
    ├── hadith/                # Phase 3: Hadith Collections & Verification Metadata
    ├── tafsir/                # Phase 4: Commentary Engines
    └── library/               # Phase 5: Authenticated Islamic Books
```

---

## 2. Layer Separation Principles

1. **Domain Layer**:
   - Contains pure Business Rules, Domain Entities, Value Objects, Repository Interfaces.
   - Zero external framework dependencies (pure Dart).
   - Independent of Flutter UI and specific storage mechanisms.

2. **Data Layer**:
   - Implements Domain Repository interfaces.
   - Manages Local Storage (Drift SQLite / Hive / SharedPreferences) and Remote APIs (if any).
   - Enforces offline-first data caching and checksum validation.

3. **Presentation Layer**:
   - Manages UI state using **BLoC (Business Logic Component)** or **Riverpod**.
   - UI views strictly consume state models and dispatch user intent events.
   - Full support for dark/light themes and RTL/LTR reactive re-rendering.

---

## 3. Platform & Background Execution Architecture (Adhan & Notifications)

Operating system constraints on Android (Doze mode, exact alarm restrictions) and iOS (Background App Refresh, UserNotifications framework limit of 64 scheduled local notifications) require a robust notification engine:

```text
+--------------------------------------------------------------------------+
|                        Prayer Notification Engine                        |
+--------------------------------------------------------------------------+
                                     |
         +---------------------------+---------------------------+
         |                                                       |
         v                                                       v
+-------------------------------+               +-------------------------------+
|         Android Layer         |               |           iOS Layer           |
+-------------------------------+               +-------------------------------+
| - AlarmManager (Exact Alarms) |               | - UNUserNotificationCenter    |
| - Foreground Service          |               | - Pre-scheduled 64 Local      |
| - Audio Focus & Full Adhan    |               |   Notifications (7-14 Days)   |
|   Playback via Foreground Svc |               | - Sound Payload (.caf/.wav)   |
| - BootReceiver (Reschedule)   |               | - BGTaskScheduler Reschedule  |
+-------------------------------+               +-------------------------------+
```

### OS Restrictions Handling Strategy
- **Android**:
  - Request `SCHEDULE_EXACT_ALARM` / `USE_EXACT_ALARM` permissions.
  - Implement a `BroadcastReceiver` listening to `BOOT_COMPLETED`, `TIMEZONE_CHANGED`, and `TIME_SET` to automatically recalculate and reschedule prayer times on device restart or time shift.
  - Play full Adhan audio via a dedicated Android Foreground Service with audio focus management.
- **iOS**:
  - Schedule local notifications using `UNUserNotificationCenter` with bundled adhan sound files (`.caf` / `.aiff`).
  - Pre-schedule prayer notifications for 14 days in advance (64 notification slots limit).
  - Register a `BGAppRefreshTask` / `BGProcessingTask` to wake up the app silently and refresh the rolling 14-day schedule when low on remaining slots.

---

## 4. Qibla Calculation Architecture
- Uses the Great Circle Navigation formula (Spherical Trigonometry) calculating bearing from user coordinates \((lat_1, lon_1)\) to the Kaaba in Makkah \((21.4225^\circ \text{N}, 39.8262^\circ \text{E})\):
  $$\theta = \text{atan2}\left(\sin(\Delta lon) \cdot \cos(lat_2), \cos(lat_1) \cdot \sin(lat_2) - \sin(lat_1) \cdot \cos(lat_2) \cdot \cos(\Delta lon)\right)$$
- Integrates device Magnetometer & Accelerometer (via sensor fusion / compass package) with magnetic declination compensation to deliver smooth, accurate UI rotation.

---

## 5. Offline-First Strategy
- All prayer time algorithms (using the high-precision `adhan` Dart engine) execute entirely on-device without requiring an internet connection.
- Location coordinates and selected calculation parameters are saved locally in encrypted/secure local storage.
- Downloadable assets (Quran text, Hadith databases, Tafsir content, audio files) are validated with SHA-256 checksums before local persistence.

---

## 6. Localization & RTL Framework
- Uses Flutter `flutter_localizations` with `.arb` translation files.
- Dynamic `Directionality` wrapping (`TextDirection.rtl` for Arabic, `TextDirection.ltr` for English).
- Fonts: Custom modern Arabic typography (**Outfit** / **Tajawal** / **Amiri** for Quranic text, **Inter** for English) for optimal legibility.
