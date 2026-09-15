# Smart Muslim — Product Roadmap & Execution Phases

## Phase 1: Al-Mu'adhin & Core Framework (Current Phase)
- [x] Project architecture blueprint & technical documentation setup.
- [ ] Core project initialization (Flutter Clean Architecture setup, modular structure, theme system, localization setup).
- [ ] Core UI System: Light/Dark theme, modern Islamic visual tokens, dynamic typography (Arabic & English), responsive layouts.
- [ ] Splash Screen implementation with exact dedication text ("هذا التطبيق صدقة جارية عن أبي وأمي وأختي وعني وعن أهل بيتي").
- [ ] Location Engine: GPS auto-detection, permission handling, fallback manual city selection/search.
- [ ] Prayer Engine: On-device astronomical calculation using `adhan` library (Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha, Next Prayer countdown).
- [ ] Juristic & Calculation Method settings UI (MWL, Makkah, Egypt, ISNA, Karachi, Hanafi/Standard Asr).
- [ ] Qibla Compass: Sensor-fusion real-time compass with magnetic declination correction and high-accuracy feedback.
- [ ] Notification & Adhan System: Native Android AlarmManager/Foreground Service + iOS UNUserNotificationCenter scheduling, Adhan audio playback options.
- [ ] Phase 1 Verification: Unit tests, background reschedule testing, offline testing, Android & iOS physical device checks, RTL layout verification.

---

## Phase 2: Holy Quran Platform
- [ ] Quran Database import with SHA-256 validation pipeline (114 Surahs, 6236 Ayahs, Uthmani script).
- [ ] Mushaf Viewer UI: Surah index, Juz index, Page navigation, last read bookmarking.
- [ ] Advanced Quran Search: Fast offline text search across Ayahs.
- [ ] Audio Reciter Engine: Streaming & background offline recitation downloader for verified Quraa.
- [ ] Modular Tafsir link layer.

---

## Phase 3: Sahih Hadith Library
- [ ] Sahih al-Bukhari & Sahih al-Muslim database integration.
- [ ] Hadith detail UI: Collection, Book, Chapter, Hadith number, Narrator, Isnad, Authenticity metadata.
- [ ] Hadith Search & Bookmarking.

---

## Phase 4: Tafsir & Commentary System
- [ ] Integration of Tafsir Ibn Kathir, Tafsir Al-Sa'di, Tafsir Al-Qurtubi.
- [ ] Ayah-by-Ayah Tafsir modal & full-screen reader.

---

## Phase 5: Authenticated Islamic Library & Scientific Works
- [ ] Categorized book reader (Aqeedah, Fiqh, Seerah, Adhkar).
- [ ] License auditing & text integrity validation for all included books.
