import 'package:cloud_firestore/cloud_firestore.dart';

class Worker {
  final String id;
  final String name;
  final String photoUrl;
  final String role; // ex: "Barbeiro Sénior"
  final String bio; // ex: "Especialista em degrade e barba tradicional"
  final double rating;
  final String shopId;

  Worker({
    required this.id,
    required this.name,
    required this.photoUrl,
    this.role = 'Profissional', // <--- Torna opcional com valor por defeito
    this.bio = '',
    required this.rating,
    required this.shopId,
  });

  // Converte DocumentSnapshot do Firestore para o modelo Worker
  factory Worker.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Worker(
      id: doc.id,
      name: data['name'] ?? '',
      photoUrl: data['photoUrl'] ?? 'https://randomuser.me/api/portraits/men/32.jpg',
      role: data['role'] ?? 'Profissional',
      bio: data['bio'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
      shopId: data['shopId'] ?? '1',
    );
  }

  // Converte o modelo Worker para Map (guardar no Firestore)
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'photoUrl': photoUrl,
      'role': role,
      'bio': bio,
      'rating': rating,
      'shopId': shopId,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}

// --- DADOS DE TESTE (Fallback) ---
final List<Worker> mockWorkers = [
  Worker(
    id: 'w1',
    name: 'Carlos Tesoura',
    role: 'Mestre Barbeiro',
    bio: 'Mais de 10 anos de experiência em cortes clássicos.',
    rating: 4.9,
    shopId: '1',
    photoUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
  ),
  Worker(
    id: 'w2',
    name: 'André Navalha',
    role: 'Especialista',
    bio: 'Mestre em barboterapia e alinhamento de barba.',
    rating: 4.7,
    shopId: '1',
    photoUrl: 'https://randomuser.me/api/portraits/men/44.jpg',
  ),
  Worker(
    id: 'w3',
    name: 'Sofia Ink',
    role: 'Tatuadora',
    bio: 'Especializada em Realismo e Fineline.',
    rating: 5.0,
    shopId: '2',
    photoUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
  ),
];