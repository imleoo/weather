import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../utils/weather_parser.dart';
import 'weather_cache_service.dart';

class WeatherService {
  final String baseUrl = 'https://wttr.in';
  final WeatherCacheService _cacheService = WeatherCacheService();

  Future<WeatherModel> getWeatherByCity(String city) async {
    try {
      final cacheKey = _cacheService.generateCacheKey(city);

      // 尝试从缓存获取数据
      final cachedData = await _cacheService.getCachedWeatherData(cacheKey);
      if (cachedData != null) {
        return await parseWeatherJsonAsync(cachedData);
      }

      // 从网络获取数据
      final response = await http.get(
        Uri.parse('$baseUrl/$city?format=j1'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;

        // 缓存数据
        await _cacheService.cacheWeatherData(cacheKey, jsonData);

        return await parseWeatherJsonAsync(jsonData);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('获取天气数据超时，请检查网络连接');
    } catch (e) {
      throw Exception('获取天气数据失败: $e');
    }
  }

  Future<WeatherModel> getWeatherByLocation(double lat, double lon) async {
    try {
      final cacheKey = _cacheService.generateLocationCacheKey(lat, lon);

      // 尝试从缓存获取数据
      final cachedData = await _cacheService.getCachedWeatherData(cacheKey);
      if (cachedData != null) {
        return await parseWeatherJsonAsync(cachedData);
      }

      // 从网络获取数据
      final response = await http.get(
        Uri.parse('$baseUrl/$lat,$lon?format=j1'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;

        // 缓存数据
        await _cacheService.cacheWeatherData(cacheKey, jsonData);

        return await parseWeatherJsonAsync(jsonData);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('获取天气数据超时，请检查网络连接');
    } catch (e) {
      throw Exception('获取天气数据失败: $e');
    }
  }

  /// 通过IP定位获取天气数据（最快的方式）
  Future<WeatherModel> getWeatherByIpLocation() async {
    try {
      final cacheKey = 'ip_location_weather';

      // 尝试从缓存获取数据
      final cachedData = await _cacheService.getCachedWeatherData(cacheKey);
      if (cachedData != null) {
        return await parseWeatherJsonAsync(cachedData);
      }

      // 从网络获取数据，使用IP定位
      final response = await http.get(
        Uri.parse('$baseUrl/?format=j1'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15)); // IP定位更快，减少超时时间

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;

        // 缓存数据，IP定位缓存时间较短（30分钟）
        await _cacheService.cacheWeatherData(cacheKey, jsonData);

        return await parseWeatherJsonAsync(jsonData);
      } else {
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('获取天气数据超时，请检查网络连接');
    } catch (e) {
      throw Exception('获取天气数据失败: $e');
    }
  }
}
