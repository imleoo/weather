import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../l10n/app_localizations.dart';

enum FishingSuitability { excellent, good, moderate, poor }

class FishingWeatherModel {
  final Hourly hourlyData;
  final FishingSuitability suitability;
  final int score;
  final Map<String, int> scoreDetails;
  final String advice;

  FishingWeatherModel({
    required this.hourlyData,
    required this.suitability,
    required this.score,
    required this.scoreDetails,
    required this.advice,
  });

  // 缓存相关常量
  static const String _cachePrefix = 'fishing_weather_cache_';
  static const Duration _cacheDuration = Duration(minutes: 30);

  // 异步评估方法，使用compute在后台线程执行
  static Future<FishingWeatherModel> evaluateAsync(Hourly hourly) async {
    return compute(_evaluateInternal, hourly);
  }

  // 带缓存的异步评估方法
  static Future<FishingWeatherModel> evaluateAsyncWithCache(
      Hourly hourly) async {
    final cacheKey = _generateCacheKey(hourly);

    // 尝试从缓存获取
    final cachedResult = await _getCachedResult(cacheKey);
    if (cachedResult != null) {
      return cachedResult;
    }

    // 计算并缓存结果
    final result = await compute(_evaluateInternal, hourly);
    await _cacheResult(cacheKey, result);

    return result;
  }

  // 同步评估方法，用于直接调用
  static FishingWeatherModel evaluate(Hourly hourly) {
    return _evaluateInternal(hourly);
  }

  // 生成缓存键
  static String _generateCacheKey(Hourly hourly) {
    return '$_cachePrefix${hourly.time}_${hourly.tempC}_${hourly.weatherCode}_${hourly.chanceofrain}_${hourly.humidity}_${hourly.windspeedKmph}_${hourly.pressure}_${hourly.cloudcover}_${hourly.visibility}';
  }

