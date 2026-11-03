import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:smart_muslim/features/adhkar/data/adhkar_data.dart';
import 'package:smart_muslim/features/hadith/data/hadith_data.dart';
import 'package:smart_muslim/features/quran/data/quran_tafsir_data.dart';

void main() {
  group('Hadith Library Integrity Tests', () {
    test('Hadith collection contains authenticated Hadiths with non-empty fields', () {
      expect(HadithData.allHadiths.isNotEmpty, isTrue);
      for (final hadith in HadithData.allHadiths) {
        expect(hadith.title.trim().isNotEmpty, isTrue);
        expect(hadith.textArabic.trim().isNotEmpty, isTrue);
        expect(hadith.narrator.trim().isNotEmpty, isTrue);
        expect(hadith.sourceBook.trim().isNotEmpty, isTrue);
        expect(hadith.grade.trim().isNotEmpty, isTrue);
      }
    });

    test('All 40 Nawawi hadiths have distinct positive numbers', () {
      final nawawi = HadithData.allHadiths.where((h) => h.collection == 'الأربعون النووية').toList();
      expect(nawawi.isNotEmpty, isTrue);
      final numbers = nawawi.map((h) => h.number).toSet();
      expect(numbers.length, equals(nawawi.length));
    });
  });

  group('Athkar Module Integrity Tests', () {
    test('Categories contain valid Dhikr items with target counts', () {
      expect(AdhkarData.categories.length, greaterThanOrEqualTo(5));
      for (final cat in AdhkarData.categories) {
        expect(cat.title.trim().isNotEmpty, isTrue);
        expect(cat.items.isNotEmpty, isTrue);
        for (final item in cat.items) {
          expect(item.title.trim().isNotEmpty, isTrue);
          expect(item.textArabic.trim().isNotEmpty, isTrue);
          expect(item.targetCount, greaterThan(0));
          expect(item.sourceReference.trim().isNotEmpty, isTrue);
        }
      }
    });

    test('No dhikr text is truncated with an ellipsis', () {
      for (final cat in AdhkarData.categories) {
        for (final item in cat.items) {
          expect(item.textArabic.contains('...'), isFalse, reason: 'dhikr ${item.id}');
          expect(item.textArabic.contains('…'), isFalse, reason: 'dhikr ${item.id}');
        }
      }
    });

    test('Quranic adhkar match the verbatim Tanzil text', () {
      final verses = <String, String>{};
      for (final line in File('assets/quran/tanzil_uthmani_v1.1.txt').readAsLinesSync()) {
        final parts = line.split('|');
        if (parts.length == 3 && int.tryParse(parts[0]) != null) {
          verses['${parts[0]}:${parts[1]}'] = parts[2];
        }
      }

      for (final cat in AdhkarData.categories) {
        for (final item in cat.items.where((i) => i.quranVerses.isNotEmpty)) {
          final expected = item.quranVerses
              .map((r) => [
                    for (var a = r.fromAyah; a <= r.toAyah; a++) verses['${r.surah}:$a']!,
                  ].join(' '))
              .join('\n\n');
          expect(item.textArabic, equals(expected), reason: 'dhikr ${item.id}');
        }
      }
    });
  });

  group('Tafsir Integrity Tests', () {
    test('No placeholder Tafsir is returned for verses without verbatim text', () {
      expect(QuranTafsirData.getAyahTafsir(2, 255), isNull);
      expect(QuranTafsirData.getAyahTafsir(1, 1), isNull);
    });
  });
}
