import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/ayah_model.dart';
import '../domain/quran_edition_profile.dart';
import '../domain/quran_juz_model.dart';
import '../domain/quran_page_model.dart';
import '../domain/quran_sajdah_model.dart';
import '../domain/surah_model.dart';

class QuranRepository {
  final QuranEditionProfile profile = QuranEditionProfile.tanzilStandard();

  static Map<int, List<AyahModel>> _surahCache = {};
  static Map<int, List<AyahModel>> _pageCache = {};
  static Map<int, List<AyahModel>> _juzCache = {};
  static List<AyahModel> _allAyahsCache = [];
  static List<SurahModel> _surahsList = [];
  static List<QuranPageModel> _pagesList = [];
  static List<QuranJuzModel> _juzList = [];
  static List<QuranSajdahModel> _sajdahsList = [];
  static bool _isLoaded = false;

  static const String _lastReadSurahKey = 'smart_muslim_quran_last_read_surah';
  static const String _lastReadAyahKey = 'smart_muslim_quran_last_read_ayah';
  static const String _lastReadPageKey = 'smart_muslim_quran_last_read_page';

  /// All 114 Surahs accessor (populated dynamically from canonical dataset, fallback to constant)
  static List<SurahModel> get allSurahs => _surahsList.isNotEmpty ? _surahsList : _fallbackSurahs;

  /// All 604 Pages metadata
  static List<QuranPageModel> get allPages => _pagesList;

  /// All 30 Juz metadata
  static List<QuranJuzModel> get allJuz => _juzList;

  /// All 15 Sajdah locations
  static List<QuranSajdahModel> get allSajdahs => _sajdahsList;

  /// Asynchronously parse and index complete Quran dataset (114 Surahs, 6,236 Ayahs, 604 Pages, 30 Juz)
  static Future<void> ensureLoaded() async {
    if (_isLoaded) return;

    try {
      // 1. Load Surahs
      final String surahsRaw = await rootBundle.loadString('assets/quran/quran_surahs.json');
      final List<dynamic> surahsJson = jsonDecode(surahsRaw);
      _surahsList = surahsJson.map((j) => SurahModel.fromJson(j as Map<String, dynamic>)).toList();

      // 2. Load Pages
      final String pagesRaw = await rootBundle.loadString('assets/quran/quran_pages.json');
      final List<dynamic> pagesJson = jsonDecode(pagesRaw);
      _pagesList = pagesJson.map((j) => QuranPageModel.fromJson(j as Map<String, dynamic>)).toList();

      // 3. Load Juz
      final String juzRaw = await rootBundle.loadString('assets/quran/quran_juz.json');
      final List<dynamic> juzJson = jsonDecode(juzRaw);
      _juzList = juzJson.map((j) => QuranJuzModel.fromJson(j as Map<String, dynamic>)).toList();

      // 4. Load Sajdahs
      final String sajdahsRaw = await rootBundle.loadString('assets/quran/quran_sajdahs.json');
      final List<dynamic> sajdahsJson = jsonDecode(sajdahsRaw);
      _sajdahsList = sajdahsJson.map((j) => QuranSajdahModel.fromJson(j as Map<String, dynamic>)).toList();

      // 5. Load Verses (6,236 Ayahs)
      final String versesRaw = await rootBundle.loadString('assets/quran/quran_verses.json');
      final List<dynamic> versesJson = jsonDecode(versesRaw);

      final Map<int, List<AyahModel>> surahMap = {};
      final Map<int, List<AyahModel>> pageMap = {};
      final Map<int, List<AyahModel>> juzMap = {};
      final List<AyahModel> allList = [];

      for (final v in versesJson) {
        final ayah = AyahModel.fromJson(v as Map<String, dynamic>);
        allList.add(ayah);
        surahMap.putIfAbsent(ayah.surahNumber, () => []).add(ayah);
        pageMap.putIfAbsent(ayah.page, () => []).add(ayah);
        juzMap.putIfAbsent(ayah.juz, () => []).add(ayah);
      }

      _surahCache = surahMap;
      _pageCache = pageMap;
      _juzCache = juzMap;
      _allAyahsCache = allList;
      _isLoaded = true;
    } catch (e) {
      // Fallback: load tanzil text if available
      await _loadTanzilFallback();
    }
  }

