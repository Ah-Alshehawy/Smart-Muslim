# Changelog — Smart Muslim | المسلم الذكي

All notable changes to the Smart Muslim project are documented in this file in reverse chronological order.

## [0.2.0-dev.3.4] - 2026-09-14

### Fixed
- **Adhan Notification Audio Playback on Android 8+**:
  - Migrated notification channel IDs from `_v2` to `_v3` (`smart_muslim_channel_adhan_makkah_v3`, `takbeer_v3`, `chime_v3`, `silent_v3`) to bypass immutable Android notification channel sound caching.
  - Purged legacy `_v1` and `_v2` channel caches via `deleteNotificationChannel()` during initialization.
  - Configured channels and zoned notification details with `AudioAttributesUsage.alarm`, `AndroidNotificationCategory.alarm`, `Priority.max`, `Importance.max`, and `fullScreenIntent: true`, ensuring notifications play on the alarm audio stream even in silenced or battery-optimized states.
- **Misbaha / Tasbih Completion Vibration & Sound Alerts**:
  - Replaced `HapticFeedback.mediumImpact()` with `HapticFeedback.vibrate()` (with mediumImpact fallback) to directly invoke the hardware `Vibrator` motor service, guaranteeing vibration on devices where touch-feedback haptics are toggled off in system settings.
  - Re-synthesized `tasbih_beep.wav` into a high-amplitude (peak 26,000), 500ms, 44.1 kHz dual-harmonic chime (880 Hz + 1760 Hz) deployed to both `assets/audio/` and `android/app/src/main/res/raw/`, resolving Android ExoPlayer buffer underrun.
  - Added preloading and audio buffering in `TasbeehCounterScreen.initState()` via `_alertService.initialize()`. Removed redundant `stop()` calls before seeking to avoid resetting ExoPlayer state from buffering to idle. Added safe fallback to `SystemSound.play(SystemSoundType.alert)`.

## [0.2.0-dev.3.3] - 2026-09-13

### Fixed
- **Qibla Compass Slowness & Lag**: Upgraded sensor subscription to high-frequency `SensorInterval.uiInterval` (~50-60 Hz) and implemented adaptive angular smoothing ($\alpha = 0.75$ on phone rotation, $\alpha = 0.25$ when still). Replaced full-scaffold `setState` with isolated `ValueNotifier` and `RepaintBoundary` for zero-lag 60+ FPS needle tracking.
- **Qibla Lateral Offset (Magnetic Declination & 3D Tilt Skew)**: Integrated 3D vector sensor fusion combining accelerometer gravity vector ($\mathbf{U}$) and magnetometer ($\mathbf{M}$) via cross product ($\mathbf{E} = \mathbf{M} \times \mathbf{U}$, $\mathbf{N} = \mathbf{U} \times \mathbf{E}$) to eliminate tilt/dip-angle error when phone is held naturally. Added offline World Magnetic Model (WMM) spherical harmonic declination compensation ($+4.8^\circ$ in Cairo) mapping magnetic heading accurately to true geographic North.
- **Qibla Needle Geometric Pivot**: Replaced off-center vertical `Column` in `Transform.rotate` with an arrow anchored strictly at its geometric center $(w/2, h/2)$ around `Alignment.center`, eliminating eccentric orbital wobble.
- **Corrected Qibla Title**: Replaced incorrect phrase `"اتصال القبلة الشريفة"` with `"اتجاه القبلة"` (English: `"Qibla Direction"`).
- **Adhan Settings Audio Preview Bug**: Replaced hardcoded single audio playback with `AdhanAudioService` and `AdhanSoundResolver`, ensuring each sound option ("أذان الحرم المكي الشريف", "التكبير فقط", "تنبيه نغمي") plays its authentic bundled audio asset.
- **Missing Audio Assets & Silent Alarms**: Extracted authentic 12.25s opening Takbeer recitation into `assets/audio/takbeer.ogg` and `android/app/src/main/res/raw/takbeer.ogg` with valid Ogg Vorbis stream and CRC32 verification.
- **Android Notification Channel Sound Immutability**: Introduced deterministic channel architecture (`smart_muslim_channel_adhan_makkah_v2`, `smart_muslim_channel_takbeer_v2`, `smart_muslim_channel_chime_v2`, and `smart_muslim_channel_silent_v2`), ensuring Android 8+ persistent channel sounds accurately match each prayer's chosen audio.
- **Per-Prayer Sound Propagation**: Propagated independent sound selections per prayer (Fajr, Dhuhr, Asr, Maghrib, Isha) into scheduled alarms and boot receivers.
- **Android 13+ Runtime Permissions**: Added explicit permission checks (`checkAndRequestPermissions`) on startup and when saving Adhan preferences.
- **Automated Test Suite Expansion**: Added 33 new automated unit tests covering mathematical bearings, tilt compensation, angular normalization, rotation delta matrix, sound resolution, channel routing, and per-prayer persistence (109 total tests passing).

