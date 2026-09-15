import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/location/location_model.dart';
import '../../../../core/location/location_service.dart';
import '../../../../core/notifications/notification_scheduler.dart';
import '../../../../core/utils/prayer_calculator.dart';
import '../../../../core/utils/qibla_math.dart';
import 'prayer_event.dart';
import 'prayer_state.dart';

class PrayerBloc extends Bloc<PrayerEvent, PrayerState> {
  static const String _methodKey = 'smart_muslim_calc_method';
  static const String _juristicKey = 'smart_muslim_juristic_method';

  Timer? _timer;
  final NotificationScheduler _notificationScheduler = NotificationSchedulerFactory.createAdapter();

  LocationModel _currentLocation = LocationModel.cairo();
  AppCalculationMethod _currentMethod = AppCalculationMethod.egyptian;
  AppJuristicMethod _currentJuristic = AppJuristicMethod.standard;

  PrayerBloc() : super(PrayerInitialState()) {
    on<LoadPrayerTimesEvent>(_onLoadPrayerTimes);
    on<ChangeCalculationMethodEvent>(_onChangeCalculationMethod);
    on<ChangeJuristicMethodEvent>(_onChangeJuristicMethod);
    on<TickTimerEvent>(_onTickTimer);

    // Start 1-second countdown timer for remaining time
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const TickTimerEvent());
    });
  }

  Future<void> _loadSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMethodIndex = prefs.getInt(_methodKey);
    if (savedMethodIndex != null && savedMethodIndex < AppCalculationMethod.values.length) {
      _currentMethod = AppCalculationMethod.values[savedMethodIndex];
    }

    final savedJuristicIndex = prefs.getInt(_juristicKey);
    if (savedJuristicIndex != null && savedJuristicIndex < AppJuristicMethod.values.length) {
      _currentJuristic = AppJuristicMethod.values[savedJuristicIndex];
    }
  }

  Future<void> _onLoadPrayerTimes(
    LoadPrayerTimesEvent event,
    Emitter<PrayerState> emit,
  ) async {
    emit(PrayerLoadingState());

    try {
      await _loadSavedPreferences();

      if (event.customLocation != null) {
        _currentLocation = event.customLocation!;
        await LocationService.saveSelectedLocation(_currentLocation);
      } else {
        final saved = await LocationService.getSavedLocation();
        if (saved != null) {
          _currentLocation = saved;
        } else {
          _currentLocation = await LocationService.getCurrentLocation();
        }
      }

      final schedule = PrayerCalculatorService.calculateSchedule(
        latitude: _currentLocation.latitude,
        longitude: _currentLocation.longitude,
        date: DateTime.now(),
        method: _currentMethod,
        juristic: _currentJuristic,
      );

      final qiblaBearing = QiblaMath.calculateQiblaBearing(
        _currentLocation.latitude,
        _currentLocation.longitude,
      );

      // Initialize and schedule background notifications
      await _notificationScheduler.initialize();
      await _notificationScheduler.checkAndRequestPermissions();
      await _notificationScheduler.schedulePrayerNotifications(
        latitude: _currentLocation.latitude,
        longitude: _currentLocation.longitude,
        method: _currentMethod,
        juristic: _currentJuristic,
      );

      emit(PrayerLoadedState(
        location: _currentLocation,
        schedule: schedule,
        selectedMethod: _currentMethod,
        selectedJuristic: _currentJuristic,
        qiblaBearing: qiblaBearing,
      ));
    } catch (e) {
      emit(PrayerErrorState('فشل في حساب مواقيت الصلاة: ${e.toString()}'));
    }
  }

  Future<void> _onChangeCalculationMethod(
    ChangeCalculationMethodEvent event,
    Emitter<PrayerState> emit,
  ) async {
    _currentMethod = event.method;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_methodKey, event.method.index);
    add(LoadPrayerTimesEvent(customLocation: _currentLocation));
  }

  Future<void> _onChangeJuristicMethod(
    ChangeJuristicMethodEvent event,
    Emitter<PrayerState> emit,
  ) async {
    _currentJuristic = event.juristic;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_juristicKey, event.juristic.index);
    add(LoadPrayerTimesEvent(customLocation: _currentLocation));
  }

  void _onTickTimer(
    TickTimerEvent event,
    Emitter<PrayerState> emit,
  ) {
    if (state is PrayerLoadedState) {
      final currentState = state as PrayerLoadedState;
      final schedule = PrayerCalculatorService.calculateSchedule(
        latitude: currentState.location.latitude,
        longitude: currentState.location.longitude,
        date: DateTime.now(),
        method: currentState.selectedMethod,
        juristic: currentState.selectedJuristic,
      );

      emit(currentState.copyWith(schedule: schedule));
    }
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
