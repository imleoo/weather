import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';

class AdService {
  static const String _appId = 'ca-app-pub-2247537732218607~7525978013';
  static const String _rewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  // Google官方测试广告ID，用于开发测试 - 尝试不同的测试ID
  static const String _testRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';

  // 测试设备ID
  static const String _testDeviceId = 'D5F37AB864F523A8D46718F9E4A07168';

  static bool _isInitialized = false;
  static RewardedAd? _rewardedAd;
  static bool _isRewardedAdLoading = false;
  static bool _isAdShowing = false;
  static int _loadAttempts = 0;
  static const int _maxLoadAttempts = 5;

  // 是否使用测试广告
  static const bool _useTestAds = true;
  
  // 是否使用模拟广告（用于测试流程）
  static const bool _useMockAds = false;

  // 初始化广告SDK
  static Future<void> initialize() async {
    if (_isInitialized) {
      print('AdMob SDK已经初始化过了');
      return;
    }

    print('开始初始化AdMob SDK...');
    try {
      // 配置测试设备 - 使用Google Ads SDK建议的测试设备ID
      MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          testDeviceIds: [_testDeviceId],
        ),
      );

      await MobileAds.instance.initialize();
      print('AdMob SDK初始化成功');
      _isInitialized = true;

      // 立即加载第一个激励广告
      Future.delayed(const Duration(seconds: 2), () {
        print('开始加载第一个激励广告...');
        loadRewardedAd();
      });
    } catch (e) {
      print('AdMob SDK初始化失败: $e');
      _isInitialized = false;
      // 延迟后重试
      Future.delayed(const Duration(seconds: 10), () {
        print('重试初始化AdMob SDK...');
        initialize();
      });
    }
  }

  // 加载激励广告
  static void loadRewardedAd() {
    if (_isRewardedAdLoading) {
      print('广告正在加载中，跳过重复加载');
      return;
    }

    _isRewardedAdLoading = true;

    // 使用测试广告ID
    const adUnitId = _useTestAds ? _testRewardedAdUnitId : _rewardedAdUnitId;

    print('=== 开始加载激励广告 ===');
    print('广告ID: $adUnitId');
    print('当前时间: ${DateTime.now()}');
    print('加载尝试次数: $_loadAttempts');

    try {
      // 创建广告请求，添加网络超时处理
      final adRequest = AdRequest(
        keywords: ['weather', 'fishing', 'outdoor'],
        contentUrl: 'https://leoobai.cn',
      );

      RewardedAd.load(
        adUnitId: adUnitId,
        request: adRequest,
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (RewardedAd ad) {
            print('🎉 激励广告加载成功！');
            print('广告对象: ${ad.responseInfo?.responseId}');
            print('广告网络: ${ad.responseInfo?.mediationAdapterClassName}');
            _rewardedAd = ad;
            _isRewardedAdLoading = false;
            _loadAttempts = 0;

            // 设置广告回调
            _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (RewardedAd ad) {
                print('广告被关闭 - 开始加载新广告');
                ad.dispose();
                _rewardedAd = null;
                // 广告关闭后，重新加载新广告
                Future.delayed(const Duration(seconds: 2), () {
                  loadRewardedAd();
                });
              },
              onAdFailedToShowFullScreenContent:
                  (RewardedAd ad, AdError error) {
                print('广告显示失败: ${error.code} - ${error.message}');
                print('错误详情: ${error.domain}');
                ad.dispose();
                _rewardedAd = null;
                _isRewardedAdLoading = false;
                // 重新加载
                Future.delayed(const Duration(seconds: 3), () {
                  loadRewardedAd();
                });
              },
              onAdShowedFullScreenContent: (RewardedAd ad) {
                print('🎬 广告显示成功！');
              },
              onAdImpression: (RewardedAd ad) {
                print('📊 广告展示记录');
              },
            );
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('❌ 激励广告加载失败:');
            print('错误代码: ${error.code}');
            print('错误消息: ${error.message}');
            print('错误域名: ${error.domain}');
            print('错误原因: ${error.responseInfo?.responseId}');
            print('响应信息: ${error.responseInfo?.responseId}');
            _isRewardedAdLoading = false;
            _loadAttempts++;

            // 网络连接错误的特殊处理
            if (error.code == 0 || error.message.contains('network') || error.message.contains('Network')) {
              print('🌐 检测到网络连接错误');
              print('可能是网络连接问题或防火墙阻止了广告请求');
              
              if (_loadAttempts < _maxLoadAttempts) {
                // 网络错误使用指数退避
                int delaySeconds = _loadAttempts * 15; // 更长的延迟
                print('将在$delaySeconds秒后重试加载广告 (尝试 $_loadAttempts/$_maxLoadAttempts)');
                Future.delayed(Duration(seconds: delaySeconds), () {
                  loadRewardedAd();
                });
              } else {
                print('⏹️ 达到最大尝试次数，暂停加载广告');
                _loadAttempts = 0;
                // 更长时间后再尝试
                Future.delayed(const Duration(minutes: 10), () {
                  loadRewardedAd();
                });
              }
            }
            // 特殊处理 "No fill" 错误 (代码 3)
            else if (error.code == 3) {
              print('🔍 检测到 "No fill" 错误');
              print('这通常意味着测试广告暂时没有库存');
              
              if (_loadAttempts < _maxLoadAttempts) {
                int delaySeconds = _loadAttempts * 10;
                print('将在$delaySeconds秒后重试加载广告 (尝试 $_loadAttempts/$_maxLoadAttempts)');
                Future.delayed(Duration(seconds: delaySeconds), () {
                  loadRewardedAd();
                });
              } else {
                print('⏹️ 达到最大尝试次数，停止加载广告');
                _loadAttempts = 0;
                Future.delayed(const Duration(minutes: 5), () {
                  loadRewardedAd();
                });
              }
            }
            // 其他错误类型的处理
            else {
              if (_loadAttempts < _maxLoadAttempts) {
                int delaySeconds = _loadAttempts * 8;
                print('将在$delaySeconds秒后重试加载广告 (尝试 $_loadAttempts/$_maxLoadAttempts)');
                Future.delayed(Duration(seconds: delaySeconds), () {
                  loadRewardedAd();
                });
              } else {
                print('⏹️ 达到最大尝试次数，停止加载广告');
                _loadAttempts = 0;
                Future.delayed(const Duration(minutes: 5), () {
                  loadRewardedAd();
                });
              }
            }
          },
        ),
      );
    } catch (e) {
      print('💥 加载广告时发生异常: $e');
      _isRewardedAdLoading = false;
      // 延迟后重试
      Future.delayed(const Duration(seconds: 15), () {
        loadRewardedAd();
      });
    }
  }

  // 显示激励广告
  static Future<bool> showRewardedAd(BuildContext context) async {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);

    print('=== 开始显示激励广告 ===');
    print('当前时间: ${DateTime.now()}');
    print('使用模拟广告: $_useMockAds');

    // 如果使用模拟广告，直接显示模拟广告
    if (_useMockAds) {
      print('🎭 显示模拟激励广告...');
      return await _showMockRewardedAd(context, settingsProvider);
    }

    print('初始化状态: $_isInitialized');
    print('广告是否准备好: ${_rewardedAd != null}');
    print('是否正在加载: $_isRewardedAdLoading');
    print('加载尝试次数: $_loadAttempts');

    // 临时移除会员检查，确保广告能显示
    // if (settingsProvider.isPremium) {
    //   print('用户已是会员，无需显示广告');
    //   return true;
    // }

    // 确保广告已初始化
    if (!_isInitialized) {
      print('广告SDK未初始化，正在初始化...');
      await initialize();
      // 等待初始化完成
      await Future.delayed(const Duration(seconds: 3));
      print('初始化完成状态: $_isInitialized');
    }

    // 如果没有加载好广告，尝试加载
    if (_rewardedAd == null) {
      print('广告未准备好，正在重新加载');
      if (!_isRewardedAdLoading) {
        loadRewardedAd();
      }
      // 等待加载完成 - 减少等待时间，避免阻塞用户
      for (int i = 0; i < 5; i++) {
        await Future.delayed(const Duration(seconds: 1));
        if (_rewardedAd != null) {
          print('广告加载成功');
          break;
        }
        print('等待广告加载... ${i + 1}/5');
      }
      
      // 再次检查
      if (_rewardedAd == null) {
        print('广告仍然未准备好，跳过广告显示');
        // 不显示错误提示，保持用户体验流畅
        return false; // 返回false表示广告未显示
      }
    }

    print('准备显示激励广告');
    // 用于跟踪是否获得了奖励
    bool receivedReward = false;

    try {
      // 标记广告开始播放
      _isAdShowing = true;
      print('🎬 广告开始播放');
      
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
      
      // 标记广告播放结束
      _isAdShowing = false;
      print('🎬 广告播放结束');
    } catch (e) {
      print('显示广告时发生异常: $e');
      _isAdShowing = false;
      _rewardedAd = null;
      loadRewardedAd();
      return false;
    }

    print('=== 激励广告显示完成，奖励状态: $receivedReward ===');
    return receivedReward;
  }

  // 显示模拟激励广告
  static Future<bool> _showMockRewardedAd(BuildContext context, SettingsProvider settingsProvider) async {
    print('🎭 开始显示模拟激励广告...');
    
    // 显示模拟广告提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎬 正在播放模拟广告...'),
        duration: Duration(seconds: 2),
      ),
    );

    // 模拟广告播放时间
    await Future.delayed(const Duration(seconds: 3));

    // 模拟用户获得奖励
    print('🎉 用户获得奖励: 1 premium');
    settingsProvider.setPremiumStatus(7);

    // 显示奖励获得提示
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🎉 恭喜！您获得了7天会员体验！'),
        duration: Duration(seconds: 3),
      ),
    );

    print('🎭 模拟广告显示完成');
    return true;
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

  // 停止正在播放的广告
  static void stopAd() {
    if (_isAdShowing && _rewardedAd != null) {
      print('🛑 定位完成，停止广告播放');
      _rewardedAd?.dispose();
      _rewardedAd = null;
      _isAdShowing = false;
    }
  }

  // 检查广告是否正在播放
  static bool get isAdShowing => _isAdShowing;
}
