import 'dart:async';
import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/location_service.dart';
import '../services/widget_service.dart';
import '../utils/app_logger.dart';

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
      final weather = await _weatherService
          .getWeatherByCity(city)
          .timeout(const Duration(seconds: 60));
      _weatherData = weather;
      _city = city;
      _error = null;

      // 更新小部件数据
      await WidgetService.updateWidgetData();
    } on TimeoutException {
      _error = '获取天气数据超时，请检查网络连接';
    } catch (e) {
      _error = '获取天气数据失败: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  /// 快速获取天气数据（优先使用IP定位）
  Future<void> fetchWeatherQuickly() async {
    print('🌤️ WeatherProvider: 开始快速获取天气数据（IP定位）');
    _setLoading(true);
    _error = null;

    try {
      // 首先尝试IP定位（最快）
      print('🌤️ WeatherProvider: 正在调用getWeatherByIpLocation...');
      final weather = await _weatherService
          .getWeatherByIpLocation()
          .timeout(const Duration(seconds: 20));
      _weatherData = weather;
      _city = weather.nearestArea.areaName;
      _error = null;
      print('🌤️ WeatherProvider: 快速获取天气数据成功: ${weather.nearestArea.areaName}');

      // 更新小部件数据
      await WidgetService.updateWidgetData();
    } on TimeoutException {
      _error = '获取天气数据超时，请检查网络连接';
      print('❌ WeatherProvider: 快速获取天气数据超时');
    } catch (e) {
      _error = '获取天气数据失败: ${e.toString()}';
      print('❌ WeatherProvider: 快速获取天气数据失败: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchWeatherByCurrentLocation() async {
    _setLoading(true);
    _error = null;

    try {
      final position = await _locationService
          .getCurrentLocation()
          .timeout(const Duration(seconds: 60));
      if (position != null) {
        final weather = await _weatherService
            .getWeatherByLocation(
              position.latitude,
              position.longitude,
            )
            .timeout(const Duration(seconds: 60));
        _weatherData = weather;
        _city = weather.nearestArea.areaName;
        _error = null;

        // 更新小部件数据
        await WidgetService.updateWidgetData();
      }
    } on TimeoutException {
      _error = '获取天气数据超时，请检查网络连接';
    } catch (e) {
      _error = '获取天气数据失败: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
