import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';

class WeatherProvider with ChangeNotifier {
  WeatherModel? _weatherData;
  String? _city;
  bool _isLoading = false;
  String? _error;

  WeatherModel? get weatherData => _weatherData;
  String? get city => _city;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();

  Future<void> fetchWeatherByCity(String city) async {
    _setLoading(true);
    _error = null;

    try {
      final weather = await _weatherService.getWeatherByCity(city);
      _weatherData = weather;
      _city = city;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchWeatherByCurrentLocation() async {
    _setLoading(true);
    _error = null;

    try {
      final position = await _locationService.getCurrentLocation();
      if (position != null) {
        final weather = await _weatherService.getWeatherByLocation(
          position.latitude,
          position.longitude,
        );
        _weatherData = weather;
        _city = weather.nearestArea.areaName;
        _error = null;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
