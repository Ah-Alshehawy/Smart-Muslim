# Smart Muslim — Data Sources & Integrity Register

## 1. Governance Principles for Islamic Content

Every piece of Islamic content in Smart Muslim must satisfy the **4-Pillars Governance Rule**:
1. **Source-Based (مصدر موثوق)**: Verified attribution to an established, recognized Islamic institution or academic repository.
2. **Traceable (قابل للتحقق)**: Clear lineage from source edition, volume, and text version.
3. **Integrity-Verified (مفحوص ومضمون)**: SHA-256 checksum validated against original canonical dataset before release.
4. **Legally Redistributable (مرخص قانونيًا)**: Verified open license or explicit permission allowing offline distribution in a non-profit app.

**Strict Prohibition**: No AI-generated verses, hadiths, rulings, or tafsirs may ever be stored or presented as authentic religious content.

---

## 2. Dataset Registry & Audit Matrix

| Domain | Source Name | Official Entity / URL | Version / License | Verification Method | Offline Support |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Prayer Times** | `adhan` engine | Batoul Apps (Astronomical Formulas) | MIT License | Mathematical Unit Tests | 100% Offline |
| **Quran Text** | King Saud University Quran Project / Tanzil | Quran KSU / Tanzil.net | Open License / Public Domain | SHA-256 Checksum + Validation Pipeline | 100% Offline |
| **Hadith** | Sunnah.com Open Datasets / Dorar.net verified archives | Authentic Collections (Bukhari & Muslim) | Public Domain / CC BY-SA | Hadith Metadata Validation (Book/Number/Isnad) | 100% Offline |
| **Tafsir** | King Saud University / Al-Tafsir | Verified Commentaries (Ibn Kathir, Sa'di) | Public Domain / Academic License | Surah/Ayah Mapping Audit | 100% Offline |

---

## 3. Quran Data Validation Pipeline

Before any Quranic dataset is embedded into Smart Muslim's SQLite storage, it must pass through an automated `QuranDataValidator` script checking:

- Exact total Surahs count: **114**
- Exact total Ayahs count: **6236** (Kufic count)
- Integrity of Surah names, order, and verse indexing
- Character-by-character Unicode UTF-8 verification for Uthmani diacritics
- SHA-256 Checksum matching canonical hash reference
- Zero missing or duplicated Ayah IDs
