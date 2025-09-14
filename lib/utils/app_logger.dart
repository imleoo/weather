import 'dart:developer' as developer;

/// 简化的应用日志工具
class AppLogger {
  static const String _tag = 'FishingWeather';

  static void debug(String message, {String? tag}) {
    final fullTag = tag != null ? '$_tag.$tag' : _tag;
    developer.log('🐛 $message', name: fullTag, level: 500);
  }

  static void info(String message, {String? tag}) {
    final fullTag = tag != null ? '$_tag.$tag' : _tag;
    developer.log('ℹ️ $message', name: fullTag, level: 800);
  }

  static void warning(String message, {String? tag}) {
    final fullTag = tag != null ? '$_tag.$tag' : _tag;
    developer.log('⚠️ $message', name: fullTag, level: 900);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace, String? tag}) {
    final fullTag = tag != null ? '$_tag.$tag' : _tag;
    developer.log(
      '❌ $message',
      name: fullTag,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}