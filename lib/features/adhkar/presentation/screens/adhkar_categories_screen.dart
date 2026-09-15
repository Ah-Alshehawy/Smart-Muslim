import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/adhkar_data.dart';
import 'dhikr_detail_screen.dart';
import 'tasbeeh_counter_screen.dart';

class AdhkarCategoriesScreen extends StatelessWidget {
  const AdhkarCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الأذكار وحصن المسلم',
          style: AppTypography.titleLarge(isDark).copyWith(
            color: AppColors.emeraldGreen,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Smart Tasbeeh Feature Card
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TasbeehCounterScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppColors.emeraldGreenDark, AppColors.darkCard]
                      : [AppColors.emeraldGreen, AppColors.emeraldGreenLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.emeraldGreen.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.touch_app, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'المسبحة الإلكترونية الذكية',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'تسبيح حر مع تحديد الأهداف والاهتزاز',
                          style: TextStyle(fontSize: 13, color: AppColors.sandGoldLight),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Sourced Adhkar Categories Header
          Text(
            'أبواب الأذكار اليومية',
            style: AppTypography.titleMedium(isDark).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Categories Grid / List
          ...AdhkarData.categories.map((category) {
            IconData iconData;
            switch (category.iconName) {
              case 'wb_sunny':
                iconData = Icons.wb_sunny;
                break;
              case 'nights_stay':
                iconData = Icons.nights_stay;
                break;
              case 'mosque':
                iconData = Icons.mosque;
                break;
              case 'bedtime':
                iconData = Icons.bedtime;
                break;
              default:
                iconData = Icons.bookmark_border;
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.emeraldGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(iconData, color: AppColors.emeraldGreen),
                ),
                title: Text(
                  category.title,
                  style: AppTypography.titleMedium(isDark).copyWith(fontSize: 16),
                ),
                subtitle: Text(
                  '${category.items.length} أذكار موثقة مع الفضل والمصدر',
                  style: AppTypography.bodyMedium(isDark),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DhikrDetailScreen(category: category),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
