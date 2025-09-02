import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/fishing_spot_model.dart';
import '../models/fish_catch_model.dart';
import 'auth_service.dart';

class ApiService {
  static const String _baseUrl = 'http://192.168.28.126:8000/api'; // 后端API地址

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
    
    final response = await http.get(
      Uri.parse('$_baseUrl/fishing-spots/nearby?lat=$latitude&lng=$longitude&radius=$radius'),
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
    final headers = await AuthService.getAuthHeaders();
    print('=== 分享钓点请求 ===');
    print('URL: $_baseUrl/fishing-spots/');
    print('Headers: $headers');
    print('Has Authorization: ${headers.containsKey('Authorization')}');
    
    final response = await http.post(
      Uri.parse('$_baseUrl/fishing-spots/'),
      headers: headers,
      body: jsonEncode({
        'name': name,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
      }),
    );

    final data = _handleResponse(response);
    return FishingSpot.fromJson(data['fishing_spot']);
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
    dynamic imageFile,
  }) async {
    final headers = await AuthService.getAuthHeaders();
    
    // 如果有图片，先上传图片
    String? imageUrl;
    if (imageFile != null) {
      imageUrl = await _uploadImage(imageFile);
    }

    final response = await http.post(
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
  static Future<void> commentOnFishCatch(int fishCatchId, String content) async {
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
      Uri.parse('$_baseUrl/users$userIdParam/fish-catches?page=$page&limit=$limit'),
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
      Uri.parse('$_baseUrl/users$userIdParam/fishing-spots?page=$page&limit=$limit'),
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
  static Future<String> _uploadImage(dynamic imageFile) async {
    final headers = await AuthService.getAuthHeaders();
    
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/upload/image'),
    );
    
    request.headers.addAll(headers);
    
    // 根据平台处理图片文件
    if (imageFile is XFile) {
      // Web平台 - XFile
      final bytes = await imageFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: imageFile.name,
        ),
      );
    } else {
      // 移动端 - File
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['image_url'] as String;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? '图片上传失败');
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