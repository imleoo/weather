import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meta/meta.dart'; // 添加meta包导入
import '../models/fishing_spot_model.dart';
import '../models/fish_catch_model.dart';
import 'auth_service.dart';

class ApiService {
  // 使用相对路径，避免CORS问题
  static const String _baseUrl = '/api'; // 相对路径，避免CORS问题

  // 用于测试的HTTP客户端
  static http.Client _httpClient = http.Client();

  // 注入HTTP客户端（用于测试）
  @visibleForTesting
  static void injectHttpClient(http.Client client) {
    _httpClient = client;
  }

  // 调试信息
  static void _logApiCall(String method, String endpoint,
      {dynamic body, dynamic response, dynamic error}) {
    print('=== API调用 ===');
    print('方法: $method');
    print('端点: $endpoint');
    if (body != null) print('请求体: $body');
    if (response != null) print('响应: $response');
    if (error != null) print('错误: $error');
    print('=============');
  }

  /// 检查API地址是否可访问
  static Future<bool> checkApiConnection() async {
    try {
      print('=== 检查API连接 ===');
      print('API地址: $_baseUrl/health');
      final response = await _httpClient.get(Uri.parse('$_baseUrl/health'));
      print('响应状态码: ${response.statusCode}');
      print('响应内容: ${response.body}');
      return response.statusCode == 200;
    } catch (e) {
      print('API连接检查失败: $e');
      return false;
    }
  }

