import 'package:flutter/material.dart';
import '../models/business_model.dart';
import '../models/service_model.dart';
import '../models/appointment_model.dart';
import '../models/worker_model.dart'; // Se tiveres workers

class AppProvider with ChangeNotifier {
  Business? _activeBusiness;
  final List<Appointment> _appointments = [];
  final Set<String> _favoriteIds = {};

  // Dados (Serviços)
  final List<Service> _services = [
    Service(id: '1', name: 'Serviço Premium', price: 25.0, durationMinutes: 60),
    Service(id: '2', name: 'Serviço Rápido', price: 15.0, durationMinutes: 30),
  ];

  // GETTERS
  Business? get activeBusiness => _activeBusiness;
  bool get isLinked => _activeBusiness != null; // <--- Isto diz ao main.dart se mostra a Loja ou o LinkScreen
  List<Appointment> get appointments => _appointments;
  List<Service> get services => _services;
  
  // Trabalhadores fictícios
  List<Worker> get shopWorkers => []; 
  
  double get totalRevenue => 450.0;

  // AÇÃO DE ENTRAR NA LOJA
  Future<bool> linkBusiness(String code) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      // Procura nos dados de teste (garante que business_model.dart tem 'barber')
      final business = mockBusinesses.firstWhere(
        (b) => b.code.toLowerCase() == code.toLowerCase(),
      );
      _activeBusiness = business;
      notifyListeners(); // <--- Atualiza a UI
      return true;
    } catch (e) {
      return false;
    }
  }

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
  
  // Outros métodos necessários para evitar erros
  void addAppointment(Appointment appt) { _appointments.add(appt); notifyListeners(); }
  void addService(Service s) { _services.add(s); notifyListeners(); }
  void removeService(String id) { _services.removeWhere((s) => s.id == id); notifyListeners(); }
  void updateShop(Business b) { _activeBusiness = b; notifyListeners(); }
  bool isFavorite(String id) => _favoriteIds.contains(id);
  void toggleFavorite(String id) { 
    if(_favoriteIds.contains(id)) _favoriteIds.remove(id); else _favoriteIds.add(id); 
    notifyListeners(); 
  }
}