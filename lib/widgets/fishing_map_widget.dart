import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/fishing_spot_model.dart';
import '../services/social_share_service.dart';
import '../utils/app_logger.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:io';

class FishingMapWidget extends StatefulWidget {
  final List<FishingSpot> fishingSpots;
  final Function(FishingSpot)? onSpotTap;
  final bool showCurrentLocation;
  final Function(LatLng)? onMapTap;
  final LatLng? currentLocation;

  const FishingMapWidget({
    super.key,
    required this.fishingSpots,
    this.onSpotTap,
    this.showCurrentLocation = true,
    this.onMapTap,
    this.currentLocation,
  });

  @override
  State<FishingMapWidget> createState() => _FishingMapWidgetState();
}

class _FishingMapWidgetState extends State<FishingMapWidget> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  bool _isLoadingLocation = true;
  bool _isLoadingTiles = true;
  final List<Marker> _markers = [];
  bool _hasNetworkError = false;
  String _errorMessage = '';
  int _retryCount = 0;
  static const int _maxRetries = 3;
  bool _useAlternativeTiles = false;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    AppLogger.info('开始初始化地图', tag: 'MAP');
    
    // 检查网络连接
    final hasNetwork = await _checkNetworkConnectivity();
    if (!hasNetwork) {
      AppLogger.warning('网络连接不可用，将显示离线模式', tag: 'MAP');
      setState(() {
        _hasNetworkError = true;
        _errorMessage = '网络连接不可用，将显示离线地图';
        _isLoadingLocation = false;
        _isLoadingTiles = false;
      });
    }
    
    // 初始化位置
    if (widget.currentLocation != null) {
      setState(() {
        _currentLocation = widget.currentLocation;
        _isLoadingLocation = false;
      });
      _updateMarkers();
    } else {
      _getCurrentLocation();
      _updateMarkers();
    }
  }

  @override
  void didUpdateWidget(FishingMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fishingSpots != widget.fishingSpots) {
      _updateMarkers();
    }
    if (oldWidget.currentLocation != widget.currentLocation && widget.currentLocation != null) {
      setState(() {
        _currentLocation = widget.currentLocation;
      });
      _updateMarkers();
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!widget.showCurrentLocation) return;

    // 如果已经有网络错误，不需要获取位置
    if (_hasNetworkError) {
      AppLogger.info('网络错误状态，跳过位置获取', tag: 'MAP');
      return;
    }

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // 检查位置权限
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppLogger.warning('位置服务未启用', tag: 'MAP');
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          AppLogger.warning('位置权限被拒绝', tag: 'MAP');
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        AppLogger.warning('位置权限被永久拒绝', tag: 'MAP');
        setState(() {
          _isLoadingLocation = false;
        });
        return;
      }

      // 获取当前位置
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;
      });

      AppLogger.info('位置获取成功', details: {'lat': position.latitude, 'lng': position.longitude}, tag: 'MAP');

      // 移动地图到当前位置
      _moveToCurrentLocation();
    } catch (e) {
      AppLogger.error('获取位置失败', error: e, tag: 'MAP');
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  void _updateMarkers() {
    _markers.clear();

    // 添加钓点标记
    for (final spot in widget.fishingSpots) {
      _markers.add(
        Marker(
          point: LatLng(spot.latitude, spot.longitude),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => widget.onSpotTap?.call(spot),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.place,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    spot.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 添加当前位置标记
    if (_currentLocation != null && widget.showCurrentLocation) {
      _markers.add(
        Marker(
          point: _currentLocation!,
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(
              Icons.my_location,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      );
    }
  }

  void _moveToCurrentLocation() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 如果有网络错误，显示错误界面
    if (_hasNetworkError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              '地图加载失败',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _retryMapLoading,
              icon: const Icon(Icons.refresh),
              label: Text(_retryCount < _maxRetries ? '重试 ($_retryCount/$_maxRetries)' : '重新加载'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                // 显示离线地图（仅显示标记，无底图）
                _showOfflineMap();
              },
              child: const Text('使用离线视图'),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentLocation ?? const LatLng(39.9042, 116.4074),
            initialZoom: 13.0,
            minZoom: 3.0,
            maxZoom: 18.0,
            onTap: (tapPosition, point) {
              widget.onMapTap?.call(point);
            },
          ),
          children: [
            _buildTileLayer(),
            MarkerLayer(markers: _markers),
          ],
        ),
        // 定位按钮
        if (widget.showCurrentLocation)
          Positioned(
            right: 16,
            bottom: 100,
            child: FloatingActionButton(
              onPressed: _moveToCurrentLocation,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.my_location),
            ),
          ),
        // 加载指示器
        if (_isLoadingLocation || _isLoadingTiles)
          Container(
            color: Colors.white.withOpacity(0.8),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    _isLoadingLocation ? '正在获取位置...' : '正在加载地图...',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTileLayer() {
    if (_hasNetworkError) {
      // 网络错误时显示空白底图
      return Container(color: Colors.grey[100]);
    }
    
    return TileLayer(
      urlTemplate: _useAlternativeTiles 
          ? 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png'
          : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.fishing_weather.app',
      tileProvider: NetworkTileProvider(),
      errorTileCallback: (tile, error, stackTrace) {
        AppLogger.error('地图瓦片加载失败', 
          error: error, 
          details: {'tile': tile.toString()},
          tag: 'MAP'
        );
        
        // 检查是否是网络错误
        if (error.toString().contains('SocketException') || 
            error.toString().contains('Network is unreachable') ||
            error.toString().contains('Connection failed')) {
          if (!_hasNetworkError) {
            if (_useAlternativeTiles) {
              // 如果备选瓦片也失败，显示错误
              setState(() {
                _hasNetworkError = true;
                _errorMessage = '网络连接失败，无法加载地图';
              });
            } else {
              // 尝试使用备选瓦片
              AppLogger.info('切换到备选瓦片服务器', tag: 'MAP');
              setState(() {
                _useAlternativeTiles = true;
              });
            }
          }
        }
      },
    );
  }

  Future<bool> _checkNetworkConnectivity() async {
    try {
      // 尝试连接OpenStreetMap服务器
      final response = await http.get(
        Uri.parse('https://tile.openstreetmap.org/0/0/0.png'),
      ).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        AppLogger.info('网络连接正常，可以使用OpenStreetMap', tag: 'MAP');
        return true;
      }
    } catch (e) {
      AppLogger.warning('网络连接检查失败: $e', tag: 'MAP');
      
      // 尝试备选服务器
      try {
        final altResponse = await http.get(
          Uri.parse('https://a.basemaps.cartocdn.com/rastertiles/voyager/0/0/0.png'),
        ).timeout(const Duration(seconds: 3));
        
        if (altResponse.statusCode == 200) {
          AppLogger.info('备选服务器可用，切换到CartoDB', tag: 'MAP');
          setState(() {
            _useAlternativeTiles = true;
          });
          return true;
        }
      } catch (altError) {
        AppLogger.error('备选服务器也失败: $altError', tag: 'MAP');
      }
    }
    
    return false;
  }

  void _showOfflineMap() {
    // 显示离线地图（仅显示标记，无底图）
    AppLogger.info('切换到离线地图视图', tag: 'MAP');
    setState(() {
      _hasNetworkError = false;
      _isLoadingTiles = false;
    });
  }

  void _retryMapLoading() {
    if (_retryCount < _maxRetries) {
      _retryCount++;
      AppLogger.info('重试加载地图', details: {'retry': _retryCount}, tag: 'MAP');
    } else {
      _retryCount = 0; // 重置重试计数
    }
    
    setState(() {
      _hasNetworkError = false;
      _isLoadingLocation = true;
    });
    
    // 重新获取位置并重置地图
    _getCurrentLocation();
    _updateMarkers();
  }
}

class FishingSpotDetailSheet extends StatelessWidget {
  final FishingSpot spot;
  final VoidCallback? onNavigate;
  final VoidCallback? onClose;

  const FishingSpotDetailSheet({
    super.key,
    required this.spot,
    this.onNavigate,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.place, color: Colors.green, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  spot.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                onPressed: onClose ?? () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.directions,
            '距离',
            '${spot.distance.toStringAsFixed(1)} km',
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            Icons.location_on,
            '坐标',
            '${spot.latitude.toStringAsFixed(6)}, ${spot.longitude.toStringAsFixed(6)}',
          ),
          if (spot.description.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              '描述',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(spot.description),
          ],
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onNavigate,
                  icon: const Icon(Icons.directions),
                  label: const Text('导航'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    SocialShareService.showShareOptions(
                      context: context,
                      shareType: 'fishing_spot',
                      shareData: {
                        'spotName': spot.name,
                        'description': spot.description,
                        'latitude': spot.latitude,
                        'longitude': spot.longitude,
                      },
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('分享'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onClose ?? () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  label: const Text('关闭'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.grey[600],
          ),
        ),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }
}