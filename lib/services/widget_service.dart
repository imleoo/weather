import 'dart:async';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';
import '../models/fishing_weather_model.dart';
import '../models/weather_model.dart';
import '../providers/weather_provider.dart';

/// 小部件服务，用于更新桌面小部件
class WidgetService {
  static const String appGroupId = 'group.com.example.weather';
  static const String androidWidgetName = 'FishingWeatherWidgetProvider';
  static const String iOSWidgetName = 'FishingWeatherWidget';

  // 后台任务名称
  static const String updateWidgetTask = 'updateFishingWidgetTask';

  /// 初始化小部件服务
  static Future<void> init() async {
    // 初始化HomeWidget插件
    await HomeWidget.setAppGroupId(appGroupId);

    // 注册小部件点击回调
    HomeWidget.registerBackgroundCallback(backgroundCallback);

    // 初始化WorkManager
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: false,
    );

    // 注册定期更新任务
    await Workmanager().registerPeriodicTask(
      updateWidgetTask,
      updateWidgetTask,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
      ),
    );

    // 首次更新小部件
    await updateWidgetData();

    // 设置定时器，每分钟更新一次小部件（确保时间显示正确）
    Timer.periodic(const Duration(minutes: 1), (timer) {
      updateWidgetTime();
    });
  }

  /// 更新小部件时间
  static Future<void> updateWidgetTime() async {
    try {
      // 更新小部件
      await HomeWidget.updateWidget(
        androidName: androidWidgetName,
        iOSName: iOSWidgetName,
      );
    } catch (e) {
      debugPrint('更新小部件时间失败: $e');
    }
  }

  /// 后台任务回调
  @pragma('vm:entry-point')
  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      if (task == updateWidgetTask) {
        await updateWidgetData();
        return true;
      }
      return false;
    });
  }

  /// 小部件点击回调
  static Future<void> backgroundCallback(Uri? uri) async {
    if (uri?.host == 'updatewidget') {
      // 当小部件被点击时，可以执行一些操作
      // 例如，更新小部件数据
      await updateWidgetData();
    }
  }

  /// 更新小部件数据
  static Future<void> updateWidgetData() async {
    try {
      final weatherProvider = WeatherProvider();
      await weatherProvider.fetchWeatherByCurrentLocation();

      if (weatherProvider.weatherData != null) {
        final weatherData = weatherProvider.weatherData!;
        final currentCondition = weatherData.currentCondition;

        // 获取当前小时的钓鱼适宜性
        final currentHourly = weatherData.forecast.isNotEmpty
            ? weatherData.forecast[0].hourly.firstWhere(
                (h) => int.parse(h.time) ~/ 100 == DateTime.now().hour,
                orElse: () => weatherData.forecast[0].hourly.first)
            : null;

        if (currentHourly != null) {
          // 评估钓鱼适宜性
          final fishingWeather = FishingWeatherModel.evaluate(currentHourly);

          // 更新小部件数据
          await HomeWidget.saveWidgetData<String>(
              'weatherCondition', currentCondition.weatherDesc);

          await HomeWidget.saveWidgetData<String>(
              'temperature', '${currentCondition.tempC}°C');

          await HomeWidget.saveWidgetData<String>(
              'suitability', _getSuitabilityText(fishingWeather.suitability));

          await HomeWidget.saveWidgetData<String>('suitability_en',
              _getSuitabilityTextEnglish(fishingWeather.suitability));

          await HomeWidget.saveWidgetData<String>(
              'score', fishingWeather.score.toString());

          await HomeWidget.saveWidgetData<String>(
              'weatherCode', currentCondition.weatherCode);

          await HomeWidget.saveWidgetData<String>('suitabilityLevel',
              fishingWeather.suitability.toString().split('.').last);

          // 保存气压数据
          await HomeWidget.saveWidgetData<String>(
              'pressure', currentCondition.pressure);

          // 更新小部件
          await HomeWidget.updateWidget(
            androidName: androidWidgetName,
            iOSName: iOSWidgetName,
          );
        }
      }
    } catch (e) {
      debugPrint('更新小部件数据失败: $e');
    }
  }

  /// 获取适宜性文本（中文）
  static String _getSuitabilityText(FishingSuitability suitability) {
    switch (suitability) {
      case FishingSuitability.excellent:
        return '非常适宜';
      case FishingSuitability.good:
        return '适宜';
      case FishingSuitability.moderate:
        return '一般';
      case FishingSuitability.poor:
        return '不适宜';
      default:
        return '未知';
    }
  }

  /// 获取适宜性文本（英文）
  static String _getSuitabilityTextEnglish(FishingSuitability suitability) {
    switch (suitability) {
      case FishingSuitability.excellent:
        return 'Excellent';
      case FishingSuitability.good:
        return 'Good';
      case FishingSuitability.moderate:
        return 'Moderate';
      case FishingSuitability.poor:
        return 'Poor';
      default:
        return 'Unknown';
    }
  }
}
