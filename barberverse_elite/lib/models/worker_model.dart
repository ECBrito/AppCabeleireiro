class Worker {
  final String id;
  final String name;
  final String photoUrl;
  final String role; // ex: "Barbeiro Sénior", "Colorista"
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

// Dados Fictícios (Para a Barbearia "Barber King" - ID '1')
final List<Worker> mockWorkers = [
  Worker(
    id: 'w1',
    name: 'Carlos Tesoura',
    photoUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
    role: 'Mestre Barbeiro',
    rating: 4.9,
    shopId: '1',
  ),
  Worker(
    id: 'w2',
    name: 'André Navalha',
    photoUrl: 'https://randomuser.me/api/portraits/men/44.jpg',
    role: 'Especialista em Barba',
    rating: 4.7,
    shopId: '1',
  ),
  Worker(
    id: 'w3',
    name: 'Sofia Cortes',
    photoUrl: 'https://randomuser.me/api/portraits/women/44.jpg',
    role: 'Estilista',
    rating: 5.0,
    shopId: '1',
  ),
];