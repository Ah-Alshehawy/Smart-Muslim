# Smart Muslim — Quran Data License & Provenance Register

**Date**: September 13, 2026  
**Cycle**: Quran Data Integration & Mushaf Foundation  
**Auditor**: Google DeepMind Antigravity Technical Engineering Lead  

---

## 1. Source Provenance

- **Source Repository**: `https://github.com/rn0x/Quran-Data`
- **Pinned Commit Hash**: `1341b85d7c5650bf12a0cb4e2da24a8342f1399f`
- **Commit Date**: Sun Sep 29 03:19:04 2024 +0300
- **Author / Maintainer**: rn0x
- **Source Files Inspected**:
  - `data/mainDataQuran.json` (SHA-256: `46885c06aecd60192a49f98441859916cab9c738ccc1ec67f997450769119b57`)
  - `data/pagesQuran.json` (SHA-256: `d19dbcf4297a1276c13afe6117dd266a50a8463822797a5caa01d8b105be16a7`)
  - `data/sqlite/database.sqlite`
  - `data/quran_image/` (604 PNG files)

---

## 2. Licensing & Redistribution Status

| Asset / Component | Source License | Redistribution Status | Technical Action |
| :--- | :--- | :--- | :--- |
| **Repository Code & Schemas** | MIT License | `PERMITTED` | Imported & adapted into deterministic Dart generation pipeline (`tool/generate_canonical_quran.dart`). |
| **Surah & Ayah Metadata (JSON)**| Open Islamic Data / Academic | `PERMITTED` | Validated, normalized, and bundled offline in `assets/quran/`. |
| **604-Page Mapping JSON** | Open Data / King Fahd Standard | `PERMITTED` | Bundled offline in `assets/quran/quran_pages.json`. |
| **Quran Page Images (`data/quran_image/`)** | Unspecified provenance in repo | `BLOCKED — LICENSE/PROVENANCE VERIFICATION REQUIRED` | **EXCLUDED from APK bundling**. Data model/interface implemented for future dynamic asset plugging once license is verified by human owner. |

---

## 3. Bundled Canonical Artifacts & Hashes

| Canonical File | Record Count | File Size | SHA-256 Checksum |
| :--- | :--- | :--- | :--- |
| `assets/quran/quran_surahs.json` | 114 Surahs | 34,406 bytes | `c6f0b1aef227ad42a9979af1f05c64527bbe673b8bfe4045510a02c0cc119ea6` |
| `assets/quran/quran_pages.json` | 604 Pages | 66,617 bytes | `90fcf45cba123293b361407ca3639e6fa0ec40e6ebd5999d5860b987d4deca68` |
| `assets/quran/quran_juz.json` | 30 Juz | 5,271 bytes | `be8bb7a7b1f0ad11141467f027345b669d972670144eeb53f1f43f9b0a166eeb` |
| `assets/quran/quran_sajdahs.json` | 15 Sajdahs | 2,348 bytes | `e452fa6ab2758a2192d978e6681808d481cc95b2ff1a8fc810262b2a6213c02a` |
| `assets/quran/quran_verses.json` | 6,236 Ayahs | 2,675,674 bytes | `ab265983d2c095816f13fface0adb158d2317c16dab1a481135ae934a3d3e0b7` |
| `assets/quran/quran_manifest.json` | Manifest | 1,745 bytes | Verified against all generated artifacts |
