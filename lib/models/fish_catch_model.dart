class FishCatch {
  final int id;
  final String fishType;
  final double weight;
  final String description;
  final double latitude;
  final double longitude;
  final String locationName;
  final String? imageUrl;
  final int userId;
  final String userName;
  final DateTime createdAt;
  final int likes;
  final int comments;
  final bool isLiked;

  FishCatch({
    required this.id,
    required this.fishType,
    required this.weight,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.locationName,
    this.imageUrl,
    required this.userId,
    required this.userName,
    required this.createdAt,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
  });

  factory FishCatch.fromJson(Map<String, dynamic> json) {
    return FishCatch(
      id: json['id'] as int,
      fishType: json['fish_type'] as String,
      weight: (json['weight'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      locationName: json['location_name'] as String,
      imageUrl: json['image_url'] as String?,
      userId: json['user_id'] as int,
      userName: json['user_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      isLiked: json['is_liked'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fish_type': fishType,
      'weight': weight,
      'description': description,
      'latitude': latitude,
      'longitude': longitude,
      'location_name': locationName,
      'image_url': imageUrl,
      'user_id': userId,
      'user_name': userName,
      'created_at': createdAt.toIso8601String(),
      'likes': likes,
      'comments': comments,
      'is_liked': isLiked,
    };
  }

  // 计算发布时间距现在的时间差，返回友好的时间格式
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}天前';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}小时前';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  FishCatch copyWith({
    int? id,
    String? fishType,
    double? weight,
    String? description,
    double? latitude,
    double? longitude,
    String? locationName,
    String? imageUrl,
    int? userId,
    String? userName,
    DateTime? createdAt,
    int? likes,
    int? comments,
    bool? isLiked,
  }) {
    return FishCatch(
      id: id ?? this.id,
      fishType: fishType ?? this.fishType,
      weight: weight ?? this.weight,
      description: description ?? this.description,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationName: locationName ?? this.locationName,
      imageUrl: imageUrl ?? this.imageUrl,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      createdAt: createdAt ?? this.createdAt,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}