import 'package:flutter/material.dart';

class WeatherIcons {
  static IconData getWeatherIcon(String weatherCode) {
    // 根据天气代码返回对应的图标
    switch (weatherCode) {
      case '113': // 晴朗
        return Icons.wb_sunny;
      case '116': // 局部多云
        return Icons.cloud_circle;
      case '119': // 多云
        return Icons.cloud;
      case '122': // 阴天
        return Icons.cloud_queue;
      case '143': // 薄雾
      case '248': // 雾
        return Icons.foggy;
      case '176': // 周边有零星小雨
      case '263': // 小雨
      case '266': // 小雨
      case '293': // 小雨
      case '296': // 小雨
        return Icons.grain;
      case '299': // 中雨
      case '302': // 中雨
      case '305': // 大雨
      case '308': // 大雨
        return Icons.water_drop;
      case '200': // 雷雨
      case '386': // 雷阵雨
      case '389': // 雷阵雨
        return Icons.thunderstorm;
      case '353': // 小阵雨
      case '356': // 中到大阵雨
        return Icons.shower;
      default:
        return Icons.cloud; // 默认图标
    }
  }

  static Color getWeatherColor(String weatherCode) {
    // 根据天气代码返回对应的颜色
    switch (weatherCode) {
      case '113': // 晴朗
        return Colors.orange;
      case '116': // 局部多云
      case '119': // 多云
        return Colors.lightBlue;
      case '122': // 阴天
        return Colors.blueGrey;
      case '143': // 薄雾
      case '248': // 雾
        return Colors.grey;
      case '176': // 周边有零星小雨
      case '263': // 小雨
      case '266': // 小雨
      case '293': // 小雨
      case '296': // 小雨
      case '299': // 中雨
      case '302': // 中雨
      case '305': // 大雨
      case '308': // 大雨
      case '353': // 小阵雨
      case '356': // 中到大阵雨
        return Colors.blueAccent;
      case '200': // 雷雨
      case '386': // 雷阵雨
      case '389': // 雷阵雨
        return Colors.deepPurple;
      default:
        return Colors.blue; // 默认颜色
    }
  }
}
