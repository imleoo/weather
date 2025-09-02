import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/fishing_spot_model.dart';
import '../services/social_share_service.dart';
import '../utils/app_logger.dart';

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
  final List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    // If currentLocation is provided, use it instead of getting location
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
  }

  Future<void> _getCurrentLocation() async {
    if (!widget.showCurrentLocation) return;

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
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.fishing_weather.app',
            ),
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
        if (_isLoadingLocation)
          const Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
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