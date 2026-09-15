import 'package:equatable/equatable.dart';
import '../../../../core/location/location_model.dart';
import '../../../../core/utils/prayer_calculator.dart';

abstract class PrayerState extends Equatable {
  const PrayerState();

  @override
  List<Object?> get props => [];
}

class PrayerInitialState extends PrayerState {}

class PrayerLoadingState extends PrayerState {}

class PrayerLoadedState extends PrayerState {
  final LocationModel location;
  final PrayerScheduleResult schedule;
  final AppCalculationMethod selectedMethod;
  final AppJuristicMethod selectedJuristic;
  final double qiblaBearing;

  const PrayerLoadedState({
    required this.location,
    required this.schedule,
    required this.selectedMethod,
    required this.selectedJuristic,
    required this.qiblaBearing,
  });

  PrayerLoadedState copyWith({
    LocationModel? location,
    PrayerScheduleResult? schedule,
    AppCalculationMethod? selectedMethod,
    AppJuristicMethod? selectedJuristic,
    double? qiblaBearing,
  }) {
    return PrayerLoadedState(
      location: location ?? this.location,
      schedule: schedule ?? this.schedule,
      selectedMethod: selectedMethod ?? this.selectedMethod,
      selectedJuristic: selectedJuristic ?? this.selectedJuristic,
      qiblaBearing: qiblaBearing ?? this.qiblaBearing,
    );
  }

  @override
  List<Object?> get props => [
        location,
        schedule,
        selectedMethod,
        selectedJuristic,
        qiblaBearing,
      ];
}

class PrayerErrorState extends PrayerState {
  final String errorMessage;
  const PrayerErrorState(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}
