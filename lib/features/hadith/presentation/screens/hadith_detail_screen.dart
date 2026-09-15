import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/hadith_model.dart';

class HadithDetailScreen extends StatelessWidget {
  final HadithModel hadith;

  const HadithDetailScreen({
    super.key,
    required this.hadith,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          hadith.title,
          style: AppTypography.titleLarge(isDark).copyWith(fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'نسخ الحديث مع المصدر',
            onPressed: () {
              final formattedText = '''
${hadith.title}

${hadith.narrator}:
«${hadith.textArabic}»

المصدر: ${hadith.sourceBook}
درجة الحديث: ${hadith.grade}
تطبيق المسلم الذكي
''';
              Clipboard.setData(ClipboardData(text: formattedText.trim()));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم نسخ نص الحديث وتخريجه إلى الحافظة بنجاح'),
                  backgroundColor: AppColors.emeraldGreen,
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Header Card with Title & Collection/Grade Badges
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [AppColors.emeraldGreenDark, AppColors.darkCard]
                    : [AppColors.emeraldGreen, AppColors.emeraldGreenLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Text(
                  hadith.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: AppTypography.arabicFontFamily,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        hadith.collection,
                        style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.sandGold,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        hadith.grade,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    if (hadith.isMutafaqAlayh)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.emeraldGreenLight,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'متفق عليه',
                          style: TextStyle(fontSize: 11, color: Colors.black87, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Narrator Card
          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                children: [
                  const Icon(Icons.person, color: AppColors.emeraldGreen, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      hadith.narrator,
                      style: AppTypography.bodyMedium(isDark).copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Hadith Text Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    hadith.textArabic,
                    textAlign: TextAlign.center,
                    style: AppTypography.arabicText(
                      fontSize: 20,
                      isDark: isDark,
                      fontWeight: FontWeight.w600,
                    ).copyWith(height: 2.1),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.bookmark_border, size: 16, color: AppColors.sandGoldDark),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'المصدر والتخريج: ${hadith.sourceBook}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Topics Section
          if (hadith.topics.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Wrap(
                spacing: 8,
                children: hadith.topics.map((t) {
                  return Chip(
                    label: Text('# $t', style: const TextStyle(fontSize: 11)),
                    backgroundColor: isDark ? AppColors.darkCard : AppColors.lightSurface,
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),
          ],

          // Explanation / Fiqh Card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.auto_stories, color: AppColors.sandGold, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'شرح وهدايات الحديث',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.emeraldGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    hadith.explanation,
                    style: AppTypography.bodyMedium(isDark).copyWith(height: 1.7),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
