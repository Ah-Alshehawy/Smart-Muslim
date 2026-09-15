import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/quran_repository.dart';
import '../../domain/surah_model.dart';
import 'quran_reader_screen.dart';

class QuranSurahListScreen extends StatefulWidget {
  const QuranSurahListScreen({super.key});

  @override
  State<QuranSurahListScreen> createState() => _QuranSurahListScreenState();
}

class _QuranSurahListScreenState extends State<QuranSurahListScreen> {
  String _searchQuery = '';
  bool _isLoading = true;
  Map<String, int>? _lastRead;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    await QuranRepository.ensureLoaded();
    final lastRead = await QuranRepository.getLastRead();
    if (mounted) {
      setState(() {
        _lastRead = lastRead;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.emeraldGreen),
            SizedBox(height: 16),
            Text('جاري تحميل المصحف الشريف...', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    final filteredSurahs = QuranRepository.allSurahs.where((surah) {
      final query = _searchQuery.trim().toLowerCase();
      if (query.isEmpty) return true;
      return surah.nameArabic.contains(query) ||
          surah.nameEnglish.toLowerCase().contains(query) ||
          surah.number.toString() == query;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'القرآن الكريم',
          style: AppTypography.titleLarge(isDark).copyWith(
            color: AppColors.emeraldGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book, color: AppColors.emeraldGreen),
            tooltip: 'المصحف الشريف (صفحات)',
            onPressed: () {
              final initialPage = _lastRead?['page'] ?? 1;
              final targetSurah = QuranRepository.getSurahForPage(initialPage) ?? QuranRepository.allSurahs.first;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuranReaderScreen(
                    surah: targetSurah,
                    initialPage: initialPage,
                  ),
                ),
              ).then((_) => _initData());
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Last Read Banner (if available)
          if (_lastRead != null && _searchQuery.isEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Card(
                color: isDark ? AppColors.emeraldGreenDark.withValues(alpha: 0.3) : AppColors.emeraldGreen.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(color: AppColors.sandGold, width: 1),
                ),
                child: ListTile(
                  leading: const Icon(Icons.bookmark, color: AppColors.sandGold, size: 28),
                  title: const Text('متابعة آخر قراءة', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                    'سورة ${_getSurahName(_lastRead!['surah']!)} • آية ${_lastRead!['ayah']} (صفحة ${_lastRead!['page']})',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.emeraldGreen),
                  onTap: () {
                    final surahModel = QuranRepository.allSurahs.firstWhere(
                      (s) => s.number == _lastRead!['surah'],
                      orElse: () => QuranRepository.allSurahs.first,
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => QuranReaderScreen(
                          surah: surahModel,
                          initialAyah: _lastRead!['ayah'],
                          initialPage: _lastRead!['page'],
                        ),
                      ),
                    ).then((_) => _initData());
                  },
                ),
              ),
            ),
          ],

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            child: TextField(
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
              decoration: InputDecoration(
                hintText: 'البحث باسم السورة أو رقمها...',
                prefixIcon: const Icon(Icons.search, color: AppColors.emeraldGreen),
                filled: true,
                fillColor: isDark ? AppColors.darkCard : AppColors.lightSurface,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Attribution Metadata Banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: AppColors.emeraldGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified, color: AppColors.emeraldGreen, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'المصحف الشريف بالرسم العثماني المعتمد • 114 سورة • 6236 آية (Tanzil v1.1)',
                    style: AppTypography.caption(isDark).copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Surahs List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: filteredSurahs.length,
              separatorBuilder: (context, index) => const SizedBox(height: 6),
              itemBuilder: (context, index) {
                final surah = filteredSurahs[index];
                return _buildSurahTile(context, surah, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getSurahName(int number) {
    try {
      return QuranRepository.allSurahs.firstWhere((s) => s.number == number).nameArabic;
    } catch (_) {
      return '';
    }
  }

  Widget _buildSurahTile(BuildContext context, SurahModel surah, bool isDark) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.emeraldGreen.withValues(alpha: 0.12),
            border: Border.all(color: AppColors.sandGold),
          ),
          child: Center(
            child: Text(
              '${surah.number}',
              style: const TextStyle(
                fontFamily: AppTypography.englishFontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: AppColors.emeraldGreen,
              ),
            ),
          ),
        ),
        title: Text(
          'سورة ${surah.nameArabic}',
          style: AppTypography.titleMedium(isDark).copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          '${surah.revelationType} • ${surah.totalAyahs} آية • صفحة ${surah.startPage}',
          style: AppTypography.bodyMedium(isDark).copyWith(fontSize: 12),
        ),
        trailing: Text(
          surah.nameEnglish,
          style: TextStyle(
            fontFamily: AppTypography.englishFontFamily,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            fontSize: 12,
          ),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuranReaderScreen(
                surah: surah,
                initialPage: surah.startPage,
              ),
            ),
          ).then((_) => _initData());
        },
      ),
    );
  }
}
