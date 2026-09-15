# Smart Muslim — Project History

هذا الملف سجل زمني تراكمي وشامل لكافة أحداث وإصدارات وقرارات مشروع "المسلم الذكي". يمنع مسح أي إدخال سابق.

---

## 2026-09-02 — Master Improvement Cycle & Alpha 0.2.0 Hardening

**Version:** `0.2.0-dev.1`  
**Build Number:** `2`  
**Channel:** `dev`  
**Type:** `Feature` / `Fix` / `Refactor` / `Content` / `Release`  

### Implemented & Fixed
1. **Prayer & Astronomical Calculation**:
   - Integrated full persistent settings for calculation method, juristic method (Shafi/Hanafi), and manual adjustments.
   - Expanded geographic dataset covering all 27 Egyptian governorates + major Arab & World cities.
   - Redesigned Dashboard to fit all 5 daily prayers without scrolling on standard mobile screens.
2. **Adhan Audio & Notifications**:
   - Fixed Android notification sound mapping to canonical `res/raw/adhan.ogg`.
   - Added in-app "Test Audio" playback via `just_audio`.
   - Added granular per-prayer settings (Notification toggle, Pre-prayer alert, Adhan audio selection, Iqama delay, Silence window) with `SharedPreferences` persistence.
3. **Qibla Compass**:
   - Replaced static rotation with live sensor streams (`sensors_plus` magnetometer and accelerometer) computing dynamic azimuth `(bearing - heading)`.
   - Added sensor-unavailable fallback UI and calibration instructions.
4. **Holy Quran Engine**:
   - Replaced placeholder stubs with offline ingestion of all 114 Surahs and 6,236 Ayahs from verified Tanzil Uthmani dataset.
   - Implemented 3 reading modes: Text Reading Mode, Mushaf/Page Mode (1-604), and Compact Mode.
   - Added Search, Juz markers, and Last Read persistence.
5. **Hadith & Athkar**:
   - Expanded to 42 Nawawi Hadiths + verified Sahih Bukhari/Muslim selections with full grading, takhrij, and book metadata.
   - Expanded Athkar across 15+ authenticated categories with interactive counters, progress tracking, and Daily Wird.
6. **Splash & Attribution**:
   - Updated Splash screen to exact tashkeel text: `صَدَقَةٌ جَارِيَةٌ ... نَسْأَلُكُمُ الدُّعَاءَ`.
   - Added Developer attribution and SBS Company Contact Us screen.
7. **Release Pipeline**:
   - Created `tool/release.dart` for automated build, testing, SHA-256 verification, and manifest archiving.

### Tests Status
- Static Analysis: `flutter analyze` — PASS (0 issues)
- Unit Tests: `flutter test` — PASS
- Physical Device Verification: `NOT VERIFIED` (Requires physical Android device for hardware sensor and background sound validation)

### Artifacts & Governance
- APK: `releases/dev/smart-muslim-0.2.0-dev.1.apk`
- Release Manifest: `releases/dev/smart-muslim-0.2.0-dev.1-manifest.json`
- Status: `IMPLEMENTED & AUTOMATED VERIFIED`
