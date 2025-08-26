import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../models/weather_model.dart';
import '../l10n/app_localizations.dart';

// 选择器组件 - 只在城市名称变化时重建
class CitySelector extends StatelessWidget {
  final Widget Function(String? city) builder;

  const CitySelector({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final city = context.select<WeatherProvider, String?>(
      (provider) => provider.city,
    );
    return builder(city);
  }
}

// 选择器组件 - 只在加载状态变化时重建
class LoadingSelector extends StatelessWidget {
  final Widget Function(bool isLoading) builder;

  const LoadingSelector({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<WeatherProvider, bool>(
      (provider) => provider.isLoading,
    );
    return builder(isLoading);
  }
}

// 选择器组件 - 只在错误状态变化时重建
class ErrorSelector extends StatelessWidget {
  final Widget Function(String? error) builder;

  const ErrorSelector({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final error = context.select<WeatherProvider, String?>(
      (provider) => provider.error,
    );
    return builder(error);
  }
}

// 选择器组件 - 只在天气数据存在性变化时重建
class WeatherDataExistenceSelector extends StatelessWidget {
  final Widget Function(bool hasData) builder;

  const WeatherDataExistenceSelector({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final hasData = context.select<WeatherProvider, bool>(
      (provider) => provider.weatherData != null,
    );
    return builder(hasData);
  }
}

// 选择器组件 - 只在当前天气条件变化时重建
class CurrentConditionSelector extends StatelessWidget {
  final Widget Function(dynamic currentCondition) builder;

  const CurrentConditionSelector({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final currentCondition = context.select<WeatherProvider, dynamic>(
      (provider) => provider.weatherData?.currentCondition,
    );
    return builder(currentCondition);
  }
}

// 选择器组件 - 只在天气预报数据变化时重建
class ForecastSelector extends StatelessWidget {
  final Widget Function(List<Weather> forecast) builder;

  const ForecastSelector({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final forecast = context.select<WeatherProvider, List<Weather>>(
      (provider) => provider.weatherData?.forecast ?? [],
    );
    return builder(forecast);
  }
}

// 选择器组件 - 只在天气代码变化时重建
class WeatherCodeSelector extends StatelessWidget {
  final Widget Function(String? weatherCode) builder;

  const WeatherCodeSelector({super.key, required this.builder});

  @override
  Widget build(BuildContext context) {
    final weatherCode = context.select<WeatherProvider, String?>(
      (provider) => provider.weatherData?.currentCondition.weatherCode,
    );
    return builder(weatherCode);
  }
}
