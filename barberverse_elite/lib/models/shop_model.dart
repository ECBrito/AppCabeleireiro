class BarberShop {
  final String id;
  final String name;
  final String address;
  final double rating;
  final String image;
  final int colorHex; // A cor do tema da loja (0xFF...)

  BarberShop({
    required this.id,
    required this.name,
    required this.address,
    required this.rating,
    required this.image,
    required this.colorHex,
  });
}

// Dados Fictícios para teste imediato
final List<BarberShop> mockShops = [
  BarberShop(
    id: '1',
    name: 'Barber King',
    address: 'Av. da Liberdade, 100',
    rating: 4.8,
    image: 'https://images.unsplash.com/photo-1585747860715-2ba37e788b70?q=80&w=800',
    colorHex: 0xFFFFD700, // Dourado
  ),
  BarberShop(
    id: '2',
    name: 'Urban Cuts',
    address: 'Rua Augusta, 25',
    rating: 4.5,
    image: 'https://images.unsplash.com/photo-1621605815971-fbc98d665033?q=80&w=800',
    colorHex: 0xFF00BFFF, // Azul Neon
  ),
  BarberShop(
    id: '3',
    name: 'Retro Shave',
    address: 'Bairro Alto, Travessa 2',
    rating: 4.9,
    image: 'https://images.unsplash.com/photo-1503951914875-452162b7f30a?q=80&w=800',
    colorHex: 0xFFCF6679, // Vermelho Vintage
  ),
];