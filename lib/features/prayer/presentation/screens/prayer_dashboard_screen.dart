import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/notifications/notification_preferences.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../adhkar/presentation/screens/adhkar_categories_screen.dart';
import '../../../hadith/presentation/screens/hadith_list_screen.dart';
import '../../../qibla/presentation/screens/qibla_screen.dart';
import '../../../quran/presentation/screens/quran_surah_list_screen.dart';
import '../../../about/about_contact_screen.dart';
import '../bloc/prayer_bloc.dart';
import '../bloc/prayer_event.dart';
import '../bloc/prayer_state.dart';
import '../widgets/next_prayer_card.dart';
import '../widgets/prayer_list_item.dart';
import 'prayer_settings_screen.dart';

class PrayerDashboardScreen extends StatefulWidget {
  const PrayerDashboardScreen({super.key});

  @override
  State<PrayerDashboardScreen> createState() => _PrayerDashboardScreenState();
}

class _PrayerDashboardScreenState extends State<PrayerDashboardScreen> {
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<PrayerBloc>().add(const LoadPrayerTimesEvent());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'المسلم الذكي',
          style: AppTypography.titleLarge(isDark).copyWith(
            color: AppColors.emeraldGreen,
            fontSize: 22,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'عن التطبيق والاتصال بنا',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutContactScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'إعدادات المواقيت والأذان',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrayerSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentTabIndex,
        children: const [
          PrayerTimesTabContent(),
          QuranSurahListScreen(),
          AdhkarCategoriesScreen(),
          HadithListScreen(),
          QiblaScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentTabIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.emeraldGreen,
        unselectedItemColor: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        selectedFontSize: 12,
        unselectedFontSize: 11,
        onTap: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.access_time_outlined),
            activeIcon: Icon(Icons.access_time_filled),
            label: 'المواقيت',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book),
            label: 'القرآن',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            activeIcon: Icon(Icons.auto_awesome),
            label: 'الأذكار',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.import_contacts_outlined),
            activeIcon: Icon(Icons.import_contacts),
            label: 'الحديث',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            activeIcon: Icon(Icons.explore),
            label: 'القبلة',
          ),
        ],
      ),
    );
  }
}

class PrayerTimesTabContent extends StatefulWidget {
  const PrayerTimesTabContent({super.key});

  @override
  State<PrayerTimesTabContent> createState() => _PrayerTimesTabContentState();
}

class _PrayerTimesTabContentState extends State<PrayerTimesTabContent> {
  NotificationPreferences _prefs = NotificationPreferences.defaultConfig();

  @override
  void initState() {
    super.initState();
    _loadNotificationPrefs();
  }

  Future<void> _loadNotificationPrefs() async {
    final loaded = await NotificationPreferences.load();
    if (mounted) {
      setState(() {
        _prefs = loaded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PrayerBloc, PrayerState>(
      builder: (context, state) {
        if (state is PrayerLoadingState) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.emeraldGreen),
          );
        }

        if (state is PrayerLoadedState) {
          final s = state.schedule;
          final nextName = s.nextPrayerName.toLowerCase();
          final nextPrayerSetting = _prefs.getPrayer(nextName);

          return RefreshIndicator(
            color: AppColors.emeraldGreen,
            onRefresh: () async {
              context.read<PrayerBloc>().add(const LoadPrayerTimesEvent());
              await _loadNotificationPrefs();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Next Prayer Countdown Header Card
                  NextPrayerCard(
                    schedule: s,
                    locationName: state.location.cityName,
                    isAutoGps: state.location.isAutoGps,
                    isNotificationActive: nextPrayerSetting.notificationEnabled && _prefs.globalNotificationsEnabled,
                  ),
                  const SizedBox(height: 10),

                  // 5 Daily Prayers + Sunrise
                  PrayerListItem(
                    prayerKey: 'fajr',
                    prayerName: 'صلاة الفجر',
                    prayerTime: s.fajr,
                    isNext: nextName == 'fajr',
                    isNotificationActive: _prefs.getPrayer('fajr').notificationEnabled,
                  ),
                  PrayerListItem(
                    prayerKey: 'sunrise',
                    prayerName: 'الشروق',
                    prayerTime: s.sunrise,
                    isNext: nextName == 'sunrise',
                    isNotificationActive: false,
                  ),
                  PrayerListItem(
                    prayerKey: 'dhuhr',
                    prayerName: 'صلاة الظهر',
                    prayerTime: s.dhuhr,
                    isNext: nextName == 'dhuhr',
                    isNotificationActive: _prefs.getPrayer('dhuhr').notificationEnabled,
                  ),
                  PrayerListItem(
                    prayerKey: 'asr',
                    prayerName: 'صلاة العصر',
                    prayerTime: s.asr,
                    isNext: nextName == 'asr',
                    isNotificationActive: _prefs.getPrayer('asr').notificationEnabled,
                  ),
                  PrayerListItem(
                    prayerKey: 'maghrib',
                    prayerName: 'صلاة المغرب',
                    prayerTime: s.maghrib,
                    isNext: nextName == 'maghrib',
                    isNotificationActive: _prefs.getPrayer('maghrib').notificationEnabled,
                  ),
                  PrayerListItem(
                    prayerKey: 'isha',
                    prayerName: 'صلاة العشاء',
                    prayerTime: s.isha,
                    isNext: nextName == 'isha',
                    isNotificationActive: _prefs.getPrayer('isha').notificationEnabled,
                  ),
                ],
              ),
            ),
          );
        }

        if (state is PrayerErrorState) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 56, color: AppColors.danger),
                  const SizedBox(height: 16),
                  Text(state.errorMessage, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<PrayerBloc>().add(const LoadPrayerTimesEvent());
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
