// ignore_for_file: avoid_print, prefer_interpolation_to_compose_strings, unnecessary_brace_in_string_interps
import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';

void main() async {
  print('=== QURAN DATA AUDIT & VALIDATION TOOL ===');

  final mainJsonFile = File('temp_quran_data/data/mainDataQuran.json');
  final pagesJsonFile = File('temp_quran_data/data/pagesQuran.json');
  final tanzilFile = File('assets/quran/tanzil_uthmani_v1.1.txt');

  if (!mainJsonFile.existsSync()) {
    print('ERROR: mainDataQuran.json not found');
    return;
  }

  // 1. Audit Tanzil current asset
  print('\n--- 1. CURRENT TANZIL ASSET AUDIT ---');
  final tanzilLines = await tanzilFile.readAsLines();
  int tanzilAyahCount = 0;
  Set<int> tanzilSurahs = {};
  Map<String, String> tanzilAyahsMap = {}; // 'surah:ayah' -> text

  for (final line in tanzilLines) {
    final t = line.trim();
    if (t.isEmpty || t.startsWith('#')) continue;
    final parts = t.split('|');
    if (parts.length >= 3) {
      final s = int.parse(parts[0]);
      final a = int.parse(parts[1]);
      final txt = parts[2].trim();
      tanzilSurahs.add(s);
      tanzilAyahCount++;
      tanzilAyahsMap['${s}_${a}'] = txt;
    }
  }
  print('Tanzil Surahs: ${tanzilSurahs.length}');
  print('Tanzil Total Ayahs: $tanzilAyahCount');
  final tanzilBytes = await tanzilFile.readAsBytes();
  print('Tanzil SHA-256: ${sha256.convert(tanzilBytes)}');

  // 2. Audit rn0x mainDataQuran.json
  print('\n--- 2. RN0X / QURAN-DATA AUDIT ---');
  final mainJsonBytes = await mainJsonFile.readAsBytes();
  print('mainDataQuran.json Size: ${(mainJsonBytes.length / (1024*1024)).toStringAsFixed(2)} MB');
  print('mainDataQuran.json SHA-256: ${sha256.convert(mainJsonBytes)}');

  final List<dynamic> surahsList = jsonDecode(utf8.decode(mainJsonBytes));
  print('Total Surahs in JSON: ${surahsList.length}');

  int totalVerses = 0;
  Set<int> pagesSet = {};
  Set<int> juzSet = {};
  int sajdahCount = 0;
  List<Map<String, dynamic>> sajdahList = [];
  Map<String, String> rn0xAyahsMap = {};
  Map<String, int> ayahToPageMap = {};
  Map<String, int> ayahToJuzMap = {};

  int textExactMatches = 0;
  int textDifferences = 0;
  List<String> textDiffSamples = [];

  for (final surah in surahsList) {
    final int surahNum = surah['number'];
    final List<dynamic> verses = surah['verses'];
    totalVerses += verses.length;

    for (final v in verses) {
      final int vNum = v['number'];
      final String textAr = v['text']['ar'];
      final int juz = v['juz'];
      final int page = v['page'];
      final dynamic sajda = v['sajda'];

      pagesSet.add(page);
      juzSet.add(juz);

      if (sajda != false && sajda != null) {
        sajdahCount++;
        sajdahList.add({
          'surah': surahNum,
          'ayah': vNum,
          'sajda': sajda,
        });
      }

      final key = '${surahNum}_${vNum}';
      rn0xAyahsMap[key] = textAr;
      ayahToPageMap[key] = page;
      ayahToJuzMap[key] = juz;

      final tanzilText = tanzilAyahsMap[key];
      if (tanzilText == textAr) {
        textExactMatches++;
      } else {
        textDifferences++;
        if (textDiffSamples.length < 8) {
          textDiffSamples.add('Ayah $key:\n  Tanzil: $tanzilText\n  rn0x:   $textAr');
        }
      }
    }
  }

  print('Total Verses in JSON: $totalVerses');
  print('Pages Range: min=${pagesSet.reduce((a,b)=>a<b?a:b)}, max=${pagesSet.reduce((a,b)=>a>b?a:b)}, total unique pages=${pagesSet.length}');
  print('Juz Range: min=${juzSet.reduce((a,b)=>a<b?a:b)}, max=${juzSet.reduce((a,b)=>a>b?a:b)}, total unique juz=${juzSet.length}');
  print('Total Sajdah Count: $sajdahCount');
  print('\nText Comparison with Tanzil Uthmani v1.1:');
  print('Exact Matches: $textExactMatches / $totalVerses');
  print('Differences: $textDifferences');
  if (textDiffSamples.isNotEmpty) {
    print('Sample Differences:\n' + textDiffSamples.join('\n\n'));
  }

  // 3. Audit pagesQuran.json
  print('\n--- 3. PAGES QURAN AUDIT ---');
  final pagesJsonBytes = await pagesJsonFile.readAsBytes();
  print('pagesQuran.json Size: ${(pagesJsonBytes.length / 1024).toStringAsFixed(2)} KB');
  print('pagesQuran.json SHA-256: ${sha256.convert(pagesJsonBytes)}');
  final List<dynamic> pagesList = jsonDecode(utf8.decode(pagesJsonBytes));
  print('Total Pages in pagesQuran.json: ${pagesList.length}');
  
  // Validate consistency between mainDataQuran pages and pagesQuran start/end
  int pageMappingMismatches = 0;
  for (final pageObj in pagesList) {
    final int pageNum = pageObj['page'];
    final int startSurah = pageObj['start']['surah_number'];
    final int startVerse = pageObj['start']['verse'];
    final int endSurah = pageObj['end']['surah_number'];
    final int endVerse = pageObj['end']['verse'];

    final startKey = '${startSurah}_${startVerse}';
    final endKey = '${endSurah}_${endVerse}';

    if (ayahToPageMap[startKey] != pageNum || ayahToPageMap[endKey] != pageNum) {
      pageMappingMismatches++;
      if (pageMappingMismatches <= 3) {
        print('Page $pageNum mismatch: start $startKey (page ${ayahToPageMap[startKey]}), end $endKey (page ${ayahToPageMap[endKey]})');
      }
    }
  }
  print('Page start/end consistency with verse page mappings: ${pageMappingMismatches == 0 ? "100% CONSISTENT" : "$pageMappingMismatches mismatches"}');

  print('\nSajdah Locations (${sajdahList.length}):');
  for (final s in sajdahList) {
    print('Surah ${s['surah']}, Ayah ${s['ayah']} (sajda: ${s['sajda']})');
  }
}
