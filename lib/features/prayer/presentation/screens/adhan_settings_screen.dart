import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';
import '../../../../core/notifications/adhan_sound_resolver.dart';
import '../../../../core/notifications/adhan_audio_service.dart';
import '../../../../core/notifications/notification_preferences.dart';
import '../../../../core/notifications/notification_scheduler.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../bloc/prayer_bloc.dart';
import '../bloc/prayer_event.dart';

class AdhanSettingsScreen extends StatefulWidget {
  final String? initialPrayerKey;

  const AdhanSettingsScreen({super.key, this.initialPrayerKey});

  @override
  State<AdhanSettingsScreen> createState() => _AdhanSettingsScreenState();
}

class _AdhanSettingsScreenState extends State<AdhanSettingsScreen> {
  late final AdhanAudioService _audioService;
  bool _isPlayingAudio = false;
  String? _currentlyPlayingSound;

  NotificationPreferences _prefs = NotificationPreferences.defaultConfig();
  bool _isLoading = true;
  String _selectedPrayerKey = 'fajr';

  final Map<String, String> _prayerNamesArabic = {
    'fajr': 'صلاة الفجر',
    'dhuhr': 'صلاة الظهر',
    'asr': 'صلاة العصر',
    'maghrib': 'صلاة المغرب',
    'isha': 'صلاة العشاء',
  };

  @override
  void initState() {
    super.initState();
    _audioService = JustAudioAdhanService();
    _audioService.playerStateStream.listen((playerState) {
      if (playerState.processingState == ProcessingState.completed) {
        if (mounted) {
          setState(() {
            _isPlayingAudio = false;
            _currentlyPlayingSound = null;
          });
        }
      }
    });

    if (widget.initialPrayerKey != null && _prayerNamesArabic.containsKey(widget.initialPrayerKey)) {
      _selectedPrayerKey = widget.initialPrayerKey!;
    }

    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final loaded = await NotificationPreferences.load();
    setState(() {
      _prefs = loaded;
      _isLoading = false;
    });
  }

