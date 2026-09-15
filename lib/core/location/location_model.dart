import 'package:equatable/equatable.dart';
import 'egypt_cities_data.dart';

class LocationModel extends Equatable {
  final double latitude;
  final double longitude;
  final String cityName;
  final String countryName;
  final String? governorate;
  final bool isAutoGps;

  const LocationModel({
    required this.latitude,
    required this.longitude,
    required this.cityName,
    required this.countryName,
    this.governorate,
    this.isAutoGps = true,
  });

  /// Default fallback location: Makkah al-Mukarramah
  factory LocationModel.makkah() {
    return const LocationModel(
      latitude: 21.4225,
      longitude: 39.8262,
      cityName: 'مكة المكرمة',
      countryName: 'المملكة العربية السعودية',
      governorate: 'منطقة مكة المكرمة',
      isAutoGps: false,
    );
  }

  /// Default fallback for Egypt: Cairo
  factory LocationModel.cairo() {
    return const LocationModel(
      latitude: 30.0444,
      longitude: 31.2357,
      cityName: 'القاهرة',
      countryName: 'مصر',
      governorate: 'محافظة القاهرة',
      isAutoGps: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'cityName': cityName,
      'countryName': countryName,
      'governorate': governorate,
      'isAutoGps': isAutoGps,
    };
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 30.0444,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 31.2357,
      cityName: json['cityName'] as String? ?? 'القاهرة',
      countryName: json['countryName'] as String? ?? 'مصر',
      governorate: json['governorate'] as String?,
      isAutoGps: json['isAutoGps'] as bool? ?? false,
    );
  }

  /// Default cities referencing the structured dataset
  static List<LocationModel> get defaultCities => EgyptAndWorldCitiesData.getAllCities();

  @override
  List<Object?> get props => [latitude, longitude, cityName, countryName, governorate, isAutoGps];
}
