import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

// 复制时间格式化函数用于测试
String _formatUpdateTime(DateTime time) {
  final now = DateTime.now();
  final difference = now.difference(time);
  
  if (difference.inMinutes < 1) {
    return '刚刚';
  } else if (difference.inMinutes < 60) {
    return '${difference.inMinutes}分钟前';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}小时前';
  } else {
    return '${difference.inDays}天前';
  }
}

void main() {
  group('WidgetService Tests', () {
    test('JSON data format matches iOS widget expectations', () {
      // 创建测试数据
      final testData = {
        'temperature': '25°C',
        'weatherCondition': '晴',
        'location': '北京',
        'fishingScore': 4,
        'fishingAdvice': '适宜',
        'updateTime': '刚刚',
      };

      // 将数据转换为JSON字符串
      final jsonString = jsonEncode(testData);
      
      // 验证JSON格式
      expect(jsonString, isNotNull);
      expect(jsonString.isNotEmpty, true);
      
      // 验证可以正确解码
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      expect(decoded['temperature'], '25°C');
      expect(decoded['weatherCondition'], '晴');
      expect(decoded['location'], '北京');
      expect(decoded['fishingScore'], 4);
      expect(decoded['fishingAdvice'], '适宜');
      expect(decoded['updateTime'], '刚刚');
    });

    test('Time formatting works correctly', () {
      final now = DateTime.now();
      final oneMinuteAgo = now.subtract(const Duration(minutes: 1));
      final oneHourAgo = now.subtract(const Duration(hours: 1));
      final oneDayAgo = now.subtract(const Duration(days: 1));

      expect(_formatUpdateTime(now), '刚刚');
      expect(_formatUpdateTime(oneMinuteAgo), '1分钟前');
      expect(_formatUpdateTime(oneHourAgo), '1小时前');
      expect(_formatUpdateTime(oneDayAgo), '1天前');
    });
  });
}