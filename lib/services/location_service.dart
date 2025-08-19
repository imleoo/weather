import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 检查位置服务是否启用
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('位置服务已禁用');
    }

    // 检查位置权限
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('位置权限被拒绝');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // 权限被永久拒绝，需要引导用户到设置中启用
      await openAppSettings();
      return Future.error('位置权限被永久拒绝，请在设置中启用');
    }

    // 获取当前位置
    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return Future.error('获取位置失败: $e');
    }
  }
}
