# Smart Muslim — Content Governance & Integrity Policy

## 1. Zero-AI Generation Rule for Religious Texts
Under no circumstances may Artificial Intelligence (LLMs, generative models) be used to compose, reconstruct, auto-complete, or synthesize Quranic verses, Hadith texts, or Islamic legal rulings. All religious content must originate exclusively from verified canonical datasets and authenticated scholarly manuscripts.

## 2. Ingestion Pipeline
Before any religious dataset enters the Smart Muslim application, it must undergo the following 8-step quality lifecycle:
1. **Source Identification**: Verifying author, edition, publisher, and standard reference.
2. **License Audit**: Ensuring 100% legal compliance for offline mobile redistribution.
3. **Integrity Validation**: Automated check of record counts, missing entries, duplicate IDs, and malformed characters.
4. **Editorial & Scholarly Review**: Verifying vowel marks (Tashkeel) and authentic attribution.
5. **Metadata Enrichment**: Attaching chapter, book, narrator, grading, and topic tags.
6. **Local Ingestion**: Packaging data into offline assets or embedded SQLite structures.
7. **Automated Unit Testing**: Executing programmatic validation scripts during CI/CD.
8. **Release Approval**: Final sign-off recorded in project documentation.

## 3. Strict Grading Separation in Hadith
- A Hadith's publication source (e.g., Jami' at-Tirmidhi or Sunan Abi Dawud) must never be conflated with its authentication status.
- Every non-Bukhari/Muslim Hadith must explicitly state its grading (Sahih, Hasan) alongside the certifying scholar (e.g., Al-Albani, Al-Arna'ut) or classical consensus.
- Fabricated (*Mawdu'*) or severely weak (*Da'eef Jiddan*) narrations are strictly prohibited from the application.

## 4. Athkar Authenticity Principle
The application's Daily Wird and Athkar sections contain only established (*Thabit*) narrations conforming to the methodology of Ahlus-Sunnah wal-Jama'ah.
