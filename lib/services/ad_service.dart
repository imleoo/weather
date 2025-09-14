import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class AdService {
  static const String _testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testDeviceId = 'D5F37AB864F523A8D46718F9E4A07168';

  static bool _isInitialized = false;
  static RewardedAd? _rewardedAd;
  static bool _isRewardedAdLoading = false;
  static bool _isAdShowing = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: [_testDeviceId]),
      );
      await MobileAds.instance.initialize();
      _isInitialized = true;
      loadRewardedAd();
    } catch (e) {
      debugPrint('AdMob初始化失败: $e');
    }
  }

  static void loadRewardedAd() {
    if (_isRewardedAdLoading) return;

    _isRewardedAdLoading = true;
    RewardedAd.load(
      adUnitId: _testRewardedAdUnitId,
      request: const AdRequest(keywords: ['weather', 'fishing']),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (RewardedAd ad) {
          _rewardedAd = ad;
          _isRewardedAdLoading = false;
          _setupAdCallbacks(ad);
        },
        onAdFailedToLoad: (LoadAdError error) {
          debugPrint('广告加载失败: ${error.message}');
          _isRewardedAdLoading = false;
        },
      ),
    );
  }

  static void _setupAdCallbacks(RewardedAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (RewardedAd ad) {
        ad.dispose();
        _rewardedAd = null;
        loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (RewardedAd ad, AdError error) {
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdLoading = false;
      },
    );
  }

  static Future<bool> showRewardedAd(BuildContext context) async {
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);

    if (settingsProvider.isPremium) return true;

    if (!_isInitialized) {
      await initialize();
      await Future.delayed(const Duration(seconds: 2));
    }

    if (_rewardedAd == null) {
      if (!_isRewardedAdLoading) loadRewardedAd();
      
      for (int i = 0; i < 3; i++) {
        await Future.delayed(const Duration(seconds: 1));
        if (_rewardedAd != null) break;
      }
      
      if (_rewardedAd == null) return false;
    }

    bool receivedReward = false;
    try {
      _isAdShowing = true;
      await _rewardedAd!.show(
        onUserEarnedReward: (AdWithoutView ad, RewardItem reward) {
          receivedReward = true;
          settingsProvider.setPremiumStatus(7);
        },
      );
      _isAdShowing = false;
    } catch (e) {
      debugPrint('显示广告失败: $e');
      _isAdShowing = false;
      _rewardedAd = null;
      return false;
    }

    return receivedReward;
  }

  static bool isRewardedAdAvailable() => _rewardedAd != null;
  static bool get isAdShowing => _isAdShowing;

  static void dispose() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
  }

  static void stopAd() {
    // 停止广告显示（如果正在显示）
    if (_isAdShowing) {
      _isAdShowing = false;
      // 这里可以添加停止广告的逻辑
    }
  }
}