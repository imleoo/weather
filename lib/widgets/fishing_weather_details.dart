import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../models/fishing_weather_model.dart';
import '../utils/date_formatter.dart';
import '../l10n/app_localizations.dart';

class FishingWeatherDetails extends StatelessWidget {
  final Hourly hourlyData;
  final FishingWeatherModel fishingData;

  const FishingWeatherDetails({
    super.key,
    required this.hourlyData,
    required this.fishingData,
  });

  @override
  Widget build(BuildContext context) {
    // 预计算颜色和样式，减少重复计算
    final suitabilityColor =
        FishingWeatherModel.getSuitabilityColor(fishingData.suitability);
    final tips = _getFishingTips();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSuitabilityCard(suitabilityColor),
        const SizedBox(height: 16),
        _buildScoreDetailsCard(),
        const SizedBox(height: 16),
        _buildWeatherDetailsCard(),
        const SizedBox(height: 16),
        _buildFishingTipsCard(tips),
      ],
    );
  }

  Widget _buildSuitabilityCard(Color suitabilityColor) {
    return Container(
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
                  '${fishingData.score} ${AppLocalizations.isEnglish ? "pts" : "分"}',
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
            fishingData.advice,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDetailsCard() {
    return Container(
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
            AppLocalizations.fishingScoreDetails,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildScoreChip(AppLocalizations.pressureScore,
                  fishingData.scoreDetails['pressure'] ?? 0),
              _buildScoreChip(AppLocalizations.weatherScore,
                  fishingData.scoreDetails['weather'] ?? 0),
              _buildScoreChip(AppLocalizations.rainChanceScore,
                  fishingData.scoreDetails['rainChance'] ?? 0),
              _buildScoreChip(AppLocalizations.cloudCoverScore,
                  fishingData.scoreDetails['cloudCover'] ?? 0),
              _buildScoreChip(AppLocalizations.windSpeedScore,
                  fishingData.scoreDetails['windSpeed'] ?? 0),
              _buildScoreChip(AppLocalizations.temperatureScore,
                  fishingData.scoreDetails['temperature'] ?? 0),
              _buildScoreChip(AppLocalizations.humidityScore,
                  fishingData.scoreDetails['humidity'] ?? 0),
              _buildScoreChip(AppLocalizations.visibilityScore,
                  fishingData.scoreDetails['visibility'] ?? 0),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherDetailsCard() {
    return Container(
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
              Icon(Icons.cloud_outlined, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.weatherDetails,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailRow(
              AppLocalizations.weatherCondition, hourlyData.weatherDesc),
          _buildDetailRow(AppLocalizations.temperature,
              '${hourlyData.tempC}°C (${AppLocalizations.feelsLike} ${hourlyData.feelsLikeC}°C)'),
          _buildDetailRow(AppLocalizations.humidity, '${hourlyData.humidity}%'),
          _buildDetailRow(AppLocalizations.windSpeed,
              '${hourlyData.windspeedKmph} ${AppLocalizations.kmh}'),
          _buildDetailRow(
              AppLocalizations.chanceOfRain, '${hourlyData.chanceofrain}%'),
          _buildDetailRow(AppLocalizations.pressure,
              '${hourlyData.pressure} ${AppLocalizations.hPa}'),
          _buildDetailRow(AppLocalizations.visibility,
              '${hourlyData.visibility} ${AppLocalizations.km}'),
          _buildDetailRow(
              AppLocalizations.cloudCover, '${hourlyData.cloudcover}%'),
          // 如果需要显示露点温度，请确保Hourly类中有dewPointC属性
        ],
      ),
    );
  }

  Widget _buildFishingTipsCard(List<String> tips) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tips_and_updates, color: Colors.amber.shade800),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.fishingAdvice,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.amber.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildFishingTips(tips),
        ],
      ),
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

  Widget _buildFishingTips(List<String> tips) {
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

  // 提取钓鱼建议逻辑到单独的方法，优化性能
  List<String> _getFishingTips() {
    final weatherDesc = hourlyData.weatherDesc.toLowerCase();
    final tempC = int.tryParse(hourlyData.tempC) ?? 0;
    final windSpeed = int.tryParse(hourlyData.windspeedKmph) ?? 0;
    final pressure = int.tryParse(hourlyData.pressure) ?? 0;

    List<String> tips = [];

    // 根据天气状况选择最重要的2条建议
    if (weatherDesc.contains('rain') || weatherDesc.contains('雨')) {
      tips.add(AppLocalizations.tipRainActive);
    } else if (weatherDesc.contains('fog') || weatherDesc.contains('雾')) {
      tips.add(AppLocalizations.isEnglish
          ? 'Low visibility in fog, be cautious and avoid long-distance casting'
          : '雾天能见度低，注意安全，不建议远距离抛竿');
    } else if (weatherDesc.contains('cloud') || weatherDesc.contains('多云')) {
      tips.add(AppLocalizations.isEnglish
          ? 'Cloudy weather has soft light, ideal for fishing'
          : '多云天气光线柔和，是钓鱼的理想天气');
    } else if (weatherDesc.contains('clear') || weatherDesc.contains('晴')) {
      tips.add(AppLocalizations.isEnglish
          ? 'Sunny weather may drive fish to shaded areas, choose spots with cover'
          : '晴天阳光强烈，鱼类可能躲在阴凉处，建议选择有遮蔽的区域');
    }

    // 添加基于温度的建议
    if (tempC > 30) {
      tips.add(AppLocalizations.isEnglish
          ? 'High temperatures reduce fish activity, try early morning or evening'
          : '高温天气鱼类活动减少，建议选择早晨或傍晚出钓');
    } else if (tempC < 15) {
      tips.add(AppLocalizations.isEnglish
          ? 'Cold weather slows fish metabolism, patience may be needed'
          : '低温天气鱼类新陈代谢减慢，可能需要更多耐心');
    } else {
      tips.add(AppLocalizations.tipTemperatureGood);
    }

    // 添加基于气压或风速的建议（选择更重要的一个）
    if (pressure < 1000) {
      tips.add(AppLocalizations.isEnglish
          ? 'Low pressure may reduce fish activity, focus on deeper waters'
          : '低气压可能降低鱼类活性，建议选择深水区域');
    } else if (windSpeed > 15) {
      tips.add(AppLocalizations.isEnglish
          ? 'Strong winds may affect casting accuracy, choose sheltered spots'
          : '风速较大，可能影响抛竿精度，建议选择背风处');
    }

    // 确保至少有3条建议
    if (tips.length < 3) {
      tips.add(AppLocalizations.isEnglish
          ? 'Adjust fishing depth and bait based on current conditions'
          : '根据当前天气条件调整钓深和饵料选择');
    }

    // 最多显示3条建议，减少渲染负担
    return tips.take(3).toList();
  }
}
