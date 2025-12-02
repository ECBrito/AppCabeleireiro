import 'package:flutter/material.dart';
import '../models/shop_model.dart';
import '../models/appointment_model.dart';
import '../models/service_model.dart';
import '../models/worker_model.dart'; // Importante para os trabalhadores

class AppProvider with ChangeNotifier {
  // 1. ESTADO DA LOJA
  BarberShop? _currentShop;

  // 2. DADOS DE DIVERSAS FUNCIONALIDADES
  final List<Appointment> _appointments = [];
  final Set<String> _favoriteShopIds = {}; // Lista de favoritos

  // Lista de Serviços (Dinâmica)
  final List<Service> _services = [
    Service(id: '1', name: 'Corte Clássico', price: 15.00, durationMinutes: 30),
    Service(id: '2', name: 'Barba Mestre', price: 10.00, durationMinutes: 20),
    Service(id: '3', name: 'Combo King', price: 22.00, durationMinutes: 50),
    Service(id: '4', name: 'Design Sobrancelha', price: 5.00, durationMinutes: 10),
  ];

  // Lista de Trabalhadores (Vem do mock)
  final List<Worker> _allWorkers = mockWorkers;

  // --- GETTERS ---

  BarberShop? get currentShop => _currentShop;
  List<Appointment> get appointments => _appointments;
  List<Service> get services => _services;

  // Filtra trabalhadores pela loja atual
  List<Worker> get shopWorkers {
    if (_currentShop == null) return [];
    return _allWorkers.where((w) => w.shopId == _currentShop!.id).toList();
  }

  // Calcula faturação total
  double get totalRevenue {
    return _appointments.fold(0, (sum, item) => sum + item.price);
  }

  // Verifica se loja é favorita
  bool isFavorite(String shopId) => _favoriteShopIds.contains(shopId);

  // Obtém cor do tema atual
  Color getThemeColor() {
    if (_currentShop != null) {
      return Color(_currentShop!.colorHex);
    }
    return const Color(0xFFFFD700); // Dourado Padrão
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

  // AQUI ESTAVA O ERRO: Agora só existe UMA vez
  void addAppointment(Appointment appointment) {
    _appointments.add(appointment);
    notifyListeners();
  }

  void addService(Service service) {
    _services.add(service);
    notifyListeners();
  }

  void removeService(String id) {
    _services.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  void toggleFavorite(String shopId) {
    if (_favoriteShopIds.contains(shopId)) {
      _favoriteShopIds.remove(shopId);
    } else {
      _favoriteShopIds.add(shopId);
    }
    notifyListeners();
  }
}