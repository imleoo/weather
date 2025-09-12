import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../l10n/app_localizations.dart';
import 'fishing_forecast.dart';

class FishingDailyForecast extends StatefulWidget {
  final List<Weather> forecast;

  const FishingDailyForecast({super.key, required this.forecast});

  @override
  State<FishingDailyForecast> createState() => _FishingDailyForecastState();
}

class _FishingDailyForecastState extends State<FishingDailyForecast>
    with AutomaticKeepAliveClientMixin {
  int _selectedDayIndex = 0;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); // 必须调用super.build()
    
    if (widget.forecast.isEmpty) {
      return Center(
        child: Text(AppLocalizations.noWeatherData),
      );
    }

    return Column(
      children: [
        // 日期选择器
        Container(
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
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      color: Colors.blue,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      AppLocalizations.fishingForecast,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      widget.forecast.length,
                      (index) => _buildDaySelector(index),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // 选中日期的钓鱼天气预报
        if (_selectedDayIndex < widget.forecast.length) ...[
          const SizedBox(height: 8),
          _buildSelectedDayForecast(),
        ],
      ],
    );
  }

  Widget _buildDaySelector(int index) {
    final day = widget.forecast[index];
    final date = DateTime.parse(day.date);
    final dayName = _getDayName(date);
    final isSelected = _selectedDayIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDayIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          dayName,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDayForecast() {
    final selectedDay = widget.forecast[_selectedDayIndex];
    final date = selectedDay.date;
    final dayName = _getDayName(DateTime.parse(date));

    return FishingForecast(
      hourlyData: selectedDay.hourly,
      date: date,
      dayName: dayName,
    );
  }

  String _getDayName(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dayAfterTomorrow = today.add(const Duration(days: 2));

    if (date.year == today.year &&
        date.month == today.month &&
        date.day == today.day) {
      return AppLocalizations.today;
    } else if (date.year == tomorrow.year &&
        date.month == tomorrow.month &&
        date.day == tomorrow.day) {
      return AppLocalizations.isEnglish ? 'Tomorrow' : '明天';
    } else if (date.year == dayAfterTomorrow.year &&
        date.month == dayAfterTomorrow.month &&
        date.day == dayAfterTomorrow.day) {
      return AppLocalizations.isEnglish ? 'Day after tomorrow' : '后天';
    } else {
      // 返回星期几
      final weekdays = AppLocalizations.isEnglish
          ? [
              'Sunday',
              'Monday',
              'Tuesday',
              'Wednesday',
              'Thursday',
              'Friday',
              'Saturday'
            ]
          : ['周日', '周一', '周二', '周三', '周四', '周五', '周六'];
      return weekdays[date.weekday % 7];
    }
  }
}
