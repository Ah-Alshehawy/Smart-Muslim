import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../screens/adhan_settings_screen.dart';

class PrayerListItem extends StatelessWidget {
  final String prayerKey;
  final String prayerName;
  final DateTime prayerTime;
  final bool isNext;
  final bool isNotificationActive;
  final IconData? iconOverride;

  const PrayerListItem({
    super.key,
    required this.prayerKey,
    required this.prayerName,
    required this.prayerTime,
    this.isNext = false,
    this.isNotificationActive = true,
    this.iconOverride,
  });

  IconData _getPrayerIcon() {
    if (iconOverride != null) return iconOverride!;
    switch (prayerKey.toLowerCase()) {
      case 'fajr':
        return Icons.wb_twilight;
      case 'sunrise':
        return Icons.wb_sunny_outlined;
      case 'dhuhr':
        return Icons.wb_sunny;
      case 'asr':
        return Icons.sunny_snowing;
      case 'maghrib':
        return Icons.nights_stay_outlined;
      case 'isha':
        return Icons.bedtime;
      default:
        return Icons.access_time;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final timeFormatted = DateFormat('hh:mm a', 'ar').format(prayerTime);
    final isSunrise = prayerKey.toLowerCase() == 'sunrise';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3.5),
      padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: isNext
            ? (isDark
                ? AppColors.emeraldGreenDark.withValues(alpha: 0.35)
                : AppColors.emeraldGreen.withValues(alpha: 0.12))
            : (isDark ? AppColors.darkCard : AppColors.lightSurface),
        borderRadius: BorderRadius.circular(14.0),
        border: Border.all(
          color: isNext
              ? AppColors.emeraldGreen
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isNext ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Prayer Icon & Name
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isNext
                      ? AppColors.emeraldGreen.withValues(alpha: 0.2)
                      : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getPrayerIcon(),
                  color: isNext
                      ? AppColors.emeraldGreen
                      : (isSunrise
                          ? AppColors.sandGold
                          : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    prayerName,
                    style: AppTypography.titleMedium(isDark).copyWith(
                      color: isNext
                          ? AppColors.emeraldGreen
                          : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                      fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  if (isNext)
                    const Text(
                      'الصلاة القادمة',
                      style: TextStyle(
                        color: AppColors.emeraldGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),
            ],
          ),

          // Time & Actions
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                timeFormatted,
                style: AppTypography.titleMedium(isDark).copyWith(
                  fontFamily: AppTypography.englishFontFamily,
                  color: isNext
                      ? AppColors.emeraldGreen
                      : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
                  fontWeight: isNext ? FontWeight.bold : FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              if (!isSunrise) ...[
                const SizedBox(width: 8),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                  icon: Icon(
                    isNotificationActive
                        ? Icons.notifications_active_outlined
                        : Icons.notifications_off_outlined,
                    color: isNotificationActive ? AppColors.emeraldGreen : Colors.grey,
                    size: 18,
                  ),
                  tooltip: 'إعدادات تنبيه $prayerName',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdhanSettingsScreen(
                          initialPrayerKey: prayerKey,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
