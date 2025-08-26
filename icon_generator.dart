import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'fishing_icon.dart';

void main() {
  runApp(const IconGeneratorApp());
}

class IconGeneratorApp extends StatelessWidget {
  const IconGeneratorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Icon Generator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const IconGeneratorScreen(),
    );
  }
}

class IconGeneratorScreen extends StatefulWidget {
  const IconGeneratorScreen({super.key});

  @override
  _IconGeneratorScreenState createState() => _IconGeneratorScreenState();
}

class _IconGeneratorScreenState extends State<IconGeneratorScreen> {
  final GlobalKey _globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fishing Forecast Icon Generator'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RepaintBoundary(
              key: _globalKey,
              child: Container(
                width: 512,
                height: 512,
                color: Colors.white,
                child: const Center(
                  child: FishingIcon(
                    size: 400,
                    color: Color(0xFF1976D2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _captureAndSavePng,
              child: const Text('Generate Icon'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _captureAndSavePng() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();

        // 保存文件
        final directory = Directory('assets/images');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        final file = File('assets/images/app_icon.png');
        await file.writeAsBytes(pngBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Icon saved to assets/images/app_icon.png')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate icon: $e')),
      );
    }
  }
}
