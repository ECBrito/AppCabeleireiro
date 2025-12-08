class Customer {
  final String id;
  final String name;
  final String phone;
  final String email;
  final int totalVisits;
  final String notes; // Ex: "Gosta do corte com a máquina 2"

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    this.totalVisits = 0,
    this.notes = '',
  });
}

// Dados de teste
final List<Customer> mockCustomers = [
  Customer(id: '1', name: 'João Silva', phone: '912345678', email: 'joao@email.com', totalVisits: 5, notes: 'Cliente fiel'),
  Customer(id: '2', name: 'Pedro Santos', phone: '965554433', email: 'pedro@email.com', totalVisits: 1, notes: ''),
  Customer(id: '3', name: 'Ana Costa', phone: '933221100', email: 'ana@email.com', totalVisits: 12, notes: 'Gosta de café'),
];