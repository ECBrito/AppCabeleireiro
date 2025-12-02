import 'package:flutter/material.dart';
import '../models/shop_model.dart';
import '../models/appointment_model.dart';
import '../models/service_model.dart'; // Importa o modelo de serviço

class AppProvider with ChangeNotifier {
  // 1. LOJA E TEMA
  BarberShop? _currentShop;

  // 2. DADOS (Agora os serviços são dinâmicos!)
  final List<Appointment> _appointments = [];

  // Lista inicial de serviços (pode ser editada pelo barbeiro)
  final List<Service> _services = [
    Service(id: '1', name: 'Corte Clássico', price: 15.00, durationMinutes: 30),
    Service(id: '2', name: 'Barba Mestre', price: 10.00, durationMinutes: 20),
    Service(id: '3', name: 'Combo King', price: 22.00, durationMinutes: 50),
  ];

  // GETTERS
  BarberShop? get currentShop => _currentShop;
  List<Appointment> get appointments => _appointments;
  List<Service> get services => _services; // Getter para a UI ler os serviços

  // FATURAÇÃO
  double get totalRevenue {
    return _appointments.fold(0, (sum, item) => sum + item.price);
  }

  // COR DO TEMA
  Color getThemeColor() {
    if (_currentShop != null) {
      return Color(_currentShop!.colorHex);
    }
    return const Color(0xFFFFD700);
  }

  // --- MÉTODOS DE AÇÃO ---

  void selectShop(BarberShop shop) {
    _currentShop = shop;
    notifyListeners();
  }

  void updateShop(BarberShop newShop) {
    _currentShop = newShop;
    notifyListeners();
  }

  void addAppointment(Appointment appointment) {
    _appointments.add(appointment);
    notifyListeners();
  }

  // NOVO: Adicionar Serviço
  void addService(Service service) {
    _services.add(service);
    notifyListeners();
  }

  // NOVO: Remover Serviço
  void removeService(String id) {
    _services.removeWhere((s) => s.id == id);
    notifyListeners();
  }
}