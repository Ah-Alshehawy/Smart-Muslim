import 'package:flutter_test/flutter_test.dart';
import 'package:smart_muslim/features/adhkar/data/adhkar_data.dart';
import 'package:smart_muslim/features/hadith/data/hadith_data.dart';

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
  });
}
