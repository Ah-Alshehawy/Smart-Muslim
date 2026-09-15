# Smart Muslim — Data Sources & License Audit

## 1. Quranic Text (المصحف الشريف)
- **Source**: Tanzil Project (Tanzil.net)
- **Version**: Text-Uthmani v1.1
- **Scope**: Complete Holy Quran (114 Surahs, 6,236 Ayahs)
- **License**: Creative Commons Attribution 3.0 Unported (CC BY 3.0)
- **Validation**: Strict line-by-line validation against King Fahd Complex Mushaf standard.
- **Storage**: `assets/quran/tanzil_uthmani_v1.1.txt`

## 2. Hadith Corpus (الحديث الشريف)
- **Sources**:
  - Al-Arba'in An-Nawawiyyah (الأربعون النووية للإمام النووي) — 42 Hadiths complete.
  - Sahih Al-Bukhari (صحيح البخاري) — Verified selections with Hadith numbers.
  - Sahih Muslim (صحيح مسلم) — Verified selections with Hadith numbers.
  - Riyad As-Salihin (رياض الصالحين) — Authenticated chapters.
- **Grading Sources**: Standard Sunnah consensus; Hadith gradings explicitly referenced (صحيح متفق عليه / صحيح / حسن).
- **License**: Classical Islamic heritage (Public Domain); editorial notes and formatting under Project Open License.

## 3. Athkar Corpus (الأذكار والأدعية النبوية)
- **Sources**:
  - Hisn Al-Muslim (حصن المسلم من أذكار الكتاب والسنة للشيخ سعيد بن علي بن وهف القحطاني).
  - Al-Adhkar by Imam An-Nawawi (كتاب الأذكار للإمام النووي).
- **Grading & Authenticity**: Every Dhikr includes source attribution (Sahih Bukhari, Sahih Muslim, Sunan Abi Dawud, At-Tirmidhi with Albani verification). Weak (da'eef) reports are strictly excluded from the core Athkar database.
- **License**: Public Domain religious texts; structured datasets maintained locally.

## 4. Geographic & City Data (قاعدة البيانات الجغرافية)
- **Scope**: Egypt (all 27 governorates + key cities), Arab capitals, and worldwide major Islamic centers.
- **Attributes**: Official Arabic Name, English Name, Latitude, Longitude, Timezone identifier.
- **License**: Open Data / Derived from public domain cartographic datasets.

## 5. Audio Assets (التسجيلات الصوتية للأذان)
- **Scope**: Standard Adhan recordings (Makkah, Madinah, Al-Aqsa, Takbeer snippet).
- **Format**: OGG Vorbis / MP3 optimized for mobile broadcast.
- **Verification**: Verified public domain / freely redistributable adhan calls.
- **Storage**: `assets/audio/adhan.ogg` and `android/app/src/main/res/raw/adhan.ogg`.