## [0.2.0-dev.3.2] - 2026-09-13

### Added
- **Circular Tasbih Completion Alert Selector**: Replaced the redundant top-left reset button with an elegant, compact circular button cycling through 4 alert states: Vibration Only -> Sound Only -> Sound + Vibration -> Off.
- **Target Completion Feedback**: Accurately triggers completion notification once upon reaching chosen targets (33, 100, 1000) without delaying counter rendering.
- **Subtle Procedural Sound Asset**: Synthesized a pure, neutral 150ms 784 Hz sine wave chime (`assets/audio/tasbih_beep.wav`, 6.6 KB) with zero copyright dependencies and graceful platform fallbacks.
- **Gentle Completion Vibration**: Integrated `HapticFeedback.mediumImpact()` delivering a single, non-fatiguing haptic pulse for repeated religious use.
- **Alert Preference Persistence**: Added `TasbihPreferences` to load and persist alert choices across app sessions with automatic fallback to Vibration Only on fresh installs.
- **Full Localization & Accessibility**: Added Arabic and English tooltips and semantic labels for all four alert modes.
- **Automated Test Expansion**: Added 21 automated unit and widget tests covering alert cycling, persistence, target completions, wrapping, and UI rendering (76 total tests passing).

## [0.2.0-dev.3.1.1] - 2026-09-13

### Added
- **ThemeCubit & Persistent Theme Management**: Introduced `ThemeCubit` (`lib/core/theme/theme_cubit.dart`) to manage and persist application theme mode (`ThemeMode.system`, `ThemeMode.light`, `ThemeMode.dark`) across app restarts via `SharedPreferences`.
- **Mushaf Light / Day Mode**: Enabled authentic daylight reading appearance featuring a warm cream parchment paper surface (`#E5DFC9` -> `#FFFDF8` -> `#F6F1E1`), native black calligraphy ink (`#000000`), and traditional sepia bronze metadata typography (`#6A604E`).
- **In-Reader Theme Selector**: Added quick theme toggle button directly in the reader AppBar opening a modal dialog to select between Light/Day, Dark/Night, and System modes.
- **Settings Screen Theme Section**: Added an Appearance / Theme section in `PrayerSettingsScreen` for global theme control.
- **True Immersive Fullscreen Mode**: Implemented full immersive reading with `SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky)` completely hiding the Android top status bar, application toolbar, sub-header, and bottom navigation controls.
- **Immersive Safe Areas & Gestures**: Added `SafeArea` padding inside `MushafPage` to ensure physical camera cutouts and rounded bezels never clip Surah headers or page footers while paper canvas extends edge-to-edge. Single-tap on page toggles controls and enters/exits fullscreen; Android back gesture/button gracefully exits fullscreen first via `PopScope`.
- **Lifecycle System UI Restoration**: Integrated `WidgetsBindingObserver` to restore standard edge-to-edge system bars when app is backgrounded, paused, or when reader is disposed.
- **Automated Test Expansion**: Added 3 new automated tests in Group 8 covering `ThemeCubit` state persistence, reader fullscreen toggling, and in-reader theme switching (total 55 passing tests across the project).

## [0.2.0-dev.3.1] - 2026-09-13

