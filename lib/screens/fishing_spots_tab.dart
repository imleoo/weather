import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import '../models/fishing_spot_model.dart';
import '../services/api_service.dart';
import '../l10n/app_localizations.dart';

class FishingSpotsTab extends StatefulWidget {
  const FishingSpotsTab({super.key});

  @override
  State<FishingSpotsTab> createState() => _FishingSpotsTabState();
}

class _FishingSpotsTabState extends State<FishingSpotsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<FishingSpot> _nearbySpots = [];
  bool _isLoading = false;

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
                // TODO: 实现导航功能
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('导航功能待实现')),
                );
              },
            ),
            onTap: () {
              // TODO: 显示钓点详情
              _showSpotDetails(spot);
            },
          ),
        );
      },
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
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              spot.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('${AppLocalizations.distance}: ${spot.distance.toStringAsFixed(1)}km'),
            const SizedBox(height: 8),
            if (spot.description.isNotEmpty) ...[
              Text(
                AppLocalizations.description,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(spot.description),
              const SizedBox(height: 16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: 实现导航
                  },
                  child: Text(AppLocalizations.navigate),
                ),
                OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.close),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _shareCurrentSpot() {
    // TODO: 实现分享当前钓点
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('钓点分享功能待实现')),
    );
  }
}