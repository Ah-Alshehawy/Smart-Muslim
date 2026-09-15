# SMART MUSLIM — MUSHAF PRESENTATION SPECIFICATION
**Version:** 0.2.0-dev.3.1.1
**URI:** `docs/quran-mushaf-presentation.md`
**Status:** Implemented & Verified

---

## 1. Transparent Plate Architecture

The Smart Muslim Visual Mushaf uses 604 high-resolution pre-rendered page plates (`assets/quran/mushaf/pages/001.webp` through `604.webp`) derived losslessly from the canonical King Fahd Complex Madinah Mushaf dataset.

* **Plate Characteristics:**
  * Dimensions: Exactly 1024 × 1656 pixels (~1:1.618 Golden Ratio).
  * Storage Format: Lossless WebP (`VP8L`).
  * Total Bundle Size: 51.58 MB (54,091,894 bytes).
  * Pixel Encoding: Black calligraphy ink and decorative frames on a **100% transparent alpha background**.
* **Distinction between Plate & Presentation:**
  The WebP file is strictly a *calligraphic plate / mask*, not an opaque paper scan. The complete visual page is achieved by compositing this transparent plate over a procedurally rendered book surface canvas with dynamic header and footer metadata overlays.

---

## 2. Presentation Layers

The Mushaf presentation architecture is separated into three decoupled, clean components:

```text
MushafPage
├── MushafPageSurface (Layer 1: Background canvas, spine lighting & margin borders)
├── MushafPlate (Layer 2: 1024x1656 transparent plate with optional dark-mode filter)
└── MushafMetadataOverlay (Layer 3: Top Surah/Juz header and bottom page number)
```

1. **Layer 1: `MushafPageSurface`**
   Provides the physical book canvas. Uses a 4-stop directional linear gradient that shifts according to Arabic RTL page parity (odd pages vs. even pages).
2. **Layer 2: `MushafPlate`**
   Renders the authentic Uthmani script plate via `Image.asset`. Under dark mode, Skia GPU color filtering inverts the black ink to cream/white while preserving background transparency.
3. **Layer 3: `MushafMetadataOverlay`**
   Renders the classical Quranic header and footer text above and below the reading plate using metadata from `QuranRepository`.

---

## 3. Light Mode Presentation

In Light Mode, the viewer presents the authentic look and feel of high-grade Quranic paper:
* **Background Surface:** Soft parchment cream tone (`#FFFDF8` to `#FAF6EB`).
* **Spine Lighting:** A subtle directional gradient simulating the curvature of the open book binding.
* **Ink Tone:** The original dense black/charcoal calligraphic ink displays with 100% natural contrast directly against the warm paper background.
* **Typography:** Header and footer text rendered in `#6A604E` (traditional dark sepia bronze).

---

## 4. Dark Mode Presentation

In Dark Mode, the viewer transforms the transparent plate at runtime without modifying the source asset:
* **Background Surface:** Non-glare slate black (`#141414`).
* **Color Transformation Matrix:**
  ```dart
  static const List<double> darkCalligraphyMatrix = <double>[
    -1,  0,  0, 0, 235,
     0, -1,  0, 0, 235,
     0,  0, -1, 0, 235,
     0,  0,  0, 1,   0,
  ];
  ```
* **Behavior:**
  * For black ink (`R=0, G=0, B=0, A=255`), the transformed value is `RGB(235, 235, 235), A=255` (radiant cream/white text).
  * For transparent background (`A=0`), the transformed alpha remains `0`. The background remains completely transparent with zero discoloration.
  * Antialiased edge pixels retain their proportional alpha, preventing glowing halos or jagged edges.
* **Typography:** Header and footer text rendered in `#C5BDB0` (warm silver).

---

## 5. Background & Book Spine Geometry

The gradient lighting is strictly RTL-aware:
* **Odd Pages (1, 3, 5...):**
  In an Arabic book, odd pages sit on the **right-hand side** of an open book spread.
  * Left Edge: Inner spine junction with subtle shadow (`#E5DFC9` -> `#F9F6EB`).
  * Center: Radiant reading light (`#FFFDF8`).
  * Right Edge: Outer trimmed leaf border (`#F6F1E1`, 1.5px border `#DDD5BE`).
* **Even Pages (2, 4, 6...):**
  In an Arabic book, even pages sit on the **left-hand side** of an open spread.
  * Left Edge: Outer trimmed leaf border (`#F6F1E1`, 1.5px border `#DDD5BE`).
  * Center: Radiant reading light (`#FFFDF8`).
  * Right Edge: Inner spine junction with subtle shadow (`#F9F6EB` -> `#E5DFC9`).

---

## 6. Metadata Overlays

* **Top Header (`MushafMetadataHeader`):**
  * Symmetrical book layout: Surah title (e.g. `سورة الفاتحة`) on outer margin, Juz' title (e.g. `الجزء ١`) on inner spine margin.
  * Subtle opacity on Pages 1 and 2 (0.75) to honor the decorative illuminated unwan frames.
* **Bottom Footer (`MushafMetadataFooter`):**
  * Centered Arabic page number in Eastern Arabic numerals (`١`, `٢`, `٣`... `٦٠٤`).
  * Formatted dynamically using `QuranRepository.toArabicDigits`.

---

## 7. RTL Navigation Engine

* Directionality is explicitly forced to `TextDirection.rtl` at the `MushafPageView` root.
* Page 1 is physically mounted on the far right. Swiping left advances to Page 2; swiping right moves back to Page 1.
* Programmatic navigation (`jumpToPage` and `animateToPage`) strictly maps logical page `N` to PageView index `N - 1`.
* Page clamping bounds: Lower bound `1`, Upper bound `604`. Any invalid integer is safely clamped via `QuranRepository.clampPageNumber`.

