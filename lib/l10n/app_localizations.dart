import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_en.dart';
import 'app_zh.dart';

class AppLocalizations {
  static const String _languageKey = 'language_code';
  static const String languageEn = 'en';
  static const String languageZh = 'zh';

  static String _currentLanguage = languageEn; // 默认英文

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString(_languageKey) ?? languageEn;
  }

  static Future<void> setLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
    _currentLanguage = languageCode;
  }

  static String get currentLanguage => _currentLanguage;

  static bool get isEnglish => _currentLanguage == languageEn;

  static String get appTitle => isEnglish ? AppEn.appTitle : AppZh.appTitle;
  static String get settings => isEnglish ? AppEn.settings : AppZh.settings;
  static String get language => isEnglish ? AppEn.language : AppZh.language;
  static String get updateFrequency =>
      isEnglish ? AppEn.updateFrequency : AppZh.updateFrequency;
  static String get weatherAlerts =>
      isEnglish ? AppEn.weatherAlerts : AppZh.weatherAlerts;
  static String get aboutApp => isEnglish ? AppEn.aboutApp : AppZh.aboutApp;
  static String get privacyPolicy =>
      isEnglish ? AppEn.privacyPolicy : AppZh.privacyPolicy;
  static String get termsOfService =>
      isEnglish ? AppEn.termsOfService : AppZh.termsOfService;
  static String get openSourceLicenses =>
      isEnglish ? AppEn.openSourceLicenses : AppZh.openSourceLicenses;
  static String get version => isEnglish ? AppEn.version : AppZh.version;
  static String get retry => isEnglish ? AppEn.retry : AppZh.retry;
  static String get loadingFailed =>
      isEnglish ? AppEn.loadingFailed : AppZh.loadingFailed;
  static String get noWeatherData =>
      isEnglish ? AppEn.noWeatherData : AppZh.noWeatherData;
  static String get english => isEnglish ? AppEn.english : AppZh.english;
  static String get chinese => isEnglish ? AppEn.chinese : AppZh.chinese;
  static String get hourly => isEnglish ? AppEn.hourly : AppZh.hourly;
  static String get every3Hours =>
      isEnglish ? AppEn.every3Hours : AppZh.every3Hours;
  static String get every6Hours =>
      isEnglish ? AppEn.every6Hours : AppZh.every6Hours;
  static String get daily => isEnglish ? AppEn.daily : AppZh.daily;
  static String get on => isEnglish ? AppEn.on : AppZh.on;
  static String get off => isEnglish ? AppEn.off : AppZh.off;
  static String get save => isEnglish ? AppEn.save : AppZh.save;
  static String get cancel => isEnglish ? AppEn.cancel : AppZh.cancel;

  // 城市搜索
  static String get selectCity =>
      isEnglish ? AppEn.selectCity : AppZh.selectCity;
  static String get enterCityName =>
      isEnglish ? AppEn.enterCityName : AppZh.enterCityName;
  static String get northAmerica =>
      isEnglish ? AppEn.northAmerica : AppZh.northAmerica;
  static String get europe => isEnglish ? AppEn.europe : AppZh.europe;
  static String get asia => isEnglish ? AppEn.asia : AppZh.asia;
  static String get southAmerica =>
      isEnglish ? AppEn.southAmerica : AppZh.southAmerica;
  static String get oceania => isEnglish ? AppEn.oceania : AppZh.oceania;
  static String get africa => isEnglish ? AppEn.africa : AppZh.africa;

  // 天气详情
  static String get weatherDetails =>
      isEnglish ? AppEn.weatherDetails : AppZh.weatherDetails;
  static String get hourlyForecast =>
      isEnglish ? AppEn.hourlyForecast : AppZh.hourlyForecast;
  static String get dailyForecast =>
      isEnglish ? AppEn.dailyForecast : AppZh.dailyForecast;
  static String get today => isEnglish ? AppEn.today : AppZh.today;
  static String get feelsLike => isEnglish ? AppEn.feelsLike : AppZh.feelsLike;
  static String get humidity => isEnglish ? AppEn.humidity : AppZh.humidity;
  static String get windSpeed => isEnglish ? AppEn.windSpeed : AppZh.windSpeed;
  static String get visibility =>
      isEnglish ? AppEn.visibility : AppZh.visibility;
  static String get pressure => isEnglish ? AppEn.pressure : AppZh.pressure;
  static String get precipitation =>
      isEnglish ? AppEn.precipitation : AppZh.precipitation;
  static String get uvIndex => isEnglish ? AppEn.uvIndex : AppZh.uvIndex;
  static String get kmh => isEnglish ? AppEn.kmh : AppZh.kmh;
  static String get km => isEnglish ? AppEn.km : AppZh.km;
  static String get hPa => isEnglish ? AppEn.hPa : AppZh.hPa;
  static String get mm => isEnglish ? AppEn.mm : AppZh.mm;
  static String get sunrise => isEnglish ? AppEn.sunrise : AppZh.sunrise;
  static String get sunset => isEnglish ? AppEn.sunset : AppZh.sunset;
  static String get sunHour => isEnglish ? AppEn.sunHour : AppZh.sunHour;

  // 钓鱼天气相关
  static String get fishingForecast =>
      isEnglish ? AppEn.fishingForecast : AppZh.fishingForecast;
  static String get fishingSuitability =>
      isEnglish ? AppEn.fishingSuitability : AppZh.fishingSuitability;
  static String get excellent => isEnglish ? AppEn.excellent : AppZh.excellent;
  static String get good => isEnglish ? AppEn.good : AppZh.good;
  static String get moderate => isEnglish ? AppEn.moderate : AppZh.moderate;
  static String get poor => isEnglish ? AppEn.poor : AppZh.poor;
  static String get fishingAdvice =>
      isEnglish ? AppEn.fishingAdvice : AppZh.fishingAdvice;
  static String get fishingScore =>
      isEnglish ? AppEn.fishingScore : AppZh.fishingScore;
  static String get weatherFactors =>
      isEnglish ? AppEn.weatherFactors : AppZh.weatherFactors;
  static String get pressureScore =>
      isEnglish ? AppEn.pressureScore : AppZh.pressureScore;
  static String get weatherScore =>
      isEnglish ? AppEn.weatherScore : AppZh.weatherScore;
  static String get rainChanceScore =>
      isEnglish ? AppEn.rainChanceScore : AppZh.rainChanceScore;
  static String get cloudCoverScore =>
      isEnglish ? AppEn.cloudCoverScore : AppZh.cloudCoverScore;
  static String get windSpeedScore =>
      isEnglish ? AppEn.windSpeedScore : AppZh.windSpeedScore;
  static String get temperatureScore =>
      isEnglish ? AppEn.temperatureScore : AppZh.temperatureScore;
  static String get humidityScore =>
      isEnglish ? AppEn.humidityScore : AppZh.humidityScore;
  static String get visibilityScore =>
      isEnglish ? AppEn.visibilityScore : AppZh.visibilityScore;
  static String get selectDate =>
      isEnglish ? AppEn.selectDate : AppZh.selectDate;

  // 新增的钓鱼建议相关
  static String get tipRainActive => isEnglish
      ? 'Rain may increase fish activity, especially for surface feeders'
      : '雨天可能增加鱼类活动，尤其是表层觅食的鱼';

  static String get tipRainDeepWater => isEnglish
      ? 'During rain, try fishing in deeper waters where fish may gather'
      : '雨天时，尝试在鱼类可能聚集的深水区域钓鱼';

  static String get tipTemperatureGood => isEnglish
      ? 'Temperature is ideal for fish activity, good time for fishing'
      : '温度适宜鱼类活动，是钓鱼的好时机';

  static String get weatherCondition =>
      isEnglish ? 'Weather Condition' : '天气状况';

  static String get temperature => isEnglish ? 'Temperature' : '温度';

  static String get chanceOfRain => isEnglish ? 'Chance of Rain' : '降水概率';

  static String get cloudCover => isEnglish ? 'Cloud Cover' : '云量';

  static String get fishingScoreDetails =>
      isEnglish ? 'Fishing Score Details' : '钓鱼评分详情';

  // 广告相关
  static String get watchAdForPremium =>
      isEnglish ? AppEn.watchAdForPremium : AppZh.watchAdForPremium;
  static String get premiumMember =>
      isEnglish ? AppEn.premiumMember : AppZh.premiumMember;
  static String get adNotAvailable =>
      isEnglish ? AppEn.adNotAvailable : AppZh.adNotAvailable;
  static String get premiumUntil =>
      isEnglish ? AppEn.premiumUntil : AppZh.premiumUntil;
  static String get getPremium =>
      isEnglish ? AppEn.getPremium : AppZh.getPremium;
}