  static Future<void> _loadTanzilFallback() async {
    try {
      final String raw = await rootBundle.loadString('assets/quran/tanzil_uthmani_v1.1.txt');
      final lines = raw.split('\n');

      final Map<int, List<AyahModel>> surahMap = {};
      final Map<int, List<AyahModel>> pageMap = {};
      final List<AyahModel> allList = [];

      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

        final parts = trimmed.split('|');
        if (parts.length >= 3) {
          final surahNumber = int.tryParse(parts[0]) ?? 1;
          final ayahNumber = int.tryParse(parts[1]) ?? 1;
          final textUthmani = parts[2].trim();

          final calculatedPage = _estimatePage(surahNumber, ayahNumber);
          final calculatedJuz = _estimateJuz(surahNumber, ayahNumber);

          final ayah = AyahModel(
            surahNumber: surahNumber,
            numberInSurah: ayahNumber,
            textUthmani: textUthmani,
            juz: calculatedJuz,
            page: calculatedPage,
          );

          allList.add(ayah);
          surahMap.putIfAbsent(surahNumber, () => []).add(ayah);
          pageMap.putIfAbsent(calculatedPage, () => []).add(ayah);
        }
      }

      _surahCache = surahMap;
      _pageCache = pageMap;
      _allAyahsCache = allList;
      _isLoaded = true;
    } catch (_) {}
  }

  /// Get Surah by its 1-indexed number (1 to 114)
  static SurahModel? getSurah(int surahNumber) {
    try {
      return allSurahs.firstWhere((s) => s.number == surahNumber);
    } catch (_) {
      return null;
    }
  }

  /// Get all Ayahs of a specific Surah
  static List<AyahModel> getSurahAyahs(int surahNumber) {
    if (_surahCache.containsKey(surahNumber)) {
      return _surahCache[surahNumber]!;
    }
    return [];
  }

  /// Get all Ayahs of a specific Page (1 to 604)
  static List<AyahModel> getPageAyahs(int pageNumber) {
    if (_pageCache.containsKey(pageNumber)) {
      return _pageCache[pageNumber]!;
    }
    return [];
  }

  /// Get all Ayahs of a specific Juz (1 to 30)
  static List<AyahModel> getJuzAyahs(int juzNumber) {
    if (_juzCache.containsKey(juzNumber)) {
      return _juzCache[juzNumber]!;
    }
    return [];
  }

  /// Get single Ayah by Surah and Ayah numbers
  static AyahModel? getAyah(int surahNumber, int ayahNumber) {
    final surahAyahs = getSurahAyahs(surahNumber);
    try {
      return surahAyahs.firstWhere((a) => a.numberInSurah == ayahNumber);
    } catch (_) {
      return null;
    }
  }

  /// Total number of standardized pages in the Madinah Mushaf
  static const int totalMushafPages = 604;

  /// Get Page metadata
  static QuranPageModel? getPageInfo(int pageNumber) {
    try {
      return _pagesList.firstWhere((p) => p.pageNumber == pageNumber);
    } catch (_) {
      return null;
    }
  }

  /// Returns the canonical asset path for a Mushaf page image (1 to 604)
  /// Throws [ArgumentError] if [pageNumber] is < 1 or > 604.
  static String getMushafPageAssetPath(int pageNumber) {
    if (pageNumber < 1 || pageNumber > totalMushafPages) {
      throw ArgumentError.value(
        pageNumber,
        'pageNumber',
        'Mushaf page number must be strictly between 1 and $totalMushafPages',
      );
    }
    final padded = pageNumber.toString().padLeft(3, '0');
    return 'assets/quran/mushaf/pages/$padded.webp';
  }

  /// Clamps an arbitrary integer into the valid Mushaf page range [1, 604]
  static int clampPageNumber(int pageNumber) {
    return pageNumber.clamp(1, totalMushafPages);
  }

  /// Get the primary Surah that appears on a given page
  static SurahModel? getSurahForPage(int pageNumber) {
    final pageInfo = getPageInfo(pageNumber);
    if (pageInfo != null) {
      return getSurah(pageInfo.startSurahNumber);
    }
    for (int i = 0; i < allSurahs.length; i++) {
      final s = allSurahs[i];
      final nextStart = (i + 1 < allSurahs.length) ? allSurahs[i + 1].startPage : 605;
      if (pageNumber >= s.startPage && pageNumber < nextStart) {
        return s;
      }
    }
    return allSurahs.isNotEmpty ? allSurahs.first : null;
  }

  /// Get the Juz metadata for a given page number (1 to 604)
  static QuranJuzModel? getJuzForPage(int pageNumber) {
    final clamped = clampPageNumber(pageNumber);
    for (final j in allJuz) {
      if (clamped >= j.startPage && clamped <= j.endPage) {
        return j;
      }
    }
    return allJuz.isNotEmpty ? allJuz.first : null;
  }

  /// Formats an integer into Eastern Arabic digits (e.g. 1 -> ١, 604 -> ٦٠٤)
  static String toArabicDigits(int number) {
    const arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((char) {
      final digit = int.tryParse(char);
      return digit != null ? arabicDigits[digit] : char;
    }).join();
  }

  /// Search across all Ayahs in the Holy Quran
  static List<AyahModel> searchAyahs(String query) {
    if (query.trim().isEmpty) return [];
    final cleanQuery = _normalizeArabic(query.trim());

    return _allAyahsCache.where((ayah) {
      final normalizedText = _normalizeArabic(ayah.textUthmani);
      return normalizedText.contains(cleanQuery);
    }).toList();
  }

  /// Save user's Last Read bookmark
  static Future<void> saveLastRead({
    required int surahNumber,
    required int ayahNumber,
    required int pageNumber,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastReadSurahKey, surahNumber);
    await prefs.setInt(_lastReadAyahKey, ayahNumber);
    await prefs.setInt(_lastReadPageKey, pageNumber);
  }

  /// Retrieve user's Last Read bookmark
  static Future<Map<String, int>?> getLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    final surah = prefs.getInt(_lastReadSurahKey);
    final ayah = prefs.getInt(_lastReadAyahKey);
    final page = prefs.getInt(_lastReadPageKey);

    if (surah != null && ayah != null) {
      return {
        'surah': surah,
        'ayah': ayah,
        'page': page ?? 1,
      };
    }
    return null;
  }

  static String _normalizeArabic(String text) {
    var s = text;
    s = s.replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED\u06E1]'), ''); // Tashkeel & Uthmani marks
    s = s.replaceAll(RegExp(r'[إأآاٱ]'), 'ا');
    s = s.replaceAll('ة', 'ه');
    s = s.replaceAll('ى', 'ي');
    s = s.replaceAll('ؤ', 'و');
    s = s.replaceAll('ئ', 'ي');
    return s.toLowerCase();
  }

  static int _estimateJuz(int surah, int ayah) {
    if (surah == 1) return 1;
    if (surah == 2) {
      if (ayah <= 141) return 1;
      if (ayah <= 252) return 2;
      return 3;
    }
    if (surah == 3) {
      if (ayah <= 92) return 3;
      return 4;
    }
    if (surah == 4) {
      if (ayah <= 23) return 4;
      if (ayah <= 147) return 5;
      return 6;
    }
    return ((surah * 30) ~/ 114).clamp(1, 30);
  }

  static int _estimatePage(int surah, int ayah) {
    if (surah == 1) return 1;
    if (surah == 2) {
      return (2 + (ayah ~/ 6)).clamp(2, 49);
    }
    if (surah == 3) {
      return (50 + (ayah ~/ 8)).clamp(50, 76);
    }
    return ((surah * 604) ~/ 114).clamp(1, 604);
  }

  static const List<SurahModel> _fallbackSurahs = [
    SurahModel(number: 1, nameArabic: 'الفاتحة', nameEnglish: 'Al-Fatihah', revelationType: 'مكية', totalAyahs: 7, startPage: 1),
    SurahModel(number: 2, nameArabic: 'البقرة', nameEnglish: 'Al-Baqarah', revelationType: 'مدنية', totalAyahs: 286, startPage: 2),
    SurahModel(number: 3, nameArabic: 'آل عمران', nameEnglish: 'Ali \'Imran', revelationType: 'مدنية', totalAyahs: 200, startPage: 50),
    SurahModel(number: 4, nameArabic: 'النساء', nameEnglish: 'An-Nisa', revelationType: 'مدنية', totalAyahs: 176, startPage: 77),
    SurahModel(number: 5, nameArabic: 'المائدة', nameEnglish: 'Al-Ma\'idah', revelationType: 'مدنية', totalAyahs: 120, startPage: 106),
    SurahModel(number: 6, nameArabic: 'الأنعام', nameEnglish: 'Al-An\'am', revelationType: 'مكية', totalAyahs: 165, startPage: 128),
    SurahModel(number: 7, nameArabic: 'الأعراف', nameEnglish: 'Al-A\'raf', revelationType: 'مكية', totalAyahs: 206, startPage: 151),
    SurahModel(number: 8, nameArabic: 'الأنفال', nameEnglish: 'Al-Anfal', revelationType: 'مدنية', totalAyahs: 75, startPage: 177),
    SurahModel(number: 9, nameArabic: 'التوبة', nameEnglish: 'At-Tawbah', revelationType: 'مدنية', totalAyahs: 129, startPage: 187),
    SurahModel(number: 10, nameArabic: 'يونس', nameEnglish: 'Yunus', revelationType: 'مكية', totalAyahs: 109, startPage: 208),
    SurahModel(number: 11, nameArabic: 'هود', nameEnglish: 'Hud', revelationType: 'مكية', totalAyahs: 123, startPage: 221),
    SurahModel(number: 12, nameArabic: 'يوسف', nameEnglish: 'Yusuf', revelationType: 'مكية', totalAyahs: 111, startPage: 235),
    SurahModel(number: 13, nameArabic: 'الرعد', nameEnglish: 'Ar-Ra\'d', revelationType: 'مدنية', totalAyahs: 43, startPage: 249),
    SurahModel(number: 14, nameArabic: 'إبراهيم', nameEnglish: 'Ibrahim', revelationType: 'مكية', totalAyahs: 52, startPage: 255),
    SurahModel(number: 15, nameArabic: 'الحجر', nameEnglish: 'Al-Hijr', revelationType: 'مكية', totalAyahs: 99, startPage: 262),
    SurahModel(number: 16, nameArabic: 'النحل', nameEnglish: 'An-Nahl', revelationType: 'مكية', totalAyahs: 128, startPage: 267),
    SurahModel(number: 17, nameArabic: 'الإسراء', nameEnglish: 'Al-Isra', revelationType: 'مكية', totalAyahs: 111, startPage: 282),
    SurahModel(number: 18, nameArabic: 'الكهف', nameEnglish: 'Al-Kahf', revelationType: 'مكية', totalAyahs: 110, startPage: 293),
    SurahModel(number: 19, nameArabic: 'مريم', nameEnglish: 'Maryam', revelationType: 'مكية', totalAyahs: 98, startPage: 305),
    SurahModel(number: 20, nameArabic: 'طه', nameEnglish: 'Taha', revelationType: 'مكية', totalAyahs: 135, startPage: 312),
    SurahModel(number: 21, nameArabic: 'الأنبياء', nameEnglish: 'Al-Anbiya', revelationType: 'مكية', totalAyahs: 112, startPage: 322),
    SurahModel(number: 22, nameArabic: 'الحج', nameEnglish: 'Al-Hajj', revelationType: 'مدنية', totalAyahs: 78, startPage: 332),
    SurahModel(number: 23, nameArabic: 'المؤمنون', nameEnglish: 'Al-Mu\'minun', revelationType: 'مكية', totalAyahs: 118, startPage: 342),
    SurahModel(number: 24, nameArabic: 'النور', nameEnglish: 'An-Nur', revelationType: 'مدنية', totalAyahs: 64, startPage: 350),
    SurahModel(number: 25, nameArabic: 'الفرقان', nameEnglish: 'Al-Furqan', revelationType: 'مكية', totalAyahs: 77, startPage: 359),
    SurahModel(number: 26, nameArabic: 'الشعراء', nameEnglish: 'Ash-Shu\'ara', revelationType: 'مكية', totalAyahs: 227, startPage: 367),
    SurahModel(number: 27, nameArabic: 'النمل', nameEnglish: 'An-Naml', revelationType: 'مكية', totalAyahs: 93, startPage: 377),
    SurahModel(number: 28, nameArabic: 'القصص', nameEnglish: 'Al-Qasas', revelationType: 'مكية', totalAyahs: 88, startPage: 385),
    SurahModel(number: 29, nameArabic: 'العنكبوت', nameEnglish: 'Al-\'Ankabut', revelationType: 'مكية', totalAyahs: 69, startPage: 396),
    SurahModel(number: 30, nameArabic: 'الروم', nameEnglish: 'Ar-Rum', revelationType: 'مكية', totalAyahs: 60, startPage: 404),
    SurahModel(number: 31, nameArabic: 'لقمان', nameEnglish: 'Luqman', revelationType: 'مكية', totalAyahs: 34, startPage: 411),
    SurahModel(number: 32, nameArabic: 'السجدة', nameEnglish: 'As-Sajdah', revelationType: 'مكية', totalAyahs: 30, startPage: 415),
    SurahModel(number: 33, nameArabic: 'الأحزاب', nameEnglish: 'Al-Ahzab', revelationType: 'مدنية', totalAyahs: 73, startPage: 418),
    SurahModel(number: 34, nameArabic: 'سبأ', nameEnglish: 'Saba', revelationType: 'مكية', totalAyahs: 54, startPage: 428),
    SurahModel(number: 35, nameArabic: 'فاطر', nameEnglish: 'Fatir', revelationType: 'مكية', totalAyahs: 45, startPage: 434),
    SurahModel(number: 36, nameArabic: 'يس', nameEnglish: 'Yaseen', revelationType: 'مكية', totalAyahs: 83, startPage: 440),
    SurahModel(number: 37, nameArabic: 'الصافات', nameEnglish: 'As-Saffat', revelationType: 'مكية', totalAyahs: 182, startPage: 446),
    SurahModel(number: 38, nameArabic: 'ص', nameEnglish: 'Sad', revelationType: 'مكية', totalAyahs: 88, startPage: 453),
    SurahModel(number: 39, nameArabic: 'الزمر', nameEnglish: 'Az-Zumar', revelationType: 'مكية', totalAyahs: 75, startPage: 458),
    SurahModel(number: 40, nameArabic: 'غافر', nameEnglish: 'Ghafir', revelationType: 'مكية', totalAyahs: 85, startPage: 467),
    SurahModel(number: 41, nameArabic: 'فصلت', nameEnglish: 'Fussilat', revelationType: 'مكية', totalAyahs: 54, startPage: 477),
    SurahModel(number: 42, nameArabic: 'الشورى', nameEnglish: 'Ash-Shura', revelationType: 'مكية', totalAyahs: 53, startPage: 483),
    SurahModel(number: 43, nameArabic: 'الزخرف', nameEnglish: 'Az-Zukhruf', revelationType: 'مكية', totalAyahs: 89, startPage: 489),
    SurahModel(number: 44, nameArabic: 'الدخان', nameEnglish: 'Ad-Dukhan', revelationType: 'مكية', totalAyahs: 59, startPage: 496),
    SurahModel(number: 45, nameArabic: 'الجاثية', nameEnglish: 'Al-Jathiyah', revelationType: 'مكية', totalAyahs: 37, startPage: 499),
    SurahModel(number: 46, nameArabic: 'الأحقاف', nameEnglish: 'Al-Ahqaf', revelationType: 'مكية', totalAyahs: 35, startPage: 502),
    SurahModel(number: 47, nameArabic: 'محمد', nameEnglish: 'Muhammad', revelationType: 'مدنية', totalAyahs: 38, startPage: 507),
    SurahModel(number: 48, nameArabic: 'الفتح', nameEnglish: 'Al-Fath', revelationType: 'مدنية', totalAyahs: 29, startPage: 511),
    SurahModel(number: 49, nameArabic: 'الحجرات', nameEnglish: 'Al-Hujurat', revelationType: 'مدنية', totalAyahs: 18, startPage: 515),
    SurahModel(number: 50, nameArabic: 'ق', nameEnglish: 'Qaf', revelationType: 'مكية', totalAyahs: 45, startPage: 518),
    SurahModel(number: 51, nameArabic: 'الذاريات', nameEnglish: 'Adh-Dhariyat', revelationType: 'مكية', totalAyahs: 60, startPage: 520),
    SurahModel(number: 52, nameArabic: 'الطور', nameEnglish: 'At-Tur', revelationType: 'مكية', totalAyahs: 49, startPage: 523),
    SurahModel(number: 53, nameArabic: 'النجم', nameEnglish: 'An-Najm', revelationType: 'مكية', totalAyahs: 62, startPage: 526),
    SurahModel(number: 54, nameArabic: 'القمر', nameEnglish: 'Al-Qamar', revelationType: 'مكية', totalAyahs: 55, startPage: 528),
    SurahModel(number: 55, nameArabic: 'الرحمن', nameEnglish: 'Ar-Rahman', revelationType: 'مدنية', totalAyahs: 78, startPage: 531),
    SurahModel(number: 56, nameArabic: 'الواقعة', nameEnglish: 'Al-Waqi\'ah', revelationType: 'مكية', totalAyahs: 96, startPage: 534),
    SurahModel(number: 57, nameArabic: 'الحديد', nameEnglish: 'Al-Hadid', revelationType: 'مدنية', totalAyahs: 29, startPage: 537),
    SurahModel(number: 58, nameArabic: 'المجادلة', nameEnglish: 'Al-Mujadila', revelationType: 'مدنية', totalAyahs: 22, startPage: 542),
    SurahModel(number: 59, nameArabic: 'الحشر', nameEnglish: 'Al-Hashr', revelationType: 'مدنية', totalAyahs: 24, startPage: 545),
    SurahModel(number: 60, nameArabic: 'الممتحنة', nameEnglish: 'Al-Mumtahanah', revelationType: 'مدنية', totalAyahs: 13, startPage: 549),
    SurahModel(number: 61, nameArabic: 'الصف', nameEnglish: 'As-Saff', revelationType: 'مدنية', totalAyahs: 14, startPage: 551),
    SurahModel(number: 62, nameArabic: 'الجمعة', nameEnglish: 'Al-Jumu\'ah', revelationType: 'مدنية', totalAyahs: 11, startPage: 553),
    SurahModel(number: 63, nameArabic: 'المنافقون', nameEnglish: 'Al-Munafiqun', revelationType: 'مدنية', totalAyahs: 11, startPage: 554),
    SurahModel(number: 64, nameArabic: 'التغابن', nameEnglish: 'At-Taghabun', revelationType: 'مدنية', totalAyahs: 18, startPage: 556),
    SurahModel(number: 65, nameArabic: 'الطلاق', nameEnglish: 'At-Talaq', revelationType: 'مدنية', totalAyahs: 12, startPage: 558),
    SurahModel(number: 66, nameArabic: 'التحريم', nameEnglish: 'At-Tahrim', revelationType: 'مدنية', totalAyahs: 12, startPage: 560),
    SurahModel(number: 67, nameArabic: 'الملك', nameEnglish: 'Al-Mulk', revelationType: 'مكية', totalAyahs: 30, startPage: 562),
    SurahModel(number: 68, nameArabic: 'القلم', nameEnglish: 'Al-Qalam', revelationType: 'مكية', totalAyahs: 52, startPage: 564),
    SurahModel(number: 69, nameArabic: 'الحاقة', nameEnglish: 'Al-Haqqah', revelationType: 'مكية', totalAyahs: 52, startPage: 566),
    SurahModel(number: 70, nameArabic: 'المعارج', nameEnglish: 'Al-Ma\'arij', revelationType: 'مكية', totalAyahs: 44, startPage: 568),
    SurahModel(number: 71, nameArabic: 'نوح', nameEnglish: 'Nuh', revelationType: 'مكية', totalAyahs: 28, startPage: 570),
    SurahModel(number: 72, nameArabic: 'الجن', nameEnglish: 'Al-Jinn', revelationType: 'مكية', totalAyahs: 28, startPage: 572),
    SurahModel(number: 73, nameArabic: 'المزمل', nameEnglish: 'Al-Muzzammil', revelationType: 'مكية', totalAyahs: 20, startPage: 574),
    SurahModel(number: 74, nameArabic: 'المدثر', nameEnglish: 'Al-Muddaththir', revelationType: 'مكية', totalAyahs: 56, startPage: 575),
    SurahModel(number: 75, nameArabic: 'القيامة', nameEnglish: 'Al-Qiyamah', revelationType: 'مكية', totalAyahs: 40, startPage: 577),
    SurahModel(number: 76, nameArabic: 'الإنسان', nameEnglish: 'Al-Insan', revelationType: 'مدنية', totalAyahs: 31, startPage: 578),
    SurahModel(number: 77, nameArabic: 'المرسلات', nameEnglish: 'Al-Mursalat', revelationType: 'مكية', totalAyahs: 50, startPage: 580),
    SurahModel(number: 78, nameArabic: 'النبأ', nameEnglish: 'An-Naba', revelationType: 'مكية', totalAyahs: 40, startPage: 582),
    SurahModel(number: 79, nameArabic: 'النازعات', nameEnglish: 'An-Nazi\'at', revelationType: 'مكية', totalAyahs: 46, startPage: 583),
    SurahModel(number: 80, nameArabic: 'عبس', nameEnglish: '\'Abasa', revelationType: 'مكية', totalAyahs: 42, startPage: 585),
    SurahModel(number: 81, nameArabic: 'التكوير', nameEnglish: 'At-Takwir', revelationType: 'مكية', totalAyahs: 29, startPage: 586),
    SurahModel(number: 82, nameArabic: 'الانفطار', nameEnglish: 'Al-Infitar', revelationType: 'مكية', totalAyahs: 19, startPage: 587),
    SurahModel(number: 83, nameArabic: 'المطففين', nameEnglish: 'Al-Mutaffifin', revelationType: 'مكية', totalAyahs: 36, startPage: 587),
    SurahModel(number: 84, nameArabic: 'الانشقاق', nameEnglish: 'Al-Inshiqaq', revelationType: 'مكية', totalAyahs: 25, startPage: 589),
    SurahModel(number: 85, nameArabic: 'البروج', nameEnglish: 'Al-Buruj', revelationType: 'مكية', totalAyahs: 22, startPage: 590),
    SurahModel(number: 86, nameArabic: 'الطارق', nameEnglish: 'At-Tariq', revelationType: 'مكية', totalAyahs: 17, startPage: 591),
    SurahModel(number: 87, nameArabic: 'الأعلى', nameEnglish: 'Al-A\'la', revelationType: 'مكية', totalAyahs: 19, startPage: 591),
    SurahModel(number: 88, nameArabic: 'الغاشية', nameEnglish: 'Al-Ghashiyah', revelationType: 'مكية', totalAyahs: 26, startPage: 592),
    SurahModel(number: 89, nameArabic: 'الفجر', nameEnglish: 'Al-Fajr', revelationType: 'مكية', totalAyahs: 30, startPage: 593),
    SurahModel(number: 90, nameArabic: 'البلد', nameEnglish: 'Al-Balad', revelationType: 'مكية', totalAyahs: 20, startPage: 594),
    SurahModel(number: 91, nameArabic: 'الشمس', nameEnglish: 'Ash-Shams', revelationType: 'مكية', totalAyahs: 15, startPage: 595),
    SurahModel(number: 92, nameArabic: 'الليل', nameEnglish: 'Al-Layl', revelationType: 'مكية', totalAyahs: 21, startPage: 595),
    SurahModel(number: 93, nameArabic: 'الضحى', nameEnglish: 'Ad-Duha', revelationType: 'مكية', totalAyahs: 11, startPage: 596),
    SurahModel(number: 94, nameArabic: 'الشرح', nameEnglish: 'Ash-Sharh', revelationType: 'مكية', totalAyahs: 8, startPage: 596),
    SurahModel(number: 95, nameArabic: 'التين', nameEnglish: 'At-Tin', revelationType: 'مكية', totalAyahs: 8, startPage: 597),
    SurahModel(number: 96, nameArabic: 'العلق', nameEnglish: 'Al-\'Alaq', revelationType: 'مكية', totalAyahs: 19, startPage: 597),
    SurahModel(number: 97, nameArabic: 'القدر', nameEnglish: 'Al-Qadr', revelationType: 'مكية', totalAyahs: 5, startPage: 598),
    SurahModel(number: 98, nameArabic: 'البينة', nameEnglish: 'Al-Bayyinah', revelationType: 'مدنية', totalAyahs: 8, startPage: 598),
    SurahModel(number: 99, nameArabic: 'الزلزلة', nameEnglish: 'Az-Zalzalah', revelationType: 'مدنية', totalAyahs: 8, startPage: 599),
    SurahModel(number: 100, nameArabic: 'العاديات', nameEnglish: 'Al-\'Adiyat', revelationType: 'مكية', totalAyahs: 11, startPage: 599),
    SurahModel(number: 101, nameArabic: 'القارعة', nameEnglish: 'Al-Qari\'ah', revelationType: 'مكية', totalAyahs: 11, startPage: 600),
    SurahModel(number: 102, nameArabic: 'التكاثر', nameEnglish: 'At-Takathur', revelationType: 'مكية', totalAyahs: 8, startPage: 600),
    SurahModel(number: 103, nameArabic: 'العصر', nameEnglish: 'Al-\'Asr', revelationType: 'مكية', totalAyahs: 3, startPage: 601),
    SurahModel(number: 104, nameArabic: 'الهمزة', nameEnglish: 'Al-Humazah', revelationType: 'مكية', totalAyahs: 9, startPage: 601),
    SurahModel(number: 105, nameArabic: 'الفيل', nameEnglish: 'Al-Fil', revelationType: 'مكية', totalAyahs: 5, startPage: 601),
    SurahModel(number: 106, nameArabic: 'قريش', nameEnglish: 'Quraysh', revelationType: 'مكية', totalAyahs: 4, startPage: 602),
    SurahModel(number: 107, nameArabic: 'الماعون', nameEnglish: 'Al-Ma\'un', revelationType: 'مكية', totalAyahs: 7, startPage: 602),
    SurahModel(number: 108, nameArabic: 'الكوثر', nameEnglish: 'Al-Kawthar', revelationType: 'مكية', totalAyahs: 3, startPage: 602),
    SurahModel(number: 109, nameArabic: 'الكافرون', nameEnglish: 'Al-Kafirun', revelationType: 'مكية', totalAyahs: 6, startPage: 603),
    SurahModel(number: 110, nameArabic: 'النصر', nameEnglish: 'An-Nasr', revelationType: 'مدنية', totalAyahs: 3, startPage: 603),
    SurahModel(number: 111, nameArabic: 'المسد', nameEnglish: 'Al-Masad', revelationType: 'مكية', totalAyahs: 5, startPage: 603),
    SurahModel(number: 112, nameArabic: 'الإخلاص', nameEnglish: 'Al-Ikhlas', revelationType: 'مكية', totalAyahs: 4, startPage: 604),
    SurahModel(number: 113, nameArabic: 'الفلق', nameEnglish: 'Al-Falaq', revelationType: 'مكية', totalAyahs: 5, startPage: 604),
    SurahModel(number: 114, nameArabic: 'الناس', nameEnglish: 'An-Nas', revelationType: 'مكية', totalAyahs: 6, startPage: 604),
  ];
}
