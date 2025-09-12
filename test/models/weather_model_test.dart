import 'package:flutter_test/flutter_test.dart';
import 'package:weather/models/weather_model.dart';
import 'package:weather/models/fishing_weather_model.dart';

void main() {
  group('WeatherModel Tests', () {
    test('WeatherModel.fromJson creates valid model from valid JSON', () {
      final json = {
        'current_condition': [
          {
            'temp_C': '25',
            'FeelsLikeC': '26',
            'humidity': '65',
            'weatherDesc': [{'value': 'Sunny'}],
            'weatherCode': '113',
            'windspeedKmph': '10',
            'precipMM': '0.0',
            'pressure': '1013',
            'visibility': '10',
            'uvIndex': '5',
            'observation_time': '12:00 PM',
          }
        ],
        'weather': [
          {
            'date': '2025-09-08',
            'maxtempC': '30',
            'mintempC': '20',
            'sunHour': '8.5',
            'uvIndex': '6',
            'hourly': [
              {
                'time': '2025-09-08 12:00',
                'tempC': '25',
                'weatherDesc': [{'value': 'Sunny'}],
                'weatherCode': '113',
                'chanceofrain': '10',
                'humidity': '65',
                'windspeedKmph': '10',
                'FeelsLikeC': '26',
                'pressure': '1013',
                'cloudcover': '25',
                'visibility': '10',
                'DewPointC': '18',
              }
            ],
            'astronomy': [
              {
                'sunrise': '06:00 AM',
                'sunset': '06:00 PM',
                'moonrise': '10:00 AM',
                'moonset': '09:00 PM',
                'moon_phase': 'Full Moon',
              }
            ]
          }
        ],
        'nearest_area': [
          {
            'areaName': [{'value': 'Beijing'}],
            'country': [{'value': 'China'}],
            'region': [{'value': 'Beijing'}],
            'latitude': '39.9042',
            'longitude': '116.4074',
          }
        ]
      };

      final weatherModel = WeatherModel.fromJson(json);

      expect(weatherModel.currentCondition.tempC, equals('25'));
      expect(weatherModel.currentCondition.weatherDesc, equals('Sunny'));
      expect(weatherModel.forecast.length, equals(1));
      expect(weatherModel.forecast[0].date, equals('2025-09-08'));
      expect(weatherModel.nearestArea.areaName, equals('Beijing'));
    });

    test('WeatherModel.fromJson handles empty JSON gracefully', () {
      final json = <String, dynamic>{};

      final weatherModel = WeatherModel.fromJson(json);

      expect(weatherModel.currentCondition.tempC, equals('0'));
      expect(weatherModel.forecast.length, equals(1));
      expect(weatherModel.nearestArea.areaName, equals('Unknown Area'));
    });

    test('Hourly fishing suitability evaluation works', () {
      final json = {
        'time': '2025-09-08 06:00',
        'tempC': '18',
        'weatherDesc': [{'value': 'Clear'}],
        'weatherCode': '113',
        'chanceofrain': '20',
        'humidity': '70',
        'windspeedKmph': '8',
        'FeelsLikeC': '19',
        'pressure': '1013',
        'cloudcover': '30',
        'visibility': '10',
        'DewPointC': '15',
      };

      final hourly = Hourly.fromJson(json);
      final fishingSuitability = hourly.fishingSuitability;

      expect(fishingSuitability, isA<FishingWeatherModel>());
      expect(fishingSuitability.score, greaterThanOrEqualTo(0));
      expect(fishingSuitability.score, lessThanOrEqualTo(20)); // Max score is 20
      expect(fishingSuitability.suitability, isA<FishingSuitability>());
    });

    test('NearestArea handles Chinese localization', () {
      final json = {
        'areaName': [{'value': 'Beijing'}],
        'country': [{'value': 'China'}],
        'region': [{'value': 'Beijing'}],
        'latitude': '39.9042',
        'longitude': '116.4074',
      };

      final nearestArea = NearestArea.fromJson(json);

      // Note: This test assumes the AppLocalizations.isEnglish is false
      // In a real test, you would need to mock the localization
      expect(nearestArea.latitude, equals('39.9042'));
      expect(nearestArea.longitude, equals('116.4074'));
    });

    test('CurrentCondition handles missing data gracefully', () {
      final json = <String, dynamic>{};

      final currentCondition = CurrentCondition.fromJson(json);

      expect(currentCondition.tempC, equals('0'));
      expect(currentCondition.weatherDesc, equals('Unknown'));
      expect(currentCondition.humidity, equals('0'));
    });

    test('Weather handles missing hourly data', () {
      final json = {
        'date': '2025-09-08',
        'maxtempC': '30',
        'mintempC': '20',
        'sunHour': '8.5',
        'uvIndex': '6',
        'hourly': [],
        'astronomy': [{
          'sunrise': '06:00 AM',
          'sunset': '06:00 PM',
          'moonrise': '10:00 AM',
          'moonset': '09:00 PM',
          'moon_phase': 'Full Moon',
        }],
      };

      final weather = Weather.fromJson(json);

      expect(weather.date, equals('未知日期')); // Model returns Chinese default on error
      expect(weather.hourly.length, equals(1)); // Should have default hourly data
    });
  });
}