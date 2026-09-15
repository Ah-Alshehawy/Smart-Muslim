import 'package:equatable/equatable.dart';
import '../../../../core/location/location_model.dart';
import '../../../../core/utils/prayer_calculator.dart';

abstract class PrayerEvent extends Equatable {
  const PrayerEvent();

  @override
  List<Object?> get props => [];
}

class LoadPrayerTimesEvent extends PrayerEvent {
  final LocationModel? customLocation;
  const LoadPrayerTimesEvent({this.customLocation});

  @override
  List<Object?> get props => [customLocation];
}

class ChangeCalculationMethodEvent extends PrayerEvent {
  final AppCalculationMethod method;
  const ChangeCalculationMethodEvent(this.method);

  @override
  List<Object?> get props => [method];
}

class ChangeJuristicMethodEvent extends PrayerEvent {
  final AppJuristicMethod juristic;
  const ChangeJuristicMethodEvent(this.juristic);

  @override
  List<Object?> get props => [juristic];
}

class TickTimerEvent extends PrayerEvent {
  const TickTimerEvent();
}
