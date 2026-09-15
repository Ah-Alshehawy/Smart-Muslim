import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/qibla_math.dart';
import '../../../prayer/presentation/bloc/prayer_bloc.dart';
import '../../../prayer/presentation/bloc/prayer_state.dart';

class QiblaScreen extends StatefulWidget {
  const QiblaScreen({super.key});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  Timer? _sensorTimeoutTimer;

  // Sensor state
  double _ax = 0.0;
  double _ay = 0.0;
  double _az = 9.8; // Default normal gravity
  double _smoothedTrueHeading = 0.0;
  bool _hasSensorData = false;
  bool _isSensorAvailable = true;
  bool _hasHapticFiredForCurrentFacing = false;

  // High-performance value notifier for isolated needle repaints
  final ValueNotifier<double> _headingNotifier = ValueNotifier<double>(0.0);

  @override
  void initState() {
    super.initState();
    _startCompassStreams();
  }

  void _startCompassStreams() {
    try {
      // 1. High-frequency Accelerometer for dynamic 3D tilt compensation
      _accelerometerSubscription = accelerometerEventStream(
        samplingPeriod: SensorInterval.uiInterval,
      ).listen(
        (AccelerometerEvent event) {
          _ax = event.x;
          _ay = event.y;
          _az = event.z;
        },
        onError: (_) {},
        cancelOnError: false,
      );

      // 2. High-frequency Magnetometer stream
      _magnetometerSubscription = magnetometerEventStream(
        samplingPeriod: SensorInterval.uiInterval,
      ).listen(
        (MagnetometerEvent event) {
          _processSensorEvent(event.x, event.y, event.z);
        },
        onError: (_) {
          if (mounted) {
            setState(() => _isSensorAvailable = false);
          }
        },
        cancelOnError: false,
      );

      // Timeout fallback for devices without magnetic hardware
      _sensorTimeoutTimer = Timer(const Duration(milliseconds: 2000), () {
        if (mounted && !_hasSensorData) {
          setState(() => _isSensorAvailable = false);
        }
      });
    } catch (_) {
      if (mounted) {
        setState(() => _isSensorAvailable = false);
      }
    }
  }

  void _processSensorEvent(double mx, double my, double mz) {
    // 1. Compute tilt-compensated magnetic heading
    final double magneticHeading = QiblaMath.calculateTiltCompensatedHeading(
      ax: _ax,
      ay: _ay,
      az: _az,
      mx: mx,
      my: my,
      mz: mz,
    );

    // 2. Obtain local magnetic declination from current location in PrayerBloc
    double declination = 0.0;
    final prayerState = context.read<PrayerBloc>().state;
    if (prayerState is PrayerLoadedState) {
      declination = QiblaMath.calculateMagneticDeclination(
        prayerState.location.latitude,
        prayerState.location.longitude,
      );
    }

    // 3. Convert to True (Geographic) Heading
    final double rawTrueHeading = QiblaMath.convertMagneticToTrueHeading(
      magneticHeading,
      declination,
    );

    // 4. Fast-response adaptive angular smoothing
    if (!_hasSensorData) {
      _smoothedTrueHeading = rawTrueHeading;
      _headingNotifier.value = _smoothedTrueHeading;
      if (mounted) {
        setState(() {
          _hasSensorData = true;
          _isSensorAvailable = true;
        });
      }
      return;
    }

    final double diff = QiblaMath.calculateShortestAngle(rawTrueHeading, _smoothedTrueHeading);
    final double absDiff = diff.abs();

    // High alpha (0.75) for fast phone turning; gentle alpha (0.25) to eliminate hand jitter
    final double alpha = absDiff > 12.0 ? 0.75 : 0.25;

    if (absDiff > 0.15) {
      _smoothedTrueHeading = QiblaMath.normalize360(_smoothedTrueHeading + alpha * diff);
      _headingNotifier.value = _smoothedTrueHeading;
    }
  }

