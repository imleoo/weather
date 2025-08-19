import 'package:flutter/material.dart';

class AnimationUtils {
  // 渐变背景效果
  static BoxDecoration gradientBackground(Color baseColor) {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          baseColor,
          baseColor.withOpacity(0.7),
          Colors.white,
        ],
      ),
    );
  }

  // 玻璃效果背景
  static BoxDecoration glassEffect({Color? color}) {
    return BoxDecoration(
      color: (color ?? Colors.white).withOpacity(0.2),
      borderRadius: BorderRadius.circular(15),
      border: Border.all(
        color: Colors.white.withOpacity(0.3),
        width: 1.5,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: 1,
        ),
      ],
    );
  }

  // 卡片装饰
  static BoxDecoration cardDecoration({Color? color}) {
    return BoxDecoration(
      color: color ?? Colors.white,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  // 天气详情项装饰
  static BoxDecoration weatherDetailDecoration(Color color) {
    return BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color.withOpacity(0.3)),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.05),
          blurRadius: 5,
          spreadRadius: 1,
        ),
      ],
    );
  }
}
