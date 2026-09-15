import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../l10n/app_localizations.dart';
import '../../data/tasbih_preferences.dart';
import '../../domain/tasbih_alert_mode.dart';
import '../../domain/tasbih_alert_service.dart';

class TasbeehCounterScreen extends StatefulWidget {
  final TasbihPreferences? preferences;
  final TasbihAlertService? alertService;

  const TasbeehCounterScreen({
    super.key,
    this.preferences,
    this.alertService,
  });

  @override
  State<TasbeehCounterScreen> createState() => _TasbeehCounterScreenState();
}

class _TasbeehCounterScreenState extends State<TasbeehCounterScreen> {
  int _counter = 0;
  int _target = 33;
  int _totalTasbeeh = 0;
  String _selectedDhikr = 'سُبْحَانَ اللَّهِ';
  TasbihAlertMode _alertMode = TasbihAlertMode.vibration;
  bool _hasAlertedForTarget = false;

  late final TasbihPreferences _preferences;
  late final TasbihAlertService _alertService;
  late final bool _ownsAlertService;

  final List<String> _dhikrList = [
    'سُبْحَانَ اللَّهِ',
    'الْحَمْدُ لِلَّهِ',
    'لَا إِلَهَ إِلَّا اللَّهُ',
    'اللَّهُ أَكْبَرُ',
    'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ',
    'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
    'اللَّهُمَّ صَلِّ وَسَلِّمْ عَلَى نَبِيِّنَا مُحَمَّدٍ',
    'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ ، سُبْحَانَ اللَّهِ الْعَظِيمِ',
  ];

  @override
  void initState() {
    super.initState();
    _preferences = widget.preferences ?? const TasbihPreferences();
    if (widget.alertService != null) {
      _alertService = widget.alertService!;
      _ownsAlertService = false;
    } else {
      _alertService = DefaultTasbihAlertService();
      _ownsAlertService = true;
    }
    _loadAlertMode();
    _alertService.initialize();
  }

  Future<void> _loadAlertMode() async {
    final mode = await _preferences.getAlertMode();
    if (mounted) {
      setState(() {
        _alertMode = mode;
      });
    }
  }

  void _cycleAlertMode() {
    setState(() {
      _alertMode = _alertMode.next;
    });
    _preferences.setAlertMode(_alertMode);
  }

  void _increment() {
    HapticFeedback.lightImpact();
    setState(() {
      if (_counter >= _target && _target > 0) {
        // Wrap to 1 for the start of the next cycle
        _counter = 1;
        _totalTasbeeh++;
        _hasAlertedForTarget = false;
      } else {
        _counter++;
        _totalTasbeeh++;
        if (_counter == _target && _target > 0 && !_hasAlertedForTarget) {
          _hasAlertedForTarget = true;
          _alertService.triggerAlert(_alertMode);
        }
      }
    });
  }

