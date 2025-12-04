class Worker {
  final String id;
  final String name;
  final String photoUrl;
  final String role; // ex: "Barbeiro Sénior"
  final double rating;
  final String shopId; // A que loja pertence

  Worker({
    required this.id,
    required this.name,
    required this.photoUrl,
    required this.role,
    required this.rating,
    required this.shopId,
  });
}

// --- DADOS DE TESTE (Para a Loja 1 e 2) ---
final List<Worker> mockWorkers = [
  // Barber King (Dourado)
  Worker(
    id: 'w1', name: 'Carlos Tesoura', role: 'Mestre Barbeiro', rating: 4.9, shopId: '1',
    photoUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
  ),
  Worker(
    id: 'w2', name: 'André Navalha', role: 'Especialista', rating: 4.7, shopId: '1',
    photoUrl: 'https://randomuser.me/api/portraits/men/44.jpg',
  ),
  
  // Ink Master (Tatuagens)
  Worker(
    id: 'w3', name: 'Sofia Ink', role: 'Tatuadora', rating: 5.0, shopId: '2',
    photoUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
  ),
];