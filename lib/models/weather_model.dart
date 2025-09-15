import '../l10n/app_localizations.dart';
import '../models/fishing_weather_model.dart';

// 扩展Hourly类，添加钓鱼适宜性评估方法
extension FishingHourlyExtension on Hourly {
  // 评估当前小时的钓鱼适宜性
  FishingWeatherModel get fishingSuitability =>
      FishingWeatherModel.evaluate(this);
}

class WeatherModel {
  final CurrentCondition currentCondition;
  final List<Weather> forecast;
  final NearestArea nearestArea;

  WeatherModel({
    required this.currentCondition,
    required this.forecast,
    required this.nearestArea,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel.fromJsonWithLanguage(json, AppLocalizations.isEnglish);
  }

  factory WeatherModel.fromJsonWithLanguage(Map<String, dynamic> json, bool isEnglish) {
    try {
      // 检查并处理current_condition - 更安全的类型转换
      List<dynamic> currentConditionList = [];
      if (json['current_condition'] is List) {
        currentConditionList = json['current_condition'] as List;
      }
      if (currentConditionList.isEmpty) {
        currentConditionList = [{}]; // 提供一个空对象作为默认值
      }

      // 检查并处理weather - 更安全的类型转换
      List<dynamic> weatherList = [];
      if (json['weather'] is List) {
        weatherList = json['weather'] as List;
      }
      if (weatherList.isEmpty) {
        weatherList = [{}]; // 提供一个空对象作为默认值
      }

      // 检查并处理nearest_area - 更安全的类型转换
      List<dynamic> nearestAreaList = [];
      if (json['nearest_area'] is List) {
        nearestAreaList = json['nearest_area'] as List;
      }
      if (nearestAreaList.isEmpty) {
        nearestAreaList = [{}]; // 提供一个空对象作为默认值
      }

      return WeatherModel(
        currentCondition: CurrentCondition.fromJsonWithLanguage(currentConditionList[0], isEnglish),
        forecast:
            weatherList.map((weather) => Weather.fromJsonWithLanguage(weather, isEnglish)).toList(),
        nearestArea: NearestArea.fromJson(nearestAreaList[0]),
      );
    } catch (e) {
      print('解析天气模型出错: $e');
      // 返回一个带有默认值的模型
      return WeatherModel(
        currentCondition: CurrentCondition.fromJsonWithLanguage({}, isEnglish),
        forecast: [Weather.fromJsonWithLanguage({}, isEnglish)],
        nearestArea: NearestArea.fromJson({}),
      );
    }
  }
}

class CurrentCondition {
  final String tempC;
  final String feelsLikeC;
  final String humidity;
  final String weatherDesc;
  final String weatherCode;
  final String windspeedKmph;
  final String precipMM;
  final String pressure;
  final String visibility;
  final String uvIndex;
  final String observationTime;
  final String localObsDateTime;

  CurrentCondition({
    required this.tempC,
    required this.feelsLikeC,
    required this.humidity,
    required this.weatherDesc,
    required this.weatherCode,
    required this.windspeedKmph,
    required this.precipMM,
    required this.pressure,
    required this.visibility,
    required this.uvIndex,
    required this.observationTime,
    required this.localObsDateTime,
  });

  factory CurrentCondition.fromJson(Map<String, dynamic> json) {
    return CurrentCondition.fromJsonWithLanguage(json, AppLocalizations.isEnglish);
  }

