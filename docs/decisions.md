# Smart Muslim — Architectural Decision Records (ADRs)

## ADR 001: Mobile Cross-Platform Technology Stack (Flutter / Dart)

### Context
Smart Muslim requires an ultra-responsive, beautiful, pixel-perfect, highly maintainable application targeting both Android and iOS from a single robust codebase. Key requirements include exact typography control for Uthmani Quranic script, high-performance offline vector rendering for Qibla compass, seamless RTL support, and reliable native background interop for Adhan notifications.

### Decision
Use **Flutter (Dart 3.x)** as the primary technology stack.

### Rationale
1. **Direct Canvas / Impeller Rendering Engine**: Ensures exact visual fidelity for Arabic fonts and Quranic glyphs across all screen sizes and OS versions.
2. **First-Class RTL Support**: Flutter has built-in, native bidirectionality (`Directionality`, `TextDirection.rtl`).
3. **High-Performance Native Interop**: Dart FFI and Platform Channels provide low-latency communication with Android AlarmManager/Foreground Services and iOS UNUserNotificationCenter.
4. **Strong Ecosystem for Offline & Islamic Utilities**: High-precision Dart libraries for astronomical prayer calculations (`adhan`), SQLite (`drift`), and local notifications (`flutter_local_notifications`).

---

## ADR 002: State Management Architecture (BLoC Pattern)

### Context
The app features background recalculation, dynamic theme changing, audio state management, and multi-screen synchronization. State management must be predictable, testable, and strictly decoupled from the UI.

### Decision
Adopt **flutter_bloc (Business Logic Component)** for application state management.

### Rationale
1. **Unidirectional Data Flow**: Events in, States out. Eliminates unexpected UI mutations.
2. **High Testability**: BLoCs can be unit-tested without instantiating Flutter widgets using `bloc_test`.
3. **Clear Modular Boundaries**: Each feature module (Prayer, Quran, Hadith) encapsulates its own BLoCs.

---

## ADR 003: Local Relational Database (Drift / SQLite)

### Context
Phases 2-5 will store Quranic Ayahs, Hadiths, Tafsirs, and Adhkar locally on the device with search capabilities across thousands of records.

### Decision
Use **Drift (Type-safe SQLite library for Dart/Flutter)**.

### Rationale
1. **Type-Safety & Code Generation**: Catches SQL queries and schema mismatches at compile time.
2. **High Performance**: Native SQLite execution speed with reactive stream support for UI updates.
3. **Migration Management**: Full support for schema versioning and database migrations as app phases evolve.

---

## ADR 004: On-Device Astronomical Prayer Times Calculation (`adhan`)

### Context
Prayer times must be calculated offline anywhere on Earth using standard astronomical algorithms.

### Decision
Use the verified open-source **`adhan`** library for Dart (port of Batoul Apps Adhan engine).

### Rationale
1. **Offline & Zero Network Overhead**: Computes exact timings locally from latitude, longitude, elevation, and timezone.
2. **Verified Mathematical Accuracy**: Standardized algorithms implemented across major Islamic algorithms globally.
3. **Configurable Parameters**: Supports all standard calculation methods (MWL, ISNA, Egypt, Makkah, Karachi, Gulf, etc.) and juristic variations (Standard vs Hanafi Asr).

---

## ADR 005: Granular Per-Prayer Settings & SharedPreferences Persistence

### Context
Users require independent notification and audio controls for each of the 5 daily prayers (Fajr, Dhuhr, Asr, Maghrib, Isha), including pre-prayer reminders, adhan audio selection, Iqama delay, and temporary silence windows.

### Decision
Store a structured JSON/key-value map in `SharedPreferences` containing individual `PrayerSetting` records for each prayer, synced reactively with `PrayerBloc` and reloaded on app launch.

### Rationale
1. **Non-blocking Persistence**: Instant retrieval on startup without opening database connections.
2. **Granular Independence**: Allows Fajr to have a full adhan sound and 20-min pre-reminder while Dhuhr uses Takbeer only.
3. **Resilience**: Prevents app-level defaults from overwriting user selections across app upgrades.

---

## ADR 006: Real-Time Qibla Azimuth Calculation via Device Magnetometer Streams

### Context
The previous Qibla implementation rotated the compass arrow by a static constant angle based purely on geographical bearing, causing the compass to remain fixed regardless of device orientation.

### Decision
Integrate `sensors_plus` magnetometer and accelerometer streams to compute the live device magnetic orientation (azimuth) relative to Magnetic/True North, and calculate the dynamic dial rotation angle as `(qiblaBearing - deviceHeading)`.

### Rationale
1. **Live Compass Responsiveness**: Real-time feedback as the user turns their phone towards the Kaaba.
2. **Graceful Degradation**: If hardware sensors are unavailable or uncalibrated, the UI informs the user with visual instructions rather than displaying a misleading static compass.

---

## ADR 007: Tanzil Offline Quran Ingestion Engine & Multi-Mode Reader

### Context
The Holy Quran must be 100% complete (114 Surahs, 6,236 Ayahs) in canonical Uthmani text with zero reliance on cloud APIs or AI-generated text. Users also require Text, Mushaf/Page, and Compact reading modes.

### Decision
Parse and cache the verified Tanzil Uthmani dataset (`assets/quran/tanzil_uthmani_v1.1.txt`) directly on startup / first reader access, indexed by Surah, Ayah, Juz, and Page number (1 to 604).

### Rationale
1. **Verifiable Data Integrity**: Canonical dataset with hash verification.
2. **Offline Instant Navigation**: Instant rendering across Text Reading mode, Mushaf Page mode, and Compact mode.
3. **Zero Hallucination Risk**: Text is immutable and directly mirrored from canonical sources.
