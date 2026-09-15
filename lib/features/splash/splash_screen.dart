import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../prayer/presentation/screens/prayer_dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();

    // Navigate to Prayer Dashboard after splash duration
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const PrayerDashboardScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(),

                    // Modern Islamic Crescent Emblem
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.emeraldGreen.withValues(alpha: 0.12),
                        border: Border.all(
                          color: AppColors.sandGold,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.emeraldGreen.withValues(alpha: 0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.mosque,
                          size: 48,
                          color: AppColors.emeraldGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Arabic App Title: المسلم الذكي
                    Text(
                      'المسلم الذكي',
                      style: AppTypography.displayLarge(isDark).copyWith(
                        color: AppColors.emeraldGreen,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // English App Subtitle
                    Text(
                      'SMART MUSLIM',
                      style: TextStyle(
                        fontFamily: AppTypography.englishFontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3.5,
                        color: isDark ? AppColors.sandGoldLight : AppColors.sandGoldDark,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Verbatim Dedication with Tashkeel
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurface.withValues(alpha: 0.7)
                            : AppColors.lightSurface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.sandGold.withValues(alpha: 0.4),
                          width: 1.2,
                        ),
                      ),
                      child: Text(
                        'صَدَقَةٌ جَارِيَةٌ ... نَسْأَلُكُمُ الدُّعَاءَ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: AppTypography.arabicFontFamily,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.sandGoldLight : AppColors.emeraldGreenDark,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    const Spacer(),

                    // Elegant Developer Attribution Footer
                    Column(
                      children: [
                        Text(
                          'Developed by: Eng. Ahmed Alshehawy',
                          style: TextStyle(
                            fontFamily: AppTypography.englishFontFamily,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'ah.alshehawy@gmail.com • +201006765695',
                          style: TextStyle(
                            fontFamily: AppTypography.englishFontFamily,
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextSecondary.withValues(alpha: 0.7) : AppColors.lightTextSecondary.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
