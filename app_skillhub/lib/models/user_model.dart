import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // 'client' ou 'owner'
  final String? businessId;
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    this.businessId,
    this.createdAt,
  });

  // Converte o documento do Firestore para o modelo Dart
  factory UserModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      role: data['role'] ?? 'client',
      businessId: data['businessId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  // Converte para Map caso precises de atualizar dados
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'role': role,
      'businessId': businessId,
      'createdAt': createdAt,
    };
  }
}