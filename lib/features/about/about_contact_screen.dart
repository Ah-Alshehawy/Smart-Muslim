import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class AboutContactScreen extends StatelessWidget {
  const AboutContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'عن التطبيق والاتصال بنا',
          style: AppTypography.titleLarge(isDark),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // App Identity Banner
          Center(
            child: Column(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.emeraldGreen.withValues(alpha: 0.12),
                    border: Border.all(color: AppColors.sandGold, width: 2),
                  ),
                  child: const Center(
                    child: Icon(Icons.mosque, size: 36, color: AppColors.emeraldGreen),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'المسلم الذكي | Smart Muslim',
                  style: AppTypography.titleLarge(isDark).copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.emeraldGreen,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'الإصدار 0.2.0-dev.3 (Build 4)',
                  style: TextStyle(
                    fontFamily: AppTypography.englishFontFamily,
                    fontSize: 12,
                    color: AppColors.sandGoldDark,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.emeraldGreen.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.sandGold.withValues(alpha: 0.3)),
                  ),
                  child: const Text(
                    'صَدَقَةٌ جَارِيَةٌ ... نَسْأَلُكُمُ الدُّعَاءَ',
                    style: TextStyle(
                      fontFamily: AppTypography.arabicFontFamily,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.emeraldGreenDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 1: Core Principles
          _buildSectionHeader('مبادئ التطبيق والخصوصية', Icons.shield_outlined, isDark),
          const SizedBox(height: 8),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _FeatureRow(icon: Icons.money_off, title: 'مجاني بالكامل وبدون إعلانات', subtitle: 'تطبيق غير ربحي خالص لوجه الله تعالى دون أي إعلانات أو اشتراكات.'),
                  Divider(height: 20),
                  _FeatureRow(icon: Icons.lock_outline, title: 'خصوصية تامة وبدون تتبع', subtitle: 'لا يتم جمع أو بيع أو مشاركة أي بيانات للمستخدم، وحساب المواقيت والقبلة يتم محلياً.'),
                  Divider(height: 20),
                  _FeatureRow(icon: Icons.wifi_off, title: 'يعمل بدون إنترنت (Offline-First)', subtitle: 'جميع وظائف المصحف الشريف، الأحاديث، الأذكار، والمواقيت متاحة بدون اتصال.'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Section 2: Developer Attribution
          _buildSectionHeader('تطوير وبرمجة التطبيق', Icons.code, isDark),
          const SizedBox(height: 8),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Developed by:',
                    style: TextStyle(fontFamily: AppTypography.englishFontFamily, fontWeight: FontWeight.bold, color: AppColors.emeraldGreen),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Eng. Ahmed Alshehawy',
                    style: TextStyle(fontFamily: AppTypography.englishFontFamily, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: AppColors.sandGoldDark),
                      SizedBox(width: 8),
                      Text('+201006765695', style: TextStyle(fontFamily: AppTypography.englishFontFamily)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.email_outlined, size: 16, color: AppColors.sandGoldDark),
                      SizedBox(width: 8),
                      Text('ah.alshehawy@gmail.com', style: TextStyle(fontFamily: AppTypography.englishFontFamily)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Section 3: Company Contact SBS
          _buildSectionHeader('اتصل بنا (الشركة الراعية)', Icons.business, isDark),
          const SizedBox(height: 8),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Smart Business Solutions (SBS)',
                    style: TextStyle(
                      fontFamily: AppTypography.englishFontFamily,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.emeraldGreen,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.phone, size: 16, color: AppColors.sandGoldDark),
                      SizedBox(width: 8),
                      Text('+201553853030', style: TextStyle(fontFamily: AppTypography.englishFontFamily)),
                    ],
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.email_outlined, size: 16, color: AppColors.sandGoldDark),
                      SizedBox(width: 8),
                      Text('info@sbs.net', style: TextStyle(fontFamily: AppTypography.englishFontFamily)),
                    ],
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

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, color: AppColors.emeraldGreen, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.titleMedium(isDark).copyWith(
            color: AppColors.emeraldGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.emeraldGreen, size: 22),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}