  // 处理HTTP响应，包括401错误
  static dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 401) {
      // 清除无效的认证信息
      AuthService.logout();
      throw Exception('登录已过期，请重新登录');
    }

    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? '请求失败');
    }
  }

  // 获取附近的钓点
  static Future<List<FishingSpot>> getNearbyFishingSpots({
    required double latitude,
    required double longitude,
    double radius = 10.0, // 默认搜索半径10公里
  }) async {
    final headers = await AuthService.getAuthHeaders();

    final response = await _httpClient.get(
      Uri.parse(
          '$_baseUrl/fishing-spots/nearby?lat=$latitude&lng=$longitude&radius=$radius'),
      headers: headers,
    );

    final data = _handleResponse(response);
    final spots = (data['spots'] as List)
        .map((json) => FishingSpot.fromJson(json))
        .toList();
    return spots;
  }

  // 分享当前钓点
  static Future<FishingSpot> shareCurrentSpot({
    required String name,
    required String description,
    required double latitude,
    required double longitude,
  }) async {
    try {
      // 先检查API连接
      print('=== 开始分享钓点 ===');
      print('检查API连接...');
      final isConnected = await checkApiConnection();
      if (!isConnected) {
        print('API连接失败，无法分享钓点');
        throw Exception('无法连接到服务器，请检查网络连接');
      }
      print('API连接正常');

      // 获取认证头部
      print('获取认证头部...');
      final headers = await AuthService.getAuthHeaders();
      print('认证头部获取成功');

      // 准备请求数据
      final requestBody = {
        'name': name,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
      };
      final encodedBody = jsonEncode(requestBody);

      print('=== 分享钓点请求 ===');
      print('URL: $_baseUrl/fishing-spots/');
      print('Headers: $headers');
      print('Has Authorization: ${headers.containsKey('Authorization')}');
      print('请求体: $encodedBody');

      // 发送请求
      print('发送POST请求...');
      final response = await _httpClient.post(
        Uri.parse('$_baseUrl/fishing-spots/'),
        headers: headers,
        body: encodedBody,
      );

      // 处理响应
      print('收到响应，状态码: ${response.statusCode}');
      print('响应内容: ${response.body}');

      final data = _handleResponse(response);
      print('响应处理成功，返回钓点数据');
      return FishingSpot.fromJson(data['fishing_spot']);
    } catch (e) {
      print('分享钓点失败: $e');
      rethrow;
    }
  }

  // 获取鱼获分享列表
  static Future<List<FishCatch>> getFishCatches({
    int page = 1,
    int limit = 20,
  }) async {
    final headers = await AuthService.getAuthHeaders();

    final response = await http.get(
      Uri.parse('$_baseUrl/fish-catches?page=$page&limit=$limit'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final catches = (data['catches'] as List)
          .map((json) => FishCatch.fromJson(json))
          .toList();
      return catches;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? '获取鱼获分享失败');
    }
  }

  // 分享鱼获
  static Future<FishCatch> shareFishCatch({
    required String fishType,
    required double weight,
    required String description,
    required double latitude,
    required double longitude,
    required String locationName,
    XFile? imageFile,  // 明确指定为XFile类型
  }) async {
    final headers = await AuthService.getAuthHeaders();

    // 如果有图片，先上传图片
    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await _uploadImage(imageFile);
    }

    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/fish-catches'),
      headers: headers,
      body: jsonEncode({
        'fish_type': fishType,
        'weight': weight,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'location_name': locationName,
        'image_url': imageUrl,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return FishCatch.fromJson(data['fish_catch']);
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? '分享鱼获失败');
    }
  }

  // 点赞鱼获
  static Future<void> likeFishCatch(int fishCatchId) async {
    final headers = await AuthService.getAuthHeaders();

    final response = await http.post(
      Uri.parse('$_baseUrl/fish-catches/$fishCatchId/like'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? '点赞失败');
    }
  }

  // 取消点赞
  static Future<void> unlikeFishCatch(int fishCatchId) async {
    final headers = await AuthService.getAuthHeaders();

    final response = await http.delete(
      Uri.parse('$_baseUrl/fish-catches/$fishCatchId/like'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? '取消点赞失败');
    }
  }

  // 评论鱼获
  static Future<void> commentOnFishCatch(
      int fishCatchId, String content) async {
    final headers = await AuthService.getAuthHeaders();

    final response = await http.post(
      Uri.parse('$_baseUrl/fish-catches/$fishCatchId/comments'),
      headers: headers,
      body: jsonEncode({
        'content': content,
      }),
    );

    if (response.statusCode != 201) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? '评论失败');
    }
  }

  // 获取用户的鱼获列表
  static Future<List<FishCatch>> getUserFishCatches({
    int? userId,
    int page = 1,
    int limit = 20,
  }) async {
    final headers = await AuthService.getAuthHeaders();
    final userIdParam = userId != null ? '/$userId' : '/me';

    final response = await http.get(
      Uri.parse(
          '$_baseUrl/users$userIdParam/fish-catches?page=$page&limit=$limit'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final catches = (data['catches'] as List)
          .map((json) => FishCatch.fromJson(json))
          .toList();
      return catches;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? '获取用户鱼获失败');
    }
  }

  // 获取用户的钓点列表
  static Future<List<FishingSpot>> getUserFishingSpots({
    int? userId,
    int page = 1,
    int limit = 20,
  }) async {
    final headers = await AuthService.getAuthHeaders();
    final userIdParam = userId != null ? '/$userId' : '/me';

    final response = await http.get(
      Uri.parse(
          '$_baseUrl/users$userIdParam/fishing-spots?page=$page&limit=$limit'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final spots = (data['spots'] as List)
          .map((json) => FishingSpot.fromJson(json))
          .toList();
      return spots;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? '获取用户钓点失败');
    }
  }

  // 获取用户点赞的分享列表
  static Future<List<FishCatch>> getLikedFishCatches({
    int page = 1,
    int limit = 20,
  }) async {
    final headers = await AuthService.getAuthHeaders();

    final response = await http.get(
      Uri.parse('$_baseUrl/users/me/liked-catches?page=$page&limit=$limit'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final catches = (data['catches'] as List)
          .map((json) => FishCatch.fromJson(json))
          .toList();
      return catches;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? '获取点赞列表失败');
    }
  }

  // 上传图片（私有方法）
  static Future<String> _uploadImage(XFile? imageFile) async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload/image'),
      );

      request.headers.addAll(headers);

      // Handle XFile upload
      if (imageFile != null) {
        // For both web and mobile, read as bytes
        final bytes = await imageFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: imageFile.name,
            contentType: MediaType('image', 'jpeg'), // Add content type
          ),
        );
      } else {
        throw Exception('图片文件为空');
      }

      print('上传图片: ${imageFile.name} (${request.files.first.length} bytes)');

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('图片上传响应: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['image_url'] as String;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? '图片上传失败');
      }
    } catch (e) {
      print('图片上传错误: $e');
      throw Exception('图片上传失败: $e');
    }
  }

  // 删除鱼获
  static Future<void> deleteFishCatch(int fishCatchId) async {
    final headers = await AuthService.getAuthHeaders();

    final response = await http.delete(
      Uri.parse('$_baseUrl/fish-catches/$fishCatchId'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? '删除鱼获失败');
    }
  }

  // 删除钓点
  static Future<void> deleteFishingSpot(int fishingSpotId) async {
    final headers = await AuthService.getAuthHeaders();

    final response = await http.delete(
      Uri.parse('$_baseUrl/fishing-spots/$fishingSpotId'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? '删除钓点失败');
    }
  }
}
