import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class AdService {
  static const String _appId = 'ca-app-pub-2247537732218607~7525978013';
  static const String _rewardedAdUnitId =
      'ca-app-pub-2247537732218607/4345566318';

  // Google官方测试广告ID，用于开发测试
  static const String _testRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  // 测试设备ID
  static const String _testDeviceId = 'DC93E2B088E425BB6537B4452C9E4743';

  static bool _isInitialized = false;
  static RewardedAd? _rewardedAd;
  static bool _isRewardedAdLoading = false;
  static int _loadAttempts = 0;
  static const int _maxLoadAttempts = 3;

  // 是否使用测试广告
  static const bool _useTestAds = true;

  // 初始化广告SDK
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 配置测试设备
      MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          testDeviceIds: [_testDeviceId],
        ),
      );

      await MobileAds.instance.initialize();
      print('AdMob SDK初始化成功');
      _isInitialized = true;

      // 加载第一个激励广告
      loadRewardedAd();
    } catch (e) {
      print('AdMob SDK初始化失败: $e');
      // 延迟后重试
      Future.delayed(const Duration(seconds: 5), () {
        initialize();
      });
    }
  }

  // 加载激励广告
  static void loadRewardedAd() {
    if (_isRewardedAdLoading) return;

    _isRewardedAdLoading = true;

    // 根据环境选择广告ID
    const adUnitId = _useTestAds ? _testRewardedAdUnitId : _rewardedAdUnitId;

    print(
        '正在加载广告，广告ID: $adUnitId，尝试次数: ${_loadAttempts + 1}/$_maxLoadAttempts');

    try {
      RewardedAd.load(
        adUnitId: adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('激励广告加载成功');
            _rewardedAd = ad;
            _isRewardedAdLoading = false;
            _loadAttempts = 0;

            // 设置广告回调
            _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (RewardedAd ad) {
                print('广告被关闭');
                ad.dispose();
                _rewardedAd = null;
                // 广告关闭后，重新加载新广告
                loadRewardedAd();
              },
              onAdFailedToShowFullScreenContent:
                  (RewardedAd ad, AdError error) {
                print('广告显示失败: ${error.message}');
                ad.dispose();
                _rewardedAd = null;
                loadRewardedAd();
              },
              onAdShowedFullScreenContent: (RewardedAd ad) {
                print('广告显示成功');
              },
              onAdImpression: (RewardedAd ad) {
                print('广告展示记录');
              },
            );
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('激励广告加载失败: ${error.code} - ${error.message}');
            _isRewardedAdLoading = false;
            _loadAttempts++;

            if (_loadAttempts < _maxLoadAttempts) {
              // 加载失败后，延迟一段时间再次尝试加载
              int delaySeconds = _loadAttempts * 5; // 递增延迟
              print('将在$delaySeconds秒后重试加载广告');
              Future.delayed(Duration(seconds: delaySeconds), () {
                loadRewardedAd();
              });
            } else {
              print('达到最大尝试次数，停止加载广告');
              _loadAttempts = 0;
              // 较长时间后再尝试
              Future.delayed(const Duration(minutes: 5), () {
                loadRewardedAd();
              });
            }
          },
        ),
      );
    } catch (e) {
      print('加载广告时发生异常: $e');
      _isRewardedAdLoading = false;
      // 延迟后重试
      Future.delayed(const Duration(seconds: 10), () {
        loadRewardedAd();
      });
    }
  }

  // 显示激励广告
  static Future<bool> showRewardedAd(BuildContext context) async {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);

    // 如果用户已经是会员，不显示广告
    if (settingsProvider.isPremium) {
      print('用户已是会员，无需显示广告');
      return true;
    }

    // 确保广告已初始化
    if (!_isInitialized) {
      print('广告SDK未初始化，正在初始化...');
      await initialize();
    }

    // 如果没有加载好广告，返回false
    if (_rewardedAd == null) {
      print('广告未准备好，正在重新加载');
      loadRewardedAd();
      return false;
    }

    print('准备显示激励广告');
    // 用于跟踪是否获得了奖励
    bool receivedReward = false;

    try {
      // 显示广告
      await _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          // 用户获得奖励
          print('用户获得奖励: ${reward.amount} ${reward.type}');
          receivedReward = true;
          // 设置7天会员
          settingsProvider.setPremiumStatus(7);
        },
      );
      print('广告显示完成');
    } catch (e) {
      print('显示广告时发生异常: $e');
      _rewardedAd = null;
      loadRewardedAd();
      return false;
    }

    return receivedReward;
  }

  // 检查是否有广告可以显示
  static bool isRewardedAdAvailable() {
    return _rewardedAd != null;
  }

  // 释放广告资源
  static void dispose() {
    print('释放广告资源');
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }

  // 重置加载状态
  static void resetLoadState() {
    _isRewardedAdLoading = false;
    _loadAttempts = 0;
  }
}