  factory CurrentCondition.fromJsonWithLanguage(Map<String, dynamic> json, bool isEnglish) {
    String getWeatherDesc() {
      try {
        // 根据当前语言选择合适的天气描述
        print('🌤️ CurrentCondition: 当前语言=${isEnglish ? '英文' : '中文'}, 解析天气描述...');
        
        if (!isEnglish) {
          // 尝试获取中文天气描述
          if (json['lang_zh'] != null) {
            print('🌤️ CurrentCondition: 找到lang_zh字段: ${json['lang_zh']}');
            if (json['lang_zh'] is List && json['lang_zh'].isNotEmpty) {
              final chineseDesc = json['lang_zh'][0]['value'] ?? '未知天气';
              print('🌤️ CurrentCondition: 使用中文天气描述: $chineseDesc');
              return chineseDesc;
            }
          } else if (json['languages'] != null &&
              json['languages'] is List &&
              json['languages'].isNotEmpty) {
            // 尝试在languages数组中查找中文描述
            for (var lang in json['languages']) {
              if (lang['lang_name'] == 'Chinese Simplified' ||
                  lang['lang_name'] == 'Chinese' ||
                  lang['lang_iso'] == 'zh') {
                return lang['day_text'] ?? lang['night_text'] ?? '未知天气';
              }
            }
          }
          // 如果没有找到中文描述，使用默认的中文描述
          return '未知天气';
        } else {
          // 英文描述
          if (json['weatherDesc'] != null &&
              json['weatherDesc'] is List &&
              json['weatherDesc'].isNotEmpty) {
            return json['weatherDesc'][0]['value'] ?? 'Unknown';
          }
          return 'Unknown';
        }
      } catch (e) {
        print('解析天气描述出错: $e');
        return AppLocalizations.isEnglish ? 'Unknown' : '未知天气';
      }
    }

    return CurrentCondition(
      tempC: json['temp_C']?.toString() ?? '0',
      feelsLikeC: json['FeelsLikeC']?.toString() ?? '0',
      humidity: json['humidity']?.toString() ?? '0',
      weatherDesc: getWeatherDesc(),
      weatherCode: json['weatherCode']?.toString() ?? '113',
      windspeedKmph: json['windspeedKmph']?.toString() ?? '0',
      precipMM: json['precipMM']?.toString() ?? '0',
      pressure: json['pressure']?.toString() ?? '0',
      visibility: json['visibility']?.toString() ?? '0',
      uvIndex: json['uvIndex']?.toString() ?? '0',
      observationTime: json['observation_time']?.toString() ?? '00:00 AM',
      localObsDateTime: json['localObsDateTime']?.toString() ?? '',
    );
  }
}

class Weather {
  final String date;
  final String maxtempC;
  final String mintempC;
  final String sunHour;
  final String uvIndex;
  final List<Hourly> hourly;
  final Astronomy astronomy;

  Weather({
    required this.date,
    required this.maxtempC,
    required this.mintempC,
    required this.sunHour,
    required this.uvIndex,
    required this.hourly,
    required this.astronomy,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather.fromJsonWithLanguage(json, AppLocalizations.isEnglish);
  }

  factory Weather.fromJsonWithLanguage(Map<String, dynamic> json, bool isEnglish) {
    try {
      // 检查并处理hourly - 更安全的类型转换
      List<dynamic> hourlyList = [];
      if (json['hourly'] is List) {
        hourlyList = json['hourly'] as List;
      }
      if (hourlyList.isEmpty) {
        hourlyList = [{}]; // 提供一个空对象作为默认值
      }

      // 检查并处理astronomy - 更安全的类型转换
      List<dynamic> astronomyList = [];
      if (json['astronomy'] is List) {
        astronomyList = json['astronomy'] as List;
      }
      if (astronomyList.isEmpty) {
        astronomyList = [{}]; // 提供一个空对象作为默认值
      }

      return Weather(
        date: json['date']?.toString() ?? '未知日期',
        maxtempC: json['maxtempC']?.toString() ?? '0',
        mintempC: json['mintempC']?.toString() ?? '0',
        sunHour: json['sunHour']?.toString() ?? '0',
        uvIndex: json['uvIndex']?.toString() ?? '0',
        hourly: hourlyList.map((hourly) => Hourly.fromJsonWithLanguage(hourly, isEnglish)).toList(),
        astronomy: Astronomy.fromJson(astronomyList[0]),
      );
    } catch (e) {
      print('解析天气预报出错: $e');
      // 返回一个带有默认值的天气预报
      return Weather(
        date: '未知日期',
        maxtempC: '0',
        mintempC: '0',
        sunHour: '0',
        uvIndex: '0',
        hourly: [Hourly.fromJsonWithLanguage({}, isEnglish)],
        astronomy: Astronomy.fromJson({}),
      );
    }
  }
}

class Hourly {
  final String time;
  final String tempC;
  final String weatherDesc;
  final String weatherCode;
  final String chanceofrain;
  final String humidity;
  final String windspeedKmph;
  final String feelsLikeC;
  final String pressure;
  final String cloudcover;
  final String visibility;
  final String dewPointC;

  Hourly({
    required this.time,
    required this.tempC,
    required this.weatherDesc,
    required this.weatherCode,
    required this.chanceofrain,
    required this.humidity,
    required this.windspeedKmph,
    required this.feelsLikeC,
    required this.pressure,
    required this.cloudcover,
    required this.visibility,
    required this.dewPointC,
  });

