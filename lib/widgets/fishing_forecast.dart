import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../models/fishing_weather_model.dart';
import '../utils/date_formatter.dart';
import '../utils/weather_icons.dart';
import '../l10n/app_localizations.dart';

class FishingForecast extends StatefulWidget {
  final List<Hourly> hourlyData;
  final String date;
  final String dayName;

  const FishingForecast({
    Key? key,
    required this.hourlyData,
    required this.date,
    required this.dayName,
  }) : super(key: key);

  @override
  State<FishingForecast> createState() => _FishingForecastState();
}

class _FishingForecastState extends State<FishingForecast> {
  final ScrollController _scrollController = ScrollController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // 在初始化时找到离当前时间最近的小时
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectBestHour();
    });
  }

  void _selectBestHour() {
    if (widget.hourlyData.isEmpty) return;

    // 如果是当天，选择离当前时间最近的小时
    // 如果是未来几天，选择评分最高的小时
    final now = DateTime.now();
    final isToday = widget.date ==
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    if (isToday) {
      final currentHour = now.hour;
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
    } else {
      // 选择钓鱼适宜性评分最高的时间段
      int bestIndex = 0;
      int highestScore = -100;

      for (int i = 0; i < widget.hourlyData.length; i++) {
        final hourly = widget.hourlyData[i];
        final fishingSuitability = hourly.fishingSuitability;

        if (fishingSuitability.score > highestScore) {
          highestScore = fishingSuitability.score;
          bestIndex = i;
        }
      }

      setState(() {
        _selectedIndex = bestIndex;
      });
    }

    // 滚动到选中的项
    if (_scrollController.hasClients) {
      const itemWidth = 100.0; // 估计每个项的宽度
      _scrollController.animateTo(
        _selectedIndex * itemWidth,
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

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.waves, color: Colors.amber),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.fishingSuitability,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Text(
                  widget.date,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
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
                itemBuilder: (context, index) {
                  final hourly = nextHours[index];
                  final isSelected = _selectedIndex == index;
                  final fishingSuitability = hourly.fishingSuitability;
                  final suitabilityColor =
                      FishingWeatherModel.getSuitabilityColor(
                          fishingSuitability.suitability);

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
                            ? suitabilityColor.withOpacity(0.2)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? suitabilityColor
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
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
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

  Widget _buildSelectedHourDetails(Hourly hourly) {
    final fishingSuitability = hourly.fishingSuitability;
    final suitabilityColor =
        FishingWeatherModel.getSuitabilityColor(fishingSuitability.suitability);
    final scoreDetails = fishingSuitability.scoreDetails;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 钓鱼适宜性评分卡
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: suitabilityColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: suitabilityColor.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.water, color: suitabilityColor),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.fishingSuitability,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: suitabilityColor,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: suitabilityColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${fishingSuitability.score} ${AppLocalizations.isEnglish ? "pts" : "分"}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: suitabilityColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                fishingSuitability.advice,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                AppLocalizations.fishingScoreDetails,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildScoreChip(AppLocalizations.pressureScore,
                      scoreDetails['pressure'] ?? 0),
                  _buildScoreChip(AppLocalizations.weatherScore,
                      scoreDetails['weather'] ?? 0),
                  _buildScoreChip(AppLocalizations.rainChanceScore,
                      scoreDetails['rainChance'] ?? 0),
                  _buildScoreChip(AppLocalizations.cloudCoverScore,
                      scoreDetails['cloudCover'] ?? 0),
                  _buildScoreChip(AppLocalizations.windSpeedScore,
                      scoreDetails['windSpeed'] ?? 0),
                  _buildScoreChip(AppLocalizations.temperatureScore,
                      scoreDetails['temperature'] ?? 0),
                  _buildScoreChip(AppLocalizations.humidityScore,
                      scoreDetails['humidity'] ?? 0),
                  _buildScoreChip(AppLocalizations.visibilityScore,
                      scoreDetails['visibility'] ?? 0),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 天气详情卡片
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.weatherDetails,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 12),
              _buildDetailRow(
                  AppLocalizations.weatherCondition, hourly.weatherDesc),
              _buildDetailRow(AppLocalizations.temperature,
                  '${hourly.tempC}°C (${AppLocalizations.feelsLike} ${hourly.feelsLikeC}°C)'),
              _buildDetailRow(AppLocalizations.humidity, '${hourly.humidity}%'),
              _buildDetailRow(AppLocalizations.windSpeed,
                  '${hourly.windspeedKmph} ${AppLocalizations.kmh}'),
              _buildDetailRow(
                  AppLocalizations.chanceOfRain, '${hourly.chanceofrain}%'),
              _buildDetailRow(AppLocalizations.pressure,
                  '${hourly.pressure} ${AppLocalizations.hPa}'),
              _buildDetailRow(AppLocalizations.visibility,
                  '${hourly.visibility} ${AppLocalizations.km}'),
              _buildDetailRow(
                  AppLocalizations.cloudCover, '${hourly.cloudcover}%'),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 钓鱼建议卡片
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.tips_and_updates, color: Colors.blue),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.fishingAdvice,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildFishingTips(hourly),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildScoreChip(String label, int score) {
    Color color;
    if (score >= 2) {
      color = Colors.green;
    } else if (score >= 0) {
      color = Colors.blue;
    } else if (score >= -1) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              score > 0 ? '+$score' : '$score',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFishingTips(Hourly hourly) {
    final weatherDesc = hourly.weatherDesc.toLowerCase();
    final tempC = int.tryParse(hourly.tempC) ?? 0;
    final windSpeed = int.tryParse(hourly.windspeedKmph) ?? 0;
    final rainChance = int.tryParse(hourly.chanceofrain) ?? 0;

    List<String> tips = [];

    // 基于天气状况的建议
    if (weatherDesc.contains('rain') || weatherDesc.contains('雨')) {
      tips.add(AppLocalizations.tipRainActive);
      tips.add(AppLocalizations.tipRainDeepWater);
    } else if (weatherDesc.contains('cloud') || weatherDesc.contains('多云')) {
      tips.add(AppLocalizations.isEnglish
          ? 'Cloudy weather has soft light, ideal for fishing'
          : '多云天气光线柔和，是钓鱼的理想天气');
      tips.add(AppLocalizations.isEnglish
          ? 'Choose open waters, fish may be active at various depths'
          : '可选择开阔水域，鱼类可能在各水层活动');
    } else if (weatherDesc.contains('clear') || weatherDesc.contains('晴')) {
      tips.add(AppLocalizations.isEnglish
          ? 'Sunny weather may drive fish to shaded areas, choose spots with cover'
          : '晴天阳光强烈，鱼类可能躲在阴凉处，建议选择有遮蔽的区域');
      tips.add(AppLocalizations.isEnglish
          ? 'Morning and evening are the best times for fishing on sunny days'
          : '早晨和傍晚是晴天钓鱼的最佳时段');
    } else if (weatherDesc.contains('fog') || weatherDesc.contains('雾')) {
      tips.add(AppLocalizations.isEnglish
          ? 'Low visibility in fog, be cautious and avoid long-distance casting'
          : '雾天能见度低，注意安全，不建议远距离抛竿');
      tips.add(AppLocalizations.isEnglish
          ? 'Fog keeps water temperature stable, may be good for shore fishing'
          : '雾天水温变化小，可能适合近岸钓鱼');
    }

    // 基于温度的建议
    if (tempC > 30) {
      tips.add(AppLocalizations.isEnglish
          ? 'High temperatures reduce fish activity, try early morning or evening'
          : '高温天气鱼类活动减少，建议选择早晨或傍晚出钓');
      tips.add(AppLocalizations.isEnglish
          ? 'Choose shaded areas or deeper waters in hot weather'
          : '高温天气可选择阴凉处或深水区域');
    } else if (tempC < 15) {
      tips.add(AppLocalizations.isEnglish
          ? 'Cold weather slows fish metabolism, patience may be needed'
          : '低温天气鱼类新陈代谢减慢，可能需要更多耐心');
      tips.add(AppLocalizations.isEnglish
          ? 'Try shallow waters in cold weather as they warm faster'
          : '低温天气可选择浅水区域，因为水温相对较高');
    } else {
      tips.add(AppLocalizations.tipTemperatureGood);
    }

    // 基于风速的建议
    if (windSpeed > 15) {
      tips.add(AppLocalizations.isEnglish
          ? 'Strong winds may affect casting accuracy, choose sheltered spots'
          : '风速较大，可能影响抛竿精度，建议选择背风处');
      tips.add(AppLocalizations.isEnglish
          ? 'Choppy water makes float observation difficult'
          : '大风天气水面波动大，鱼漂观察难度增加');
    } else if (windSpeed < 5) {
      tips.add(AppLocalizations.isEnglish
          ? 'Calm water surface is good for observing float movements'
          : '风速较小，水面平静，适合观察鱼漂动作');
    } else {
      tips.add(AppLocalizations.isEnglish
          ? 'Light breeze helps oxygen exchange in water, may increase fish activity'
          : '微风有利于水中氧气交换，可能增加鱼类活跃度');
    }

    // 基于降水概率的建议
    if (rainChance > 60) {
      tips.add(AppLocalizations.isEnglish
          ? 'High chance of rain, bring waterproof gear'
          : '降水概率高，建议携带防雨装备');
      tips.add(AppLocalizations.isEnglish
          ? 'Fish often feed more actively before rain'
          : '雨前鱼类觅食欲望增强，可能是钓鱼的好时机');
    }

    // 如果没有生成任何建议，添加一个通用建议
    if (tips.isEmpty) {
      tips.add(AppLocalizations.isEnglish
          ? 'Adjust fishing spots and techniques based on current weather conditions'
          : '根据当前天气条件调整钓点和钓法，提高钓获率');
      tips.add(AppLocalizations.isEnglish
          ? 'Bring appropriate gear for the current weather conditions'
          : '注意携带适合当前天气的装备，确保钓鱼体验舒适');
    }

    // 最多显示3条建议
    tips = tips.take(3).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: tips
          .map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('• ',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Expanded(
                      child: Text(
                        tip,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}