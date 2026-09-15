import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_muslim/features/quran/domain/ayah_model.dart';
import 'package:smart_muslim/features/quran/domain/quran_juz_model.dart';
import 'package:smart_muslim/features/quran/domain/quran_page_model.dart';
import 'package:smart_muslim/features/quran/domain/surah_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Quran Data Invariants & Canonical Integrity Tests', () {
    test('Surah metadata contains exactly 114 Surahs with unique consecutive IDs', () {
      final file = File('assets/quran/quran_surahs.json');
      expect(file.existsSync(), isTrue);

      final List<dynamic> list = jsonDecode(file.readAsStringSync());
      expect(list.length, equals(114));

      for (int i = 0; i < 114; i++) {
        final surah = list[i];
        expect(surah['number'], equals(i + 1));
        expect(surah['name_ar'], isNotEmpty);
        expect(surah['name_en'], isNotEmpty);
        expect(surah['verses_count'], greaterThan(0));
        expect(surah['start_page'], inInclusiveRange(1, 604));
      }

      expect(list.first['name_ar'], equals('الفاتحة'));
      expect(list.last['name_ar'], equals('الناس'));
    });

    test('Sum of total ayahs across all 114 surahs matches exactly 6236', () {
      final file = File('assets/quran/quran_surahs.json');
      final List<dynamic> list = jsonDecode(file.readAsStringSync());
      final total = list.fold<int>(0, (sum, s) => sum + (s['verses_count'] as int));
      expect(total, equals(6236));
    });

    test('Canonical verses dataset contains exactly 6236 Ayahs with valid structure', () {
      final file = File('assets/quran/quran_verses.json');
      expect(file.existsSync(), isTrue);

      final List<dynamic> verses = jsonDecode(file.readAsStringSync());
      expect(verses.length, equals(6236));

      final Set<String> uniqueKeys = {};
      for (final v in verses) {
        final int surah = v['surah'];
        final int ayah = v['ayah'];
        final String text = v['text'];
        final int juz = v['juz'];
        final int page = v['page'];

        expect(surah, inInclusiveRange(1, 114));
        expect(ayah, greaterThan(0));
        expect(text.trim(), isNotEmpty);
        expect(juz, inInclusiveRange(1, 30));
        expect(page, inInclusiveRange(1, 604));

        final key = '${surah}_$ayah';
        expect(uniqueKeys.contains(key), isFalse, reason: 'Duplicate key $key');
        uniqueKeys.add(key);
      }
      expect(uniqueKeys.length, equals(6236));
    });

    test('Canonical pages dataset contains exactly 604 pages (Madinah Mushaf Standard)', () {
      final file = File('assets/quran/quran_pages.json');
      expect(file.existsSync(), isTrue);

      final List<dynamic> pages = jsonDecode(file.readAsStringSync());
      expect(pages.length, equals(604));

      for (int i = 0; i < 604; i++) {
        final p = pages[i];
        expect(p['page'], equals(i + 1));
        expect(p['start_surah'], inInclusiveRange(1, 114));
        expect(p['end_surah'], inInclusiveRange(1, 114));
        expect(p['start_ayah'], greaterThan(0));
        expect(p['end_ayah'], greaterThan(0));
      }

      // Page 1 is Al-Fatihah 1-7
      expect(pages[0]['start_surah'], equals(1));
      expect(pages[0]['start_ayah'], equals(1));
      expect(pages[0]['end_surah'], equals(1));
      expect(pages[0]['end_ayah'], equals(7));

      // Page 604 ends at Surah 114 Ayah 6
      expect(pages[603]['end_surah'], equals(114));
      expect(pages[603]['end_ayah'], equals(6));
    });

    test('Canonical Juz dataset contains exactly 30 Juz', () {
      final file = File('assets/quran/quran_juz.json');
      expect(file.existsSync(), isTrue);

      final List<dynamic> juzList = jsonDecode(file.readAsStringSync());
      expect(juzList.length, equals(30));

      int sumAyahs = 0;
      for (int j = 0; j < 30; j++) {
        final juz = juzList[j];
        expect(juz['juz'], equals(j + 1));
        expect(juz['start_page'], inInclusiveRange(1, 604));
        expect(juz['end_page'], inInclusiveRange(1, 604));
        sumAyahs += (juz['total_ayahs'] as int);
      }
      expect(sumAyahs, equals(6236));
    });

    test('Canonical Sajdah dataset contains exactly 15 authentic Sajdah positions', () {
      final file = File('assets/quran/quran_sajdahs.json');
      expect(file.existsSync(), isTrue);

      final List<dynamic> sajdahs = jsonDecode(file.readAsStringSync());
      expect(sajdahs.length, equals(15));

      // First Sajdah is Al-Araf (7:206)
      expect(sajdahs.first['surah_number'], equals(7));
      expect(sajdahs.first['ayah_number'], equals(206));

      // Last Sajdah is Al-Alaq (96:19)
      expect(sajdahs.last['surah_number'], equals(96));
      expect(sajdahs.last['ayah_number'], equals(19));
    });

    test('Quran Manifest matches actual SHA-256 hashes and file sizes', () {
      final manifestFile = File('assets/quran/quran_manifest.json');
      expect(manifestFile.existsSync(), isTrue);

      final Map<String, dynamic> manifest = jsonDecode(manifestFile.readAsStringSync());
      final artifacts = manifest['artifacts'] as Map<String, dynamic>;

      for (final entry in artifacts.entries) {
        final path = entry.value['path'] as String;
        final expectedSha = entry.value['sha256'] as String;
        final expectedSize = entry.value['size_bytes'] as int;

        final targetFile = File(path);
        expect(targetFile.existsSync(), isTrue, reason: '$path must exist');
        expect(targetFile.lengthSync(), equals(expectedSize), reason: '$path size mismatch');

        final actualSha = sha256.convert(targetFile.readAsBytesSync()).toString();
        expect(actualSha, equals(expectedSha), reason: '$path SHA256 mismatch');
      }
    });
  });

  group('Quran Domain Models Serialization Tests', () {
    test('SurahModel fromJson and toJson roundtrip', () {
      const model = SurahModel(
        number: 1,
        nameArabic: 'الفاتحة',
        nameEnglish: 'The Opening',
        nameTransliteration: 'Al-Fatihah',
        revelationType: 'مكية',
        totalAyahs: 7,
        wordsCount: 29,
        lettersCount: 139,
        startPage: 1,
      );

      final json = model.toJson();
      final restored = SurahModel.fromJson(json);

      expect(restored.number, equals(model.number));
      expect(restored.nameArabic, equals(model.nameArabic));
      expect(restored.nameEnglish, equals(model.nameEnglish));
      expect(restored.revelationType, equals(model.revelationType));
      expect(restored.totalAyahs, equals(model.totalAyahs));
      expect(restored.startPage, equals(model.startPage));
    });

    test('AyahModel fromJson and toJson roundtrip', () {
      const model = AyahModel(
        surahNumber: 2,
        numberInSurah: 255,
        textUthmani: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
        textEnglish: 'Allah - there is no deity except Him, the Ever-Living, the Sustainer of all existence.',
        juz: 3,
        page: 42,
        isSajdah: false,
      );

      final json = model.toJson();
      final restored = AyahModel.fromJson(json);

      expect(restored.surahNumber, equals(model.surahNumber));
      expect(restored.numberInSurah, equals(model.numberInSurah));
      expect(restored.textUthmani, equals(model.textUthmani));
      expect(restored.juz, equals(model.juz));
      expect(restored.page, equals(model.page));
    });

    test('QuranPageModel and QuranJuzModel serialization', () {
      const page = QuranPageModel(
        pageNumber: 50,
        startSurahNumber: 3,
        startAyahNumber: 1,
        endSurahNumber: 3,
        endAyahNumber: 9,
      );
      final pageRestored = QuranPageModel.fromJson(page.toJson());
      expect(pageRestored.pageNumber, equals(50));
      expect(pageRestored.startSurahNumber, equals(3));

      const juz = QuranJuzModel(
        juzNumber: 30,
        startSurahNumber: 78,
        startAyahNumber: 1,
        endSurahNumber: 114,
        endAyahNumber: 6,
        startPage: 582,
        endPage: 604,
        totalAyahs: 564,
      );
      final juzRestored = QuranJuzModel.fromJson(juz.toJson());
      expect(juzRestored.juzNumber, equals(30));
      expect(juzRestored.startPage, equals(582));
    });
  });
}
