import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/prayer_calculator.dart';

class NextPrayerCard extends StatelessWidget {
  final PrayerScheduleResult schedule;
  final String locationName;
  final bool isAutoGps;
  final bool isNotificationActive;

  const NextPrayerCard({
    super.key,
    required this.schedule,
    required this.locationName,
    this.isAutoGps = false,
    this.isNotificationActive = true,
  });

  String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  String _getPrayerArabicName(String name) {
    switch (name.toLowerCase()) {
      case 'fajr':
        return 'الفجر';
      case 'sunrise':
        return 'الشروق';
      case 'dhuhr':
        return 'الظهر';
      case 'asr':
        return 'العصر';
      case 'maghrib':
        return 'المغرب';
      case 'isha':
        return 'العشاء';
      default:
        return name;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final arabicPrayerName = _getPrayerArabicName(schedule.nextPrayerName);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.emeraldGreenDark, AppColors.darkCard]
              : [AppColors.emeraldGreen, AppColors.emeraldGreenLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: AppColors.emeraldGreen.withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Location Badge & Badges Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.location_on, color: AppColors.sandGold, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    locationName,
                    style: AppTypography.bodyMedium(true).copyWith(
                      color: AppColors.sandGoldLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Auto / Manual Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAutoGps ? Icons.my_location : Icons.location_city,
                          color: AppColors.sandGold,
                          size: 12,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isAutoGps ? 'تلقائي (GPS)' : 'يدوي',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Notification state badge
                  Icon(
                    isNotificationActive ? Icons.notifications_active : Icons.notifications_off,
                    color: isNotificationActive ? AppColors.sandGold : Colors.white60,
                    size: 18,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Next Prayer Title
          Text(
            'الصلاة القادمة: $arabicPrayerName',
            style: AppTypography.titleLarge(true).copyWith(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Timer Countdown Text
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              _formatDuration(schedule.timeRemaining),
              style: const TextStyle(
                fontFamily: AppTypography.englishFontFamily,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.sandGold,
                letterSpacing: 2.0,
              ),
            ),
          ),
          const SizedBox(height: 4),

          Text(
            'المتبقي حتى رفع الأذان',
            style: AppTypography.caption(true).copyWith(
              color: Colors.white70,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
