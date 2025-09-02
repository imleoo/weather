import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import '../providers/weather_provider.dart';
import '../models/fishing_spot_model.dart';
import '../services/api_service.dart';
import '../services/social_share_service.dart';
import '../l10n/app_localizations.dart';
import '../widgets/fishing_map_widget.dart';
import '../utils/app_logger.dart';
import 'package:url_launcher/url_launcher.dart';

class FishingSpotsTab extends StatefulWidget {
  const FishingSpotsTab({super.key});

  @override
  State<FishingSpotsTab> createState() => _FishingSpotsTabState();
}

class _FishingSpotsTabState extends State<FishingSpotsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<FishingSpot> _nearbySpots = [];
  bool _isLoading = false;
  bool _showMap = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadNearbySpots();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNearbySpots() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
      final location = weatherProvider.weatherData?.nearestArea;
      
      if (location != null) {
        final spots = await ApiService.getNearbyFishingSpots(
          latitude: double.parse(location.latitude),
          longitude: double.parse(location.longitude),
        );
        setState(() {
          _nearbySpots = spots;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载附近钓点失败: $e')),
        );
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
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_nearbySpots.isEmpty) {
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
            ElevatedButton(
              onPressed: _loadNearbySpots,
              child: Text(AppLocalizations.refresh),
            ),
          ],
        ),
      );
    }

    if (_showMap) {
      // 地图视图
      return FishingMapWidget(
        fishingSpots: _nearbySpots,
        onSpotTap: (spot) {
          _showSpotDetails(spot);
        },
        onMapTap: (point) {
          AppLogger.info(
            '点击地图',
            details: {'lat': point.latitude, 'lng': point.longitude},
            tag: 'FISHING_SPOTS',
          );
        },
      );
    } else {
      // 列表视图
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
                  Text('${AppLocalizations.distance}: ${spot.distance.toStringAsFixed(1)}km'),
                  if (spot.description.isNotEmpty)
                    Text(spot.description, maxLines: 2, overflow: TextOverflow.ellipsis),
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
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                            Text('${AppLocalizations.location}: ${location.areaName}'),
                            Text('${AppLocalizations.coordinates}: ${location.latitude}, ${location.longitude}'),
                            const SizedBox(height: 16),
                            TextField(
                              decoration: InputDecoration(
                                labelText: AppLocalizations.spotDescription,
                                hintText: AppLocalizations.describeThisSpot,
                                border: const OutlineInputBorder(),
                              ),
                              maxLines: 3,
                              onChanged: (value) {
                                // TODO: 保存描述
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
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${spot.latitude},${spot.longitude}';
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

  void _shareCurrentSpot() {
    // TODO: 实现分享当前钓点
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('钓点分享功能待实现')),
    );
  }
}