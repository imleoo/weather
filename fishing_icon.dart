import 'package:flutter/material.dart';

class FishingIcon extends StatelessWidget {
  final double size;
  final Color color;

  const FishingIcon({
    super.key,
    this.size = 200.0,
    this.color = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: FishingIconPainter(color: color),
    );
  }
}

class FishingIconPainter extends CustomPainter {
  final Color color;

  FishingIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.45;

    // 绘制背景圆形
    final bgPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // 绘制波浪
    final wavePaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.03;

    final wavePath1 = Path();
    wavePath1.moveTo(center.dx - radius * 0.7, center.dy + radius * 0.2);
    wavePath1.quadraticBezierTo(center.dx - radius * 0.3,
        center.dy - radius * 0.2, center.dx, center.dy + radius * 0.2);
    wavePath1.quadraticBezierTo(
        center.dx + radius * 0.3,
        center.dy + radius * 0.6,
        center.dx + radius * 0.7,
        center.dy + radius * 0.2);
    canvas.drawPath(wavePath1, wavePaint);

    // 绘制鱼钩
    final hookPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.04
      ..strokeCap = StrokeCap.round;

    final hookPath = Path();
    hookPath.moveTo(center.dx, center.dy - radius * 0.7);
    hookPath.lineTo(center.dx, center.dy + radius * 0.1);
    hookPath.addArc(
        Rect.fromCircle(
            center:
                Offset(center.dx + radius * 0.15, center.dy + radius * 0.25),
            radius: radius * 0.15),
        3.14,
        4.5);
    canvas.drawPath(hookPath, hookPaint);

    // 绘制鱼
    final fishPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final fishPath = Path();
    final fishCenter =
        Offset(center.dx - radius * 0.3, center.dy + radius * 0.3);
    fishPath.moveTo(fishCenter.dx - radius * 0.15, fishCenter.dy);
    fishPath.quadraticBezierTo(fishCenter.dx, fishCenter.dy - radius * 0.1,
        fishCenter.dx + radius * 0.15, fishCenter.dy);
    fishPath.quadraticBezierTo(fishCenter.dx, fishCenter.dy + radius * 0.1,
        fishCenter.dx - radius * 0.15, fishCenter.dy);

    // 鱼尾
    fishPath.moveTo(fishCenter.dx - radius * 0.15, fishCenter.dy);
    fishPath.lineTo(
        fishCenter.dx - radius * 0.25, fishCenter.dy - radius * 0.1);
    fishPath.lineTo(
        fishCenter.dx - radius * 0.25, fishCenter.dy + radius * 0.1);
    fishPath.close();

    canvas.drawPath(fishPath, fishPaint);

    // 鱼眼
    final eyePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawCircle(
        Offset(fishCenter.dx + radius * 0.05, fishCenter.dy - radius * 0.03),
        radius * 0.02,
        eyePaint);

    // 绘制云朵
    final cloudPaint = Paint()
      ..color = Colors.white.withOpacity(0.7)
      ..style = PaintingStyle.fill;

    final cloudCenter =
        Offset(center.dx + radius * 0.4, center.dy - radius * 0.4);
    canvas.drawCircle(cloudCenter, radius * 0.12, cloudPaint);
    canvas.drawCircle(
        Offset(cloudCenter.dx - radius * 0.1, cloudCenter.dy + radius * 0.05),
        radius * 0.1,
        cloudPaint);
    canvas.drawCircle(
        Offset(cloudCenter.dx + radius * 0.1, cloudCenter.dy + radius * 0.05),
        radius * 0.1,
        cloudPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
