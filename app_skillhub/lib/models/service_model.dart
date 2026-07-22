import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceModel {
  final String id;
  final String name;
  final double price;
  final int durationMinutes;
  final String description;
  final bool isActive;

  ServiceModel({
    required this.id,
    required this.name,
    required this.price,
    required this.durationMinutes,
    this.description = '',
    this.isActive = true,
  });

  factory ServiceModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ServiceModel(
      id: doc.id,
      name: data['name'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      durationMinutes: (data['durationMinutes'] as num?)?.toInt() ?? 30,
      description: data['description'] ?? '',
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'durationMinutes': durationMinutes,
      'description': description,
      'isActive': isActive,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}