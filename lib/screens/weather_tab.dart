import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/weather_icons.dart';
import '../widgets/current_weather.dart';
import '../widgets/fishing_daily_forecast.dart';
import '../widgets/weather_selectors.dart';
import '../l10n/app_localizations.dart';
import '../services/ad_service.dart';
import 'city_search_screen.dart';
import 'settings_screen.dart';

class WeatherTab extends StatefulWidget {
  const WeatherTab({super.key});

  @override
  State<WeatherTab> createState() => _WeatherTabState();
}

class _WeatherTabState extends State<WeatherTab> {
  @override
  void initState() {
    super.initState();
    // 初始化时获取当前位置的天气
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchWeatherData();
      // 预加载广告
      AdService.initialize();
    });
  }

  Future<void> _fetchWeatherData() async {
    final weatherProvider = Provider.of<WeatherProvider>(
      context,
      listen: false,
    );
    try {
      // 首次启动使用IP定位快速获取天气
      await weatherProvider.fetchWeatherQuickly();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取天气数据失败: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: CitySelector(
          builder: (city) {
            return Text(
              city ?? AppLocalizations.weather,
              style: const TextStyle(color: Colors.white),
            );
          },
        ),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () async {
              final selectedCity = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CitySearchScreen(),
                ),
              );

              if (selectedCity != null && selectedCity.isNotEmpty) {
                final weatherProvider = Provider.of<WeatherProvider>(
                  context,
                  listen: false,
                );
                await weatherProvider.fetchWeatherByCity(selectedCity);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.my_location, color: Colors.white),
            onPressed: () async {
              // 显示开始提示
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('正在获取位置信息...'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
              
              // 并行执行广告显示和定位功能
              final weatherProvider = Provider.of<WeatherProvider>(
                context,
                listen: false,
              );
              
              // 启动定位任务
              final locationTask = weatherProvider.fetchWeatherByCurrentLocation().then((_) {
                // 定位成功 - 立即停止广告
                print('🎯 定位完成，立即停止广告播放');
                AdService.stopAd();
                
                // 显示定位成功提示
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('位置信息已更新'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }).catchError((e) {
                // 定位失败 - 也停止广告
                print('❌ 定位失败，停止广告播放');
                AdService.stopAd();
                
                // 显示定位失败提示
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('获取天气数据失败: ${e.toString()}')),
                  );
                }
              });
              
              // 启动广告显示任务
              try {
                print('准备显示激励广告...');
                AdService.showRewardedAd(context).then((adResult) {
                  print('广告结果显示: $adResult');
                }).catchError((e) {
                  print('广告显示异常: $e');
                });
              } catch (e) {
                print('广告启动异常: $e');
              }
              
              print('🚀 定位和广告任务已并行启动 - 定位完成时将停止广告');
            },
          ),
        ],
      ),
      body: LoadingSelector(
        builder: (isLoading) {
          if (isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ErrorSelector(
            builder: (error) {
              if (error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${AppLocalizations.loadingFailed}: $error',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _fetchWeatherData,
                        child: Text(AppLocalizations.retry),
                      ),
                    ],
                  ),
                );
              }

              return WeatherDataExistenceSelector(
                builder: (hasData) {
                  if (!hasData) {
                    return Center(child: Text(AppLocalizations.noWeatherData));
                  }

                  return WeatherCodeSelector(
                    builder: (weatherCode) {
                      final backgroundColor =
                          WeatherIcons.getWeatherColor(weatherCode ?? '113');

                      return Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              backgroundColor,
                              backgroundColor.withOpacity(0.7),
                              Colors.white,
                            ],
                          ),
                        ),
                        child: RefreshIndicator(
                          onRefresh: () async {
                            final weatherProvider =
                                Provider.of<WeatherProvider>(
                              context,
                              listen: false,
                            );
                            if (weatherProvider.city != null &&
                                weatherProvider.city !=
                                    weatherProvider
                                        .weatherData?.nearestArea.areaName) {
                              // 如果是手动选择的城市，刷新城市天气
                              await weatherProvider.fetchWeatherByCity(
                                weatherProvider.city!,
                              );
                            } else {
                              // 否则使用快速IP定位刷新
                              await weatherProvider.fetchWeatherQuickly();
                            }
                          },
                          child: ListView(
                            padding: const EdgeInsets.all(16.0),
                            children: [
                              CurrentConditionSelector(
                                builder: (currentCondition) {
                                  return CurrentWeather(
                                    currentCondition: currentCondition,
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              // 使用新的钓鱼天气预报组件
                              ForecastSelector(
                                builder: (forecast) {
                                  return FishingDailyForecast(
                                      forecast: forecast);
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
