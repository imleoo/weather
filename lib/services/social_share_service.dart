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
    'instagram': {
      'name': 'Instagram',
      'url': '', // Instagram不支持直接分享URL，需要使用原生分享
      'icon': 'assets/icons/instagram.png',
    },
    'youtube': {
      'name': 'YouTube',
      'url': '', // YouTube通常用于视频分享
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
      'url': '', // 微信需要使用原生分享
      'icon': 'assets/icons/wechat.png',
    },
    'qq': {
      'name': 'QQ',
      'url': 'https://connect.qq.com/widget/shareqq/index.html?url={url}&title={text}',
      'icon': 'assets/icons/qq.png',
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
        throw Exception('不支持的平台: $platform');
      }

      switch (platform.toLowerCase()) {
        case 'instagram':
        case 'wechat':
          // 这些平台需要使用原生分享对话框
          throw Exception('请使用原生分享对话框');
        
        case 'youtube':
          // YouTube通常用于分享视频链接
          if (url != null && url.isNotEmpty) {
            await _launchURL(platformInfo['url']!.replaceFirst('{url}', url));
          } else {
            throw Exception('分享到YouTube需要提供URL');
          }
          break;
        
        default:
          // 其他平台可以使用URL scheme
          if (platformInfo['url']!.isNotEmpty) {
            final shareUrl = platformInfo['url']!
                .replaceFirst('{text}', Uri.encodeComponent(text))
                .replaceFirst('{url}', url != null ? Uri.encodeComponent(url!) : '');
            await _launchURL(shareUrl);
          } else {
            // 如果没有URL scheme，使用原生分享
            throw Exception('请使用原生分享对话框');
          }
      }
    } catch (e) {
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
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择分享平台'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: socialPlatforms.length,
            itemBuilder: (context, index) {
              final platform = socialPlatforms.entries.elementAt(index);
              return InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _handleShare(
                    context: context,
                    shareType: shareType,
                    shareData: shareData,
                    platform: platform.key,
                  );
                },
                borderRadius: BorderRadius.circular(8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getPlatformIcon(platform.key),
                      size: 40,
                      color: _getPlatformColor(platform.key),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      platform.value['name']!,
                      style: const TextStyle(fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  /// 处理分享
  static Future<void> _handleShare({
    required BuildContext context,
    required String shareType,
    required Map<String, dynamic> shareData,
    required String platform,
  }) async {
    switch (shareType) {
      case 'fish_catch':
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
        await shareFishingSpot(
          context: context,
          spotName: shareData['spotName'],
          description: shareData['description'],
          latitude: shareData['latitude'],
          longitude: shareData['longitude'],
          platform: platform,
        );
        break;
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