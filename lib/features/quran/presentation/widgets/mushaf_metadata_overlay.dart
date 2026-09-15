import 'package:flutter/material.dart';
import '../../data/quran_repository.dart';

/// Renders authentic Quranic page metadata:
/// - Header: Surah title (outer edge) and Juz'/Rub' information (inner spine edge).
/// - Footer: Centered page number in Eastern Arabic numerals.
class MushafMetadataHeader extends StatelessWidget {
  final int pageNumber;
  final bool isDark;

  const MushafMetadataHeader({
    super.key,
    required this.pageNumber,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final surah = QuranRepository.getSurahForPage(pageNumber);
    final juz = QuranRepository.getJuzForPage(pageNumber);

    final surahTitle = surah != null ? 'سورة ${surah.nameArabic}' : '';
    final juzTitle = juz != null ? 'الجزء ${QuranRepository.toArabicDigits(juz.juzNumber)}' : '';

    final textColor = isDark ? const Color(0xFFC5BDB0) : const Color(0xFF6A604E);
    final isOddPage = pageNumber % 2 != 0;

    // In Arabic book layout:
    // Odd pages (right page): Surah name is on the right (outer margin), Juz on left (spine).
    // Even pages (left page): Juz name is on right (spine), Surah on left (outer margin).
    final rightTitle = isOddPage ? surahTitle : juzTitle;
    final leftTitle = isOddPage ? juzTitle : surahTitle;

    // In pages 1 and 2, the classical illuminated unwan (frame) fills the top;
    // render headers with soft subtlety
    final isIntroPage = pageNumber == 1 || pageNumber == 2;
    final opacity = isIntroPage ? 0.75 : 1.0;

    return Opacity(
      opacity: opacity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Right-aligned title (RTL natural start)
            Text(
              rightTitle,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: textColor,
                letterSpacing: 0.2,
              ),
            ),
            // Left-aligned title
            Text(
              leftTitle,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: textColor,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MushafMetadataFooter extends StatelessWidget {
  final int pageNumber;
  final bool isDark;

  const MushafMetadataFooter({
    super.key,
    required this.pageNumber,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark ? const Color(0xFFC5BDB0) : const Color(0xFF6A604E);
    final arabicPageNum = QuranRepository.toArabicDigits(pageNumber);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Center(
        child: Text(
          arabicPageNum,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 13.0,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
