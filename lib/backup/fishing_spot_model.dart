class FishingSpot {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String description;
  final int userId;
  final String userName;
  final DateTime createdAt;
  final double distance; // 距离当前位置的距离（km）

  FishingSpot({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.userId,
    required this.userName,
    required this.createdAt,
    this.distance = 0.0,
  });

  factory FishingSpot.fromJson(Map<String, dynamic> json) {
    return FishingSpot(
      id: json['id'] as int,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      userId: json['user_id'] as int,
      userName: json['user_name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'description': description,
      'user_id': userId,
      'user_name': userName,
      'created_at': createdAt.toIso8601String(),
      'distance': distance,
    };
  }

  FishingSpot copyWith({
    int? id,
    String? name,
    double? latitude,
    double? longitude,
    String? description,
    int? userId,
    String? userName,
    DateTime? createdAt,
    double? distance,
  }) {
    return FishingSpot(
      id: id ?? this.id,
      name: name ?? this.name,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      description: description ?? this.description,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      createdAt: createdAt ?? this.createdAt,
      distance: distance ?? this.distance,
    );
  }
}