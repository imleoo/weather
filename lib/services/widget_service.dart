import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';
import '../models/fishing_weather_model.dart';
import '../models/weather_model.dart';
import '../providers/weather_provider.dart';

/// 小部件服务，用于更新桌面小部件
class WidgetService {
  static const String appGroupId = 'group.cn.leoobai.fishingweather';
  static const String androidWidgetName = 'FishingWeatherWidgetLargeProvider';
  static const String iOSWidgetName = 'FishingWidget';

  // 后台任务名称
  static const String updateWidgetTask = 'updateFishingWidgetTask';

  // 应用状态管理
  static bool _isAppVisible = true;
  static Timer? _timeUpdateTimer;
  static Timer? _weatherUpdateTimer;

  /// 初始化小部件服务
  static Future<void> init() async {
    try {
      // 初始化HomeWidget插件
      await HomeWidget.setAppGroupId(appGroupId);

      // 注册小部件点击回调
      HomeWidget.registerBackgroundCallback(backgroundCallback);

      // 初始化WorkManager
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false,
      );

      // 注册定期更新任务（减少频率以节省资源）
      await Workmanager().registerPeriodicTask(
        updateWidgetTask,
        updateWidgetTask,
        frequency: const Duration(minutes: 30), // 从10分钟改为30分钟
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
      );

      // 首次更新小部件（异步进行，不阻塞初始化）
      unawaited(updateWidgetData());

      // 设置定时器，每分钟更新一次小部件时间（减少资源消耗）
      startTimeUpdateTimer();

      // 设置天气更新定时器（每30分钟，与后台任务保持一致）
      startWeatherUpdateTimer();
    } catch (e) {
      debugPrint('Widget service initialization error: $e');
      // 小部件服务初始化失败不影响应用运行
    }
  }

  /// 开始时间更新定时器
  static void startTimeUpdateTimer() {
    _timeUpdateTimer?.cancel(); // 取消之前的定时器
    _timeUpdateTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_isAppVisible) {
        updateWidgetTime();
      }
    });
  }

  /// 开始天气更新定时器
  static void startWeatherUpdateTimer() {
    _weatherUpdateTimer?.cancel(); // 取消之前的定时器
    _weatherUpdateTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      if (_isAppVisible) {
        updateWidgetData();
      }
    });
  }

  /// 应用进入前台
  static void onAppForeground() {
    _isAppVisible = true;
    startTimeUpdateTimer();
    startWeatherUpdateTimer();
    // 立即更新一次时间和天气
    unawaited(updateWidgetTime());
    unawaited(updateWidgetData());
  }

  /// 应用进入后台
  static void onAppBackground() {
    _isAppVisible = false;
    _timeUpdateTimer?.cancel();
    _weatherUpdateTimer?.cancel();
  }

  /// 停止所有定时器
  static void stopAllTimers() {
    _timeUpdateTimer?.cancel();
    _weatherUpdateTimer?.cancel();
    _timeUpdateTimer = null;
    _weatherUpdateTimer = null;
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

  // 全局WeatherProvider实例，用于在应用内共享
  static WeatherProvider? _globalWeatherProvider;

  // 设置全局WeatherProvider实例
  static void setGlobalWeatherProvider(WeatherProvider provider) {
    _globalWeatherProvider = provider;
  }

  // 获取全局天气数据
  static WeatherModel? _getGlobalWeatherData() {
    return _globalWeatherProvider?.weatherData;
  }

  /// 更新小部件数据
  static Future<void> updateWidgetData() async {
    try {
      // 获取全局WeatherProvider实例或创建新实例
      WeatherModel? weatherData;

      // 尝试从全局状态获取现有天气数据
      final globalWeatherData = _getGlobalWeatherData();

      if (globalWeatherData != null) {
        // 使用应用内现有的天气数据
        weatherData = globalWeatherData;
      } else {
        // 如果没有现有数据（例如在后台任务中），则创建新实例并获取数据
        final weatherProvider = WeatherProvider();
        await weatherProvider
            .fetchWeatherQuickly()
            .timeout(const Duration(seconds: 30));
        weatherData = weatherProvider.weatherData;
      }

      if (weatherData != null) {
        final currentCondition = weatherData.currentCondition;

        // 安全地获取当前小时的钓鱼适宜性
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
          currentHourly = null;
        }

        if (currentHourly != null) {
          // 评估钓鱼适宜性
          final fishingWeather = FishingWeatherModel.evaluate(currentHourly);

          // 创建iOS小部件需要的WeatherData对象
          final widgetData = {
            'temperature': '${currentCondition.tempC}°C',
            'weatherCondition': currentCondition.weatherDesc,
            'location': weatherData.nearestArea.areaName,
            'fishingScore': fishingWeather.score,
            'fishingAdvice': _getSuitabilityText(fishingWeather.suitability),
            'updateTime': _formatUpdateTime(DateTime.now()),
          };

          // 将数据保存为JSON格式，供iOS小部件使用
          await HomeWidget.saveWidgetData<String>(
              'fishing_weather_data', jsonEncode(widgetData));

          // 同时保存单独的字段供Android使用（保持兼容性）
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

          // 保存定位地址数据
          await HomeWidget.saveWidgetData<String>(
              'location', weatherData.nearestArea.areaName);

          // 保存最后更新时间（iOS小部件需要）
          await HomeWidget.saveWidgetData<int>(
              'lastUpdated', DateTime.now().millisecondsSinceEpoch);

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

  /// 格式化更新时间
  static String _formatUpdateTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    
    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else {
      return '${difference.inDays}天前';
    }
  }
}
