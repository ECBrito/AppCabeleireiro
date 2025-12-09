import 'package:flutter/material.dart';

enum UserRole { client, owner }

class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final UserRole role;
  final String? shopId;
  final String? phoneNumber;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
    this.shopId,
    this.phoneNumber,
  });
}

class AuthProvider with ChangeNotifier {
  User? _currentUser;

  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isOwner => _currentUser?.role == UserRole.owner;

  // Base de Dados Mock
  final List<User> _users = [
    User(
        id: 'admin1',
        name: 'Dono da Loja',
        email: 'king@barber.com',
        password: '123',
        role: UserRole.owner,
        shopId: '1'
    ),
    User(
        id: 'user1',
        name: 'Ricardo Silva',
        email: 'cliente@gmail.com',
        password: '123',
        role: UserRole.client,
        phoneNumber: '912345678'
    ),
  ];

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Delay menor para ser rápido

    try {
      // PROCURA INTELIGENTE:
      final user = _users.firstWhere((u) {
        // 1. Verificação Real (Email e Pass exatos)
        final bool isExactMatch = u.email.toLowerCase() == email.toLowerCase() && u.password == password;

        // 2. Atalho de Teste (Basta escrever "admin" ou "cliente" em qualquer campo)
        final bool isDevAdmin = email.toLowerCase().contains('admin') && u.role == UserRole.owner;
        final bool isDevClient = email.toLowerCase().contains('client') && u.role == UserRole.client;

        return isExactMatch || isDevAdmin || isDevClient;
      });

      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(String name, String email, String password, UserRole role) async {
    await Future.delayed(const Duration(seconds: 1));
    final exists = _users.any((u) => u.email.toLowerCase() == email.toLowerCase());
    if (exists) return false;

    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      password: password,
      role: role,
      shopId: role == UserRole.owner ? 'shop_${DateTime.now().millisecondsSinceEpoch}' : null,
    );

    _users.add(newUser);
    _currentUser = newUser;
    notifyListeners();
    return true;
  }

  void updateProfile({String? name, String? phone}) {
    if (_currentUser == null) return;
    _currentUser = User(
      id: _currentUser!.id,
      email: _currentUser!.email,
      password: _currentUser!.password,
      role: _currentUser!.role,
      shopId: _currentUser!.shopId,
      name: name ?? _currentUser!.name,
      phoneNumber: phone ?? _currentUser!.phoneNumber,
    );
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }
}