  factory Hourly.fromJson(Map<String, dynamic> json) {
    return Hourly.fromJsonWithLanguage(json, AppLocalizations.isEnglish);
  }

  factory Hourly.fromJsonWithLanguage(Map<String, dynamic> json, bool isEnglish) {
    String getWeatherDesc() {
      try {
        // 根据当前语言选择合适的天气描述
        print('🌤️ Hourly: 当前语言=${isEnglish ? '英文' : '中文'}, 解析天气描述...');
        
        if (!isEnglish) {
          // 尝试获取中文天气描述
          if (json['lang_zh'] != null) {
            print('🌤️ Hourly: 找到lang_zh字段: ${json['lang_zh']}');
            if (json['lang_zh'] is List && json['lang_zh'].isNotEmpty) {
              final chineseDesc = json['lang_zh'][0]['value'] ?? '未知天气';
              print('🌤️ Hourly: 使用中文天气描述: $chineseDesc');
              return chineseDesc;
            }
          } else if (json['languages'] != null &&
              json['languages'] is List &&
              json['languages'].isNotEmpty) {
            // 尝试在languages数组中查找中文描述
            for (var lang in json['languages']) {
              if (lang['lang_name'] == 'Chinese Simplified' ||
                  lang['lang_name'] == 'Chinese' ||
                  lang['lang_iso'] == 'zh') {
                return lang['day_text'] ?? lang['night_text'] ?? '未知天气';
              }
            }
          }
          // 如果没有找到中文描述，使用默认的中文描述
          return '未知天气';
        } else {
          // 英文描述
          if (json['weatherDesc'] != null &&
              json['weatherDesc'] is List &&
              json['weatherDesc'].isNotEmpty) {
            return json['weatherDesc'][0]['value'] ?? 'Unknown';
          }
          return 'Unknown';
        }
      } catch (e) {
        print('解析小时天气描述出错: $e');
        return isEnglish ? 'Unknown' : '未知天气';
      }
    }

    return Hourly(
      time: json['time']?.toString() ?? '0',
      tempC: json['tempC']?.toString() ?? '0',
      weatherDesc: getWeatherDesc(),
      weatherCode: json['weatherCode']?.toString() ?? '113',
      chanceofrain: json['chanceofrain']?.toString() ?? '0',
      humidity: json['humidity']?.toString() ?? '0',
      windspeedKmph: json['windspeedKmph']?.toString() ?? '0',
      feelsLikeC: json['FeelsLikeC']?.toString() ?? '0',
      pressure: json['pressure']?.toString() ?? '1010',
      cloudcover: json['cloudcover']?.toString() ?? '50',
      visibility: json['visibility']?.toString() ?? '10',
      dewPointC: json['DewPointC']?.toString() ?? '0',
    );
  }
}

class Astronomy {
  final String sunrise;
  final String sunset;
  final String moonrise;
  final String moonset;
  final String moonPhase;

  Astronomy({
    required this.sunrise,
    required this.sunset,
    required this.moonrise,
    required this.moonset,
    required this.moonPhase,
  });

  factory Astronomy.fromJson(Map<String, dynamic> json) {
    try {
      return Astronomy(
        sunrise: json['sunrise']?.toString() ?? '06:00 AM',
        sunset: json['sunset']?.toString() ?? '06:00 PM',
        moonrise: json['moonrise']?.toString() ?? '未知',
        moonset: json['moonset']?.toString() ?? '未知',
        moonPhase: json['moon_phase']?.toString() ?? '未知',
      );
    } catch (e) {
      print('解析天文数据出错: $e');
      return Astronomy(
        sunrise: '06:00 AM',
        sunset: '06:00 PM',
        moonrise: '未知',
        moonset: '未知',
        moonPhase: '未知',
      );
    }
  }
}

class NearestArea {
  final String areaName;
  final String country;
  final String region;
  final String latitude;
  final String longitude;

  NearestArea({
    required this.areaName,
    required this.country,
    required this.region,
    required this.latitude,
    required this.longitude,
  });

