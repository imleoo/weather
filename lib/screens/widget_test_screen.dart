import 'package:flutter/material.dart';
import 'package:weather/services/widget_service.dart';

class WidgetTestScreen extends StatefulWidget {
  const WidgetTestScreen({super.key});

  @override
  State<WidgetTestScreen> createState() => _WidgetTestScreenState();
}

class _WidgetTestScreenState extends State<WidgetTestScreen> {
  String _status = '准备测试小部件...';

  @override
  void initState() {
    super.initState();
    _testWidgetData();
  }

  Future<void> _testWidgetData() async {
    setState(() {
      _status = '正在测试小部件数据保存...';
    });

    try {
      // 创建测试数据
      final testData = {
        'temperature': '25°C',
        'weatherCondition': '晴',
        'location': '北京',
        'fishingScore': 4,
        'fishingAdvice': '适宜',
        'updateTime': '刚刚',
      };

      // 保存测试数据
      await WidgetService.updateWidgetData();
      
      setState(() {
        _status = '小部件数据保存成功！\n\n测试数据：\n温度: ${testData['temperature']}\n天气: ${testData['weatherCondition']}\n位置: ${testData['location']}\n钓鱼指数: ${testData['fishingScore']}/5\n建议: ${testData['fishingAdvice']}';
      });
    } catch (e) {
      setState(() {
        _status = '小部件数据保存失败: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('小部件测试'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.widgets,
                size: 64,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              Text(
                _status,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _testWidgetData,
                child: const Text('重新测试'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}