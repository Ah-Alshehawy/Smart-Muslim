# Quran Data Validation & Verification Criteria

## 1. Tanzil Standard v1.1 Verification
- **Total Surahs**: Exactly 114
- **Total Ayahs**: Exactly 6,236 (Kufic canonical numbering)
- **Format**: `SurahNumber|AyahNumber|TextUthmani`
- **Integrity Checklist**:
  - Surah 1 (Al-Fatihah): 7 Ayahs (Ayah 1 is Basmalah).
  - Surah 2 (Al-Baqarah): 286 Ayahs (Ayah 255 is Ayat Al-Kursi).
  - Surah 9 (At-Tawbah): 129 Ayahs (No Basmalah).
  - Surah 114 (An-Nas): 6 Ayahs.
  - Zero duplicate lines.
  - Zero empty text records.
  - Vowel points (Tashkeel) and Uthmani stop signs (ۚ ۖ ۗ ۘ ۙ ۛ) preserved.

## 2. Page & Juz Indexing
- **Pages**: 1 to 604 conforming to the standard Madinah Mushaf layout.
- **Ajza'**: 1 to 30 mapped accurately across surah boundaries.

## 3. Automated Test Verification
Automated test suite `test/unit/quran_data_integrity_test.dart` verifies:
1. Surah count = 114.
2. Ayah count = 6236.
3. Every surah total ayahs matches `surah_model.dart` metadata.
4. Parsing latency < 300ms on first load.
