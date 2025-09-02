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

  // Navigation
  static String get weather => isEnglish ? AppEn.weather : AppZh.weather;
  static String get fishingSpots => isEnglish ? AppEn.fishingSpots : AppZh.fishingSpots;
  static String get share => isEnglish ? AppEn.share : AppZh.share;
  static String get my => isEnglish ? AppEn.my : AppZh.my;

  // Fishing Spots
  static String get nearbySpots => isEnglish ? AppEn.nearbySpots : AppZh.nearbySpots;
  static String get shareCurrentSpot => isEnglish ? AppEn.shareCurrentSpot : AppZh.shareCurrentSpot;
  static String get noNearbySpots => isEnglish ? AppEn.noNearbySpots : AppZh.noNearbySpots;
  static String get refresh => isEnglish ? AppEn.refresh : AppZh.refresh;
  static String get distance => isEnglish ? AppEn.distance : AppZh.distance;
  static String get description => isEnglish ? AppEn.description : AppZh.description;
  static String get navigate => isEnglish ? AppEn.navigate : AppZh.navigate;
  static String get close => isEnglish ? AppEn.close : AppZh.close;
  static String get currentLocation => isEnglish ? AppEn.currentLocation : AppZh.currentLocation;
  static String get location => isEnglish ? AppEn.location : AppZh.location;
  static String get coordinates => isEnglish ? AppEn.coordinates : AppZh.coordinates;
  static String get spotDescription => isEnglish ? AppEn.spotDescription : AppZh.spotDescription;
  static String get describeThisSpot => isEnglish ? AppEn.describeThisSpot : AppZh.describeThisSpot;
  static String get shareThisSpot => isEnglish ? AppEn.shareThisSpot : AppZh.shareThisSpot;
  static String get locationNotAvailable => isEnglish ? AppEn.locationNotAvailable : AppZh.locationNotAvailable;

  // Share
  static String get shareCatch => isEnglish ? AppEn.shareCatch : AppZh.shareCatch;
  static String get communityShares => isEnglish ? AppEn.communityShares : AppZh.communityShares;
  static String get shareFishCatch => isEnglish ? AppEn.shareFishCatch : AppZh.shareFishCatch;
  static String get fishType => isEnglish ? AppEn.fishType : AppZh.fishType;
  static String get enterFishType => isEnglish ? AppEn.enterFishType : AppZh.enterFishType;
  static String get weight => isEnglish ? AppEn.weight : AppZh.weight;
  static String get enterWeight => isEnglish ? AppEn.enterWeight : AppZh.enterWeight;
  static String get shareYourExperience => isEnglish ? AppEn.shareYourExperience : AppZh.shareYourExperience;
  static String get addPhoto => isEnglish ? AppEn.addPhoto : AppZh.addPhoto;
  static String get shareNow => isEnglish ? AppEn.shareNow : AppZh.shareNow;
  static String get noCommunityShares => isEnglish ? AppEn.noCommunityShares : AppZh.noCommunityShares;
  static String get pleaseFillRequired => isEnglish ? AppEn.pleaseFillRequired : AppZh.pleaseFillRequired;
  static String get shareSuccess => isEnglish ? AppEn.shareSuccess : AppZh.shareSuccess;
  static String get shareFailed => isEnglish ? AppEn.shareFailed : AppZh.shareFailed;

  // User
  static String get pleaseLogin => isEnglish ? AppEn.pleaseLogin : AppZh.pleaseLogin;
  static String get loginToAccessFeatures => isEnglish ? AppEn.loginToAccessFeatures : AppZh.loginToAccessFeatures;
  static String get loginRegister => isEnglish ? AppEn.loginRegister : AppZh.loginRegister;
  static String get editProfile => isEnglish ? AppEn.editProfile : AppZh.editProfile;
  static String get myFishCatches => isEnglish ? AppEn.myFishCatches : AppZh.myFishCatches;
  static String get myFishingSpots => isEnglish ? AppEn.myFishingSpots : AppZh.myFishingSpots;
  static String get likedShares => isEnglish ? AppEn.likedShares : AppZh.likedShares;
  static String get help => isEnglish ? AppEn.help : AppZh.help;
  static String get about => isEnglish ? AppEn.about : AppZh.about;
  static String get confirmLogout => isEnglish ? AppEn.confirmLogout : AppZh.confirmLogout;
  static String get logoutConfirmMessage => isEnglish ? AppEn.logoutConfirmMessage : AppZh.logoutConfirmMessage;
  static String get confirm => isEnglish ? AppEn.confirm : AppZh.confirm;
  static String get logout => isEnglish ? AppEn.logout : AppZh.logout;
  static String get logoutSuccess => isEnglish ? AppEn.logoutSuccess : AppZh.logoutSuccess;
  static String get logoutFailed => isEnglish ? AppEn.logoutFailed : AppZh.logoutFailed;
  static String get aboutDescription => isEnglish ? AppEn.aboutDescription : AppZh.aboutDescription;

  // Login/Register
  static String get login => isEnglish ? AppEn.login : AppZh.login;
  static String get register => isEnglish ? AppEn.register : AppZh.register;
  static String get welcomeBack => isEnglish ? AppEn.welcomeBack : AppZh.welcomeBack;
  static String get loginToContinue => isEnglish ? AppEn.loginToContinue : AppZh.loginToContinue;
  static String get createAccount => isEnglish ? AppEn.createAccount : AppZh.createAccount;
  static String get joinOurCommunity => isEnglish ? AppEn.joinOurCommunity : AppZh.joinOurCommunity;
  static String get email => isEnglish ? AppEn.email : AppZh.email;
  static String get enterEmail => isEnglish ? AppEn.enterEmail : AppZh.enterEmail;
  static String get password => isEnglish ? AppEn.password : AppZh.password;
  static String get enterPassword => isEnglish ? AppEn.enterPassword : AppZh.enterPassword;
  static String get nickname => isEnglish ? AppEn.nickname : AppZh.nickname;
  static String get enterNickname => isEnglish ? AppEn.enterNickname : AppZh.enterNickname;
  static String get confirmPassword => isEnglish ? AppEn.confirmPassword : AppZh.confirmPassword;
  static String get enterPasswordAgain => isEnglish ? AppEn.enterPasswordAgain : AppZh.enterPasswordAgain;
  static String get forgotPassword => isEnglish ? AppEn.forgotPassword : AppZh.forgotPassword;
  static String get termsAgreement => isEnglish ? AppEn.termsAgreement : AppZh.termsAgreement;
  static String get emailRequired => isEnglish ? AppEn.emailRequired : AppZh.emailRequired;
  static String get emailInvalid => isEnglish ? AppEn.emailInvalid : AppZh.emailInvalid;
  static String get passwordRequired => isEnglish ? AppEn.passwordRequired : AppZh.passwordRequired;
  static String get passwordTooShort => isEnglish ? AppEn.passwordTooShort : AppZh.passwordTooShort;
  static String get nicknameRequired => isEnglish ? AppEn.nicknameRequired : AppZh.nicknameRequired;
  static String get nicknameTooShort => isEnglish ? AppEn.nicknameTooShort : AppZh.nicknameTooShort;
  static String get confirmPasswordRequired => isEnglish ? AppEn.confirmPasswordRequired : AppZh.confirmPasswordRequired;
  static String get passwordsDoNotMatch => isEnglish ? AppEn.passwordsDoNotMatch : AppZh.passwordsDoNotMatch;
  static String get loginSuccess => isEnglish ? AppEn.loginSuccess : AppZh.loginSuccess;
  static String get loginFailed => isEnglish ? AppEn.loginFailed : AppZh.loginFailed;
  static String get registerSuccess => isEnglish ? AppEn.registerSuccess : AppZh.registerSuccess;
  static String get registerFailed => isEnglish ? AppEn.registerFailed : AppZh.registerFailed;

  // Profile
  static String get bio => isEnglish ? AppEn.bio : AppZh.bio;
  static String get introduceBriefly => isEnglish ? AppEn.introduceBriefly : AppZh.introduceBriefly;
  static String get saveChanges => isEnglish ? AppEn.saveChanges : AppZh.saveChanges;
  static String get changePassword => isEnglish ? AppEn.changePassword : AppZh.changePassword;
  static String get accountInfo => isEnglish ? AppEn.accountInfo : AppZh.accountInfo;
  static String get joinDate => isEnglish ? AppEn.joinDate : AppZh.joinDate;
  static String get lastUpdate => isEnglish ? AppEn.lastUpdate : AppZh.lastUpdate;
  static String get profileUpdateSuccess => isEnglish ? AppEn.profileUpdateSuccess : AppZh.profileUpdateSuccess;
  static String get profileUpdateFailed => isEnglish ? AppEn.profileUpdateFailed : AppZh.profileUpdateFailed;
  static String get oldPassword => isEnglish ? AppEn.oldPassword : AppZh.oldPassword;
  static String get newPassword => isEnglish ? AppEn.newPassword : AppZh.newPassword;
  static String get confirmNewPassword => isEnglish ? AppEn.confirmNewPassword : AppZh.confirmNewPassword;
  static String get oldPasswordRequired => isEnglish ? AppEn.oldPasswordRequired : AppZh.oldPasswordRequired;
  static String get newPasswordRequired => isEnglish ? AppEn.newPasswordRequired : AppZh.newPasswordRequired;
  static String get passwordChangeSuccess => isEnglish ? AppEn.passwordChangeSuccess : AppZh.passwordChangeSuccess;
  static String get passwordChangeFailed => isEnglish ? AppEn.passwordChangeFailed : AppZh.passwordChangeFailed;
}
