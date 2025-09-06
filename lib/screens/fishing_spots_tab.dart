import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../providers/weather_provider.dart';
import '../models/fishing_spot_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/location_service.dart';
import '../services/social_share_service_new.dart';
import '../l10n/app_localizations.dart';
import '../widgets/fishing_map_widget.dart';
import '../utils/app_logger.dart';
import 'package:url_launcher/url_launcher.dart';
import 'login_screen.dart';

class FishingSpotsTab extends StatefulWidget {
  const FishingSpotsTab({super.key});

  @override
  State<FishingSpotsTab> createState() => _FishingSpotsTabState();
}

class _FishingSpotsTabState extends State<FishingSpotsTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<FishingSpot> _nearbySpots = [];
  bool _isLoading = false;
  bool _showMap = true; // 默认显示地图
  String _spotDescription = '';
  LatLng? _currentLocation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _getCurrentLocation();
    _loadNearbySpots();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final locationService = LocationService();
      final position = await locationService.getCurrentLocation();
      if (position != null) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (e) {
      // 忽略位置获取错误，使用天气数据作为备选
      print('获取位置失败: $e');
    }
  }

  Future<void> _loadNearbySpots() async {
    setState(() {
      _isLoading = true;
    });

    try {
      double? lat, lng;

      // 首先尝试从当前位置获取
      if (_currentLocation != null) {
        lat = _currentLocation!.latitude;
        lng = _currentLocation!.longitude;
      } else {
        // 否则从天气数据获取
        final weatherProvider =
            Provider.of<WeatherProvider>(context, listen: false);
        final location = weatherProvider.weatherData?.nearestArea;
        if (location != null) {
          lat = double.parse(location.latitude);
          lng = double.parse(location.longitude);
        }
      }

      if (lat != null && lng != null) {
        final spots = await ApiService.getNearbyFishingSpots(
          latitude: lat,
          longitude: lng,
        );
        setState(() {
          _nearbySpots = spots;
        });
        
        // 如果有钓点，记录日志
        if (spots.isNotEmpty) {
          AppLogger.info(
            '加载附近钓点成功',
            details: {
              'count': spots.length,
              'location': '$lat, $lng',
              'spots': spots.map((s) => s.name).toList(),
            },
            tag: 'FISHING_SPOTS',
          );
        } else {
          AppLogger.info(
            '附近没有钓点',
            details: {'location': '$lat, $lng'},
            tag: 'FISHING_SPOTS',
          );
        }
      }
    } catch (e) {
      print('加载附近钓点失败: $e');
      if (mounted) {
        // 检查是否是认证错误
        if (e.toString().contains('登录已过期')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('登录已过期，请重新登录')),
          );
          // 延迟后跳转到登录页面
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LoginScreen(),
                ),
              );
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('加载附近钓点失败: $e')),
          );
        }
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.fishingSpots,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppLocalizations.nearbySpots),
            Tab(text: AppLocalizations.shareCurrentSpot),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
        actions: [
          // 地图/列表切换按钮
          IconButton(
            icon: Icon(_showMap ? Icons.list : Icons.map),
            onPressed: () {
              setState(() {
                _showMap = !_showMap;
              });
              AppLogger.info(
                '切换钓点视图',
                details: {'view': _showMap ? 'map' : 'list'},
                tag: 'FISHING_SPOTS',
              );
            },
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNearbySpots(),
          _buildShareCurrentSpot(),
        ],
      ),
    );
  }

  Widget _buildNearbySpots() {
    return RefreshIndicator(
      onRefresh: _loadNearbySpots,
      child: _buildNearbySpotsContent(),
    );
  }

  Widget _buildNearbySpotsContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 默认显示地图视图，包含所有钓点标记
    if (_showMap) {
      return Stack(
        children: [
          FishingMapWidget(
            fishingSpots: _nearbySpots,
            currentLocation: _currentLocation,
            onSpotTap: (spot) {
              _showSpotDetails(spot);
            },
            onMapTap: (point) {
              AppLogger.info(
                '点击地图',
                details: {'lat': point.latitude, 'lng': point.longitude},
                tag: 'FISHING_SPOTS',
              );
              // 显示分享钓点选项
              _showShareSpotOption(point);
            },
          ),
          // 在地图上显示钓点数量指示器
          if (_nearbySpots.isNotEmpty)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.place, color: Colors.green, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '${_nearbySpots.length} 个钓点',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    }

    // 列表视图 - 当有钓点时显示详细列表
    if (_nearbySpots.isNotEmpty) {
      return ListView.builder(
        itemCount: _nearbySpots.length,
        itemBuilder: (context, index) {
          final spot = _nearbySpots[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.place, color: Colors.white),
              ),
              title: Text(spot.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      '${AppLocalizations.distance}: ${spot.distance.toStringAsFixed(1)}km'),
                  if (spot.description.isNotEmpty)
                    Text(spot.description,
                        maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.directions),
                onPressed: () {
                  _launchMapsNavigation(spot);
                },
              ),
              onTap: () {
                _showSpotDetails(spot);
              },
            ),
          );
        },
      );
    }

    // 当没有钓点时的占位显示
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.location_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.noNearbySpots,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          Text(
            '当前位置: ${_currentLocation?.latitude.toStringAsFixed(4)}, ${_currentLocation?.longitude.toStringAsFixed(4)}',
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadNearbySpots,
            child: Text(AppLocalizations.refresh),
          ),
        ],
      ),
    );
  }

  Widget _buildShareCurrentSpot() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.my_location, color: Colors.green),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.currentLocation,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Consumer<WeatherProvider>(
                    builder: (context, weatherProvider, child) {
                      final location = weatherProvider.weatherData?.nearestArea;
                      if (location != null) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${AppLocalizations.location}: ${location.areaName}'),
                            Text(
                                '${AppLocalizations.coordinates}: ${location.latitude}, ${location.longitude}'),
                            const SizedBox(height: 16),
                            TextField(
                              decoration: InputDecoration(
                                labelText: AppLocalizations.spotDescription,
                                hintText: AppLocalizations.describeThisSpot,
                                border: const OutlineInputBorder(),
                              ),
                              maxLines: 3,
                              onChanged: (value) {
                                setState(() {
                                  _spotDescription = value;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  _shareCurrentSpot();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text(AppLocalizations.shareThisSpot),
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Text(AppLocalizations.locationNotAvailable);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSpotDetails(FishingSpot spot) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FishingSpotDetailSheet(
        spot: spot,
        onNavigate: () {
          Navigator.pop(context);
          _launchMapsNavigation(spot);
        },
      ),
    );
  }

  Future<void> _launchMapsNavigation(FishingSpot spot) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${spot.latitude},${spot.longitude}';
    AppLogger.info(
      '启动导航',
      details: {
        'spot': spot.name,
        'lat': spot.latitude,
        'lng': spot.longitude,
        'url': url,
      },
      tag: 'FISHING_SPOTS',
    );

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法启动地图应用')),
      );
    }
  }

  void _shareCurrentSpot() async {
    print('=== 分享按钮被点击 ===');
    // 检查是否已登录，如果未登录会自动跳转到登录页面
    // 登录成功后会自动执行分享
    await AuthService.ensureLoggedIn(context, onSuccess: () {
      print('=== 登录检查通过，准备分享 ===');
      _shareCurrentSpotInternal();
    });
  }

  void _showShareSpotOption(LatLng point) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '分享这个位置作为钓点？',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              '坐标: ${point.latitude.toStringAsFixed(6)}, ${point.longitude.toStringAsFixed(6)}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _shareCustomSpot(point);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('分享钓点'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('取消'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _shareCustomSpot(LatLng point) {
    // 切换到分享标签页并设置位置
    _tabController.animateTo(1);
    // 可以在这里预填充位置信息
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('请在分享页面填写钓点信息')),
    );
  }

  void _shareCurrentSpotInternal() async {
    print('=== 开始分享钓点 ===');
    print('当前位置: $_currentLocation');
    print('钓点描述: "${_spotDescription.trim()}"');

    if (_currentLocation == null) {
      print('错误: 当前位置为空');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('无法获取当前位置，请检查定位权限')),
      );
      return;
    }

    if (_spotDescription.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请输入钓点描述')),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      await ApiService.shareCurrentSpot(
        name: '我的钓点',
        latitude: _currentLocation!.latitude,
        longitude: _currentLocation!.longitude,
        description: _spotDescription,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('钓点分享成功！')),
      );

      // 保存描述，因为后面会清空
      final String savedDescription = _spotDescription;

      // 清空描述并刷新列表
      setState(() {
        _spotDescription = '';
      });
      _loadNearbySpots();

      // 显示社交分享选项
      print('=== 准备显示社交分享选项 ===');
      try {
        SocialShareService.showShareOptions(
          context: context,
          shareType: 'fishing_spot',
          shareData: {
            'spotName': '我的钓点',
            'description': savedDescription,
            'latitude': _currentLocation!.latitude,
            'longitude': _currentLocation!.longitude,
          },
        );
        print('=== 社交分享选项显示成功 ===');
      } catch (e) {
        print('=== 显示社交分享选项失败: $e ===');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('显示分享选项失败: ${e.toString()}')),
        );
      }
    } catch (e) {
      print('分享钓点失败: $e');
      // 检查是否是认证错误
      if (e.toString().contains('登录已过期')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('登录已过期，请重新登录')),
        );
        // 延迟后跳转到登录页面
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            );
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('分享失败: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