---

## 8. Page Mapping Specification

* `UI Page 1` -> `assets/quran/mushaf/pages/001.webp` (Index 0)
* `UI Page 2` -> `assets/quran/mushaf/pages/002.webp` (Index 1)
* `UI Page 100` -> `assets/quran/mushaf/pages/100.webp` (Index 99)
* `UI Page 604` -> `assets/quran/mushaf/pages/604.webp` (Index 603)
* Out-of-bounds inputs (0, -1, 605, 9999) throw an `ArgumentError` in `getMushafPageAssetPath` and are clamped to `[1, 604]` in `clampPageNumber`.

---

## 9. Zoom and Pan Functionality

* Powered by `InteractiveViewer`.
* Scaling parameters: Minimum scale `1.0x`, Maximum scale `3.5x`.
* Double-tap gesture: Toggles between standard view (`1.0x`) and inspection zoom (`1.8x`).
* Zoom state resets automatically to `Matrix4.identity()` whenever the user swipes to a different page.

---

## 10. TransformationController Bounded Lifecycle

To eliminate memory leaks caused by unbounded controller accumulation:
* `MushafPageViewState` implements a bounded window cache (`Map<int, TransformationController> _transformControllers`).
* Active Window: Retains controllers only for `{currentPage - 1, currentPage, currentPage + 1}` (maximum 3 instances).
* Eviction Policy: Whenever the active page changes, `_pruneTransformControllers` iterates through the map. Any controller outside the 3-page active window is explicitly disposed (`controller.dispose()`) and deleted from the map.
* On Widget Disposal: All remaining controllers are disposed in `dispose()`.
* Memory Invariant: Even if a user visits all 604 pages in a single session, the live controller count never exceeds 3.

---

## 11. Image Cache Strategy

* `Image.asset` specifies `cacheWidth: 1024`.
* Flutter's Skia/Impeller texture cache manages decoded bitmaps in GPU memory.
* Preloading is bounded to immediate adjacent pages via standard `PageView` viewport caching. The app does not preload all 604 pages into RAM simultaneously.

---

## 12. Automated Test Verification

A dedicated test suite (`test/unit/mushaf_viewer_and_assets_test.dart`) validates:
1. Deterministic asset path mappings and out-of-bounds rejection.
2. Manifest SHA-256 integrity for all 604 WebP files.
3. Actual Flutter asset decoding (1024 × 1656 dimensions verified on sample pages 001, 002, 010, 100, 300, 604).
4. Eastern Arabic numeral conversions (`toArabicDigits`).
5. Canonical Surah and Juz page lookups.
6. Mathematical correctness of `darkCalligraphyMatrix`.
7. Light and Dark mode widget composition.
8. Bounded `TransformationController` lifecycle (verified max count <= 3 across disparate page jumps).
9. RTL text direction and Reader integration.

---

## 13. Provenance & Licensing

* **Calligraphic Plate Artwork:** Produced by the King Fahd Complex for the Printing of the Holy Quran (مجمع الملك فهد لطباعة المصحف الشريف).
* **Generation Tooling:** `quran/quran.com-images` (GPLv3).
* **Licensing Compliance:** Permitted for non-commercial, non-profit offline distribution with 100% text integrity. Smart Muslim contains zero ads, zero tracking, and zero commercial monetization.

---

## 10. Theme Architecture & Persistence (dev.3.1.1)

Smart Muslim integrates theme management through ThemeCubit (lib/core/theme/theme_cubit.dart):
* **Supported Modes:**
  * ThemeMode.system (Default): Dynamically adapts to host OS settings.
  * ThemeMode.light (Day Mode): Applies AppTheme.lightTheme with authentic warm parchment paper canvas, black calligraphy, and sepia metadata.
  * ThemeMode.dark (Night Mode): Applies AppTheme.darkTheme with non-glare slate canvas, Skia GPU-inverted cream calligraphy, and warm silver metadata.
* **Persistence:**
  * Managed via SharedPreferences under key smart_muslim_theme_mode.
  * Preserved across application restarts and screen transitions.
* **Control Surfaces:**
  * **In-Reader Dialog:** Accessible via AppBar theme button (Icons.light_mode_outlined / Icons.dark_mode_outlined), allowing instant switching during reading.
  * **Settings Screen:** Integrated into PrayerSettingsScreen under Appearance section.

---

## 11. True Immersive Fullscreen Architecture (dev.3.1.1)

The Mushaf reading mode supports true immersive fullscreen reading:
* **System UI Mode:** SystemUiMode.immersiveSticky.
* **Visual Transformations on Enter:**
  * Android top status bar is completely hidden.
  * Application AppBar is completely removed from widget tree (ppBar: null).
  * Sub-header is removed.
  * Bottom navigation controls are removed (ottomNavigationBar: null).
  * 100% of the display viewport is dedicated to the Mushaf page canvas.
  * SafeArea(top: true, bottom: true) inside MushafPage protects metadata overlays from hardware display cutouts and rounded corners while parchment canvas flows edge-to-edge.
* **Enter / Exit Controls:**
  * Action button in AppBar (Icons.fullscreen).
  * Single tap on the Mushaf page toggles between Normal and Fullscreen modes.
  * Device back button / swipe: intercepted by PopScope to exit fullscreen first before popping.
* **Lifecycle & Navigation Restoration:**
  * WidgetsBindingObserver monitors application lifecycle (paused, inactive, detached, 
esumed).
  * Disposing the screen (dispose()) immediately restores standard system UI (SystemUiMode.edgeToEdge).
  * Leaving the screen or switching reading modes restores standard system UI overlays.
