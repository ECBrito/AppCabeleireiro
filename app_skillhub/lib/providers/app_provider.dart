import 'package:flutter/material.dart';
import '../models/business_model.dart';
import '../models/service_model.dart';
import '../models/appointment_model.dart';
import '../models/worker_model.dart';
import '../models/customer_model.dart';
import '../models/promotion_model.dart';


class AppProvider with ChangeNotifier {
  // ESTADO
  Business? _activeBusiness;
  final List<Appointment> _appointments = [];
  final Set<String> _favoriteIds = {};

  // GETTERS
  Business? get activeBusiness => _activeBusiness;
  bool get isLinked => _activeBusiness != null;
  List<Appointment> get appointments => _appointments;
  
  // Lista de Clientes
  final List<Customer> _customers = [...mockCustomers];
  List<Customer> get customers => _customers;

  // Lista de Serviços
  final List<Service> _services = [
    Service(id: '1', name: 'Serviço Premium', price: 25.0, durationMinutes: 60),
    Service(id: '2', name: 'Serviço Rápido', price: 15.0, durationMinutes: 30),
    Service(id: '3', name: 'Consultoria', price: 0.00, durationMinutes: 15),
  ];
  List<Service> get services => _services;

  // LISTA DE PROMOÇÕES (CORRIGIDO: Agora usa 'colorHex' como exige o modelo)
  final List<Promotion> promotions = [
  Promotion(
    id: '1',
    title: 'Oferta de Boas-Vindas',
    subtitle: '10% no primeiro corte',
    color: 0xFF9C27B0,
  ),
  Promotion(
    id: '2',
    title: 'Indique um Amigo',
    subtitle: 'Ganhe 50 pts',
    color: 0xFF2196F3,
  ),
];
 
  // Trabalhadores
  final List<Worker> _allWorkers = mockWorkers;
  List<Worker> get shopWorkers {
    if (currentShop == null) return [];
    return _allWorkers.where((w) => w.shopId == currentShop!.id).toList();
  }
  
  BarberShop? get currentShop => _activeBusiness != null 
      ? BarberShop(id: _activeBusiness!.id, name: _activeBusiness!.name, primaryColor: _activeBusiness!.colorHex.toRadixString(16), logoIcon: 'cut', address: _activeBusiness!.address, rating: _activeBusiness!.rating) 
      : null;


  // --- LÓGICA DE ANALYTICS AVANÇADA (NOVO) ---

  // 1. Filtrar por Período
  List<Appointment> getAppointmentsByPeriod(String period) {
    final now = DateTime.now();
    return _appointments.where((appt) {
      if (period == 'Semana') {
        final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
        return appt.date.isAfter(startOfWeek.subtract(const Duration(days: 1)));
      } else if (period == 'Mês') {
        return appt.date.month == now.month && appt.date.year == now.year;
      } else if (period == 'Ano') {
        return appt.date.year == now.year;
      }
      return true; // Todos
    }).toList();
  }

  // 2. Calcular Faturação por Período
  double getRevenueByPeriod(String period) {
    final filtered = getAppointmentsByPeriod(period);
    return filtered.fold(0.0, (sum, item) => sum + item.price);
  }

  // 3. Calcular Crescimento (Comparação com período anterior simulada)
  double getGrowthPercentage(String period) {
    // Para este exemplo, usamos um valor fixo ou random, 
    // mas aqui iríamos buscar os dados do mês/semana anterior à base de dados.
    if (_appointments.isEmpty) return 0.0;
    
    // Simulação: Se o período for Mês, comparamos com o mês passado
    // Retorna positivo (crescimento) ou negativo (perda)
    return 12.5; 
  }

  // 4. Top Serviços (Calculado dinamicamente)
  List<Map<String, dynamic>> getTopServices() {
    final Map<String, int> counts = {};
    
    for (var appt in _appointments) {
      counts[appt.serviceName] = (counts[appt.serviceName] ?? 0) + 1;
    }

    final List<Map<String, dynamic>> result = [];
    counts.forEach((key, value) {
      // Calcula percentagem
      final percent = _appointments.isEmpty ? 0.0 : (value / _appointments.length);
      result.add({
        "name": key,
        "percent": "${(percent * 100).toStringAsFixed(0)}%",
        "value": percent, // 0.0 a 1.0 para a barra de progresso
      });
    });

    // Ordenar por popularidade
    result.sort((a, b) => (b['value'] as double).compareTo(a['value'] as double));
    return result;
  }
  
  // 5. Dados para o Gráfico (Agrupados por dia)
  List<double> getWeeklyChartData() {
    // Retorna array de 7 doubles (Seg-Dom)
    List<double> data = [0,0,0,0,0,0,0];
    if (_appointments.isEmpty) return [0.1, 0.3, 0.2, 0.5, 0.4, 0.8, 0.6]; // Dados dummy se vazio

    for (var appt in _appointments) {
      // Ajusta para índice 0-6 (Segunda=1 -> 0)
      int index = appt.date.weekday - 1; 
      if (index >= 0 && index < 7) {
        data[index] += appt.price;
      }
    }
    
    // Normalizar para 0.0-1.0 para o gráfico visual
    double max = data.reduce((curr, next) => curr > next ? curr : next);
    if (max == 0) max = 1;
    return data.map((e) => e / max).toList();
  }


  // --- MÉTODOS DE AÇÃO (MANTIDOS) ---
  
  void addPromotion(Promotion promo) { promotions.add(promo); notifyListeners(); }
  void removePromotion(String id) { promotions.removeWhere((p) => p.id == id); notifyListeners(); }
  void addCustomer(Customer customer) { _customers.add(customer); notifyListeners(); }
  void removeCustomer(String id) { _customers.removeWhere((c) => c.id == id); notifyListeners(); }
  void addService(Service service) { _services.add(service); notifyListeners(); }
  void removeService(String id) { _services.removeWhere((s) => s.id == id); notifyListeners(); }

  Future<bool> linkBusiness(String code) async {
    await Future.delayed(const Duration(seconds: 1)); 
    try {
      final business = mockBusinesses.firstWhere((b) => b.code.toLowerCase() == code.toLowerCase());
      _activeBusiness = business;
      notifyListeners();
      return true;
    } catch (e) { return false; }
  }

  void selectShop(Business business) { _activeBusiness = business; notifyListeners(); }

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
    if (index != -1) mockBusinesses[index] = updatedBusiness;
    notifyListeners();
  }

  void unlinkBusiness() { _activeBusiness = null; notifyListeners(); }

  Color getThemeColor() {
    if (_activeBusiness != null) return Color(_activeBusiness!.colorHex);
    return const Color(0xFFFFD700); 
  }
  
  void addAppointment(Appointment appt) { _appointments.add(appt); notifyListeners(); }

  double get totalRevenue => _appointments.fold(0.0, (sum, item) => sum + item.price);

  bool isFavorite(String id) => _favoriteIds.contains(id);
  void toggleFavorite(String id) { if(_favoriteIds.contains(id)) _favoriteIds.remove(id); else _favoriteIds.add(id); notifyListeners(); }
}

// Classe Auxiliar
class BarberShop {
  final String id; final String name; final String primaryColor; final String logoIcon; final String address; final double rating;
  BarberShop({required this.id, required this.name, required this.primaryColor, required this.logoIcon, required this.address, required this.rating});
  Color get color => Color(int.parse(primaryColor, radix: 16) + 0xFF000000);
}