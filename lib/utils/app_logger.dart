/// 前端日志工具类
/// 统一管理前端日志记录

import 'dart:developer' as developer;
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 日志级别枚举
enum LogLevel {
  debug(0),
  info(1),
  warning(2),
  error(3);
  
  final int value;
  const LogLevel(this.value);
}

class AppLogger {
  static const String _tag = 'FishingWeather';
  static bool _enableConsoleLog = true;
  static bool _enableFileLog = false;
  static LogLevel _minLevel = LogLevel.debug;
  static File? _logFile;
  
  /// 初始化日志系统
  static Future<void> init({
    bool enableConsoleLog = true,
    bool enableFileLog = false,
    LogLevel minLevel = LogLevel.debug,
    String logDirectory = '/logs',
  }) async {
    _enableConsoleLog = enableConsoleLog;
    _enableFileLog = enableFileLog;
    _minLevel = minLevel;
    
    if (_enableFileLog) {
      await _initLogFile(logDirectory);
    }
    
    info(
      '日志系统初始化完成',
      details: {
        'consoleLog': enableConsoleLog,
        'fileLog': enableFileLog,
        'minLevel': minLevel.toString(),
      },
    );
  }
  
  /// 初始化日志文件
  static Future<void> _initLogFile(String directory) async {
    try {
      final dir = Directory(directory);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      
      final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
      _logFile = File('$directory/app_$dateStr.log');
      
      // 检查文件大小，如果超过10MB则创建新文件
      if (await _logFile!.exists()) {
        final size = await _logFile!.length();
        if (size > 10 * 1024 * 1024) {
          final timeStr = DateFormat('HH-mm-ss').format(DateTime.now());
          _logFile = File('$directory/app_${dateStr}_$timeStr.log');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('初始化日志文件失败: $e');
      }
    }
  }
  
  /// 写入日志文件
  static Future<void> _writeToFile(String level, String message, {Map<String, dynamic>? details}) async {
    if (!_enableFileLog || _logFile == null) return;
    
    try {
      final timestamp = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(DateTime.now());
      var logEntry = '[$timestamp] [$level] $message';
      
      if (details != null) {
        logEntry += '\nDetails: ${details.toString()}';
      }
      
      logEntry += '\n';
      
      await _logFile!.writeAsString(logEntry, mode: FileMode.append);
    } catch (e) {
      if (kDebugMode) {
        print('写入日志文件失败: $e');
      }
    }
  }
  
  /// 调试日志
  static void debug(String message, {Map<String, dynamic>? details, String? tag}) {
    if (_minLevel.value > LogLevel.debug.value) return;
    
    final fullTag = tag != null ? '$_tag.$tag' : _tag;
    if (_enableConsoleLog && kDebugMode) {
      developer.log('🐛 $message', name: fullTag, level: 500);
    }
    
    _writeToFile('DEBUG', message, details: details);
  }
  
  /// 信息日志
  static void info(String message, {Map<String, dynamic>? details, String? tag}) {
    if (_minLevel.value > LogLevel.info.value) return;
    
    final fullTag = tag != null ? '$_tag.$tag' : _tag;
    if (_enableConsoleLog) {
      developer.log('ℹ️ $message', name: fullTag, level: 800);
    }
    
    _writeToFile('INFO', message, details: details);
  }
  
  /// 警告日志
  static void warning(String message, {Map<String, dynamic>? details, String? tag}) {
    if (_minLevel.value > LogLevel.warning.value) return;
    
    final fullTag = tag != null ? '$_tag.$tag' : _tag;
    if (_enableConsoleLog) {
      developer.log('⚠️ $message', name: fullTag, level: 900);
    }
    
    _writeToFile('WARNING', message, details: details);
  }
  
  /// 错误日志
  static void error(String message, {Object? error, StackTrace? stackTrace, Map<String, dynamic>? details, String? tag}) {
    if (_minLevel.value > LogLevel.error.value) return;
    
    final fullTag = tag != null ? '$_tag.$tag' : _tag;
    if (_enableConsoleLog) {
      developer.log(
        '❌ $message',
        name: fullTag,
        level: 1000,
        error: error,
        stackTrace: stackTrace,
      );
    }
    
    final errorDetails = <String, dynamic>{};
    if (details != null) {
      errorDetails.addAll(details);
    }
    if (error != null) {
      errorDetails['error'] = error.toString();
    }
    
    _writeToFile('ERROR', message, details: errorDetails);
  }
  
  /// API调用日志
  static void logApiCall({
    required String method,
    required String endpoint,
    required int statusCode,
    required Duration duration,
    Map<String, dynamic>? requestData,
    Map<String, dynamic>? responseData,
    String? userId,
    String? error,
  }) {
    final details = <String, dynamic>{
      'method': method,
      'endpoint': endpoint,
      'statusCode': statusCode,
      'duration': duration.inMilliseconds,
    };
    
    if (requestData != null) {
      details['request'] = requestData;
    }
    if (responseData != null) {
      details['response'] = responseData;
    }
    if (userId != null) {
      details['userId'] = userId;
    }
    if (error != null) {
      details['error'] = error;
    }
    
    if (statusCode >= 400) {
      AppLogger.error('API调用失败: $method $endpoint', details: details, tag: 'API');
    } else {
      AppLogger.info('API调用成功: $method $endpoint', details: details, tag: 'API');
    }
  }
  
  /// 用户操作日志
  static void logUserAction({
    required String action,
    required String userId,
    String? targetType,
    String? targetId,
    Map<String, dynamic>? details,
  }) {
    final logDetails = <String, dynamic>{
      'action': action,
      'userId': userId,
    };
    
    if (targetType != null) {
      logDetails['targetType'] = targetType;
    }
    if (targetId != null) {
      logDetails['targetId'] = targetId;
    }
    if (details != null) {
      logDetails['details'] = details;
    }
    
    info('用户操作: $action', details: logDetails, tag: 'USER');
  }
  
  /// 性能日志
  static void logPerformance({
    required String operation,
    required Duration duration,
    Map<String, dynamic>? details,
  }) {
    final perfDetails = <String, dynamic>{
      'operation': operation,
      'duration': duration.inMilliseconds,
    };
    
    if (details != null) {
      perfDetails.addAll(details);
    }
    
    if (duration.inMilliseconds > 1000) {
      warning('性能警告: $operation 耗时过长', details: perfDetails, tag: 'PERF');
    } else {
      debug('性能记录: $operation', details: perfDetails, tag: 'PERF');
    }
  }
  
  /// 获取日志文件
  static Future<List<File>> getLogFiles({String directory = '/logs'}) async {
    try {
      final dir = Directory(directory);
      if (!await dir.exists()) {
        return [];
      }
      
      final files = await dir.list().where((entity) => entity is File && entity.path.endsWith('.log')).cast<File>().toList();
      files.sort((a, b) => b.path.compareTo(a.path)); // 按文件名降序排列
      return files;
    } catch (e) {
      error('获取日志文件失败', error: e);
      return [];
    }
  }
  
  /// 清理旧日志文件
  static Future<void> cleanOldLogs({String directory = '/logs', int keepDays = 7}) async {
    try {
      final files = await getLogFiles(directory: directory);
      final cutoffDate = DateTime.now().subtract(Duration(days: keepDays));
      
      for (final file in files) {
        final stat = await file.stat();
        if (stat.modified.isBefore(cutoffDate)) {
          await file.delete();
          info('已删除旧日志文件: ${file.path}', tag: 'LOGGER');
        }
      }
    } catch (e) {
      error('清理日志文件失败', error: e);
    }
  }
}

/// 性能测量工具
class PerformanceTimer {
  final String _operation;
  final Map<String, dynamic>? _details;
  final DateTime _startTime;
  
  PerformanceTimer(this._operation, {Map<String, dynamic>? details})
      : _details = details,
        _startTime = DateTime.now();
  
  /// 停止计时并记录日志
  void stop({Map<String, dynamic>? additionalDetails}) {
    final duration = DateTime.now().difference(_startTime);
    final details = <String, dynamic>{};
    if (_details != null) {
      details.addAll(_details!);
    }
    if (additionalDetails != null) {
      details.addAll(additionalDetails);
    }
    
    AppLogger.logPerformance(
      operation: _operation,
      duration: duration,
      details: details.isNotEmpty ? details : null,
    );
  }
}