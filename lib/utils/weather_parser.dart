import 'package:flutter/foundation.dart';
import '../models/weather_model.dart';

// 静态方法，可在后台线程执行
WeatherModel _parseWeatherJson(Map<String, dynamic> json) {
  return WeatherModel.fromJson(json);
}

// 异步解析方法，使用compute在后台线程执行
Future<WeatherModel> parseWeatherJsonAsync(Map<String, dynamic> json) async {
  return compute(_parseWeatherJson, json);
}