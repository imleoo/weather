import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherCacheService {
  static const String _cachePrefix = 'weather_cache_';
  static const Duration _cacheDuration = Duration(minutes: 10);

  Future<void> cacheWeatherData(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    await prefs.setString('$_cachePrefix$key', json.encode(cacheData));
  }

  Future<Map<String, dynamic>?> getCachedWeatherData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('$_cachePrefix$key');

    if (cachedData == null) return null;

    try {
      final decoded = json.decode(cachedData) as Map<String, dynamic>;
      final timestamp =
          DateTime.fromMillisecondsSinceEpoch(decoded['timestamp']);

      if (DateTime.now().difference(timestamp) > _cacheDuration) {
        await prefs.remove('$_cachePrefix$key');
        return null;
      }

      return decoded['data'] as Map<String, dynamic>;
    } catch (e) {
      await prefs.remove('$_cachePrefix$key');
      return null;
    }
  }

  Future<bool> isDataCached(String key) async {
    final cachedData = await getCachedWeatherData(key);
    return cachedData != null;
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith(_cachePrefix)) {
        await prefs.remove(key);
      }
    }
  }

  String generateCacheKey(String city) => 'city_$city';
  String generateLocationCacheKey(double lat, double lon) =>
      'location_${lat.toStringAsFixed(2)}_${lon.toStringAsFixed(2)}';
}
