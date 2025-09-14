import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../utils/weather_parser.dart';
import 'weather_cache_service.dart';
import '../l10n/app_localizations.dart';

class WeatherService {
  final String baseUrl = 'https://wttr.in';
  final WeatherCacheService _cacheService = WeatherCacheService();

  /// 获取API请求的语言参数
  String _getLanguageParam() {
    final isEnglish = AppLocalizations.isEnglish;
    final langParam = isEnglish ? 'en' : 'zh';
    print('🌤️ WeatherService: 当前语言=${isEnglish ? '英文' : '中文'}, API语言参数=$langParam');
    return langParam;
  }

  Future<WeatherModel> getWeatherByCity(String city) async {
    try {
      final cacheKey = _cacheService.generateCacheKey(city);

      // 尝试从缓存获取数据
      final cachedData = await _cacheService.getCachedWeatherData(cacheKey);
      if (cachedData != null) {
        return await parseWeatherJsonAsync(cachedData);
      }

      // 从网络获取数据
      final langParam = _getLanguageParam();
      final response = await http.get(
        Uri.parse('$baseUrl/$city?format=j1&lang=$langParam'),
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
        print('🌤️ WeatherService: 从缓存获取位置天气数据: lat=$lat, lon=$lon');
        return await parseWeatherJsonAsync(cachedData);
      }

      // 从网络获取数据
      final langParam = _getLanguageParam();
      final url = '$baseUrl/?format=j1&lang=$langParam&q=$lat,$lon';
      print('🌤️ WeatherService: 请求位置天气数据 - URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 30));

      print('🌤️ WeatherService: 位置天气API响应 - 状态码: ${response.statusCode}');
      print('🌤️ WeatherService: 位置天气API响应 - 响应头: ${response.headers}');
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        print('🌤️ WeatherService: 位置天气数据解析成功');

        // 缓存数据
        await _cacheService.cacheWeatherData(cacheKey, jsonData);

        return await parseWeatherJsonAsync(jsonData);
      } else {
        print('🌤️ WeatherService: 位置天气API请求失败 - 状态码: ${response.statusCode}');
        print('🌤️ WeatherService: 位置天气API响应内容: ${response.body}');
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } on TimeoutException {
      print('🌤️ WeatherService: 位置天气API请求超时');
      throw Exception('获取天气数据超时，请检查网络连接');
    } catch (e) {
      print('🌤️ WeatherService: 位置天气API请求异常: $e');
      throw Exception('获取天气数据失败: $e');
    }
  }

  /// 通过IP定位获取天气数据（最快的方式）
  Future<WeatherModel> getWeatherByIpLocation() async {
    try {
      final cacheKey = 'ip_location_weather_${_getLanguageParam()}';

      // 尝试从缓存获取数据
      final cachedData = await _cacheService.getCachedWeatherData(cacheKey);
      if (cachedData != null) {
        print('🌤️ WeatherService: 从缓存获取IP定位天气数据');
        return await parseWeatherJsonAsync(cachedData);
      }

      // 从网络获取数据，使用IP定位
      final langParam = _getLanguageParam();
      final url = '$baseUrl/?format=j1&lang=$langParam';
      print('🌤️ WeatherService: 请求IP定位天气数据 - URL: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 15)); // IP定位更快，减少超时时间

      print('🌤️ WeatherService: IP定位天气API响应 - 状态码: ${response.statusCode}');
      print('🌤️ WeatherService: IP定位天气API响应 - 响应头: ${response.headers}');
      
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        print('🌤️ WeatherService: IP定位天气数据解析成功');

        // 缓存数据，IP定位缓存时间较短（30分钟）
        await _cacheService.cacheWeatherData(cacheKey, jsonData);

        return await parseWeatherJsonAsync(jsonData);
      } else {
        print('🌤️ WeatherService: IP定位天气API请求失败 - 状态码: ${response.statusCode}');
        print('🌤️ WeatherService: IP定位天气API响应内容: ${response.body}');
        throw Exception('Failed to load weather data: ${response.statusCode}');
      }
    } on TimeoutException {
      print('🌤️ WeatherService: IP定位天气API请求超时');
      throw Exception('获取天气数据超时，请检查网络连接');
    } catch (e) {
      print('🌤️ WeatherService: IP定位天气API请求异常: $e');
      throw Exception('获取天气数据失败: $e');
    }
  }
}
