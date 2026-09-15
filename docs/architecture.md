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
│   ├── core_ui/               # Design Tokens, Palette, Typography, Common Widgets
│   ├── core_localization/     # Localization (Ar/En), RTL Framework, arb files
│   ├── core_network/          # HTTP Client, Asset Downloader, Offline Caching
│   ├── core_storage/          # Secure Storage, Key-Value Store, Drift SQLite Engine
│   ├── core_location/         # Location Services, GPS Provider, Geocoding
│   ├── core_notifications/    # Platform Abstraction Layer (Android & iOS Adapters)
│   └── core_utils/            # Extension Methods, Date/Hijri Utilities, Error Handler
│
└── features/                  # Domain-Specific Feature Modules
    ├── prayer/                # Phase 1: Prayer Times, Adhan Settings, Qibla Compass
    │   ├── data/              # Repositories, Calculation Engines, Local Cache
    │   ├── domain/            # Prayer Entities, Calculation Use Cases, Qibla Math
    │   └── presentation/      # BLoCs, Screens, Widgets
    │
    ├── quran/                 # Phase 2: Mushaf, Edition Profiles, Recitation Player
    ├── hadith/                # Phase 3: Hadith Collections & Verification Metadata
    ├── tafsir/                # Phase 4: Commentary Engines
    └── library/               # Phase 5: Authenticated Islamic Books
```

---

## 2. Platform Abstraction & Background Architecture (Adhan & Notifications)

Operating system constraints on Android (Doze mode, exact alarm restrictions) and iOS (Background App Refresh, `UNUserNotificationCenter` limit of 64 scheduled local notifications) require a decoupled Platform Abstraction Layer:

```text
+--------------------------------------------------------------------------+
|                     Prayer Schedule & Notification Engine                |
+--------------------------------------------------------------------------+
                                     |
         +---------------------------+---------------------------+
         |                                                       |
         v                                                       v
+-------------------------------+               +-------------------------------+
|    Android Platform Adapter   |               |      iOS Platform Adapter     |
+-------------------------------+               +-------------------------------+
| - Exact Alarm Permission Check|               | - UNUserNotificationCenter    |
| - setExactAndAllowWhileIdle() |               | - Rolling 10-Day Schedule     |
| - System Receivers (Boot/Time)|               |   (Max 60 Request Limit)      |
| - Doze Recovery & Log Resched |               | - Sound Payload (<30s Sound)  |
| - Full In-App Adhan Audio     |               | - In-App Full Adhan Audio     |
+-------------------------------+               +-------------------------------+
```

---

## 3. Scalable UI/UX Design System Specification

Smart Muslim includes a dedicated `core_ui` package providing design tokens and reusable widgets across all product phases:

### 3.1 Design Tokens & Theme Tokens
- **Color Palette (Light & Dark)**:
  - **Primary**: Emerald Green (`#0F5132` / `#198754`) representing peace, growth, and Islamic heritage.
  - **Accent**: Warm Sand Gold (`#D4AF37` / `#C5A059`) for high-contrast highlights and indicators.
  - **Surface Light**: Clean Off-White (`#F8F9FA` / `#FFFFFF`).
  - **Surface Dark**: Deep Midnight Slate (`#12181B` / `#1E262B`).
  - **Status Colors**: Success Green (`#198754`), Warning Amber (`#FFC107`), Danger Red (`#DC3545`).
- **Typography Engine**:
  - Arabic Headings & Body: **Tajawal** / **Outfit**
  - Quranic Uthmani Script: **Amiri Quran** / **Me Quran** (Verified glyphs)
  - English Headings & Body: **Inter**
- **Spatial Grid & Geometry**:
  - Spacing Scale: `4px, 8px, 12px, 16px, 24px, 32px, 48px`
  - Border Radius Scale: `xs: 4px, sm: 8px, md: 12px, lg: 16px, xl: 24px, pill: 999px`
  - Elevation Tokens: `none: 0, low: 2dp, medium: 6dp, high: 12dp`

### 3.2 Standard Reusable Components
- **State States**: Loading Skeletons, Empty Data Views, Network Error Cards, Permission Request Bottom Sheets, Offline Indicators.
- **Navigation Controls**: Modern Floating Bottom Navigation Bar with smooth tab switching and RTL support.
- **Feedback & Dialogs**: Native-styled Bottom Sheets, Accessibility-compliant Dialogs, Toast notifications.

---

## 4. Qibla Calculation Architecture
- Uses the Great Circle Navigation formula calculating bearing from user coordinates \((lat_1, lon_1)\) to Makkah \((21.4225^\circ \text{N}, 39.8262^\circ \text{E})\):
  $$\theta = \text{atan2}\left(\sin(\Delta lon) \cdot \cos(lat_2), \cos(lat_1) \cdot \sin(lat_2) - \sin(lat_1) \cdot \cos(lat_2) \cdot \cos(\Delta lon)\right)$$
- Integrates Magnetometer & Accelerometer sensors with magnetic declination compensation for smooth, real-time UI rotation.

---

## 5. Offline-First & Data Security Strategy
- Astronomical prayer time calculations execute 100% on-device using `adhan` library.
- Embedded SQLite databases (Quran, Hadith, Tafsir) are verified via SHA-256 checksums before local persistence.
- Zero network dependency for core worship features.
