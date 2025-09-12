import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_logger.dart';

class SocialShareService {
  // 社交媒体配置
  static const Map<String, Map<String, String>> socialPlatforms = {
    'twitter': {
      'name': 'Twitter',
      'url': 'https://twitter.com/intent/tweet?text={text}&url={url}',
      'icon': 'assets/icons/twitter.png',
    },
    'facebook': {
      'name': 'Facebook',
      'url': 'https://www.facebook.com/sharer/sharer.php?u={url}&quote={text}',
      'icon': 'assets/icons/facebook.png',
    },
    'linkedin': {
      'name': 'LinkedIn',
      'url':
          'https://www.linkedin.com/sharing/share-offsite/?url={url}&summary={text}',
      'icon': 'assets/icons/linkedin.png',
    },
    'instagram': {
      'name': 'Instagram',
      'url': 'instagram://library?AssetPath={url}', // 尝试打开Instagram应用
      'icon': 'assets/icons/instagram.png',
    },
    'youtube': {
      'name': 'YouTube',
      'url': 'https://www.youtube.com/share?url={url}',
      'icon': 'assets/icons/youtube.png',
    },
    'whatsapp': {
      'name': 'WhatsApp',
      'url': 'https://wa.me/?text={text}%20{url}',
      'icon': 'assets/icons/whatsapp.png',
    },
    'telegram': {
      'name': 'Telegram',
      'url': 'https://t.me/share/url?url={url}&text={text}',
      'icon': 'assets/icons/telegram.png',
    },
    'weibo': {
      'name': '微博',
      'url': 'https://service.weibo.com/share/share.php?url={url}&title={text}',
      'icon': 'assets/icons/weibo.png',
    },
    'wechat': {
      'name': '微信',
      'url': 'weixin://dl/moments', // 尝试打开微信朋友圈
      'icon': 'assets/icons/wechat.png',
    },
    'qq': {
      'name': 'QQ',
      'url':
          'https://connect.qq.com/widget/shareqq/index.html?url={url}&title={text}',
      'icon': 'assets/icons/qq.png',
    },
    'zhihu': {
      'name': '知乎',
      'url': 'https://www.zhihu.com/share?url={url}&title={text}',
      'icon': 'assets/icons/zhihu.png',
    },
    'xiaohongshu': {
      'name': '小红书',
      'url':
          'https://www.xiaohongshu.com/discovery/item?share_source=copy_link&share_title={text}&share_link={url}',
      'icon': 'assets/icons/xiaohongshu.png',
    },
  };

  /// 分享文本内容到指定平台
  static Future<void> shareToSocialPlatform({
    required String platform,
    required String text,
    String? url,
    String? subject,
  }) async {
    try {
      AppLogger.info(
        '分享到社交平台',
        details: {
          'platform': platform,
          'text': text,
          'url': url,
        },
        tag: 'SOCIAL_SHARE',
      );

      final platformInfo = socialPlatforms[platform.toLowerCase()];
      if (platformInfo == null) {
        print('不支持的平台: $platform，使用原生分享');
        throw Exception('不支持的平台: $platform');
      }

      final platformUrl = platformInfo['url'];
      if (platformUrl == null || platformUrl.isEmpty) {
        print('平台 $platform 没有配置URL，使用原生分享');
        throw Exception('平台没有配置URL，请使用原生分享');
      }

      // 替换URL中的占位符
      String shareUrl = platformUrl;
      if (text.isNotEmpty) {
        shareUrl = shareUrl.replaceAll('{text}', Uri.encodeComponent(text));
      }
      if (url != null && url.isNotEmpty) {
        shareUrl = shareUrl.replaceAll('{url}', Uri.encodeComponent(url));
      }

      print('准备启动URL: $shareUrl');

      // 尝试启动URL
      final uri = Uri.parse(shareUrl);
      if (await canLaunchUrl(uri)) {
        print('启动URL: $shareUrl');
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        print('URL启动成功');
      } else {
        print('无法启动URL: $shareUrl，尝试使用原生分享');
        throw Exception('无法启动URL: $shareUrl');
      }
    } catch (e) {
      print('分享失败: $e');
      AppLogger.error(
        '分享失败',
        error: e,
        details: {
          'platform': platform,
          'text': text,
        },
        tag: 'SOCIAL_SHARE',
      );
      rethrow;
    }
  }

  /// 使用原生分享对话框
  static Future<void> shareWithNativeDialog({
    required BuildContext context,
    required String text,
    String? subject,
  }) async {
    await Share.share(
      text,
      subject: subject,
    );
  }

