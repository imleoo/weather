import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../utils/weather_icons.dart';
import '../widgets/current_weather.dart';
import '../widgets/fishing_daily_forecast.dart';
import '../l10n/app_localizations.dart';
import 'city_search_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // 初始化时获取当前位置的天气
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchWeatherData();
    });
  }

  Future<void> _fetchWeatherData() async {
    final weatherProvider = Provider.of<WeatherProvider>(
      context,
      listen: false,
    );
    await weatherProvider.fetchWeatherByCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<WeatherProvider>(
          builder: (context, weatherProvider, child) {
            return Text(
              weatherProvider.city ?? AppLocalizations.appTitle,
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
            onPressed: _fetchWeatherData,
          ),
        ],
      ),
      body: Consumer<WeatherProvider>(
        builder: (context, weatherProvider, child) {
          if (weatherProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (weatherProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${AppLocalizations.loadingFailed}: ${weatherProvider.error}',
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

          if (weatherProvider.weatherData == null) {
            return Center(child: Text(AppLocalizations.noWeatherData));
          }

          final weatherData = weatherProvider.weatherData!;
          final currentCondition = weatherData.currentCondition;
          final weatherCode = currentCondition.weatherCode;
          final backgroundColor = WeatherIcons.getWeatherColor(weatherCode);

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
                if (weatherProvider.city != null) {
                  await weatherProvider.fetchWeatherByCity(
                    weatherProvider.city!,
                  );
                } else {
                  await weatherProvider.fetchWeatherByCurrentLocation();
                }
              },
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  CurrentWeather(currentCondition: currentCondition),
                  const SizedBox(height: 20),
                  // 使用新的钓鱼天气预报组件
                  FishingDailyForecast(forecast: weatherData.forecast),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