  void _reset() {
    setState(() {
      _counter = 0;
      _hasAlertedForTarget = false;
    });
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    if (_ownsAlertService) {
      _alertService.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'المسبحة الإلكترونية',
          style: AppTypography.titleLarge(isDark),
        ),
        actions: [
          _buildAlertModeButton(context, isDark),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            children: [
              // Dhikr Selector Dropdown Card
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: _selectedDhikr,
                      items: _dhikrList.map((dhikr) {
                        return DropdownMenuItem(
                          value: dhikr,
                          child: Text(
                            dhikr,
                            style: AppTypography.titleMedium(isDark).copyWith(
                              color: AppColors.emeraldGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedDhikr = val;
                            _counter = 0;
                            _hasAlertedForTarget = false;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Target Selector Chips
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTargetChip(33),
                  const SizedBox(width: 8),
                  _buildTargetChip(100),
                  const SizedBox(width: 8),
                  _buildTargetChip(1000),
                ],
              ),
              const Spacer(),

              // Circular Interactive Tap Counter
              GestureDetector(
                key: const Key('tasbih_counter_tap_target'),
                onTap: _increment,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: isDark
                          ? [AppColors.emeraldGreenDark, AppColors.darkCard]
                          : [AppColors.emeraldGreen, AppColors.emeraldGreenLight],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.emeraldGreen.withValues(alpha: 0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(color: AppColors.sandGold, width: 3),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$_counter',
                        key: const Key('tasbih_counter_value_text'),
                        style: const TextStyle(
                          fontSize: 64,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: AppTypography.englishFontFamily,
                        ),
                      ),
                      Text(
                        'الهدف: $_target',
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.sandGoldLight,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),

              // Total Lifetime Tasbeeh Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('مجموع التسبيحات', style: TextStyle(fontSize: 13)),
                        const SizedBox(height: 4),
                        Text(
                          '$_totalTasbeeh',
                          key: const Key('tasbih_total_value_text'),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.emeraldGreen,
                            fontFamily: AppTypography.englishFontFamily,
                          ),
                        ),
                      ],
                    ),
                    Container(height: 30, width: 1, color: Colors.grey.shade400),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger.withValues(alpha: 0.1),
                        foregroundColor: AppColors.danger,
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('تصفير'),
                      onPressed: _reset,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertModeButton(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);
    final String tooltip;
    final Widget iconWidget;

    switch (_alertMode) {
      case TasbihAlertMode.vibration:
        tooltip = l10n?.tasbihAlertVibration ?? 'تنبيه بالاهتزاز';
        iconWidget = const Icon(
          Icons.vibration,
          key: Key('tasbih_alert_icon_vibration'),
          size: 20,
          color: AppColors.emeraldGreen,
        );
        break;
      case TasbihAlertMode.sound:
        tooltip = l10n?.tasbihAlertSound ?? 'تنبيه صوتي';
        iconWidget = const Icon(
          Icons.volume_up_rounded,
          key: Key('tasbih_alert_icon_sound'),
          size: 20,
          color: AppColors.emeraldGreen,
        );
        break;
      case TasbihAlertMode.soundAndVibration:
        tooltip = l10n?.tasbihAlertSoundAndVibration ?? 'تنبيه صوتي واهتزاز';
        iconWidget = const Row(
          key: Key('tasbih_alert_icon_sound_and_vibration'),
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.volume_up_rounded, size: 14, color: AppColors.emeraldGreen),
            SizedBox(width: 2),
            Icon(Icons.vibration, size: 14, color: AppColors.emeraldGreen),
          ],
        );
        break;
      case TasbihAlertMode.off:
        tooltip = l10n?.tasbihAlertOff ?? 'التنبيه متوقف';
        iconWidget = Icon(
          Icons.notifications_off_outlined,
          key: const Key('tasbih_alert_icon_off'),
          size: 20,
          color: isDark ? Colors.white60 : Colors.black45,
        );
        break;
    }

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 12.0),
      child: Center(
        child: Tooltip(
          message: tooltip,
          child: Semantics(
            button: true,
            label: tooltip,
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                key: const Key('tasbih_alert_mode_button'),
                onTap: _cycleAlertMode,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? AppColors.darkCard : AppColors.lightSurface,
                    border: Border.all(
                      color: _alertMode == TasbihAlertMode.off
                          ? (isDark ? AppColors.darkBorder : AppColors.lightBorder)
                          : AppColors.emeraldGreen.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (_alertMode == TasbihAlertMode.off
                                ? Colors.black
                                : AppColors.emeraldGreen)
                            .withValues(alpha: 0.08),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: iconWidget,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTargetChip(int target) {
    final isSelected = _target == target;
    return ChoiceChip(
      label: Text('$target مرة'),
      selected: isSelected,
      selectedColor: AppColors.emeraldGreen,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppColors.emeraldGreen,
        fontWeight: FontWeight.bold,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _target = target;
            _counter = 0;
            _hasAlertedForTarget = false;
          });
        }
      },
    );
  }
}
