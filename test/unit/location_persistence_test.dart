import 'package:flutter_test/flutter_test.dart';
import 'package:smart_muslim/core/location/egypt_cities_data.dart';
import 'package:smart_muslim/core/location/location_model.dart';

void main() {
  group('Location Model & City Data Persistence Tests', () {
    test('LocationModel JSON roundtrip serialization', () {
      const original = LocationModel(
        latitude: 31.2001,
        longitude: 29.9187,
        cityName: 'الإسكندرية',
        countryName: 'مصر',
        governorate: 'محافظة الإسكندرية',
        isAutoGps: false,
      );

      final json = original.toJson();
      final reconstructed = LocationModel.fromJson(json);

      expect(reconstructed.latitude, equals(original.latitude));
      expect(reconstructed.longitude, equals(original.longitude));
      expect(reconstructed.cityName, equals(original.cityName));
      expect(reconstructed.countryName, equals(original.countryName));
      expect(reconstructed.governorate, equals(original.governorate));
      expect(reconstructed.isAutoGps, equals(original.isAutoGps));
      expect(reconstructed, equals(original));
    });

    test('LocationModel.fromJson handles null or corrupted values safely', () {
      final corruptedJson = <String, dynamic>{
        'latitude': null,
        'longitude': null,
        'cityName': null,
        'countryName': null,
      };

      final fallback = LocationModel.fromJson(corruptedJson);

      expect(fallback.latitude, equals(30.0444));
      expect(fallback.longitude, equals(31.2357));
      expect(fallback.cityName, equals('القاهرة'));
      expect(fallback.countryName, equals('مصر'));
    });

    test('Egypt dataset covers all 27 governorates', () {
      expect(EgyptAndWorldCitiesData.egyptCities.isNotEmpty, isTrue);
      final governorates = EgyptAndWorldCitiesData.egyptCities
          .map((c) => c.governorate)
          .whereType<String>()
          .toSet();
      expect(governorates.length, equals(27));

      for (final city in EgyptAndWorldCitiesData.egyptCities) {
        expect(city.cityName.isNotEmpty, isTrue);
        expect(city.countryName, equals('مصر'));
        expect(city.latitude, greaterThan(20.0));
        expect(city.latitude, lessThan(35.0));
        expect(city.longitude, greaterThan(24.0));
        expect(city.longitude, lessThan(38.0));
      }
    });

    test('Arab and World cities dataset contains valid coordinates', () {
      expect(EgyptAndWorldCitiesData.arabAndWorldCities.isNotEmpty, isTrue);
      for (final city in EgyptAndWorldCitiesData.arabAndWorldCities) {
        expect(city.cityName.isNotEmpty, isTrue);
        expect(city.countryName.isNotEmpty, isTrue);
        expect(city.latitude, isNotNull);
        expect(city.longitude, isNotNull);
      }
    });
  });
}
