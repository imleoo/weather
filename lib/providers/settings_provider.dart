import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';

class SettingsProvider with ChangeNotifier {
  static const String _updateFrequencyKey = 'update_frequency';
  static const String _weatherAlertsKey = 'weather_alerts';
  static const String _premiumUntilKey = 'premium_until';

  String _updateFrequency = 'every3hours'; // 默认每3小时更新一次
  bool _weatherAlerts = false; // 默认关闭天气提醒
  DateTime? _premiumUntil; // 会员到期时间

  String get updateFrequency => _updateFrequency;
  bool get weatherAlerts => _weatherAlerts;
  bool get isPremium =>
      _premiumUntil != null && _premiumUntil!.isAfter(DateTime.now());
  DateTime? get premiumUntil => _premiumUntil;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    _updateFrequency = prefs.getString(_updateFrequencyKey) ?? 'every3hours';
    _weatherAlerts = prefs.getBool(_weatherAlertsKey) ?? false;

    // 加载会员状态
    final premiumUntilStr = prefs.getString(_premiumUntilKey);
    if (premiumUntilStr != null) {
      try {
        _premiumUntil = DateTime.parse(premiumUntilStr);
      } catch (e) {
        _premiumUntil = null;
      }
    }

    notifyListeners();
  }

  Future<void> setLanguage(String languageCode) async {
    await AppLocalizations.setLanguage(languageCode);
    notifyListeners();
  }

  Future<void> setFollowSystemLanguage(bool follow) async {
    await AppLocalizations.setFollowSystemLanguage(follow);
    notifyListeners();
  }

  Future<void> setUpdateFrequency(String frequency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_updateFrequencyKey, frequency);
    _updateFrequency = frequency;
    notifyListeners();
  }

  Future<void> setWeatherAlerts(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_weatherAlertsKey, enabled);
    _weatherAlerts = enabled;
    notifyListeners();
  }

  // 设置会员状态，days为会员天数
  Future<void> setPremiumStatus(int days) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();

    // 如果已经是会员，则在现有会员期限上增加天数
    if (isPremium) {
      _premiumUntil = _premiumUntil!.add(Duration(days: days));
    } else {
      _premiumUntil = now.add(Duration(days: days));
    }

    await prefs.setString(_premiumUntilKey, _premiumUntil!.toIso8601String());
    notifyListeners();
  }

  // 清除会员状态
  Future<void> clearPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_premiumUntilKey);
    _premiumUntil = null;
    notifyListeners();
  }
}
