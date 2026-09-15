import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/hadith_data.dart';
import '../../domain/hadith_model.dart';
import 'hadith_detail_screen.dart';

class HadithListScreen extends StatefulWidget {
  const HadithListScreen({super.key});

  @override
  State<HadithListScreen> createState() => _HadithListScreenState();
}

class _HadithListScreenState extends State<HadithListScreen> {
  String _searchQuery = '';
  String _selectedCollection = 'الكل';
  String _selectedGrade = 'الكل';

  final List<String> _collections = ['الكل', 'الأربعون النووية', 'صحيح البخاري', 'صحيح مسلم'];
  final List<String> _grades = ['الكل', 'متفق عليه', 'صحيح', 'حسن'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredHadiths = HadithData.allHadiths.where((hadith) {
      // 1. Search Query filter
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          hadith.title.toLowerCase().contains(query) ||
          hadith.textArabic.toLowerCase().contains(query) ||
          hadith.narrator.toLowerCase().contains(query) ||
          hadith.topics.any((t) => t.toLowerCase().contains(query));

      // 2. Collection filter
      final matchesCollection = _selectedCollection == 'الكل' || hadith.collection == _selectedCollection;

      // 3. Grade filter
      final matchesGrade = _selectedGrade == 'الكل' ||
          (_selectedGrade == 'متفق عليه' && hadith.isMutafaqAlayh) ||
          hadith.grade.contains(_selectedGrade);

      return matchesSearch && matchesCollection && matchesGrade;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الحديث الشريف وعلومه',
          style: AppTypography.titleLarge(isDark).copyWith(
            color: AppColors.emeraldGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'البحث في المتن، الراوي، أو الموضوع...',
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

          // Collection Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              children: _collections.map((col) {
                final isSelected = _selectedCollection == col;
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: FilterChip(
                    label: Text(col),
                    selected: isSelected,
                    selectedColor: AppColors.emeraldGreen,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedCollection = col);
                    },
                  ),
                );
              }).toList(),
            ),
          ),

          // Grade Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              children: _grades.map((grade) {
                final isSelected = _selectedGrade == grade;
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: ChoiceChip(
                    label: Text(grade),
                    selected: isSelected,
                    selectedColor: AppColors.sandGold,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : (isDark ? Colors.white70 : Colors.black87),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 11,
                    ),
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedGrade = grade);
                    },
                  ),
                );
              }).toList(),
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
                    'أحاديث موثقة المصدر والتخريج مع الفصل بين المصدر ودرجة الحديث',
                    style: AppTypography.caption(isDark).copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Hadith List
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: filteredHadiths.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final hadith = filteredHadiths[index];
                return _buildHadithTile(context, hadith, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHadithTile(BuildContext context, HadithModel hadith, bool isDark) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.emeraldGreen.withValues(alpha: 0.12),
            border: Border.all(color: AppColors.sandGold),
          ),
          child: Center(
            child: Text(
              '${hadith.number}',
              style: const TextStyle(
                fontFamily: AppTypography.englishFontFamily,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColors.emeraldGreen,
              ),
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                hadith.title,
                style: AppTypography.titleMedium(isDark).copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            if (hadith.isMutafaqAlayh)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.sandGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.sandGold, width: 0.5),
                ),
                child: const Text(
                  'متفق عليه',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.sandGoldDark),
                ),
              ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              hadith.narrator,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'المصدر: ${hadith.sourceBook}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.emeraldGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HadithDetailScreen(hadith: hadith),
            ),
          );
        },
      ),
    );
  }
}
