import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';
import '../models/fishing_weather_model.dart';
import '../models/weather_model.dart';
import '../providers/weather_provider.dart';
import '../l10n/app_localizations.dart';

/// 简化的小部件服务
class WidgetService {
  static const String appGroupId = 'group.cn.leoobai.fishingweather';
  static const String androidWidgetName = 'FishingWeatherWidgetLargeProvider';
  static const String iOSWidgetName = 'FishingWidget';
  static const String updateWidgetTask = 'updateFishingWidgetTask';

  static Timer? _updateTimer;
  static WeatherProvider? _globalWeatherProvider;

  static Future<void> init() async {
    try {
      await HomeWidget.setAppGroupId(appGroupId);
      HomeWidget.registerBackgroundCallback(backgroundCallback);
      
      await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
      await Workmanager().registerPeriodicTask(
        updateWidgetTask,
        updateWidgetTask,
        frequency: const Duration(minutes: 30),
        constraints: Constraints(networkType: NetworkType.connected),
      );

      // 延迟初始化widget数据，确保应用启动后获取数据
      Future.delayed(const Duration(seconds: 5), () async {
        await updateWidgetData();
      });
      _startPeriodicUpdates();
    } catch (e) {
      debugPrint('Widget service initialization error: $e');
    }
  }

  static void _startPeriodicUpdates() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      updateWidgetData();
    });
  }

  static void setGlobalWeatherProvider(WeatherProvider provider) {
    _globalWeatherProvider = provider;
    
    // 监听provider的变化
    provider.addListener(() {
      // 当天气数据变化时，更新widget
      if (provider.weatherData != null) {
        // 延迟更新，避免频繁调用
        Future.delayed(const Duration(seconds: 2), () async {
          await updateWidgetData();
        });
      }
    });
  }

  static WeatherModel? _getGlobalWeatherData() {
    return _globalWeatherProvider?.weatherData;
  }

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

  static Future<void> backgroundCallback(Uri? uri) async {
    if (uri?.host == 'updatewidget') {
      await updateWidgetData();
    }
  }

  static Future<void> updateWidgetData() async {
    try {
      WeatherModel? weatherData = _getGlobalWeatherData();
      
      if (weatherData == null) {
        // 如果没有全局天气数据，尝试重新获取
        final weatherProvider = WeatherProvider();
        try {
          await weatherProvider.fetchWeatherQuickly()
              .timeout(const Duration(seconds: 30));
          weatherData = weatherProvider.weatherData;
        } catch (e) {
          debugPrint('获取天气数据失败: $e');
          return;
        }
      }

      if (weatherData != null) {
        final currentCondition = weatherData.currentCondition;
        Hourly? currentHourly;

        try {
          final forecastList = weatherData.forecast;
          if (forecastList.isNotEmpty && forecastList[0].hourly.isNotEmpty) {
            currentHourly = forecastList[0].hourly.firstWhere(
                (h) => int.parse(h.time) ~/ 100 == DateTime.now().hour,
                orElse: () => forecastList[0].hourly.first);
          }
        } catch (e) {
          debugPrint('获取当前小时天气数据失败: $e');
        }

        if (currentHourly != null) {
          final fishingWeather = FishingWeatherModel.evaluate(currentHourly);
          
          // 获取当前应用的本地化文本
          final suitabilityText = _getLocalizedSuitabilityText(fishingWeather.suitability.name);
          
          // 保存应用标题和其他本地化文本
          await HomeWidget.saveWidgetData<String>(
              'widget_title', AppLocalizations.appTitle);
          await HomeWidget.saveWidgetData<String>(
              'level_prefix', AppLocalizations.isEnglish ? 'Level: ' : '适宜性: ');
          await HomeWidget.saveWidgetData<String>(
              'score_prefix', AppLocalizations.isEnglish ? 'Score: ' : '评分: ');

          final widgetData = {
            'temperature': '${currentCondition.tempC}°C',
            'weatherCondition': currentCondition.weatherDesc,
            'location': weatherData.nearestArea.areaName,
            'fishingScore': fishingWeather.score,
            'fishingAdvice': fishingWeather.advice,
            'updateTime': _formatUpdateTime(DateTime.now()),
          };

          await HomeWidget.saveWidgetData<String>(
              'fishing_weather_data', jsonEncode(widgetData));

          await HomeWidget.saveWidgetData<String>(
              'weatherCondition', currentCondition.weatherDesc);
          await HomeWidget.saveWidgetData<String>(
              'temperature', '${currentCondition.tempC}°C');
          // 保存本地化文本而不是枚举值
          await HomeWidget.saveWidgetData<String>(
              'suitability', suitabilityText);
          await HomeWidget.saveWidgetData<String>(
              'score', fishingWeather.score.toString());
          await HomeWidget.saveWidgetData<String>(
              'pressure', currentCondition.pressure);
          await HomeWidget.saveWidgetData<String>(
              'location', weatherData.nearestArea.areaName);
          await HomeWidget.saveWidgetData<int>(
              'lastUpdated', DateTime.now().millisecondsSinceEpoch);

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

  
  static String _getLocalizedSuitabilityText(String suitabilityEnum) {
    switch (suitabilityEnum) {
      case 'excellent':
        return AppLocalizations.excellent;
      case 'good':
        return AppLocalizations.good;
      case 'moderate':
        return AppLocalizations.moderate;
      case 'poor':
        return AppLocalizations.poor;
      default:
        return AppLocalizations.isEnglish ? 'Unknown' : '未知';
    }
  }

  static String _formatUpdateTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) return '刚刚';
    if (difference.inMinutes < 60) return '${difference.inMinutes}分钟前';
    if (difference.inHours < 24) return '${difference.inHours}小时前';
    return '${difference.inDays}天前';
  }

  static void dispose() {
    _updateTimer?.cancel();
    _updateTimer = null;
  }
}