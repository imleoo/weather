import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/weather_provider.dart';
import '../models/fish_catch_model.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/social_share_service.dart';
import '../l10n/app_localizations.dart';
import 'dart:io';

class ShareTab extends StatefulWidget {
  const ShareTab({super.key});

  @override
  State<ShareTab> createState() => _ShareTabState();
}

class _ShareTabState extends State<ShareTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<FishCatch> _fishCatches = [];
  bool _isLoading = false;

  final TextEditingController _fishTypeController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFishCatches();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fishTypeController.dispose();
    _weightController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadFishCatches() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final catches = await ApiService.getFishCatches();
      setState(() {
        _fishCatches = catches;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('加载鱼获信息失败: $e')),
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
          AppLocalizations.share,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: AppLocalizations.shareCatch),
            Tab(text: AppLocalizations.communityShares),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildShareCatch(),
          _buildCommunityShares(),
        ],
      ),
    );
  }

  Widget _buildShareCatch() {
    return SingleChildScrollView(
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
                  Text(
                    AppLocalizations.shareFishCatch,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // 鱼类型输入
                  TextField(
                    controller: _fishTypeController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.fishType,
                      hintText: AppLocalizations.enterFishType,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.water),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 重量输入
                  TextField(
                    controller: _weightController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.weight,
                      hintText: AppLocalizations.enterWeight,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.monitor_weight),
                      suffixText: 'kg',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16),

                  // 描述输入
                  TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.description,
                      hintText: AppLocalizations.shareYourExperience,
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.description),
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),

                  // 图片选择
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_selectedImage!.path),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.broken_image,
                                        size: 48, color: Colors.grey),
                                    SizedBox(height: 8),
                                    Text('图片预览不可用',
                                        style: TextStyle(color: Colors.grey)),
                                  ],
                                );
                              },
                            ),
                          )
                        : InkWell(
                            onTap: _pickImage,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.add_a_photo,
                                    size: 48, color: Colors.grey),
                                const SizedBox(height: 8),
                                Text(
                                  AppLocalizations.addPhoto,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 16),

                  // 位置信息显示
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.3)),
                    ),
                    child: Consumer<WeatherProvider>(
                      builder: (context, weatherProvider, child) {
                        final location =
                            weatherProvider.weatherData?.nearestArea;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    color: Colors.blue),
                                const SizedBox(width: 8),
                                Text(
                                  AppLocalizations.currentLocation,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (location != null) ...[
                              Text(
                                  '${AppLocalizations.location}: ${location.areaName}'),
                              Text(
                                  '${AppLocalizations.coordinates}: ${location.latitude}, ${location.longitude}'),
                            ] else ...[
                              Text(AppLocalizations.locationNotAvailable),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 分享按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _shareFishCatch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : Text(
                              AppLocalizations.shareNow,
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityShares() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_fishCatches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.water_drop, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.noCommunityShares,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFishCatches,
              child: Text(AppLocalizations.refresh),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _fishCatches.length,
      itemBuilder: (context, index) {
        final fishCatch = _fishCatches[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Text(
                        fishCatch.userName.substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fishCatch.userName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            fishCatch.timeAgo,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (fishCatch.imageUrl != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      fishCatch.imageUrl!,
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                Row(
                  children: [
                    const Icon(Icons.water, size: 16, color: Colors.blue),
                    const SizedBox(width: 4),
                    Text(
                      '${fishCatch.fishType} • ${fishCatch.weight}kg',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (fishCatch.description.isNotEmpty) ...[
                  Text(fishCatch.description),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.red),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        fishCatch.locationName,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    TextButton.icon(
                      onPressed: () => _likeFishCatch(fishCatch.id),
                      icon: Icon(
                        fishCatch.isLiked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: fishCatch.isLiked ? Colors.red : Colors.grey,
                      ),
                      label: Text('${fishCatch.likes}'),
                    ),
                    TextButton.icon(
                      onPressed: () => _commentOnFishCatch(fishCatch),
                      icon: const Icon(Icons.comment_outlined,
                          color: Colors.grey),
                      label: Text('${fishCatch.comments}'),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        SocialShareService.showShareOptions(
                          context: context,
                          shareType: 'fish_catch',
                          shareData: {
                            'fishType': fishCatch.fishType,
                            'weight': fishCatch.weight,
                            'description': fishCatch.description,
                            'location': fishCatch.locationName,
                            'imageUrl': fishCatch.imageUrl,
                          },
                        );
                      },
                      icon: const Icon(Icons.share, color: Colors.grey),
                      label: const Text('分享'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          // Always use XFile for consistency
          _selectedImage = image;
        });
      }
    } catch (e) {
      print('图片选择错误: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('选择图片失败: $e')),
      );
    }
  }

  void _shareFishCatch() async {
    // 检查是否已登录，如果未登录会自动跳转到登录页面
    // 登录成功后会自动执行分享
    if (!await AuthService.ensureLoggedIn(context, onSuccess: () {
      _shareFishCatchInternal();
    })) {
      return;
    }

    _shareFishCatchInternal();
  }

  void _shareFishCatchInternal() async {
    if (_fishTypeController.text.isEmpty || _weightController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.pleaseFillRequired)),
      );
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final weatherProvider =
          Provider.of<WeatherProvider>(context, listen: false);
      final location = weatherProvider.weatherData?.nearestArea;

      await ApiService.shareFishCatch(
        fishType: _fishTypeController.text,
        weight: double.tryParse(_weightController.text) ?? 0,
        description: _descriptionController.text,
        latitude: location != null ? double.parse(location.latitude) : 0,
        longitude: location != null ? double.parse(location.longitude) : 0,
        locationName: location?.areaName ?? '',
        imageFile: _selectedImage,
      );

      // 清空表单
      _fishTypeController.clear();
      _weightController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedImage = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.shareSuccess)),
      );

      // 刷新社区分享列表
      _loadFishCatches();

      // 切换到社区分享标签页
      _tabController.animateTo(1);

      // 显示分享选项
      WidgetsBinding.instance.addPostFrameCallback((_) {
        SocialShareService.showShareOptions(
          context: context,
          shareType: 'fish_catch',
          shareData: {
            'fishType': _fishTypeController.text,
            'weight': double.tryParse(_weightController.text) ?? 0,
            'description': _descriptionController.text,
            'location': location?.areaName ?? '',
          },
        );
      });
    } catch (e) {
      print('分享鱼获失败: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${AppLocalizations.shareFailed}: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _likeFishCatch(int fishCatchId) async {
    // 检查是否已登录，如果未登录会自动跳转到登录页面
    if (!await AuthService.ensureLoggedIn(context)) {
      return;
    }

    // TODO: 实现点赞功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('点赞功能待实现')),
    );
  }

  void _commentOnFishCatch(FishCatch fishCatch) async {
    // 检查是否已登录，如果未登录会自动跳转到登录页面
    if (!await AuthService.ensureLoggedIn(context)) {
      return;
    }

    // TODO: 实现评论功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('评论功能待实现')),
    );
  }
}
