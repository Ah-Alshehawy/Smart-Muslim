import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/location/egypt_cities_data.dart';
import '../../../../core/location/location_model.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/theme_cubit.dart';
import '../../../../core/utils/prayer_calculator.dart';
import '../bloc/prayer_bloc.dart';
import '../bloc/prayer_event.dart';
import '../bloc/prayer_state.dart';
import 'adhan_settings_screen.dart';

class PrayerSettingsScreen extends StatefulWidget {
  const PrayerSettingsScreen({super.key});

  @override
  State<PrayerSettingsScreen> createState() => _PrayerSettingsScreenState();
}

class _PrayerSettingsScreenState extends State<PrayerSettingsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إعدادات المواقيت والموقع',
          style: AppTypography.titleLarge(isDark),
        ),
      ),
      body: BlocBuilder<PrayerBloc, PrayerState>(
        builder: (context, state) {
          LocationModel? currentLocation;
          AppCalculationMethod selectedMethod = AppCalculationMethod.egyptian;
          AppJuristicMethod selectedJuristic = AppJuristicMethod.standard;

          if (state is PrayerLoadedState) {
            currentLocation = state.location;
            selectedMethod = state.selectedMethod;
            selectedJuristic = state.selectedJuristic;
          }

          final bool isAutoGpsActive = currentLocation?.isAutoGps ?? false;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Theme / Appearance Section
              _buildSectionHeader(context, 'المظهر والسمة (نهاري / ليلي)', Icons.palette_outlined),
              const SizedBox(height: 8),
              BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, currentMode) {
                  return Card(
                    child: Column(
                      children: [
                        ListTile(
                          title: const Text('تلقائي (حسب مظهر النظام)'),
                          subtitle: const Text('يتوافق مع وضع هاتفك الحالي'),
                          leading: const Icon(Icons.brightness_auto, color: AppColors.emeraldGreen),
                          trailing: currentMode == ThemeMode.system
                              ? const Icon(Icons.check_circle, color: AppColors.emeraldGreen)
                              : const Icon(Icons.circle_outlined, color: Colors.grey),
                          onTap: () {
                            context.read<ThemeCubit>().setThemeMode(ThemeMode.system);
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: const Text('الوضع النهاري (فاتح)'),
                          subtitle: const Text('أرضية ورقية دافئة وخط أسود كالمصحف الشريف'),
                          leading: const Icon(Icons.wb_sunny_outlined, color: AppColors.sandGold),
                          trailing: currentMode == ThemeMode.light
                              ? const Icon(Icons.check_circle, color: AppColors.emeraldGreen)
                              : const Icon(Icons.circle_outlined, color: Colors.grey),
                          onTap: () {
                            context.read<ThemeCubit>().setThemeMode(ThemeMode.light);
                          },
                        ),
                        const Divider(height: 1),
                        ListTile(
                          title: const Text('الوضع الليلي (داكن)'),
                          subtitle: const Text('أرضية داكنة مريحة للعين وخط ناصع'),
                          leading: const Icon(Icons.nightlight_round, color: AppColors.emeraldGreenLight),
                          trailing: currentMode == ThemeMode.dark
                              ? const Icon(Icons.check_circle, color: AppColors.emeraldGreen)
                              : const Icon(Icons.circle_outlined, color: Colors.grey),
                          onTap: () {
                            context.read<ThemeCubit>().setThemeMode(ThemeMode.dark);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Section 0: Adhan and Notifications Customization
              _buildSectionHeader(context, 'التنبيهات والأذان', Icons.notifications_active),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.volume_up, color: AppColors.emeraldGreen),
                  title: const Text('تخصيص أصوات الأذان والتنبيهات', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('أصوات الحرمين والأقصى، التنبيه المسبق، والإقامة لكل صلاة'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdhanSettingsScreen()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Section 1: Location Settings
              _buildSectionHeader(context, 'الموقع الجغرافي والمدن', Icons.location_on),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('التحديد التلقائي عبر الـ GPS'),
                      subtitle: isAutoGpsActive
                          ? const Text(
                              'مفعل حاليًا',
                              style: TextStyle(color: AppColors.emeraldGreen, fontSize: 12),
                            )
                          : const Text('الحصول على الإحداثيات الدقيقة لموقعك الحالي'),
                      leading: const Icon(Icons.my_location, color: AppColors.emeraldGreen),
                      trailing: isAutoGpsActive
                          ? const Icon(Icons.check_circle, color: AppColors.emeraldGreen)
                          : null,
                      onTap: () {
                        context.read<PrayerBloc>().add(const LoadPrayerTimesEvent());
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('جاري تحديث الموقع تلقائيًا عبر GPS...'),
                            duration: Duration(seconds: 1),
                          ),
                        );
                        Navigator.pop(context);
                      },
                    ),
                    const Divider(height: 1),
                    ExpansionTile(
                      title: const Text('اختيار المحافظة / المدينة يدويًا'),
                      subtitle: (!isAutoGpsActive && currentLocation != null)
                          ? Text(
                              'المحدد: ${currentLocation.cityName} (${currentLocation.countryName})',
                              style: const TextStyle(color: AppColors.emeraldGreen, fontSize: 12, fontWeight: FontWeight.bold),
                            )
                          : const Text('محافظات جمهورية مصر العربية والعالم العربي'),
                      leading: const Icon(Icons.location_city, color: AppColors.emeraldGreen),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'ابحث عن مدينة أو محافظة...',
                              prefixIcon: const Icon(Icons.search, size: 20),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onChanged: (val) => setState(() => _searchQuery = val.trim()),
                          ),
                        ),
                        // Egypt Section Header
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '🇪🇬 محافظات ومدن جمهورية مصر العربية (27 محافظة)',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.sandGoldDark),
                            ),
                          ),
                        ),
                        ..._filterCities(EgyptAndWorldCitiesData.egyptCities, _searchQuery).map((city) {
                          final bool isSelected = !isAutoGpsActive && currentLocation?.cityName == city.cityName;
                          return ListTile(
                            dense: true,
                            title: Text(city.cityName),
                            subtitle: Text(city.governorate ?? city.countryName, style: const TextStyle(fontSize: 11)),
                            trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.emeraldGreen, size: 20) : null,
                            onTap: () {
                              context.read<PrayerBloc>().add(LoadPrayerTimesEvent(customLocation: city));
                              Navigator.pop(context);
                            },
                          );
                        }),
                        const Divider(),
                        // Arab & World Cities Section Header
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '🌍 العواصم والمدن الإسلامية والعالمية',
                              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.sandGoldDark),
                            ),
                          ),
                        ),
                        ..._filterCities(EgyptAndWorldCitiesData.arabAndWorldCities, _searchQuery).map((city) {
                          final bool isSelected = !isAutoGpsActive && currentLocation?.cityName == city.cityName;
                          return ListTile(
                            dense: true,
                            title: Text(city.cityName),
                            subtitle: Text(city.countryName, style: const TextStyle(fontSize: 11)),
                            trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.emeraldGreen, size: 20) : null,
                            onTap: () {
                              context.read<PrayerBloc>().add(LoadPrayerTimesEvent(customLocation: city));
                              Navigator.pop(context);
                            },
                          );
                        }),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Section 2: Calculation Methods
              _buildSectionHeader(context, 'طريقة حساب المواقيت', Icons.calculate),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: AppCalculationMethod.values.map((method) {
                    final isSelected = selectedMethod == method;
                    return ListTile(
                      title: Text(
                        PrayerCalculatorService.getMethodDisplayName(method),
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? AppColors.emeraldGreen : null,
                        ),
                      ),
                      trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.emeraldGreen) : null,
                      onTap: () {
                        context.read<PrayerBloc>().add(ChangeCalculationMethodEvent(method));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('تم اعتماد: ${PrayerCalculatorService.getMethodDisplayName(method)}'),
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 24),

              // Section 3: Juristic Method (Asr)
              _buildSectionHeader(context, 'المذهب الفقهي (صلاة العصر)', Icons.balance),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('الجمهور (الشافعي، المالكي، الحنبلي)'),
                      subtitle: const Text('ظل الشيء مثله (المعيار المعتمد في معظم العالم الإسلامي)'),
                      trailing: selectedJuristic == AppJuristicMethod.standard
                          ? const Icon(Icons.check_circle, color: AppColors.emeraldGreen)
                          : null,
                      onTap: () {
                        context.read<PrayerBloc>().add(const ChangeJuristicMethodEvent(AppJuristicMethod.standard));
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      title: const Text('المذهب الحنفي'),
                      subtitle: const Text('ظل الشيء مثليه'),
                      trailing: selectedJuristic == AppJuristicMethod.hanafi
                          ? const Icon(Icons.check_circle, color: AppColors.emeraldGreen)
                          : null,
                      onTap: () {
                        context.read<PrayerBloc>().add(const ChangeJuristicMethodEvent(AppJuristicMethod.hanafi));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  List<LocationModel> _filterCities(List<LocationModel> list, String query) {
    if (query.isEmpty) return list;
    final q = query.toLowerCase();
    return list.where((c) {
      return c.cityName.toLowerCase().contains(q) ||
          c.countryName.toLowerCase().contains(q) ||
          (c.governorate != null && c.governorate!.toLowerCase().contains(q));
    }).toList();
  }

  Widget _buildSectionHeader(BuildContext context, String title, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
