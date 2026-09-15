# Smart Muslim — المسلم الذكي
## Product Specification Document

### 1. Project Overview & Vision
**Smart Muslim (المسلم الذكي)** is an open-source, non-profit, production-grade Islamic mobile application for Android and iOS. It serves as a unified, dignified, and highly reliable companion for Muslims in their daily worship, Quranic reading, and Islamic learning.

#### Core Commitments
- **100% Free Forever**: No paid tiers, freemium models, or locked features.
- **Zero Ads & Zero Commercial Distractions**: Pure spiritual experience without banners, popups, or native ads.
- **Privacy & Security First**: Zero tracking, zero analytics profiling, zero selling of user data. Location data is processed locally for prayer times and Qibla computation.
- **Authenticity & Governance**: Strictly source-based Islamic content adhering to Quran, authentic Sunnah, and the consensus of Ahl al-Sunnah wal-Jama'ah.
- **Modern UX/UI**: Pristine, responsive, accessible design with native RTL/LTR support, light/dark themes, and offline capability.

---

### 2. Branding & Opening Splash
- **Official Name (Arabic)**: المسلم الذكي
- **Official Name (English)**: Smart Muslim
- **App Identifier**: `com.smartmuslim.app`

#### Splash Screen Specification
Upon application startup, the splash screen displays the app title cleanly alongside the exact required dedication statement:

> **المسلم الذكي**
> *"هذا التطبيق صدقة جارية عن أبي وأمي وأختي وعني وعن أهل بيتي"*

- **Design Tone**: Serene, elegant, minimal Islamic aesthetic with smooth fade transitions.
- **No intrusive audio or musical stings.**

---

### 3. Product Phases & Scope

#### Phase 1: Al-Mu'adhin (المؤذن) & Core Platform [Current Scope]
- Accurate offline prayer times calculation (Fajr, Sunrise, Dhuhr, Asr, Maghrib, Isha).
- Support for global calculation methods (MWL, ISNA, Egypt, Makkah, Karachi, Tehran, Gulf, Kuwait, Qatar, Singapore, France, Turkey, etc.).
- Custom juristic methods for Asr (Standard / Hanafi).
- Dynamic high-latitude adjustment rules.
- Automatic location detection via GPS & manual location selection/search.
- Precise real-time Qibla compass using device sensors and location.
- Multi-tier notification system:
  - Adhan audio (full / takbeer only).
  - Pre-prayer notifications (e.g. 15 mins before Fajr).
  - Silent/Vibration alerts.
- Offline-first prayer schedule cache & background rescheduling.
- Arabic (RTL) & English (LTR) localization framework.

#### Phase 2: Holy Quran (القرآن الكريم) [Architecturally Prepared]
- Full Mushaf text in Uthmani script with checksum verification.
- Search engine by Surah, Juz, Page, and Ayah text.
- Offline bookmarks and reading progress tracking.
- Audio recitation player with offline download manager.
- Modular Tafsir engine with verified scholar commentaries.

#### Phase 3: Prophet's Hadith (الحديث الشريف) [Architecturally Prepared]
- Sahih al-Bukhari & Sahih al-Muslim integration.
- Full Hadith metadata: Collection, Book, Chapter, Hadith Number, Narrator, Grade, Takhreej.

#### Phase 4: Tafsir & Islamic Commentary [Architecturally Prepared]
- Verified Tafsir databases (Ibn Kathir, Al-Sa'di, Al-Qurtubi, Al-Baghawi, etc.) mapped by Ayah ID.

#### Phase 5: Library & Scientific Books [Architecturally Prepared]
- Authenticated Islamic books across Aqeedah, Fiqh, Seerah, Adhkar, and Sciences of Quran/Hadith with license auditing.