  /// 启动URL
  static Future<void> _launchURL(String url) async {
    print('_launchURL 方法被调用: $url');
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      print('启动URL: $url');
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      print('URL启动成功');
    } else {
      print('无法启动URL: $url');
      throw Exception('无法启动URL: $url');
    }
  }

  /// 分享鱼获
  static Future<void> shareFishCatch({
    required BuildContext context,
    required String fishType,
    required double weight,
    String? description,
    String? location,
    String? imageUrl,
    String? platform,
  }) async {
    final text = _buildFishCatchShareText(
      fishType: fishType,
      weight: weight,
      description: description,
      location: location,
    );

    if (platform != null && platform.isNotEmpty) {
      try {
        // 分享到指定平台
        await shareToSocialPlatform(
          platform: platform,
          text: text,
          url: imageUrl,
          subject: '我在钓鱼天气应用分享了我的鱼获！',
        );
      } catch (e) {
        // 如果平台不支持，使用原生分享
        await shareWithNativeDialog(
          context: context,
          text: text,
          subject: '我在钓鱼天气应用分享了我的鱼获！',
        );
      }
    } else {
      // 使用原生分享对话框
      await shareWithNativeDialog(
        context: context,
        text: text,
        subject: '我在钓鱼天气应用分享了我的鱼获！',
      );
    }
  }

  /// 分享钓点
  static Future<void> shareFishingSpot({
    required BuildContext context,
    required String spotName,
    required String description,
    required double latitude,
    required double longitude,
    String? platform,
  }) async {
    final text = '发现了一个不错的钓点：$spotName\n\n$description';
    final url = 'https://www.google.com/maps?q=$latitude,$longitude';

    if (platform != null && platform.isNotEmpty) {
      try {
        // 分享到指定平台
        await shareToSocialPlatform(
          platform: platform,
          text: text,
          url: url,
          subject: '推荐一个钓鱼好去处！',
        );
      } catch (e) {
        // 如果平台不支持，使用原生分享
        await shareWithNativeDialog(
          context: context,
          text: '$text\n\n位置：$url',
          subject: '推荐一个钓鱼好去处！',
        );
      }
    } else {
      // 使用原生分享对话框
      await shareWithNativeDialog(
        context: context,
        text: '$text\n\n位置：$url',
        subject: '推荐一个钓鱼好去处！',
      );
    }
  }

  /// 构建鱼获分享文本
  static String _buildFishCatchShareText({
    required String fishType,
    required double weight,
    String? description,
    String? location,
  }) {
    var text = '我在钓鱼天气应用钓到了一条$fishType，重${weight}kg！';

    if (description != null && description.isNotEmpty) {
      text += '\n\n$description';
    }

    if (location != null && location.isNotEmpty) {
      text += '\n\n地点：$location';
    }

    text += '\n\n来自钓鱼天气应用';

    return text;
  }

  /// 获取支持的社交平台列表
  static List<Map<String, String>> getSupportedPlatforms() {
    return socialPlatforms.entries.map((entry) {
      return {
        'key': entry.key,
        'name': entry.value['name']!,
        'icon': entry.value['icon']!,
      };
    }).toList();
  }

  /// 显示分享选项对话框
  static void showShareOptions({
    required BuildContext context,
    required String shareType,
    required Map<String, dynamic> shareData,
  }) {
    print('显示分享选项对话框: $shareType, $shareData');
    AppLogger.info(
      '显示分享选项',
      details: {
        'shareType': shareType,
        'shareData': shareData.toString(),
      },
      tag: 'SOCIAL_SHARE',
    );

    // 显示社交媒体选择对话框
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('选择分享平台',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const Divider(),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // 系统分享选项
                      ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.blue,
                          child: Icon(Icons.share, color: Colors.white),
                        ),
                        title: const Text('系统分享'),
                        subtitle: const Text('使用系统默认分享'),
                        onTap: () {
                          Navigator.pop(context);
                          _shareWithSystem(context, shareType, shareData);
                        },
                      ),
                      const Divider(),
                      // 社交媒体平台
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        alignment: WrapAlignment.center,
                        children: [
                          _buildSocialPlatformButton(
                              context, 'twitter', shareType, shareData),
                          _buildSocialPlatformButton(
                              context, 'facebook', shareType, shareData),
                          _buildSocialPlatformButton(
                              context, 'linkedin', shareType, shareData),
                          _buildSocialPlatformButton(
                              context, 'weibo', shareType, shareData),
                          _buildSocialPlatformButton(
                              context, 'wechat', shareType, shareData),
                          _buildSocialPlatformButton(
                              context, 'qq', shareType, shareData),
                          _buildSocialPlatformButton(
                              context, 'zhihu', shareType, shareData),
                          _buildSocialPlatformButton(
                              context, 'xiaohongshu', shareType, shareData),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建社交平台按钮
  static Widget _buildSocialPlatformButton(
    BuildContext context,
    String platform,
    String shareType,
    Map<String, dynamic> shareData,
  ) {
    final platformInfo = socialPlatforms[platform];
    if (platformInfo == null) return const SizedBox.shrink();

    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _handleShare(
          context: context,
          shareType: shareType,
          shareData: shareData,
          platform: platform,
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            backgroundColor: _getPlatformColor(platform),
            radius: 25,
            child: Icon(_getPlatformIcon(platform), color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(platformInfo['name']!, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  /// 使用系统分享
  static Future<void> _shareWithSystem(
    BuildContext context,
    String shareType,
    Map<String, dynamic> shareData,
  ) async {
    try {
      print('使用系统分享: $shareType');

      if (shareType == 'fish_catch') {
        final text = _buildFishCatchShareText(
          fishType: shareData['fishType'] ?? '',
          weight: shareData['weight'] ?? 0.0,
          description: shareData['description'],
          location: shareData['location'],
        );

        await Share.share(
          text,
          subject: '我在钓鱼天气应用分享了我的鱼获！',
        );
      } else if (shareType == 'fishing_spot') {
        final text =
            '发现了一个不错的钓点：${shareData['spotName'] ?? ''}\n\n${shareData['description'] ?? ''}';
        final url =
            'https://www.google.com/maps?q=${shareData['latitude'] ?? 0.0},${shareData['longitude'] ?? 0.0}';
        final fullText = '$text\n\n位置：$url';

        await Share.share(
          fullText,
          subject: '推荐一个钓鱼好去处！',
        );
      }

      print('系统分享成功');
      AppLogger.info('系统分享成功', tag: 'SOCIAL_SHARE');
    } catch (e) {
      print('系统分享失败: $e');
      AppLogger.error(
        '系统分享失败',
        error: e,
        details: {'shareType': shareType},
        tag: 'SOCIAL_SHARE',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('分享失败: ${e.toString()}')),
        );
      }
    }
  }

  /// 处理分享
  static Future<void> _handleShare({
    required BuildContext context,
    required String shareType,
    required Map<String, dynamic> shareData,
    required String platform,
  }) async {
    print('处理分享: $shareType, $platform');
    try {
      switch (shareType) {
        case 'fish_catch':
          print('分享鱼获到 $platform');
          await shareFishCatch(
            context: context,
            fishType: shareData['fishType'],
            weight: shareData['weight'],
            description: shareData['description'],
            location: shareData['location'],
            imageUrl: shareData['imageUrl'],
            platform: platform,
          );
          break;

        case 'fishing_spot':
          print('分享钓点到 $platform');
          await shareFishingSpot(
            context: context,
            spotName: shareData['spotName'],
            description: shareData['description'],
            latitude: shareData['latitude'],
            longitude: shareData['longitude'],
            platform: platform,
          );
          break;
        default:
          print('未知的分享类型: $shareType');
          // 使用原生分享
          await shareWithNativeDialog(
            context: context,
            text: '来自钓鱼天气应用的分享',
            subject: '钓鱼天气分享',
          );
      }
      print('分享处理完成');
    } catch (e) {
      print('分享处理失败: $e');
      // 如果特定平台分享失败，尝试使用原生分享
      try {
        print('尝试使用原生分享');
        if (shareType == 'fish_catch') {
          final text = _buildFishCatchShareText(
            fishType: shareData['fishType'],
            weight: shareData['weight'],
            description: shareData['description'],
            location: shareData['location'],
          );
          await shareWithNativeDialog(
            context: context,
            text: text,
            subject: '我在钓鱼天气应用分享了我的鱼获！',
          );
        } else if (shareType == 'fishing_spot') {
          final text =
              '发现了一个不错的钓点：${shareData['spotName']}\n\n${shareData['description']}';
          final url =
              'https://www.google.com/maps?q=${shareData['latitude']},${shareData['longitude']}';
          await shareWithNativeDialog(
            context: context,
            text: '$text\n\n位置：$url',
            subject: '推荐一个钓鱼好去处！',
          );
        }
        print('原生分享成功');
      } catch (e2) {
        print('原生分享也失败了: $e2');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('分享失败: ${e2.toString()}')),
        );
      }
    }
  }

  /// 获取平台图标
  static IconData _getPlatformIcon(String platform) {
    switch (platform) {
      case 'twitter':
        return Icons.tag;
      case 'facebook':
        return Icons.facebook;
      case 'instagram':
        return Icons.camera_alt;
      case 'youtube':
        return Icons.play_circle;
      case 'whatsapp':
        return Icons.message;
      case 'telegram':
        return Icons.send;
      case 'weibo':
        return Icons.chat;
      case 'wechat':
        return Icons.chat_bubble;
      case 'qq':
        return Icons.chat;
      default:
        return Icons.share;
    }
  }

  /// 获取平台颜色
  static Color _getPlatformColor(String platform) {
    switch (platform) {
      case 'twitter':
        return const Color(0xFF1DA1F2);
      case 'facebook':
        return const Color(0xFF4267B2);
      case 'instagram':
        return const Color(0xFFE4405F);
      case 'youtube':
        return const Color(0xFFFF0000);
      case 'whatsapp':
        return const Color(0xFF25D366);
      case 'telegram':
        return const Color(0xFF0088CC);
      case 'weibo':
        return const Color(0xFFE6162D);
      case 'wechat':
        return const Color(0xFF07C160);
      case 'qq':
        return const Color(0xFF12B7F5);
      default:
        return Colors.grey;
    }
  }
}
