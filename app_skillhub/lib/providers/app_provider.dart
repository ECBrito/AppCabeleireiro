import 'package:flutter/material.dart';
import '../models/business_model.dart';

class AppProvider with ChangeNotifier {
  Business? _activeBusiness;

  Business? get activeBusiness => _activeBusiness;
  bool get isLinked => _activeBusiness != null;

  // Tenta encontrar a loja pelo código
  Future<bool> linkBusiness(String code) async {
    await Future.delayed(const Duration(seconds: 1)); // Fingir que carrega
    try {
      _activeBusiness = mockBusinesses.firstWhere((b) => b.code == code);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void unlink() {
    _activeBusiness = null;
    notifyListeners();
  }

  Color getThemeColor() {
    return _activeBusiness != null ? Color(_activeBusiness!.colorHex) : Colors.white;
  }
}