  @override
  void dispose() {
    _sensorTimeoutTimer?.cancel();
    _sensorTimeoutTimer = null;
    _magnetometerSubscription?.cancel();
    _magnetometerSubscription = null;
    _accelerometerSubscription?.cancel();
    _accelerometerSubscription = null;
    _headingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'اتجاه القبلة',
          style: AppTypography.titleLarge(isDark),
        ),
      ),
      body: BlocBuilder<PrayerBloc, PrayerState>(
        builder: (context, state) {
          if (state is PrayerLoadedState) {
            final double qiblaBearing = state.qiblaBearing;

            return Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Location & Target Bearing
                    Text(
                      'اتجاه القبلة من موقعك الحالي (${state.location.cityName})',
                      style: AppTypography.titleMedium(isDark),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${qiblaBearing.toStringAsFixed(1)}° من الشمال الحقيقي',
                      style: AppTypography.caption(isDark).copyWith(
                        fontSize: 16,
                        color: AppColors.sandGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Modern Compass Dial with Isolated RepaintBoundary
                    RepaintBoundary(
                      child: ValueListenableBuilder<double>(
                        valueListenable: _headingNotifier,
                        builder: (context, currentHeading, _) {
                          final double relativeAngle = _hasSensorData
                              ? QiblaMath.calculateRelativeQiblaAngle(
                                  qiblaBearing: qiblaBearing,
                                  trueHeading: currentHeading,
                                )
                              : qiblaBearing;

                          final bool isFacingQibla = relativeAngle.abs() <= 4.0;

                          // Haptic pulse when entering accurate Qibla alignment
                          if (isFacingQibla && !_hasHapticFiredForCurrentFacing) {
                            HapticFeedback.selectionClick();
                            _hasHapticFiredForCurrentFacing = true;
                          } else if (!isFacingQibla) {
                            _hasHapticFiredForCurrentFacing = false;
                          }

                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // Dial Outer Ring
                              Container(
                                width: 280,
                                height: 280,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                                  border: Border.all(
                                    color: isFacingQibla
                                        ? AppColors.emeraldGreen
                                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                    width: isFacingQibla ? 4 : 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isFacingQibla
                                          ? AppColors.emeraldGreen.withValues(alpha: 0.35)
                                          : Colors.black.withValues(alpha: 0.08),
                                      blurRadius: 24,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // North Marker (ش)
                                    Positioned(
                                      top: 12,
                                      child: Text(
                                        'ش (N)',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: AppColors.danger,
                                        ),
                                      ),
                                    ),
                                    // East Marker (ق)
                                    Positioned(
                                      right: 14,
                                      child: Text('ق (E)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                    ),
                                    // South Marker (ج)
                                    Positioned(
                                      bottom: 12,
                                      child: Text('ج (S)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                    ),
                                    // West Marker (غ)
                                    Positioned(
                                      left: 14,
                                      child: Text('غ (W)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                                    ),
                                  ],
                                ),
                              ),

                              // Symmetrically Centered Compass Needle Rotating Exactly Around Pivot
                              Transform.rotate(
                                angle: relativeAngle * (math.pi / 180.0),
                                alignment: Alignment.center,
                                child: SizedBox(
                                  width: 280,
                                  height: 280,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      // Top Arrow (Points directly to Kaaba)
                                      Positioned(
                                        top: 36,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.navigation,
                                              size: 64,
                                              color: isFacingQibla ? AppColors.sandGold : AppColors.emeraldGreen,
                                            ),
                                            const SizedBox(height: 2),
                                            Container(
                                              width: 12,
                                              height: 12,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: isFacingQibla ? AppColors.sandGold : AppColors.emeraldGreen,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Pivot Center Pin
                                      Container(
                                        width: 24,
                                        height: 24,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isFacingQibla ? AppColors.sandGold : AppColors.emeraldGreen,
                                          border: Border.all(color: Colors.white, width: 2.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Center Alignment Status Badge (Fixed in Center Pivot)
                              Positioned(
                                bottom: 20,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isFacingQibla ? AppColors.emeraldGreen : (isDark ? Colors.black54 : Colors.white70),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isFacingQibla ? AppColors.emeraldGreen : Colors.grey.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    isFacingQibla ? '✓ في اتجاه القبلة تمامًا' : 'وجّه هاتفك نحو السهم',
                                    style: TextStyle(
                                      fontFamily: AppTypography.arabicFontFamily,
                                      color: isFacingQibla ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Live Sensor Status Badge
                    ValueListenableBuilder<double>(
                      valueListenable: _headingNotifier,
                      builder: (context, currentHeading, _) {
                        if (_hasSensorData) {
                          final double relativeAngle = QiblaMath.calculateRelativeQiblaAngle(
                            qiblaBearing: qiblaBearing,
                            trueHeading: currentHeading,
                          );
                          final bool isFacingQibla = relativeAngle.abs() <= 4.0;

                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: isFacingQibla
                                  ? AppColors.emeraldGreen.withValues(alpha: 0.15)
                                  : (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.04)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isFacingQibla ? AppColors.emeraldGreen : Colors.transparent,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.sensors,
                                  size: 16,
                                  color: isFacingQibla ? AppColors.emeraldGreen : AppColors.sandGold,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'اتجاه البوصلة الحقيقي: ${currentHeading.toStringAsFixed(0)}°',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                              ],
                            ),
                          );
                        } else if (!_isSensorAvailable) {
                          return Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.sandGold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.sandGold),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline, color: AppColors.sandGoldDark, size: 20),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'حساس البوصلة غير متاح في جهازك - يتم عرض الزاوية الجغرافية الثابتة بالنسبة للشمال.',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),

                    const SizedBox(height: 20),
                    Text(
                      'حرّك الهاتف بشكل دائري أو على شكل 8 لمعايرة البوصلة عند الحاجة.',
                      textAlign: TextAlign.center,
                      style: AppTypography.bodyMedium(isDark).copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          }

          return const Center(
            child: CircularProgressIndicator(color: AppColors.emeraldGreen),
          );
        },
      ),
    );
  }
}
