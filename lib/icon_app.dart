import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:io';
import 'dart:typed_data';
import 'dart:math';

void main() {
  runApp(const IconApp());
}

class IconApp extends StatelessWidget {
  const IconApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fishing Forecast Icon',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const IconScreen(),
    );
  }
}

class IconScreen extends StatefulWidget {
  const IconScreen({Key? key}) : super(key: key);

  @override
  _IconScreenState createState() => _IconScreenState();
}

class _IconScreenState extends State<IconScreen> {
  final GlobalKey _iconKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fishing Forecast Icon'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            RepaintBoundary(
              key: _iconKey,
              child: Container(
                width: 512,
                height: 512,
                color: Colors.transparent,
                child: Center(
                  child: _buildFishingIcon(400),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveIcon,
              child: const Text('Save Icon'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFishingIcon(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Stack(
          children: [
            // 天空背景 - 渐变蓝色
            Container(
              width: size,
              height: size,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF87CEEB), // 浅蓝色
                    Color(0xFFADD8E6), // 淡蓝色
                  ],
                ),
              ),
            ),

            // 太阳
            Positioned(
              top: size * 0.15,
              left: size * 0.15,
              child: Container(
                width: size * 0.2,
                height: size * 0.2,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD700), // 金黄色
                  shape: BoxShape.circle,
                ),
                child: CustomPaint(
                  size: Size(size * 0.2, size * 0.2),
                  painter: SunRaysPainter(),
                ),
              ),
            ),

            // 水面
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: size * 0.3,
              child: CustomPaint(
                size: Size(size, size * 0.3),
                painter: WaterSurfacePainter(),
              ),
            ),

            // 鱼
            Positioned(
              top: size * 0.4,
              left: size * 0.25,
              child: CustomPaint(
                size: Size(size * 0.5, size * 0.3),
                painter: DetailedFishPainter(),
              ),
            ),

            // 钓鱼线
            CustomPaint(
              size: Size(size, size),
              painter: FishingLinePainter(),
            ),

            // 浮标
            Positioned(
              top: size * 0.35,
              right: size * 0.3,
              child: Container(
                width: size * 0.05,
                height: size * 0.05,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // 云朵
            Positioned(
              bottom: size * 0.15,
              right: size * 0.1,
              child: CustomPaint(
                size: Size(size * 0.3, size * 0.15),
                painter: CloudPainter(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveIcon() async {
    try {
      RenderRepaintBoundary boundary =
          _iconKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();

        // 保存文件
        final directory = Directory('assets/icon');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }

        final file = File('assets/icon/icon.png');
        await file.writeAsBytes(pngBytes);

        // 保存前景图标
        final foregroundFile = File('assets/icon/icon_foreground.png');
        await foregroundFile.writeAsBytes(pngBytes);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Icon saved to assets/icon/')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save icon: $e')),
      );
    }
  }
}

class WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.7);

    // 第一个波浪
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.6,
        size.width * 0.5, size.height * 0.7);

    // 第二个波浪
    path.quadraticBezierTo(
        size.width * 0.75, size.height * 0.8, size.width, size.height * 0.7);

    // 完成路径
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SunRaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.yellow.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;

    // 绘制8条光芒
    for (int i = 0; i < 8; i++) {
      final angle = i * pi / 4;
      final startX = center.dx + radius * 0.6 * cos(angle);
      final startY = center.dy + radius * 0.6 * sin(angle);
      final endX = center.dx + radius * 1.0 * cos(angle);
      final endY = center.dy + radius * 1.0 * sin(angle);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WaterSurfacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF87CEFA)
      ..style = PaintingStyle.fill;

    // 绘制水面
    final path = Path();
    path.moveTo(0, 0);

    // 创建波浪效果
    double waveHeight = size.height * 0.2;
    double waveWidth = size.width / 6; // 6个波浪

    for (int i = 0; i <= 6; i++) {
      if (i % 2 == 0) {
        path.quadraticBezierTo(
            waveWidth * i + waveWidth / 2, -waveHeight, waveWidth * (i + 1), 0);
      } else {
        path.quadraticBezierTo(
            waveWidth * i + waveWidth / 2, waveHeight, waveWidth * (i + 1), 0);
      }
    }

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);

    // 绘制水面上的细线
    final linePaint = Paint()
      ..color = Colors.white.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 绘制几条水波纹
    final line1 = Path();
    line1.moveTo(size.width * 0.2, size.height * 0.3);
    line1.quadraticBezierTo(size.width * 0.3, size.height * 0.2,
        size.width * 0.4, size.height * 0.3);
    canvas.drawPath(line1, linePaint);

    final line2 = Path();
    line2.moveTo(size.width * 0.6, size.height * 0.5);
    line2.quadraticBezierTo(size.width * 0.7, size.height * 0.4,
        size.width * 0.8, size.height * 0.5);
    canvas.drawPath(line2, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DetailedFishPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // 鱼身体
    final bodyPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.fill;

    final bodyPath = Path();
    bodyPath.moveTo(size.width * 0.2, size.height * 0.5);
    bodyPath.quadraticBezierTo(size.width * 0.1, size.height * 0.3,
        size.width * 0.3, size.height * 0.2);
    bodyPath.quadraticBezierTo(size.width * 0.7, size.height * 0.1,
        size.width * 0.8, size.height * 0.5);
    bodyPath.quadraticBezierTo(size.width * 0.7, size.height * 0.9,
        size.width * 0.3, size.height * 0.8);
    bodyPath.quadraticBezierTo(size.width * 0.1, size.height * 0.7,
        size.width * 0.2, size.height * 0.5);

    canvas.drawPath(bodyPath, bodyPaint);

    // 鱼鳍
    final finPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.fill;

    // 上鳍
    final topFinPath = Path();
    topFinPath.moveTo(size.width * 0.5, size.height * 0.2);
    topFinPath.quadraticBezierTo(size.width * 0.55, size.height * 0.05,
        size.width * 0.6, size.height * 0.2);
    canvas.drawPath(topFinPath, finPaint);

    // 下鳍
    final bottomFinPath = Path();
    bottomFinPath.moveTo(size.width * 0.5, size.height * 0.8);
    bottomFinPath.quadraticBezierTo(size.width * 0.55, size.height * 0.95,
        size.width * 0.6, size.height * 0.8);
    canvas.drawPath(bottomFinPath, finPaint);

    // 尾巴
    final tailPath = Path();
    tailPath.moveTo(size.width * 0.2, size.height * 0.5);
    tailPath.lineTo(size.width * 0.05, size.height * 0.3);
    tailPath.lineTo(size.width * 0.05, size.height * 0.7);
    tailPath.close();
    canvas.drawPath(tailPath, finPaint);

    // 鱼眼
    final eyePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.4),
        size.width * 0.05, eyePaint);

    // 鱼眼高光
    final eyeHighlightPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width * 0.77, size.height * 0.38),
        size.width * 0.015, eyeHighlightPaint);

    // 鱼鳞
    final scalePaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 绘制几行鱼鳞
    for (int row = 0; row < 3; row++) {
      for (int col = 0; col < 5; col++) {
        final scaleX = size.width * (0.3 + col * 0.1);
        final scaleY = size.height * (0.4 + row * 0.1);

        if (scaleX < size.width * 0.8 && scaleY < size.height * 0.7) {
          final scalePath = Path();
          scalePath.addArc(
              Rect.fromCenter(
                  center: Offset(scaleX, scaleY),
                  width: size.width * 0.1,
                  height: size.height * 0.1),
              pi,
              pi);
          canvas.drawPath(scalePath, scalePaint);
        }
      }
    }

    // 鱼嘴
    final mouthPaint = Paint()
      ..color = Colors.red.shade300
      ..style = PaintingStyle.fill;

    final mouthPath = Path();
    mouthPath.moveTo(size.width * 0.8, size.height * 0.5);
    mouthPath.quadraticBezierTo(size.width * 0.85, size.height * 0.55,
        size.width * 0.8, size.height * 0.6);
    canvas.drawPath(mouthPath, mouthPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FishingLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade400
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // 钓鱼线
    final path = Path();
    path.moveTo(size.width * 0.3, size.height * 0.1);
    path.quadraticBezierTo(size.width * 0.5, size.height * 0.2,
        size.width * 0.7, size.height * 0.35);

    canvas.drawPath(path, paint);

    // 钓鱼钩
    final hookPaint = Paint()
      ..color = Colors.amber.shade700
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final hookPath = Path();
    hookPath.moveTo(size.width * 0.3, size.height * 0.45);
    hookPath.addArc(
        Rect.fromCenter(
            center: Offset(size.width * 0.28, size.height * 0.48),
            width: size.width * 0.05,
            height: size.height * 0.05),
        -pi / 4,
        pi * 1.5);

    canvas.drawPath(hookPath, hookPaint);

    // 连接线和钩
    final connectPath = Path();
    connectPath.moveTo(size.width * 0.7, size.height * 0.35);
    connectPath.quadraticBezierTo(size.width * 0.5, size.height * 0.4,
        size.width * 0.3, size.height * 0.45);

    canvas.drawPath(connectPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CloudPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // 绘制云朵的几个圆形组合
    canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.6), size.width * 0.2, paint);
    canvas.drawCircle(
        Offset(size.width * 0.3, size.height * 0.5), size.width * 0.15, paint);
    canvas.drawCircle(
        Offset(size.width * 0.7, size.height * 0.5), size.width * 0.15, paint);
    canvas.drawCircle(
        Offset(size.width * 0.4, size.height * 0.4), size.width * 0.12, paint);
    canvas.drawCircle(
        Offset(size.width * 0.6, size.height * 0.4), size.width * 0.12, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
