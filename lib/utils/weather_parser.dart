import 'package:flutter/foundation.dart';
import '../models/weather_model.dart';
import '../l10n/app_localizations.dart';

// 解析参数类
class WeatherParseParams {
  final Map<String, dynamic> json;
  final bool isEnglish;

  WeatherParseParams({
    required this.json,
    required this.isEnglish,
  });
}

// 静态方法，可在后台线程执行
WeatherModel _parseWeatherJson(WeatherParseParams params) {
  return WeatherModel.fromJsonWithLanguage(params.json, params.isEnglish);
}

// 异步解析方法，使用compute在后台线程执行
Future<WeatherModel> parseWeatherJsonAsync(Map<String, dynamic> json) async {
  final isEnglish = AppLocalizations.isEnglish;
  final params = WeatherParseParams(json: json, isEnglish: isEnglish);
  return compute(_parseWeatherJson, params);
}