  // 从缓存获取结果
  static Future<FishingWeatherModel?> _getCachedResult(String cacheKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(cacheKey);

      if (cachedData == null) return null;

      final decoded = json.decode(cachedData) as Map<String, dynamic>;
      final timestamp =
          DateTime.fromMillisecondsSinceEpoch(decoded['timestamp']);

      if (DateTime.now().difference(timestamp) > _cacheDuration) {
        await prefs.remove(cacheKey);
        return null;
      }

      return FishingWeatherModel(
        hourlyData: Hourly.fromJson(decoded['hourlyData']),
        suitability: FishingSuitability.values.firstWhere(
          (e) => e.name == decoded['suitability'],
        ),
        score: decoded['score'],
        scoreDetails: Map<String, int>.from(decoded['scoreDetails']),
        advice: decoded['advice'],
      );
    } catch (e) {
      return null;
    }
  }

  // 缓存结果
  static Future<void> _cacheResult(
      String cacheKey, FishingWeatherModel result) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'hourlyData': {
          'time': result.hourlyData.time,
          'tempC': result.hourlyData.tempC,
          'weatherCode': result.hourlyData.weatherCode,
          'chanceofrain': result.hourlyData.chanceofrain,
          'humidity': result.hourlyData.humidity,
          'windspeedKmph': result.hourlyData.windspeedKmph,
          'pressure': result.hourlyData.pressure,
          'cloudcover': result.hourlyData.cloudcover,
          'visibility': result.hourlyData.visibility,
        },
        'suitability': result.suitability.name,
        'score': result.score,
        'scoreDetails': result.scoreDetails,
        'advice': result.advice,
      };

      await prefs.setString(cacheKey, json.encode(cacheData));
    } catch (e) {
      // 缓存失败不影响主要功能
    }
  }

  // 清除钓鱼天气缓存
  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();

    for (final key in keys) {
      if (key.startsWith(_cachePrefix)) {
        await prefs.remove(key);
      }
    }
  }

  // 内部评估逻辑，可在后台线程执行
  static FishingWeatherModel _evaluateInternal(Hourly hourly) {
    // 初始化评分详情
    Map<String, int> scoreDetails = {
      'pressure': 0,
      'weather': 0,
      'rainChance': 0,
      'cloudCover': 0,
      'windSpeed': 0,
      'temperature': 0,
      'humidity': 0,
      'visibility': 0,
    };

    // 评估气压 (假设API返回的pressure是hPa单位)
    int pressureValue = int.tryParse(hourly.pressure ?? '0') ?? 0;
    if (pressureValue >= 1005 && pressureValue <= 1015) {
      scoreDetails['pressure'] = 2;
    } else if (pressureValue > 1015) {
      scoreDetails['pressure'] = 1;
    } else {
      scoreDetails['pressure'] = -1;
    }

    // 评估天气状况
    String weatherDesc = hourly.weatherDesc.toLowerCase();
    if (!weatherDesc.contains('rain') &&
        !weatherDesc.contains('雨') &&
        !weatherDesc.contains('fog') &&
        !weatherDesc.contains('雾')) {
      scoreDetails['weather'] = 2;
    } else if (weatherDesc.contains('light rain') ||
        weatherDesc.contains('小雨') ||
        weatherDesc.contains('patchy rain') ||
        weatherDesc.contains('零星')) {
      scoreDetails['weather'] = 0;
    } else if (weatherDesc.contains('fog') ||
        weatherDesc.contains('雾') ||
        weatherDesc.contains('mist') ||
        weatherDesc.contains('薄雾')) {
      scoreDetails['weather'] = -1;
    } else {
      scoreDetails['weather'] = -2; // 大雨或其他恶劣天气
    }

    // 评估降水概率
    int rainChance = int.tryParse(hourly.chanceofrain) ?? 0;
    if (rainChance < 30) {
      scoreDetails['rainChance'] = 2;
    } else if (rainChance >= 30 && rainChance <= 60) {
      scoreDetails['rainChance'] = 0;
    } else {
      scoreDetails['rainChance'] = -1;
    }

    // 评估云量 (假设API返回的cloudcover是百分比)
    int cloudCover = int.tryParse(hourly.cloudcover ?? '0') ?? 0;
    if (cloudCover >= 20 && cloudCover <= 60) {
      scoreDetails['cloudCover'] = 2;
    } else if (cloudCover < 20 || (cloudCover > 60 && cloudCover <= 80)) {
      scoreDetails['cloudCover'] = 0;
    } else {
      scoreDetails['cloudCover'] = -1;
    }

    // 评估风速
    int windSpeed = int.tryParse(hourly.windspeedKmph) ?? 0;
    if (windSpeed >= 2 && windSpeed <= 10) {
      scoreDetails['windSpeed'] = 2;
    } else if (windSpeed < 2 || (windSpeed > 10 && windSpeed <= 15)) {
      scoreDetails['windSpeed'] = 0;
    } else {
      scoreDetails['windSpeed'] = -2;
    }

    // 评估温度
    int temperature = int.tryParse(hourly.tempC) ?? 0;
    if (temperature >= 15 && temperature <= 30) {
      scoreDetails['temperature'] = 2;
    } else if (temperature < 15 || (temperature > 30 && temperature <= 35)) {
      scoreDetails['temperature'] = 0;
    } else {
      scoreDetails['temperature'] = -2;
    }

    // 评估湿度
    int humidity = int.tryParse(hourly.humidity) ?? 0;
    if (humidity >= 40 && humidity <= 80) {
      scoreDetails['humidity'] = 2;
    } else if (humidity < 40 || (humidity > 80 && humidity <= 90)) {
      scoreDetails['humidity'] = 0;
    } else {
      scoreDetails['humidity'] = -1;
    }

    // 评估能见度 (假设API返回的visibility是公里单位)
    int visibility = int.tryParse(hourly.visibility ?? '0') ?? 0;
    if (visibility > 5) {
      scoreDetails['visibility'] = 2;
    } else if (visibility >= 2 && visibility <= 5) {
      scoreDetails['visibility'] = 0;
    } else {
      scoreDetails['visibility'] = -2;
    }

    // 计算总分
    int totalScore = scoreDetails.values.reduce((a, b) => a + b);

    // 确定适宜性等级
    FishingSuitability suitability;

    // 使用列表存储建议，减少字符串拼接操作
    List<String> adviceParts = [];

    if (totalScore >= 12) {
      suitability = FishingSuitability.excellent;
      adviceParts.add(AppLocalizations.isEnglish
          ? 'Excellent fishing conditions! Fish are likely to be active. Highly recommended!'
          : '非常适宜钓鱼，鱼群活跃，建议出钓！');
    } else if (totalScore >= 8) {
      suitability = FishingSuitability.good;
      adviceParts.add(AppLocalizations.isEnglish
          ? 'Good fishing conditions. Favorable weather for fishing.'
          : '适宜钓鱼，条件良好，可以考虑出钓。');
    } else if (totalScore >= 4) {
      suitability = FishingSuitability.moderate;
      adviceParts.add(AppLocalizations.isEnglish
          ? 'Moderate fishing conditions. Catch may be inconsistent.'
          : '钓鱼条件一般，鱼获可能不稳定。');
    } else {
      suitability = FishingSuitability.poor;
      adviceParts.add(AppLocalizations.isEnglish
          ? 'Poor fishing conditions. Consider choosing another time.'
          : '不适宜钓鱼，建议选择其他时间。');
    }

    // 添加具体因素的建议
    if (scoreDetails['pressure']! < 0) {
      adviceParts.add(AppLocalizations.isEnglish
          ? 'Low pressure may reduce fish activity.'
          : '气压较低，鱼群活性可能降低。');
    }

    if (scoreDetails['windSpeed']! < 0) {
      adviceParts.add(AppLocalizations.isEnglish
          ? 'Strong wind, choose sheltered spots.'
          : '风速较大，建议选择背风处钓鱼。');
    }

    if (scoreDetails['visibility']! < 0) {
      adviceParts.add(AppLocalizations.isEnglish
          ? 'Poor visibility, be cautious.'
          : '能见度较低，注意安全。');
    }

    return FishingWeatherModel(
      hourlyData: hourly,
      suitability: suitability,
      score: totalScore,
      scoreDetails: scoreDetails,
      advice: adviceParts.join(' '),
    );
  }

  // 获取适宜性颜色
  static Color getSuitabilityColor(FishingSuitability suitability) {
    switch (suitability) {
      case FishingSuitability.excellent:
        return Colors.green;
      case FishingSuitability.good:
        return Colors.blue;
      case FishingSuitability.moderate:
        return Colors.orange;
      case FishingSuitability.poor:
        return Colors.red;
    }
  }

  // 获取适宜性文本
  static String getSuitabilityText(FishingSuitability suitability) {
    switch (suitability) {
      case FishingSuitability.excellent:
        return AppLocalizations.excellent;
      case FishingSuitability.good:
        return AppLocalizations.good;
      case FishingSuitability.moderate:
        return AppLocalizations.moderate;
      case FishingSuitability.poor:
        return AppLocalizations.poor;
    }
  }

  // 获取详细的钓鱼建议
  String getDetailedAdvice() {
    List<String> detailedAdvice = [];

    // 基础建议
    detailedAdvice.add(advice);

    // 根据评分添加具体建议
    if (scoreDetails['temperature']! < 0) {
      detailedAdvice.add(AppLocalizations.isEnglish
          ? 'Temperature is not ideal. Fish may be less active.'
          : '温度不适宜，鱼群活性可能受影响，建议在水深处钓鱼。');
    }

    if (scoreDetails['cloudCover']! > 0) {
      detailedAdvice.add(AppLocalizations.isEnglish
          ? 'Cloud cover is optimal for fishing.'
          : '云量适中，有利于钓鱼。');
    }

    if (scoreDetails['rainChance']! < 0 && scoreDetails['weather']! >= 0) {
      detailedAdvice.add(AppLocalizations.isEnglish
          ? 'Light rain may increase fish activity.'
          : '小雨可能使鱼群活跃，但需注意装备防水。');
    }

    return detailedAdvice.join(' ');
  }
}
