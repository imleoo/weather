import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../utils/weather_icons.dart';
import '../utils/date_formatter.dart';
import '../l10n/app_localizations.dart';
import '../utils/animation_utils.dart';
import '../providers/settings_provider.dart';
import 'package:provider/provider.dart';

class HourlyForecast extends StatefulWidget {
  final List<Hourly> hourlyData;
  final String? observationTime;

  const HourlyForecast({super.key, required this.hourlyData, this.observationTime});

  @override
  State<HourlyForecast> createState() => _HourlyForecastState();
}

class _HourlyForecastState extends State<HourlyForecast> {
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    // 在初始化时找到离当前时间最近的小时
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectNearestHour();
    });
  }

  
  void _selectNearestHour() {
    if (widget.hourlyData.isEmpty) return;

    // 优先使用API观察时间，如果没有则使用系统时间
    int currentHour;
    if (widget.observationTime != null && widget.observationTime!.isNotEmpty) {
      // 解析API观察时间，格式如 "2025-09-14 10:06 PM"
      try {
        final obsDateTime = _parseObservationDateTime(widget.observationTime!);
        currentHour = obsDateTime.hour;
        print('⏰ HourlyForecast: 使用API观察时间选择小时: $currentHour (来自 ${widget.observationTime})');
      } catch (e) {
        print('⏰ HourlyForecast: 解析观察时间失败，使用系统时间: $e');
        currentHour = DateTime.now().hour;
      }
    } else {
      currentHour = DateTime.now().hour;
      print('⏰ HourlyForecast: 使用系统时间选择小时: $currentHour');
    }
    int nearestIndex = 0;
    int smallestDifference = 24; // 最大可能差值

    for (int i = 0; i < widget.hourlyData.length; i++) {
      final hourly = widget.hourlyData[i];
      final hourlyHour = int.tryParse(hourly.time) != null
          ? (int.parse(hourly.time) ~/ 100)
          : 0;

      final difference = (hourlyHour - currentHour).abs();
      if (difference < smallestDifference) {
        smallestDifference = difference;
        nearestIndex = i;
      }
    }

    setState(() {
      _selectedIndex = nearestIndex;
    });

    // 滚动到选中的项
    if (_scrollController.hasClients) {
      const itemWidth = 100.0; // 估计每个项的宽度
      _scrollController.animateTo(
        nearestIndex * itemWidth,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 直接使用所有小时预报数据
    final List<Hourly> nextHours = widget.hourlyData;
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final bool isPremium = settingsProvider.isPremium;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: AnimationUtils.cardDecoration(),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.blue.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.hourlyForecast,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                  if (isPremium)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade700),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified_user,
                          color: Colors.green.shade700,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          AppLocalizations.premiumMember,
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const Divider(height: 24),
            Container(
              height: 170,
              constraints: const BoxConstraints(maxHeight: 170),
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: nextHours.length,
                addAutomaticKeepAlives: true,
                addRepaintBoundaries: true,
                itemBuilder: (context, index) {
                  final hourly = nextHours[index];
                  final isSelected = _selectedIndex == index;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIndex = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 6.0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 8.0),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? WeatherIcons.getWeatherColor(hourly.weatherCode)
                                .withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? WeatherIcons.getWeatherColor(hourly.weatherCode)
                              : Colors.grey.shade300,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            DateFormatter.formatTime(hourly.time),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.black87
                                  : Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildWeatherIcon(hourly.weatherCode, isSelected),
                          const SizedBox(height: 12),
                          Text(
                            '${hourly.tempC}°C',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: isSelected ? 18 : 16,
                              color: isSelected ? Colors.black : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _buildRainChance(hourly.chanceofrain, isSelected),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_selectedIndex < nextHours.length) ...[
              const SizedBox(height: 16),
              _buildSelectedHourDetails(nextHours[_selectedIndex]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherIcon(String weatherCode, bool isSelected) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(isSelected ? 8.0 : 4.0),
      decoration: isSelected
          ? BoxDecoration(
              color: WeatherIcons.getWeatherColor(weatherCode).withOpacity(0.1),
              shape: BoxShape.circle,
            )
          : null,
      child: Icon(
        WeatherIcons.getWeatherIcon(weatherCode),
        color: WeatherIcons.getWeatherColor(weatherCode),
        size: isSelected ? 36 : 28,
      ),
    );
  }

  Widget _buildRainChance(String chanceOfRain, bool isSelected) {
    final chance = int.tryParse(chanceOfRain) ?? 0;
    final color = chance > 50
        ? Colors.blue.shade700
        : (chance > 20 ? Colors.blue.shade400 : Colors.blue.shade200);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.water_drop,
          color: color,
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(
          '$chanceOfRain%',
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedHourDetails(Hourly hourly) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            WeatherIcons.getWeatherColor(hourly.weatherCode).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWeatherDescriptionWithTooltip(hourly.weatherDesc, hourly.weatherCode),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildDetailChip(
                  Icons.thermostat,
                  '${AppLocalizations.feelsLike}: ${hourly.feelsLikeC}°C',
                  Colors.orange.shade700,
                ),
                const SizedBox(width: 8),
                _buildDetailChip(
                  Icons.water_drop,
                  '${AppLocalizations.humidity}: ${hourly.humidity}%',
                  Colors.blue.shade600,
                ),
                const SizedBox(width: 8),
                _buildDetailChip(
                  Icons.air,
                  '${hourly.windspeedKmph} ${AppLocalizations.kmh}',
                  Colors.blueGrey.shade600,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // 构建带工具提示的天气描述，处理长文本显示
  Widget _buildWeatherDescriptionWithTooltip(String weatherDesc, String weatherCode) {
    final weatherColor = WeatherIcons.getWeatherColor(weatherCode);
    
    // 如果文本很短，直接显示
    if (weatherDesc.length <= 20) {
      return Text(
        weatherDesc,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: weatherColor,
        ),
      );
    }

    // 如果文本很长，显示截断版本并提供工具提示
    return Tooltip(
      message: weatherDesc,
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
      ),
      preferBelow: true,
      verticalOffset: 20,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        weatherDesc,
        style: TextStyle(
          fontSize: 14, // 长文本时稍微减小字体
          fontWeight: FontWeight.bold,
          color: weatherColor,
        ),
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    );
  }

  // 解析API观察时间，格式如 "2025-09-14 10:06 PM"
  DateTime _parseObservationDateTime(String observationTime) {
    try {
      // 移除可能的时区信息并解析
      final cleanTime = observationTime.split(' ')[0]; // 获取日期部分
      final timePart = observationTime.substring(cleanTime.length + 1); // 获取时间部分
      
      // 解析日期
      final dateParts = cleanTime.split('-');
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);
      
      // 解析时间 (格式: "10:06 PM")
      final timeParts = timePart.split(' ');
      final hourMinute = timeParts[0].split(':');
      var hour = int.parse(hourMinute[0]);
      final minute = int.parse(hourMinute[1]);
      
      // 处理AM/PM
      if (timeParts.length > 1 && timeParts[1] == 'PM' && hour != 12) {
        hour += 12;
      } else if (timeParts.length > 1 && timeParts[1] == 'AM' && hour == 12) {
        hour = 0;
      }
      
      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      print('⏰ HourlyForecast: 解析观察时间失败: $e, 原始值: $observationTime');
      rethrow;
    }
  }
}
