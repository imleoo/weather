import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:weather/services/api_service.dart';
import 'package:weather/services/auth_service.dart';
import 'package:weather/models/fishing_spot_model.dart';
import 'package:weather/models/fish_catch_model.dart';
import 'dart:convert';

// 生成模拟HTTP客户端
@GenerateMocks([http.Client])
import 'api_service_test.mocks.dart'; // 这个文件将由build_runner生成

// 模拟AuthService
class MockAuthService {
  static Future<Map<String, String>> getAuthHeaders() async {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer test_token',
    };
  }
}

void main() {
  // 初始化Flutter绑定
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ApiService Tests', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      // 注入模拟客户端
      ApiService.injectHttpClient(mockClient);

      // 模拟健康检查API调用
      when(mockClient.get(Uri.parse('http://192.168.28.126:8000/api/health')))
          .thenAnswer((_) async => http.Response('{"status": "healthy"}', 200));
    });

    test('shareCurrentSpot should return a FishingSpot on success', () async {
      // 准备模拟响应
      final responseJson = {
        'fishing_spot': {
          'id': 1,
          'name': 'Test Spot',
          'description': 'A test fishing spot',
          'latitude': 39.9,
          'longitude': 116.4,
          'created_at': '2025-09-02T12:00:00Z',
          'user_id': 1,
          'user_name': 'testuser',
        }
      };

      // 配置模拟客户端的行为
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
            jsonEncode(responseJson),
            201,
          ));

      // 执行测试
      final result = await ApiService.shareCurrentSpot(
        name: 'Test Spot',
        description: 'A test fishing spot',
        latitude: 39.9,
        longitude: 116.4,
      );

      // 验证结果
      expect(result, isA<FishingSpot>());
      expect(result.name, 'Test Spot');
      expect(result.description, 'A test fishing spot');
      expect(result.latitude, 39.9);
      expect(result.longitude, 116.4);
    });

    test('shareCurrentSpot should throw an exception on failure', () async {
      // 配置模拟客户端的行为
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
            jsonEncode({'message': 'Failed to share spot'}),
            400,
          ));

      // 执行测试并验证异常
      expect(
        () => ApiService.shareCurrentSpot(
          name: 'Test Spot',
          description: 'A test fishing spot',
          latitude: 39.9,
          longitude: 116.4,
        ),
        throwsException,
      );
    });

    test('shareFishCatch should return a FishCatch on success', () async {
      // 准备模拟响应
      final responseJson = {
        'fish_catch': {
          'id': 1,
          'fish_type': 'Bass',
          'weight': 2.5,
          'description': 'A nice bass',
          'latitude': 39.9,
          'longitude': 116.4,
          'location_name': 'Test Lake',
          'image_url': 'http://example.com/image.jpg',
          'created_at': '2025-09-02T12:00:00Z',
          'user_id': 1,
          'user_name': 'testuser',
          'likes_count': 0,
          'comments_count': 0,
          'liked_by_me': false,
        }
      };

      // 配置模拟客户端的行为
      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
            jsonEncode(responseJson),
            201,
          ));

      // 执行测试
      final result = await ApiService.shareFishCatch(
        fishType: 'Bass',
        weight: 2.5,
        description: 'A nice bass',
        latitude: 39.9,
        longitude: 116.4,
        locationName: 'Test Lake',
        imageFile: null,
      );

      // 验证结果
      expect(result, isA<FishCatch>());
      expect(result.fishType, 'Bass');
      expect(result.weight, 2.5);
      expect(result.description, 'A nice bass');
      expect(result.locationName, 'Test Lake');
    });

    test('getNearbyFishingSpots should return a list of fishing spots',
        () async {
      // 准备模拟响应
      final responseJson = {
        'spots': [
          {
            'id': 1,
            'name': 'Spot 1',
            'description': 'Description 1',
            'latitude': 39.9,
            'longitude': 116.4,
            'created_at': '2025-09-02T12:00:00Z',
            'user_id': 1,
            'user_name': 'user1',
          },
          {
            'id': 2,
            'name': 'Spot 2',
            'description': 'Description 2',
            'latitude': 39.8,
            'longitude': 116.5,
            'created_at': '2025-09-02T12:00:00Z',
            'user_id': 2,
            'user_name': 'user2',
          },
        ]
      };

      // 配置模拟客户端的行为
      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
            jsonEncode(responseJson),
            200,
          ));

      // 执行测试
      final result = await ApiService.getNearbyFishingSpots(
        latitude: 39.9,
        longitude: 116.4,
        radius: 10.0,
      );

      // 验证结果
      expect(result, isA<List<FishingSpot>>());
      expect(result.length, 2);
      expect(result[0].name, 'Spot 1');
      expect(result[1].name, 'Spot 2');
    });

    test('checkApiConnection should return true on success', () async {
      // 配置模拟客户端的行为
      when(mockClient.get(any))
          .thenAnswer((_) async => http.Response('{"status": "healthy"}', 200));

      // 执行测试
      final result = await ApiService.checkApiConnection();

      // 验证结果
      expect(result, true);
    });

    test('checkApiConnection should return false on failure', () async {
      // 配置模拟客户端的行为
      when(mockClient.get(any)).thenThrow(Exception('Connection failed'));

      // 执行测试
      final result = await ApiService.checkApiConnection();

      // 验证结果
      expect(result, false);
    });
  });
}
