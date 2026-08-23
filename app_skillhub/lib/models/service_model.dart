class ServiceModel {
  final int id;
  final int shopId;
  final String name;
  final double price;
  final int durationMinutes;
  final String description;

  ServiceModel({
    required this.id,
    this.shopId = 1,
    required this.name,
    required this.price,
    required this.durationMinutes,
    this.description = '',
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      shopId: json['shop_id'] != null ? int.parse(json['shop_id'].toString()) : 1,
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: json['duration_minutes'] != null
          ? int.parse(json['duration_minutes'].toString())
          : 30,
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shop_id': shopId,
      'name': name,
      'price': price,
      'duration_minutes': durationMinutes,
      'description': description,
    };
  }
}