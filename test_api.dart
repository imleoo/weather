import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  // 测试中文API请求
  print('测试中文API请求...');
  try {
    final response = await http.get(
      Uri.parse('https://wttr.in/beijing?format=j1&lang=zh'),
      headers: {'Accept': 'application/json'},
    ).timeout(const Duration(seconds: 30));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as Map<String, dynamic>;
      final currentCondition = jsonData['current_condition'][0] as Map<String, dynamic>;
      
      print('完整当前条件数据:');
      print(currentCondition);
      print('\nlang_zh字段: ${currentCondition['lang_zh']}');
      print('weatherDesc字段: ${currentCondition['weatherDesc']}');
      
      if (currentCondition['lang_zh'] != null) {
        final langZh = currentCondition['lang_zh'] as List;
        if (langZh.isNotEmpty) {
          final chineseDesc = langZh[0]['value'];
          print('中文天气描述: $chineseDesc');
        }
      }
      
      if (currentCondition['weatherDesc'] != null) {
        final weatherDesc = currentCondition['weatherDesc'] as List;
        if (weatherDesc.isNotEmpty) {
          final englishDesc = weatherDesc[0]['value'];
          print('英文天气描述: $englishDesc');
        }
      }
    } else {
      print('请求失败: ${response.statusCode}');
    }
  } catch (e) {
    print('请求异常: $e');
  }
}