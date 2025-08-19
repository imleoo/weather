import 'dart:io';
import 'package:flutter/material.dart';

void main() {
  runApp(const SaveIconApp());
}

class SaveIconApp extends StatelessWidget {
  const SaveIconApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Save Icon',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SaveIconScreen(),
    );
  }
}

class SaveIconScreen extends StatefulWidget {
  const SaveIconScreen({Key? key}) : super(key: key);

  @override
  _SaveIconScreenState createState() => _SaveIconScreenState();
}

class _SaveIconScreenState extends State<SaveIconScreen> {
  final TextEditingController _urlController = TextEditingController();
  String _status = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Save Icon from URL'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '请将图标图片拖放到下方区域或粘贴图片URL:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _urlController,
              decoration: const InputDecoration(
                labelText: '图片URL',
                hintText: '输入图片URL或拖放图片到此处',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveIconFromUrl,
                  child: const Text('保存图标'),
                ),
                const SizedBox(width: 16),
                if (_isLoading) const CircularProgressIndicator(),
              ],
            ),
            const SizedBox(height: 16),
            Text(_status),
            const SizedBox(height: 32),
            const Text(
              '或者手动保存图片:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              '1. 将图片保存为: assets/images/app_icon.png\n'
              '2. 将前景图片保存为: assets/images/app_icon_foreground.png\n'
              '3. 确保图片尺寸至少为512x512像素',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _checkFilesAndRunIconGenerator();
              },
              child: const Text('检查文件并生成图标'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveIconFromUrl() async {
    if (_urlController.text.isEmpty) {
      setState(() {
        _status = '请输入URL';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _status = '正在下载图片...';
    });

    try {
      // 创建目录
      final directory = Directory('assets/images');
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // 下载图片
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(_urlController.text));
      final response = await request.close();
      final bytes = await response.fold<List<int>>(
        <int>[],
        (previous, element) => previous..addAll(element),
      );

      // 保存主图标
      final file = File('assets/images/app_icon.png');
      await file.writeAsBytes(bytes);

      // 保存前景图标 (相同图片)
      final foregroundFile = File('assets/images/app_icon_foreground.png');
      await foregroundFile.writeAsBytes(bytes);

      setState(() {
        _isLoading = false;
        _status = '图片已保存到:\n'
            'assets/images/app_icon.png\n'
            'assets/images/app_icon_foreground.png';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _status = '保存失败: $e';
      });
    }
  }

  Future<void> _checkFilesAndRunIconGenerator() async {
    setState(() {
      _isLoading = true;
      _status = '检查文件...';
    });

    try {
      final mainIcon = File('assets/images/app_icon.png');
      final foregroundIcon = File('assets/images/app_icon_foreground.png');

      if (!await mainIcon.exists()) {
        setState(() {
          _status = '错误: assets/images/app_icon.png 不存在';
          _isLoading = false;
        });
        return;
      }

      if (!await foregroundIcon.exists()) {
        setState(() {
          _status = '错误: assets/images/app_icon_foreground.png 不存在';
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _status = '文件检查通过，请运行以下命令生成图标:\n'
            'flutter pub run flutter_launcher_icons';
      });
    } catch (e) {
      setState(() {
        _status = '检查失败: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