### Added
- **Composited Mushaf Presentation Architecture**: Implemented multi-layer visual presentation separating `MushafPageSurface`, `MushafPlate`, and `MushafMetadataOverlay` to transform raw transparent plates into authentic Madinah Mushaf pages.
- **Natural Book Surface & Spine Lighting**: Introduced `MushafPageSurface` rendering directional 4-stop parchment gradients (`#E5DFC9` -> `#F9F6EB` -> `#FFFDF8` -> `#F6F1E1`) and edge borders, tailored to Arabic RTL book leaf geometry (spine on left for odd pages, spine on right for even pages).
- **Dark Mode Color Matrix Inversion**: Added GPU-accelerated Skia `ColorFilter.matrix` (`darkCalligraphyMatrix`) to `MushafPlate` inverting black ink into radiant cream/white calligraphy (`RGB 235, 235, 235`) while keeping transparent background pixels 100% transparent with zero halos.
- **Dynamic Quranic Header & Footer Overlays**: Integrated `MushafMetadataHeader` rendering Surah title and Juz' number, and `MushafMetadataFooter` rendering Eastern Arabic page numerals (`١`, `٢`, `٣`... `٦٠٤`) dynamically from canonical datasets.
- **Juz Page Lookup & Numeral Helpers**: Added `QuranRepository.getJuzForPage` and `QuranRepository.toArabicDigits` for canonical metadata resolution across all 604 pages.

### Fixed
- **Resolved Dark-Mode Black-on-Black Bug (Screenshot A)**: Eliminated unreadable dark silhouette by inverting calligraphy ink at runtime without altering source WebP assets.
- **TransformationController Memory Leak Fix**: Replaced unbounded controller retention with bounded 3-page active window (`[currentPage - 1, currentPage, currentPage + 1]`); evicted controllers are cleanly disposed on page changes and view unmounting.
- **Flutter Test Suite Expansion**: Added 6 new automated tests verifying WebP image decoding, 1024x1656 dimensions, color inversion matrix math, widget tree layer composition, bounded controller lifecycle, and RTL layout (total 52 passing tests, zero analyze warnings).

## [0.2.0-dev.3] - 2026-09-13

### Added
- **Real Visual 604-Page Mushaf Viewer**: Implemented high-fidelity `MushafPageView` rendering authentic King Fahd Complex Madinah Mushaf pages (`001.webp` through `604.webp`) replacing the text reflow simulation.
- **Offline Mushaf Page Assets**: Integrated complete set of 604 Madinah Mushaf page assets stored locally in `assets/quran/mushaf/pages/` (Lossless WebP, 51.58 MB total, 100% bit-for-bit visible fidelity).
- **RTL Page Navigation Engine**: Native Right-to-Left PageView navigation adhering to authentic Arabic Mushaf reading flow (Page 1 starts on far right; swiping left advances forward).
- **Page Jump & Direct Slider**: Floating page navigation with jump-to-page dialog (1–604) and real-time page slider with Eastern Arabic numerals.
- **Mushaf Zoom & Pan**: Integrated `InteractiveViewer` with pinch-to-zoom (up to 3.5x), smooth panning, and double-tap zoom toggle (1.0x to 1.8x) for inspecting fine diacritical marks.
- **Last-Read Page Integration**: Automatically records and restores last-read page in visual Mushaf mode, accessible from both home dashboard and Surah list.
- **Canonical Mushaf Asset Manifest**: Added `assets/quran/mushaf/mushaf_manifest.json` documenting per-page dimensions, file sizes, and SHA-256 integrity checksums.
- **Expanded Test Coverage**: Added 9 new unit and widget tests covering asset path mappings, out-of-bound rejections, manifest SHA-256 verification, Surah-page lookups, and RTL widget rendering (total 46 passing tests).

## [0.2.0-dev.2] - 2026-09-13

