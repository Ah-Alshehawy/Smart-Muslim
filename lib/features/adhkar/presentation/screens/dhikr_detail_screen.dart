import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/dhikr_model.dart';

class DhikrDetailScreen extends StatefulWidget {
  final DhikrCategoryModel category;

  const DhikrDetailScreen({
    super.key,
    required this.category,
  });

  @override
  State<DhikrDetailScreen> createState() => _DhikrDetailScreenState();
}

class _DhikrDetailScreenState extends State<DhikrDetailScreen> {
  late List<int> _currentCounts;

  @override
  void initState() {
    super.initState();
    _currentCounts = List.filled(widget.category.items.length, 0);
  }

  void _incrementCount(int index) {
    final item = widget.category.items[index];
    if (_currentCounts[index] < item.targetCount) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentCounts[index]++;
      });
      if (_currentCounts[index] == item.targetCount) {
        HapticFeedback.heavyImpact();
      }
    }
  }

  void _resetCounts() {
    setState(() {
      _currentCounts = List.filled(widget.category.items.length, 0);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تمت إعادة ضبط عدادات الأذكار')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category.title,
          style: AppTypography.titleLarge(isDark),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'إعادة الضبط',
            onPressed: _resetCounts,
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16.0),
        itemCount: widget.category.items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final item = widget.category.items[index];
          final current = _currentCounts[index];
          final isCompleted = current >= item.targetCount;

          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isCompleted ? AppColors.emeraldGreen : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () => _incrementCount(index),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header: Title and Counter Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: AppTypography.titleMedium(isDark).copyWith(
                              color: AppColors.emeraldGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? AppColors.emeraldGreen
                                : AppColors.emeraldGreen.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$current / ${item.targetCount}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isCompleted ? Colors.white : AppColors.emeraldGreen,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Arabic Text
                    Text(
                      item.textArabic,
                      textAlign: TextAlign.center,
                      style: AppTypography.arabicText(
                        fontSize: 20,
                        isDark: isDark,
                        fontWeight: FontWeight.w600,
                      ).copyWith(height: 1.8),
                    ),
                    const SizedBox(height: 16),

                    // Fadl / Benefit
                    if (item.benefit.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.star, color: AppColors.sandGold, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.benefit,
                                style: AppTypography.caption(isDark).copyWith(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],

                    // Source Reference
                    Text(
                      'المصدر: ${item.sourceReference}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Tap to count button
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isCompleted
                            ? AppColors.emeraldGreen
                            : AppColors.emeraldGreen.withValues(alpha: 0.15),
                        foregroundColor: isCompleted ? Colors.white : AppColors.emeraldGreen,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _incrementCount(index),
                      child: Text(
                        isCompleted ? 'تم بحمد الله ✓' : 'اضغط للتسبيح ($current / ${item.targetCount})',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
