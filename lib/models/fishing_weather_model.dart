import 'package:flutter/material.dart';
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

  // 根据小时天气数据评估钓鱼适宜性
  static FishingWeatherModel evaluate(Hourly hourly) {
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
    String advice;

    if (totalScore >= 12) {
      suitability = FishingSuitability.excellent;
      advice = AppLocalizations.isEnglish
          ? 'Excellent fishing conditions! Fish are likely to be active. Highly recommended!'
          : '非常适宜钓鱼，鱼群活跃，建议出钓！';
    } else if (totalScore >= 8) {
      suitability = FishingSuitability.good;
      advice = AppLocalizations.isEnglish
          ? 'Good fishing conditions. Favorable weather for fishing.'
          : '适宜钓鱼，条件良好，可以考虑出钓。';
    } else if (totalScore >= 4) {
      suitability = FishingSuitability.moderate;
      advice = AppLocalizations.isEnglish
          ? 'Moderate fishing conditions. Catch may be inconsistent.'
          : '钓鱼条件一般，鱼获可能不稳定。';
    } else {
      suitability = FishingSuitability.poor;
      advice = AppLocalizations.isEnglish
          ? 'Poor fishing conditions. Consider choosing another time.'
          : '不适宜钓鱼，建议选择其他时间。';
    }

    return FishingWeatherModel(
      hourlyData: hourly,
      suitability: suitability,
      score: totalScore,
      scoreDetails: scoreDetails,
      advice: advice,
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
}

// 扩展Hourly类，添加钓鱼相关字段
extension FishingHourlyExtension on Hourly {
  String get pressure => '1010'; // 假设API没有提供气压数据，使用默认值
  String get cloudcover => '50'; // 假设API没有提供云量数据，使用默认值
  String get visibility => '10'; // 假设API没有提供能见度数据，使用默认值

  // 评估当前小时的钓鱼适宜性
  FishingWeatherModel get fishingSuitability =>
      FishingWeatherModel.evaluate(this);
}
