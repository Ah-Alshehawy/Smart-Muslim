// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';

void main() async {
  print('====================================================');
  print('CANONICAL QURAN DATA GENERATOR & VALIDATION PIPELINE');
  print('====================================================');

  final mainJsonFile = File('temp_quran_data/data/mainDataQuran.json');
  final pagesJsonFile = File('temp_quran_data/data/pagesQuran.json');

  if (!mainJsonFile.existsSync()) {
    print('ERROR: temp_quran_data/data/mainDataQuran.json does not exist');
    exit(1);
  }

  final mainJsonBytes = await mainJsonFile.readAsBytes();
  final List<dynamic> rawSurahs = jsonDecode(utf8.decode(mainJsonBytes));

  final pagesJsonBytes = await pagesJsonFile.readAsBytes();
  final List<dynamic> rawPages = jsonDecode(utf8.decode(pagesJsonBytes));

  print('1. Validating Surah and Ayah structural invariants...');
  if (rawSurahs.length != 114) {
    print('VALIDATION ERROR: Expected 114 Surahs, found ${rawSurahs.length}');
    exit(1);
  }
  if (rawPages.length != 604) {
    print('VALIDATION ERROR: Expected 604 Pages, found ${rawPages.length}');
    exit(1);
  }

  final List<Map<String, dynamic>> canonicalSurahs = [];
  final List<Map<String, dynamic>> canonicalVerses = [];
  final List<Map<String, dynamic>> canonicalPages = [];
  final List<Map<String, dynamic>> canonicalJuz = [];
  final List<Map<String, dynamic>> canonicalSajdahs = [];

  final Map<int, int> surahStartPage = {};
  final Map<int, int> juzStartPage = {};
  final Set<int> seenAyahKeys = {};

  int totalAyahCount = 0;

  for (final rawSurah in rawSurahs) {
    final int surahNumber = rawSurah['number'];
    final String nameAr = rawSurah['name']['ar'];
    final String nameEn = rawSurah['name']['en'];
    final String nameTransliteration = rawSurah['name']['transliteration'] ?? '';
    final String revPlaceAr = rawSurah['revelation_place']['ar'];
    final String revPlaceEn = rawSurah['revelation_place']['en'];
    final int versesCount = rawSurah['verses_count'];
    final int wordsCount = rawSurah['words_count'] ?? 0;
    final int lettersCount = rawSurah['letters_count'] ?? 0;

    final List<dynamic> verses = rawSurah['verses'];
    if (verses.length != versesCount) {
      print('VALIDATION ERROR: Surah $surahNumber count mismatch: verses_count=$versesCount, actual=${verses.length}');
      exit(1);
    }

    // First verse page is surah start page
    final int firstVersePage = verses.first['page'];
    surahStartPage[surahNumber] = firstVersePage;

    for (final v in verses) {
      final int ayahNumber = v['number'];
      final String textAr = v['text']['ar'].trim();
      final String textEn = (v['text']['en'] ?? '').trim();
      final int juz = v['juz'];
      final int page = v['page'];
      final dynamic sajdaRaw = v['sajda'];

      if (textAr.isEmpty) {
        print('VALIDATION ERROR: Empty Arabic text in Surah $surahNumber Ayah $ayahNumber');
        exit(1);
      }

      final key = surahNumber * 1000 + ayahNumber;
      if (seenAyahKeys.contains(key)) {
        print('VALIDATION ERROR: Duplicate Ayah key $surahNumber:$ayahNumber');
        exit(1);
      }
      seenAyahKeys.add(key);

      if (!juzStartPage.containsKey(juz)) {
        juzStartPage[juz] = page;
      }

      bool isSajdah = false;
      int? sajdahId;
      bool? sajdahRecommended;
      bool? sajdahObligatory;

      if (sajdaRaw != null && sajdaRaw != false) {
        isSajdah = true;
        if (sajdaRaw is Map) {
          sajdahId = sajdaRaw['id'];
          sajdahRecommended = sajdaRaw['recommended'];
          sajdahObligatory = sajdaRaw['obligatory'];
        }
        canonicalSajdahs.add({
          'surah_number': surahNumber,
          'ayah_number': ayahNumber,
          'sajda_id': sajdahId,
          'recommended': sajdahRecommended ?? false,
          'obligatory': sajdahObligatory ?? false,
          'page': page,
          'juz': juz,
        });
      }

      canonicalVerses.add({
        'surah': surahNumber,
        'ayah': ayahNumber,
        'text': textAr,
        'text_en': textEn,
        'juz': juz,
        'page': page,
        'sajda': isSajdah,
        if (sajdahId != null) 'sajda_id': sajdahId,
      });

      totalAyahCount++;
    }

    canonicalSurahs.add({
      'number': surahNumber,
      'name_ar': nameAr,
      'name_en': nameEn,
      'name_transliteration': nameTransliteration,
      'revelation_place_ar': revPlaceAr,
      'revelation_place_en': revPlaceEn,
      'verses_count': versesCount,
      'words_count': wordsCount,
      'letters_count': lettersCount,
      'start_page': firstVersePage,
    });
  }

  print('Validated Surahs: ${canonicalSurahs.length}');
  print('Validated Total Ayahs: $totalAyahCount (Expected: 6236)');
  if (totalAyahCount != 6236) {
    print('VALIDATION ERROR: Total Ayahs must be 6236, got $totalAyahCount');
    exit(1);
  }

  // Process Pages
  for (final rawPage in rawPages) {
    final int pageNum = rawPage['page'];
    final int startSurah = rawPage['start']['surah_number'];
    final int startVerse = rawPage['start']['verse'];
    final int endSurah = rawPage['end']['surah_number'];
    final int endVerse = rawPage['end']['verse'];

    canonicalPages.add({
      'page': pageNum,
      'start_surah': startSurah,
      'start_ayah': startVerse,
      'end_surah': endSurah,
      'end_ayah': endVerse,
    });
  }

  // Process 30 Juz
  for (int j = 1; j <= 30; j++) {
    final juzVerses = canonicalVerses.where((v) => v['juz'] == j).toList();
    if (juzVerses.isNotEmpty) {
      final first = juzVerses.first;
      final last = juzVerses.last;
      canonicalJuz.add({
        'juz': j,
        'start_surah': first['surah'],
        'start_ayah': first['ayah'],
        'end_surah': last['surah'],
        'end_ayah': last['ayah'],
        'start_page': first['page'],
        'end_page': last['page'],
        'total_ayahs': juzVerses.length,
      });
    }
  }

  print('Validated Pages: ${canonicalPages.length}');
  print('Validated Juz: ${canonicalJuz.length}');
  print('Validated Sajdahs: ${canonicalSajdahs.length}');

  // Ensure output directory exists
  final outDir = Directory('assets/quran');
  if (!outDir.existsSync()) {
    outDir.createSync(recursive: true);
  }

  final surahsJsonStr = const JsonEncoder.withIndent('  ').convert(canonicalSurahs);
  final pagesJsonStr = const JsonEncoder.withIndent('  ').convert(canonicalPages);
  final juzJsonStr = const JsonEncoder.withIndent('  ').convert(canonicalJuz);
  final sajdahsJsonStr = const JsonEncoder.withIndent('  ').convert(canonicalSajdahs);
  final versesJsonStr = jsonEncode(canonicalVerses);

  final surahsFile = File('assets/quran/quran_surahs.json');
  final pagesFile = File('assets/quran/quran_pages.json');
  final juzFile = File('assets/quran/quran_juz.json');
  final sajdahsFile = File('assets/quran/quran_sajdahs.json');
  final versesFile = File('assets/quran/quran_verses.json');

  await surahsFile.writeAsString(surahsJsonStr, encoding: utf8);
  await pagesFile.writeAsString(pagesJsonStr, encoding: utf8);
  await juzFile.writeAsString(juzJsonStr, encoding: utf8);
  await sajdahsFile.writeAsString(sajdahsJsonStr, encoding: utf8);
  await versesFile.writeAsString(versesJsonStr, encoding: utf8);

  final surahsSha = sha256.convert(await surahsFile.readAsBytes()).toString();
  final pagesSha = sha256.convert(await pagesFile.readAsBytes()).toString();
  final juzSha = sha256.convert(await juzFile.readAsBytes()).toString();
  final sajdahsSha = sha256.convert(await sajdahsFile.readAsBytes()).toString();
  final versesSha = sha256.convert(await versesFile.readAsBytes()).toString();

  final manifest = {
    'source': 'https://github.com/rn0x/Quran-Data',
    'source_commit': '1341b85d7c5650bf12a0cb4e2da24a8342f1399f',
    'source_license': 'MIT',
    'generator_version': '1.0.0',
    'generated_at': DateTime.now().toUtc().toIso8601String(),
    'statistics': {
      'surahs_count': canonicalSurahs.length,
      'ayahs_count': canonicalVerses.length,
      'pages_count': canonicalPages.length,
      'juz_count': canonicalJuz.length,
      'sajdahs_count': canonicalSajdahs.length,
    },
    'artifacts': {
      'quran_surahs.json': {
        'path': 'assets/quran/quran_surahs.json',
        'size_bytes': surahsFile.lengthSync(),
        'sha256': surahsSha,
      },
      'quran_pages.json': {
        'path': 'assets/quran/quran_pages.json',
        'size_bytes': pagesFile.lengthSync(),
        'sha256': pagesSha,
      },
      'quran_juz.json': {
        'path': 'assets/quran/quran_juz.json',
        'size_bytes': juzFile.lengthSync(),
        'sha256': juzSha,
      },
      'quran_sajdahs.json': {
        'path': 'assets/quran/quran_sajdahs.json',
        'size_bytes': sajdahsFile.lengthSync(),
        'sha256': sajdahsSha,
      },
      'quran_verses.json': {
        'path': 'assets/quran/quran_verses.json',
        'size_bytes': versesFile.lengthSync(),
        'sha256': versesSha,
      },
    }
  };

  final manifestFile = File('assets/quran/quran_manifest.json');
  await manifestFile.writeAsString(const JsonEncoder.withIndent('  ').convert(manifest), encoding: utf8);

  print('\n=== CANONICAL ASSETS GENERATED & VERIFIED ===');
  print('Surahs JSON : ${surahsFile.lengthSync()} bytes | SHA256: $surahsSha');
  print('Pages JSON  : ${pagesFile.lengthSync()} bytes | SHA256: $pagesSha');
  print('Juz JSON    : ${juzFile.lengthSync()} bytes | SHA256: $juzSha');
  print('Sajdahs JSON: ${sajdahsFile.lengthSync()} bytes | SHA256: $sajdahsSha');
  print('Verses JSON : ${versesFile.lengthSync()} bytes (${(versesFile.lengthSync()/(1024*1024)).toStringAsFixed(2)} MB) | SHA256: $versesSha');
  print('Manifest    : ${manifestFile.path}');
}
