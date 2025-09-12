import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../models/fishing_weather_model.dart';
import '../utils/date_formatter.dart';
import '../utils/weather_icons.dart';
import '../utils/animation_utils.dart';
import './fishing_weather_details.dart';
import '../l10n/app_localizations.dart';

class FishingForecast extends StatefulWidget {
  final List<Hourly> hourlyData;
  final String date;
  final String dayName;

  const FishingForecast({
    super.key,
    required this.hourlyData,
    required this.date,
    required this.dayName,
  });

  @override
  State<FishingForecast> createState() => _FishingForecastState();
}

class _FishingForecastState extends State<FishingForecast> {
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // 在初始化时找到离当前时间最近的小时，使用延迟执行避免阻塞主线程
    Future.microtask(() {
      _selectBestHour();
    });
  }

  // 优化选择最佳小时的方法，减少计算量
  void _selectBestHour() {
    if (widget.hourlyData.isEmpty) return;

    int bestIndex = 0;

    // 使用更高效的方式确定最佳时间
    final now = DateTime.now();
    final isToday = widget.date ==
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    if (isToday) {
      // 当天：找到离当前时间最近的小时
      final currentHour = now.hour;
      int nearestIndex = 0;
      int smallestDifference = 24;

      // 优化循环，减少计算
      for (int i = 0; i < widget.hourlyData.length; i++) {
        final hourly = widget.hourlyData[i];
        // 避免重复解析
        final hourlyTime = hourly.time;
        if (hourlyTime.isEmpty) continue;

        final hourlyHour = int.tryParse(hourlyTime) != null
            ? (int.parse(hourlyTime) ~/ 100)
            : 0;

        final difference = (hourlyHour - currentHour).abs();
        if (difference < smallestDifference) {
          smallestDifference = difference;
          nearestIndex = i;
        }
      }

      bestIndex = nearestIndex;
    } else {
      // 未来几天：选择评分最高的小时（最多检查前4个时段）
      int highestScore = -100;
      final checkLimit =
          widget.hourlyData.length > 4 ? 4 : widget.hourlyData.length;

      for (int i = 0; i < checkLimit; i++) {
        final hourly = widget.hourlyData[i];
        final fishingSuitability = hourly.fishingSuitability;

        if (fishingSuitability.score > highestScore) {
          highestScore = fishingSuitability.score;
          bestIndex = i;
        }
      }
    }

    // 使用单一setState减少重建
    setState(() {
      _selectedIndex = bestIndex;
    });

    // 延迟滚动操作，避免在布局完成前执行
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        const itemWidth = 100.0;
        _scrollController.animateTo(
          _selectedIndex * itemWidth,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
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
                      Icons.waves,
                      color: Colors.amber.shade700,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.fishingSuitability,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ],
                ),
                Flexible(
                  child: Text(
                    "${widget.dayName} ${widget.date}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            SizedBox(
              height: 170,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: nextHours.length,
                addAutomaticKeepAlives: true,
                addRepaintBoundaries: true,
                itemBuilder: (context, index) {
                  final hourly = nextHours[index];
                  final isSelected = _selectedIndex == index;

                  // 使用缓存的方式获取适宜性信息，避免重复计算
                  final fishingSuitability = hourly.fishingSuitability;
                  final suitabilityColor =
                      FishingWeatherModel.getSuitabilityColor(
                          fishingSuitability.suitability);

                  return _buildHourItem(
                    hourly: hourly,
                    isSelected: isSelected,
                    fishingSuitability: fishingSuitability,
                    suitabilityColor: suitabilityColor,
                    index: index,
                  );
                },
              ),
            ),
            if (_selectedIndex < nextHours.length) ...[
              const SizedBox(height: 16),
              FishingWeatherDetails(
                hourlyData: nextHours[_selectedIndex],
                fishingData: nextHours[_selectedIndex].fishingSuitability,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // 提取小时项构建逻辑到单独的方法，优化性能
  Widget _buildHourItem({
    required Hourly hourly,
    required bool isSelected,
    required FishingWeatherModel fishingSuitability,
    required Color suitabilityColor,
    required int index,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 6.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: isSelected
              ? suitabilityColor.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? suitabilityColor : Colors.grey.shade300,
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
                color: isSelected ? Colors.black87 : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            _buildWeatherIcon(hourly.weatherCode, isSelected),
            const SizedBox(height: 8),
            Text(
              '${hourly.tempC}°C',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isSelected ? 16 : 14,
                color: isSelected ? Colors.black : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: suitabilityColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                FishingWeatherModel.getSuitabilityText(
                    fishingSuitability.suitability),
                style: TextStyle(
                  color: suitabilityColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
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
}
