import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 检查位置服务是否启用
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('位置服务已禁用');
    }

    // 检查位置权限
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('位置权限被拒绝');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // 权限被永久拒绝，需要引导用户到设置中启用
      await openAppSettings();
      throw Exception('位置权限被永久拒绝，请在设置中启用');
    }

    // 获取当前位置
    try {
      // 首先尝试高精度定位
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 60),
      );
    } on TimeoutException {
      // 高精度超时，尝试中等精度
      try {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
          timeLimit: const Duration(seconds: 30),
        );
      } catch (e) {
        throw Exception('获取位置超时，请检查网络连接和GPS设置');
      }
    } catch (e) {
      throw Exception('获取位置失败: $e');
    }
  }
}
