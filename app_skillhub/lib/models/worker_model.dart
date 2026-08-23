class Worker {
  final int id;
  final int shopId;
  final String name;
  final String photoUrl;
  final String role;
  final String bio;
  final double rating;

  Worker({
    required this.id,
    this.shopId = 1,
    required this.name,
    required this.photoUrl,
    this.role = 'Profissional',
    this.bio = '',
    this.rating = 5.0,
  });

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      shopId: json['shop_id'] != null ? int.parse(json['shop_id'].toString()) : 1,
      name: json['name'] ?? '',
      photoUrl: json['photo_url'] ?? 'https://randomuser.me/api/portraits/men/32.jpg',
      role: json['role'] ?? 'Profissional',
      bio: json['bio'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shop_id': shopId,
      'name': name,
      'photo_url': photoUrl,
      'role': role,
      'bio': bio,
      'rating': rating,
    };
  }
}