# Smart Muslim — Quran Data Integration & Mushaf Foundation Guide

**Date**: September 13, 2026  
**Version**: `0.2.0-dev.2` (Build 3)  
**Author**: Google DeepMind Antigravity Technical Engineering Lead  

---

## 1. Executive Summary

This document describes the technical integration of the authoritative Quran dataset from `rn0x/Quran-Data` into Smart Muslim. The integration replaces heuristic page/juz estimations with exact, authentic 604-page Madinah Mushaf mappings, 30 Juz structures, and 15 Sajdah points while maintaining 100% offline-first functionality and zero runtime network dependencies.

---

## 2. Canonical Pipeline & Data Flow

```text
External Source (rn0x/Quran-Data @ commit 1341b85)
                       ↓
  tool/generate_canonical_quran.dart (Validation Pipeline)
                       ↓
  Structured Immutable JSON Assets (assets/quran/)
     ├── quran_surahs.json  (114 Surahs with metadata & startPage)
     ├── quran_pages.json   (604 Pages with verse bounds)
     ├── quran_juz.json     (30 Juz with page and ayah bounds)
     ├── quran_sajdahs.json (15 Sajdah locations)
     ├── quran_verses.json  (6,236 Ayahs with exact Uthmani text)
     └── quran_manifest.json (SHA-256 Checksums & Record Counts)
                       ↓
         QuranRepository (Data Layer)
                       ↓
  Domain Models (SurahModel, AyahModel, QuranPageModel, QuranJuzModel)
                       ↓
  Presentation Layer (QuranSurahListScreen, QuranReaderScreen)
     ├── Mode 1: Text Reading Mode (Verse-By-Verse with Tafsir)
     ├── Mode 2: Mushaf Page Mode (1-604 Authentic Physical Simulator)
     └── Mode 3: Compact Continuous Reading Mode
```

---

## 3. Schema & Models

### 3.1 `SurahModel`
- `number`: 1..114
- `nameArabic`: e.g. `الفاتحة`
- `nameEnglish`: e.g. `Al-Fatihah`
- `nameTransliteration`: e.g. `Al-Fatihah`
- `revelationType`: `مكية` / `مدنية`
- `totalAyahs`: count of verses
- `wordsCount`: total words in Surah
- `lettersCount`: total letters in Surah
- `startPage`: 1..604 (the exact physical page where this Surah begins)

### 3.2 `AyahModel`
- `surahNumber`: 1..114
- `numberInSurah`: 1..N
- `textUthmani`: Complete Arabic text with Uthmani diacritics
- `textEnglish`: English translation
- `juz`: 1..30
- `page`: 1..604 (Madinah Mushaf standard)
- `isSajdah`: boolean
- `sajdahId`: 1..15 optional ID

### 3.3 `QuranPageModel`
- `pageNumber`: 1..604
- `startSurahNumber`: first Surah on this page
- `startAyahNumber`: first verse on this page
- `endSurahNumber`: last Surah on this page
- `endAyahNumber`: last verse on this page

### 3.4 `QuranJuzModel`
- `juzNumber`: 1..30
- `startSurahNumber`: starting Surah
- `startAyahNumber`: starting Ayah
- `endSurahNumber`: ending Surah
- `endAyahNumber`: ending Ayah
- `startPage`: 1..604
- `endPage`: 1..604
- `totalAyahs`: total count of ayahs in this Juz

---

## 4. Offline-First Verification

- All Surah metadata, Ayahs text, Page mappings, Juz bounds, and Sajdah points are embedded directly in the application APK as immutable assets in `assets/quran/`.
- No HTTP or network requests are executed during Surah listing, verse reading, search, or bookmarking.
- The user's Last Read position (Surah, Ayah, Page) is saved locally in `SharedPreferences`.

---

## 5. Scope for Human Owner Review

The technical integration and automated tests are verified. The human owner will perform:
1. Verification of Uthmani script typography and rendering comfort across screen sizes.
2. Verification of Mushaf page presentation in Mode 2 (604 pages).
3. Review of Surah names, Ayah numbers, and religious correctness.
