import 'package:flutter/material.dart';
import '../models/business_model.dart';
import '../models/service_model.dart';
import '../models/appointment_model.dart';
import '../models/worker_model.dart';
import '../models/customer_model.dart'; // <--- IMPORT NOVO

class AppProvider with ChangeNotifier {
  // ESTADO
  Business? _activeBusiness;
  final List<Appointment> _appointments = [];
  final Set<String> _favoriteIds = {};

  // GETTERS
  Business? get activeBusiness => _activeBusiness;
  bool get isLinked => _activeBusiness != null;
  List<Appointment> get appointments => _appointments;
  
  // LISTA DE CLIENTES (NOVO)
  final List<Customer> _customers = [...mockCustomers]; // Inicia com os dados mock
  List<Customer> get customers => _customers;

  // Serviços (Dados Mock Iniciais)
  final List<Service> _services = [
    Service(id: '1', name: 'Serviço Premium', price: 25.0, durationMinutes: 60),
    Service(id: '2', name: 'Serviço Rápido', price: 15.0, durationMinutes: 30),
    Service(id: '3', name: 'Consultoria', price: 0.00, durationMinutes: 15),
  ];
  
  List<Service> get services => _services;

  // Lista de Trabalhadores
  final List<Worker> _allWorkers = mockWorkers;
  List<Worker> get shopWorkers {
    if (currentShop == null) return [];
    return _allWorkers.where((w) => w.shopId == currentShop!.id).toList();
  }
  
  // Getter auxiliar para currentShop (compatibilidade com UI antiga)
  BarberShop? get currentShop => _activeBusiness != null 
      ? BarberShop(id: _activeBusiness!.id, name: _activeBusiness!.name, primaryColor: _activeBusiness!.colorHex.toRadixString(16), logoIcon: 'cut', address: _activeBusiness!.address, rating: _activeBusiness!.rating) 
      : null;


  // --- GESTÃO DE CLIENTES (NOVO) ---

  void addCustomer(Customer customer) {
    _customers.add(customer);
    notifyListeners();
  }

  void removeCustomer(String id) {
    _customers.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  // --- LÓGICA DE GESTÃO DE SERVIÇOS ---

  void addService(Service service) {
    _services.add(service);
    notifyListeners(); 
  }

  void removeService(String id) {
    _services.removeWhere((s) => s.id == id);
    notifyListeners(); 
  }

  // --- LÓGICA SAAS ---

  Future<bool> linkBusiness(String code) async {
    await Future.delayed(const Duration(seconds: 1)); 
    try {
      final business = mockBusinesses.firstWhere(
        (b) => b.code.toLowerCase() == code.toLowerCase(),
      );
      _activeBusiness = business;
      notifyListeners();
      return true;
    } catch (e) {
      return false; 
    }
  }

  // --- LÓGICA DE ADMINISTRAÇÃO ---

  void selectShop(Business business) {
    _activeBusiness = business;
    notifyListeners();
  }

  Future<bool> checkCodeAvailability(String code) async {
    await Future.delayed(const Duration(milliseconds: 500)); 
    return !mockBusinesses.any((b) => b.code.toLowerCase() == code.toLowerCase());
  }

  Future<void> createBusiness(Business newShop) async {
    await Future.delayed(const Duration(seconds: 2)); 
    mockBusinesses.add(newShop);
    _activeBusiness = newShop;
    notifyListeners();
  }

  void updateShop(Business updatedBusiness) {
    _activeBusiness = updatedBusiness;
    final index = mockBusinesses.indexWhere((b) => b.id == updatedBusiness.id);
    if (index != -1) {
      mockBusinesses[index] = updatedBusiness;
    }
    notifyListeners();
  }

  // --- OUTROS MÉTODOS ---

  void unlinkBusiness() {
    _activeBusiness = null;
    notifyListeners();
  }

  Color getThemeColor() {
    if (_activeBusiness != null) {
      return Color(_activeBusiness!.colorHex);
    }
    return const Color(0xFFFFD700); 
  }
  
  void addAppointment(Appointment appt) {
    _appointments.add(appt);
    notifyListeners();
  }

  double get totalRevenue {
    return _appointments.fold(0.0, (sum, item) => sum + item.price);
  }

  bool isFavorite(String id) => _favoriteIds.contains(id);
  
  void toggleFavorite(String id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();
  }
}

// Classe Auxiliar para compatibilidade (BarberShop vs Business)
class BarberShop {
  final String id;
  final String name;
  final String primaryColor;
  final String logoIcon;
  final String address;
  final double rating;
  BarberShop({required this.id, required this.name, required this.primaryColor, required this.logoIcon, required this.address, required this.rating});
  Color get color => Color(int.parse(primaryColor, radix: 16) + 0xFF000000);
}