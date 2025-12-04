import 'package:flutter/material.dart';

enum UserRole { client, owner }

class User {
  final String id;
  final String email;
  final UserRole role;
  User({required this.id, required this.email, required this.role});
}

class AuthProvider with ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isOwner => _currentUser?.role == UserRole.owner;

  // Login Simulado
  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    
    if (email.contains('admin')) {
      _currentUser = User(id: 'admin1', email: email, role: UserRole.owner);
    } else {
      _currentUser = User(id: 'user1', email: email, role: UserRole.client);
    }
    
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}