import 'package:flutter/material.dart';
import '../models/shop_model.dart';
import '../models/appointment_model.dart'; // Novo import

class AppProvider with ChangeNotifier {
  // A loja que o cliente está a ver atualmente
  BarberShop? _currentShop;

  // Lista de todas as marcações (Memória)
  final List<Appointment> _appointments = [];

  BarberShop? get currentShop => _currentShop;
  List<Appointment> get appointments => _appointments;

  // Define a loja e avisa a app para mudar de cor
  void selectShop(BarberShop shop) {
    _currentShop = shop;
    notifyListeners();
  }

  // Adiciona uma nova marcação
  void addAppointment(Appointment appointment) {
    _appointments.add(appointment);
    notifyListeners(); // Avisa o AdminDashboard para atualizar
  }

  // Calcula a faturação total
  double get totalRevenue {
    return _appointments.fold(0, (sum, item) => sum + item.price);
  }

  // Retorna a cor da loja ou Dourado se não houver loja selecionada
  Color getThemeColor() {
    if (_currentShop != null) {
      return Color(_currentShop!.colorHex);
    }
    return const Color(0xFFFFD700); // Dourado Padrão
  }

  // Método para atualizar dados da loja (usado no ShopEditScreen)
  void updateShop(BarberShop newShop) {
    _currentShop = newShop;
    notifyListeners();
  }
}