  factory NearestArea.fromJson(Map<String, dynamic> json) {
    try {
      // 检查并处理areaName
      String getAreaName() {
        try {
          if (json['areaName'] != null &&
              json['areaName'] is List &&
              json['areaName'].isNotEmpty &&
              json['areaName'][0]['value'] != null) {
            // 这里可以添加中文城市名称的映射
            String englishName = json['areaName'][0]['value'];
            if (!AppLocalizations.isEnglish) {
              // 常见城市的英文到中文映射
              Map<String, String> cityNameMap = {
                'Beijing': '北京',
                'Shanghai': '上海',
                'Guangzhou': '广州',
                'Shenzhen': '深圳',
                'Hong Kong': '香港',
                'Taipei': '台北',
                'Tokyo': '东京',
                'Seoul': '首尔',
                'Singapore': '新加坡',
                'Bangkok': '曼谷',
                'New York': '纽约',
                'Los Angeles': '洛杉矶',
                'Chicago': '芝加哥',
                'Toronto': '多伦多',
                'London': '伦敦',
                'Paris': '巴黎',
                'Berlin': '柏林',
                'Rome': '罗马',
                'Madrid': '马德里',
                'Sydney': '悉尼',
                'Melbourne': '墨尔本',
                // 可以根据需要添加更多城市
              };
              return cityNameMap[englishName] ?? englishName;
            }
            return englishName;
          }
          return AppLocalizations.isEnglish ? 'Unknown Area' : '未知地区';
        } catch (e) {
          print('解析地区名称出错: $e');
          return AppLocalizations.isEnglish ? 'Unknown Area' : '未知地区';
        }
      }

      // 检查并处理country
      String getCountry() {
        try {
          if (json['country'] != null &&
              json['country'] is List &&
              json['country'].isNotEmpty &&
              json['country'][0]['value'] != null) {
            // 国家名称的英文到中文映射
            String englishName = json['country'][0]['value'];
            if (!AppLocalizations.isEnglish) {
              Map<String, String> countryNameMap = {
                'China': '中国',
                'Japan': '日本',
                'South Korea': '韩国',
                'Singapore': '新加坡',
                'Thailand': '泰国',
                'United States': '美国',
                'Canada': '加拿大',
                'United Kingdom': '英国',
                'France': '法国',
                'Germany': '德国',
                'Italy': '意大利',
                'Spain': '西班牙',
                'Australia': '澳大利亚',
                'New Zealand': '新西兰',
                // 可以根据需要添加更多国家
              };
              return countryNameMap[englishName] ?? englishName;
            }
            return englishName;
          }
          return AppLocalizations.isEnglish ? 'Unknown Country' : '未知国家';
        } catch (e) {
          print('解析国家名称出错: $e');
          return AppLocalizations.isEnglish ? 'Unknown Country' : '未知国家';
        }
      }

      // 检查并处理region
      String getRegion() {
        try {
          if (json['region'] != null &&
              json['region'] is List &&
              json['region'].isNotEmpty &&
              json['region'][0]['value'] != null) {
            // 地区名称的英文到中文映射
            String englishName = json['region'][0]['value'];
            if (!AppLocalizations.isEnglish) {
              Map<String, String> regionNameMap = {
                'Beijing': '北京',
                'Shanghai': '上海',
                'Guangdong': '广东',
                'Hong Kong': '香港',
                'Taiwan': '台湾',
                'Tokyo': '东京',
                'Seoul': '首尔',
                'New York': '纽约',
                'California': '加利福尼亚',
                'Illinois': '伊利诺伊',
                'Ontario': '安大略',
                'England': '英格兰',
                'Ile-de-France': '法兰西岛',
                'Berlin': '柏林',
                'Lazio': '拉齐奥',
                'Madrid': '马德里',
                'New South Wales': '新南威尔士',
                'Victoria': '维多利亚',
                // 可以根据需要添加更多地区
              };
              return regionNameMap[englishName] ?? englishName;
            }
            return englishName;
          }
          return AppLocalizations.isEnglish ? 'Unknown Region' : '未知地区';
        } catch (e) {
          print('解析地区出错: $e');
          return AppLocalizations.isEnglish ? 'Unknown Region' : '未知地区';
        }
      }

      return NearestArea(
        areaName: getAreaName(),
        country: getCountry(),
        region: getRegion(),
        latitude: json['latitude']?.toString() ?? '0',
        longitude: json['longitude']?.toString() ?? '0',
      );
    } catch (e) {
      print('解析位置数据出错: $e');
      return NearestArea(
        areaName: '未知地区',
        country: '未知国家',
        region: '未知地区',
        latitude: '0',
        longitude: '0',
      );
    }
  }
}