### Added
- **Canonical Quran Data Integration**: Integrated authoritative dataset from `rn0x/Quran-Data` (commit `1341b85d7c5650bf12a0cb4e2da24a8342f1399f`).
- **Exact Madinah Mushaf 604-Page Foundation**: Integrated authentic Ayah-to-page and page-to-verse boundary mappings (`assets/quran/quran_pages.json`).
- **Structured 30 Juz & 15 Sajdah Datasets**: Added `quran_juz.json` and `quran_sajdahs.json` with authentic references.
- **Quran Domain Extensions**: Added `QuranPageModel`, `QuranJuzModel`, `QuranSajdahModel`, and expanded `SurahModel` (with `startPage`, transliteration, word/letter counts) and `AyahModel` (with `textEnglish`, `isSajdah`, `sajdahId`).
- **Deterministic Validation & Generation Pipeline**: Added `tool/generate_canonical_quran.dart` with SHA-256 manifest verification (`assets/quran/quran_manifest.json`).
- **Expanded Test Suite**: Added comprehensive dataset invariant and repository test suites bringing the automated suite to 37 passing unit/widget tests.

### Fixed
- Replaced heuristic page estimation (`_estimatePage`) and heuristic juz estimation (`_estimateJuz`) in `QuranRepository` with exact canonical datasets.
- Fixed Bismillah banner condition in Mushaf Page mode to trigger accurately on each Surah's `startPage`.

## [0.2.0-dev.1] - 2026-09-02

### Added
- **Geographic Data**: Comprehensive dataset for all 27 Egyptian governorates and major cities with coordinates and timezones (`lib/core/location/egypt_cities_data.dart`).
- **Live Qibla Compass**: Dynamic heading calculation using `sensors_plus` magnetometer with low-pass angular smoothing and fallback UI for sensorless devices.
- **Quran Multi-Mode Reader**: Text Reading Mode, Mushaf/Page Mode (1-604), and Compact Mode powered by the complete 6,236-Ayah Tanzil Uthmani dataset.
- **Hadith Library Expansion**: 42 Hadiths of Imam An-Nawawi + authenticated selections from Sahih Al-Bukhari, Sahih Muslim, and Riyad As-Salihin with source and grading filters.
- **Athkar Expansion**: 15+ authenticated categories with interactive counters, progress tracking, and Daily Wird.
- **Per-Prayer Audio & Notification Settings**: Independent controls for each prayer with pre-prayer alerts, custom adhan sounds, and temporary silence duration.
- **Audio Testing & Multi-Channel Android Notifications**: In-app "Test Audio" playback powered by `just_audio`; 3 Android notification channels (`adhan_channel_id`, `takbeer_channel_id`, `prayer_silent_channel_id`).
- **Timezone-Aware Scheduling**: Integrated `flutter_timezone` to bind native device timezone to notification scheduler.
- **Boot Alarm Persistence**: Declared `ScheduledNotificationBootReceiver` and `ScheduledNotificationReceiver` in `AndroidManifest.xml` to persist prayer schedules across device restarts.
- **Contact Us Screen**: Dedicated view with Smart Business Solutions (SBS) company information.
- **Release & Debug Build Automation**: Automated pipeline `tool/release.dart` supporting both `--mode=debug` and `--mode=release`, calculating SHA-256 and generating JSON release manifests.
- **Automated Test Suite**: 28 automated unit and widget test suites covering edge cases, boundaries, data integrity, and UI rendering.

### Fixed
- Fixed static Qibla compass needle bug by binding real-time azimuth to sensor events with angular smoothing.
- Fixed Android adhan notification sound error by correctly binding resource to `raw/adhan.ogg` and `raw/takbeer.ogg`.
- Fixed SharedPreferences persistence for calculation methods, juristic schools, and location selections across app restarts.
- Fixed Quran repository stub by replacing mock data with full offline Tanzil parser.
- Corrected Splash Screen dedication text with full Arabic diacritics (Tashkeel): `صَدَقَةٌ جَارِيَةٌ ... نَسْأَلُكُمُ الدُّعَاءَ`.
- Redesigned Dashboard layout to display all 5 daily prayers on standard mobile viewports without vertical scroll.
- Hardened `LocationModel.fromJson` against null or malformed attributes in stored JSON.
- Resolved timer leak in QiblaScreen during widget tree disposal.