  Future<void> _savePreferences() async {
    await _prefs.save();
    // Check and request notification & exact alarm permissions if notifications are enabled
    if (_prefs.globalNotificationsEnabled) {
      final scheduler = NotificationSchedulerFactory.createAdapter();
      await scheduler.checkAndRequestPermissions();
    }

    if (mounted) {
      context.read<PrayerBloc>().add(const LoadPrayerTimesEvent());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حفظ إعدادات الأذان وجدولة التنبيهات بنجاح!'),
          backgroundColor: AppColors.emeraldGreen,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _togglePlayTestAudio(String soundKey) async {
    if (_isPlayingAudio && _currentlyPlayingSound == soundKey) {
      await _audioService.stop();
      if (mounted) {
        setState(() {
          _isPlayingAudio = false;
          _currentlyPlayingSound = null;
        });
      }
      return;
    }

    try {
      await _audioService.playSound(soundKey);
      if (mounted) {
        setState(() {
          _isPlayingAudio = true;
          _currentlyPlayingSound = soundKey;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تعذر تشغيل ملف الصوت: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.emeraldGreen)),
      );
    }

    final currentSetting = _prefs.getPrayer(_selectedPrayerKey);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إعدادات الأذان والتنبيهات',
          style: AppTypography.titleLarge(isDark),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'استعادة الافتراضي',
            onPressed: () {
              setState(() {
                _prefs = NotificationPreferences.defaultConfig();
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('تمت استعادة الإعدادات الافتراضية')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Section 1: Global Toggle & Silence Duration
          _buildSectionHeader(context, 'التحكم العام بالتنبيهات', Icons.settings_suggest),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('تفعيل إشعارات وتنبيهات الصلوات', style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('تشغيل التنبيهات المجدولة لجميع الصلوات'),
                  value: _prefs.globalNotificationsEnabled,
                  onChanged: (val) {
                    setState(() {
                      _prefs = NotificationPreferences(
                        prayers: _prefs.prayers,
                        globalNotificationsEnabled: val,
                        globalSilenceMinutes: _prefs.globalSilenceMinutes,
                      );
                    });
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.do_not_disturb_on_outlined, color: AppColors.sandGold),
                  title: const Text('كتم صوت التطبيق مؤقتًا'),
                  subtitle: Text(_prefs.globalSilenceMinutes == 0
                      ? 'غير مفعل (الصوت يعمل بشكل طبيعي)'
                      : 'مكتوم لمدة ${_prefs.globalSilenceMinutes} دقيقة'),
                  trailing: DropdownButton<int>(
                    value: _prefs.globalSilenceMinutes,
                    underline: const SizedBox(),
                    items: const [
                      DropdownMenuItem(value: 0, child: Text('إيقاف (OFF)')),
                      DropdownMenuItem(value: 5, child: Text('٥ دقائق')),
                      DropdownMenuItem(value: 10, child: Text('١٠ دقائق')),
                      DropdownMenuItem(value: 15, child: Text('١٥ دقيقة')),
                      DropdownMenuItem(value: 30, child: Text('٣٠ دقيقة')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _prefs = NotificationPreferences(
                            prayers: _prefs.prayers,
                            globalNotificationsEnabled: _prefs.globalNotificationsEnabled,
                            globalSilenceMinutes: val,
                          );
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Section 2: Prayer Selector Chips
          _buildSectionHeader(context, 'تخصيص الصلاة المحددة', Icons.tune),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _prayerNamesArabic.entries.map((entry) {
                final isSelected = _selectedPrayerKey == entry.key;
                final prayerSetting = _prefs.getPrayer(entry.key);

                return Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(entry.value),
                        const SizedBox(width: 4),
                        Icon(
                          prayerSetting.notificationEnabled
                              ? Icons.notifications_active
                              : Icons.notifications_off,
                          size: 14,
                          color: isSelected
                              ? Colors.white
                              : (prayerSetting.notificationEnabled ? AppColors.emeraldGreen : Colors.grey),
                        ),
                      ],
                    ),
                    selected: isSelected,
                    selectedColor: AppColors.emeraldGreen,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black87),
                      fontWeight: FontWeight.bold,
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _selectedPrayerKey = entry.key);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Section 3: Selected Prayer Settings Card
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.emeraldGreen, width: 1.5),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _prayerNamesArabic[_selectedPrayerKey] ?? '',
                        style: AppTypography.titleMedium(isDark).copyWith(
                          color: AppColors.emeraldGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: currentSetting.notificationEnabled,
                        onChanged: (val) {
                          setState(() {
                            _prefs = _prefs.updatePrayer(
                              _selectedPrayerKey,
                              currentSetting.copyWith(notificationEnabled: val),
                            );
                          });
                        },
                      ),
                    ],
                  ),
                  const Divider(),

                  // Adhan Audio Switch
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('تشغيل صوت الأذان'),
                    subtitle: const Text('صوت الأذان عند دخول الوقت'),
                    value: currentSetting.adhanAudioEnabled,
                    onChanged: currentSetting.notificationEnabled
                        ? (val) {
                            setState(() {
                              _prefs = _prefs.updatePrayer(
                                _selectedPrayerKey,
                                currentSetting.copyWith(adhanAudioEnabled: val),
                              );
                            });
                          }
                        : null,
                  ),

                  // Pre-Prayer Reminder
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('تنبيه الاستعداد قبل الصلاة'),
                    subtitle: const Text('إشعار مسبق قبل دخول وقت الصلاة'),
                    value: currentSetting.prePrayerReminder,
                    onChanged: currentSetting.notificationEnabled
                        ? (val) {
                            setState(() {
                              _prefs = _prefs.updatePrayer(
                                _selectedPrayerKey,
                                currentSetting.copyWith(prePrayerReminder: val),
                              );
                            });
                          }
                        : null,
                  ),

                  if (currentSetting.prePrayerReminder) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('وقت التنبيه المسبق:'),
                        DropdownButton<int>(
                          value: currentSetting.prePrayerMinutes,
                          underline: const SizedBox(),
                          items: const [
                            DropdownMenuItem(value: 5, child: Text('٥ دقائق')),
                            DropdownMenuItem(value: 10, child: Text('١٠ دقائق')),
                            DropdownMenuItem(value: 15, child: Text('١٥ دقيقة')),
                            DropdownMenuItem(value: 20, child: Text('٢٠ دقيقة')),
                            DropdownMenuItem(value: 30, child: Text('٣٠ دقيقة')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _prefs = _prefs.updatePrayer(
                                  _selectedPrayerKey,
                                  currentSetting.copyWith(prePrayerMinutes: val),
                                );
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],

                  const Divider(),

                  // Adhan Mode: Full Adhan vs Takbeer Only
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('نوع الأذان'),
                    subtitle: Text(currentSetting.isFullAdhan ? 'أذان كامل' : 'التكبير فقط'),
                    trailing: DropdownButton<bool>(
                      value: currentSetting.isFullAdhan,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(value: true, child: Text('أذان كامل')),
                        DropdownMenuItem(value: false, child: Text('التكبير فقط')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _prefs = _prefs.updatePrayer(
                              _selectedPrayerKey,
                              currentSetting.copyWith(isFullAdhan: val),
                            );
                          });
                        }
                      },
                    ),
                  ),

                  // Iqama Reminder
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('تنبيه الإقامة'),
                    subtitle: Text(currentSetting.iqamaReminder
                        ? 'بعد ${currentSetting.iqamaDelayMinutes} دقيقة من الأذان'
                        : 'معطل'),
                    value: currentSetting.iqamaReminder,
                    onChanged: (val) {
                      setState(() {
                        _prefs = _prefs.updatePrayer(
                          _selectedPrayerKey,
                          currentSetting.copyWith(iqamaReminder: val),
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Section 4: Audio Selection & Test Audio Playback
          _buildSectionHeader(context, 'اختبار وتحديد صوت الأذان (Adhan Audio)', Icons.volume_up),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                for (int i = 0; i < AdhanSoundResolver.availableSounds.length; i++) ...[
                  if (i > 0) const Divider(height: 1),
                  _buildAudioTestTile(
                    AdhanSoundResolver.availableSounds[i].titleArabic,
                    AdhanSoundResolver.availableSounds[i].key,
                    isDark,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Save & Reschedule Action Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.emeraldGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text(
              'حفظ الإعدادات وإعادة جدولة التنبيهات',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              await _savePreferences();
              if (!context.mounted) return;
              Navigator.pop(context);
            },
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildAudioTestTile(String title, String soundKey, bool isDark) {
    final isCurrentPlaying = _isPlayingAudio && _currentlyPlayingSound == soundKey;
    final isSelectedForCurrentPrayer = _prefs.getPrayer(_selectedPrayerKey).adhanSound == soundKey;

    return ListTile(
      title: Text(title, style: TextStyle(fontWeight: isSelectedForCurrentPrayer ? FontWeight.bold : FontWeight.normal)),
      subtitle: Text(isSelectedForCurrentPrayer ? 'الصوت المعتمد لـ ${_prayerNamesArabic[_selectedPrayerKey]}' : 'صوت متاح'),
      leading: Icon(
        isSelectedForCurrentPrayer ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelectedForCurrentPrayer ? AppColors.emeraldGreen : Colors.grey,
      ),
      trailing: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: isCurrentPlaying ? AppColors.danger : AppColors.emeraldGreen.withValues(alpha: 0.15),
          foregroundColor: isCurrentPlaying ? Colors.white : AppColors.emeraldGreen,
          elevation: 0,
        ),
        icon: Icon(isCurrentPlaying ? Icons.stop : Icons.play_arrow, size: 18),
        label: Text(isCurrentPlaying ? 'إيقاف' : 'تجربة'),
        onPressed: () => _togglePlayTestAudio(soundKey),
      ),
      onTap: () {
        setState(() {
          final current = _prefs.getPrayer(_selectedPrayerKey);
          _prefs = _prefs.updatePrayer(
            _selectedPrayerKey,
            current.copyWith(adhanSound: soundKey),
          );
        });
      },
    );
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
