# Smart Muslim — Quran Dataset Comparison & Discrepancy Report

**Date**: September 13, 2026  
**Cycle**: Quran Data Integration & Mushaf Foundation  
**Auditor**: Google DeepMind Antigravity Technical Engineering Lead  
**Scope**: Comparison between baseline `assets/quran/tanzil_uthmani_v1.1.txt` and canonical `rn0x/Quran-Data` (commit `1341b85d7c5650bf12a0cb4e2da24a8342f1399f`).

---

## 1. Executive Comparison Summary

| Metric / Attribute | Baseline (`tanzil_uthmani_v1.1.txt`) | New Source (`rn0x/Quran-Data`) | Status Classification |
| :--- | :--- | :--- | :--- |
| **Total Surahs** | 114 | 114 | **MATCH** |
| **Total Ayahs** | 6,236 | 6,236 | **MATCH** |
| **Surah Numbering / Order** | 1 (Al-Fatihah) to 114 (An-Nas) | 1 (Al-Fatihah) to 114 (An-Nas) | **MATCH** |
| **Ayah Numbering per Surah** | Consecutive (1..N) | Consecutive (1..N) | **MATCH** |
| **Page Mapping (Mushaf 1-604)**| Missing (Estimated via heuristic formula `_estimatePage`) | Exact King Fahd Complex 604-page mapping per Ayah | **STRUCTURAL DIFFERENCE** |
| **Juz Mapping (1-30)** | Incomplete heuristic estimation | Exact 30 Juz mapping per Ayah | **METADATA DIFFERENCE** |
| **Sajdah Locations** | None (0 references in text) | 15 authentic Sajdah points with `id`, `recommended`, `obligatory` metadata | **METADATA DIFFERENCE** |
| **Surah Metadata** | Arabic name, English name, revelation type, total ayahs | Adds transliteration, words count, letters count, exact start page | **METADATA DIFFERENCE** |
| **Basmalah in Surah Openings**| Prefixed to Ayah 1 text in Surahs > 1 (e.g. 2:1 = `بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ الٓمٓ`) | Separated as opening header; Ayah 1 is purely `الٓمٓ` | **STRUCTURAL DIFFERENCE** |
| **Uthmani Orthography (Diacritics)** | Standard Unicode Sukun (`\u0652` ْ) and Dagger Alif with Tatweel (`\u0640\u0670` ـٰ) | Authentic Quranic Sukun/Jazm head (`\u06E1` ۡ) and Superscript Dagger Alif (`\u0670` ٰ) | **TEXT DIFFERENCE — OWNER REVIEW REQUIRED** |

---

## 2. Detailed Discrepancy Classification

### 2.1 Surahs & Ayahs Count
- **Classification**: `MATCH`
- **Details**: Both datasets contain exactly 114 Surahs and 6,236 Ayahs (Standard Kufic numbering).

### 2.2 Mushaf Page Mapping (1-604)
- **Classification**: `STRUCTURAL DIFFERENCE`
- **Details**: 
  - Baseline Smart Muslim code estimated pages via a crude mathematical heuristic: `(surah * 604) ~/ 114` which produced arbitrary non-authentic page groupings.
  - The `rn0x/Quran-Data` dataset provides exact Ayah-to-page and Page-to-Ayah bounds matching the 604-page Madinah Mushaf (King Fahd Complex standard).

### 2.3 Sajdah Points
- **Classification**: `METADATA DIFFERENCE`
- **Details**: Exactly 15 authentic Sajdah points identified with Surah, Ayah, Page, and Juz references:
  1. 7:206 (Al-A'raf)
  2. 13:15 (Ar-Ra'd)
  3. 16:50 (An-Nahl)
  4. 17:109 (Al-Isra)
  5. 19:58 (Maryam)
  6. 22:18 (Al-Hajj)
  7. 22:77 (Al-Hajj)
  8. 25:60 (Al-Furqan)
  9. 27:26 (An-Naml)
  10. 32:15 (As-Sajdah)
  11. 38:24 (Sad)
  12. 41:38 (Fussilat)
  13. 53:62 (An-Najm)
  14. 84:21 (Al-Inshiqaq)
  15. 96:19 (Al-'Alaq)

### 2.4 Text & Diacritical Representation
- **Classification**: `TEXT DIFFERENCE — OWNER REVIEW REQUIRED`
- **Sample Observations**:
  - **Ayah 1:1**:
    - *Tanzil*: `بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ` (uses standard Sukun `\u0652` on Seen and Meem, Tatweel+Alif on Rahman).
    - *rn0x*: `بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ` (uses Quranic Jazm head `\u06E1` on Seen and Meem, superscript Alif `\u0670` on Rahman).
  - **Ayah 2:1**:
    - *Tanzil*: `بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ الٓمٓ` (Basmalah concatenated into verse string).
    - *rn0x*: `الٓمٓ` (Basmalah rendered via the dedicated header component).
- **Governance Ruling**: Per Project Data Governance Rule 4, no AI modification of Quranic text has been made. Both representations are traceable, and the text rendering layout is submitted for **Owner Review**.
