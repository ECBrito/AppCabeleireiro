class Service {
  final String id;
  final String name;
  final double price;
  final int durationMinutes;

  Service({
    required this.id,
    required this.name,
    required this.price,
    required this.durationMinutes,
  });
}

// Dados fictícios para a UI
final List<Service> mockServices = [
  Service(id: '1', name: 'Corte Clássico', price: 15.00, durationMinutes: 30),
  Service(id: '2', name: 'Barba Mestre', price: 10.00, durationMinutes: 20),
  Service(id: '3', name: 'Combo King (Cabelo + Barba)', price: 22.00, durationMinutes: 50),
  Service(id: '4', name: 'Design de Sobrancelha', price: 5.00, durationMinutes: 10),
];