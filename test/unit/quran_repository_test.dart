import 'package:flutter_test/flutter_test.dart';
import 'package:smart_muslim/features/quran/data/quran_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('QuranRepository Tests', () {
    test('allSurahs contains 114 Surahs before and after ensureLoaded', () {
      expect(QuranRepository.allSurahs.length, equals(114));
      expect(QuranRepository.allSurahs.first.number, equals(1));
      expect(QuranRepository.allSurahs.first.nameArabic, equals('الفاتحة'));
      expect(QuranRepository.allSurahs.last.number, equals(114));
      expect(QuranRepository.allSurahs.last.nameArabic, equals('الناس'));
    });

    test('getSurah returns correct SurahModel by ID', () {
      final fatihah = QuranRepository.getSurah(1);
      expect(fatihah, isNotNull);
      expect(fatihah!.nameArabic, equals('الفاتحة'));
      expect(fatihah.totalAyahs, equals(7));

      final baqarah = QuranRepository.getSurah(2);
      expect(baqarah, isNotNull);
      expect(baqarah!.nameArabic, equals('البقرة'));
      expect(baqarah.totalAyahs, equals(286));

      final invalid = QuranRepository.getSurah(999);
      expect(invalid, isNull);
    });
  });
}
