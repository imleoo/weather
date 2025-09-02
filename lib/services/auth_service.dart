import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _baseUrl = 'http://192.168.28.126:8000/api'; // 后端API地址
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  static String? _authToken;
  static User? _currentUser;

  // 登录
  static Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Handle both login and registration token formats
      final token = data['access_token'] ?? data['token'] as String;
      final user = User.fromJson(data['user']);

      // 保存token和用户信息
      await _saveAuthData(token, user);

      _authToken = token;
      _currentUser = user;

      return user;
    } else {
      final errorData = jsonDecode(response.body);
      // Handle both FastAPI 'detail' and custom 'message' formats
      final errorMessage = errorData['detail'] ?? errorData['message'] ?? '登录失败';
      throw Exception(errorMessage);
    }
  }

  // 注册
  static Future<User> register(String email, String password, String nickname) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'password': password,
        'nickname': nickname,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      // Handle both login and registration token formats
      final token = data['access_token'] ?? data['token'] as String;
      final user = User.fromJson(data['user']);

      // 保存token和用户信息
      await _saveAuthData(token, user);

      _authToken = token;
      _currentUser = user;

      return user;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? '注册失败');
    }
  }

  // 获取当前用户
  static Future<User?> getCurrentUser() async {
    if (_currentUser != null) {
      return _currentUser;
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userDataString = prefs.getString(_userKey);

    if (token != null && userDataString != null) {
      try {
        final userData = jsonDecode(userDataString);
        _authToken = token;
        _currentUser = User.fromJson(userData);
        return _currentUser;
      } catch (e) {
        // 如果解析用户数据失败，清除本地存储
        await logout();
        return null;
      }
    }

    return null;
  }

  // 更新用户信息
  static Future<User> updateProfile({
    required String nickname,
    required String bio,
  }) async {
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('未登录');
    }

    final response = await http.put(
      Uri.parse('$_baseUrl/auth/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'nickname': nickname,
        'bio': bio,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = User.fromJson(data['user']);

      // 更新本地用户信息
      await _saveUserData(user);
      _currentUser = user;

      return user;
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? '更新失败');
    }
  }

  // 修改密码
  static Future<void> changePassword(String oldPassword, String newPassword) async {
    final token = await _getAuthToken();
    if (token == null) {
      throw Exception('未登录');
    }

    final response = await http.put(
      Uri.parse('$_baseUrl/auth/password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'old_password': oldPassword,
        'new_password': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? '密码修改失败');
    }
  }

  // 退出登录
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);

    _authToken = null;
    _currentUser = null;
  }

  // 获取当前的认证token
  static Future<String?> _getAuthToken() async {
    if (_authToken != null) {
      return _authToken;
    }

    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // 保存认证数据
  static Future<void> _saveAuthData(String token, User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  // 保存用户数据
  static Future<void> _saveUserData(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  // 获取认证头部
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await _getAuthToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 检查是否已登录
  static Future<bool> isLoggedIn() async {
    final token = await _getAuthToken();
    return token != null;
  }
}