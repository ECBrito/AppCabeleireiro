import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class AuthService {
  // 10.0.2.2 aponta para o localhost da máquina host no emulador Android
  static const String baseUrl = 'http://10.0.2.2:3000/auth';

  UserModel? _currentUser;
  final _authStateController = StreamController<UserModel?>.broadcast();

  UserModel? get currentUser => _currentUser;
  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  // Login com Email e Password
  Future<UserModel> login(String email, String password) async {
    debugPrint("=== [DEBUG AUTH_SERVICE] 1. A iniciar pedido HTTP POST para $baseUrl/login ===");

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      ).timeout(const Duration(seconds: 7));

      debugPrint("=== [DEBUG AUTH_SERVICE] 2. Resposta recebida. Status: ${response.statusCode} ===");
      debugPrint("=== [DEBUG AUTH_SERVICE] 3. Corpo: ${response.body} ===");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = UserModel.fromJson(data['user']);
        _currentUser = user;
        _authStateController.add(_currentUser);
        debugPrint("=== [DEBUG AUTH_SERVICE] 4. Login OK. User: ${user.name} | Role: ${user.role} ===");
        return user;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Falha ao iniciar sessão');
      }
    } catch (e, stack) {
      debugPrint("=== [DEBUG AUTH_SERVICE] ERRO NO POST: $e ===");
      debugPrint(stack.toString());
      rethrow;
    }
  }

  // Registo de Utilizador
  Future<UserModel> register({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phone,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
        'role': role,
        'phone': phone,
      }),
    ).timeout(const Duration(seconds: 7));

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = UserModel.fromJson(data['user']);
      _currentUser = user;
      _authStateController.add(_currentUser);
      return user;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Falha ao criar conta');
    }
  }

  // Obter perfil do utilizador
  Future<UserModel> getUserProfile(int id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile/$id'),
      headers: {'Content-Type': 'application/json'},
    ).timeout(const Duration(seconds: 7));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final user = UserModel.fromJson(data['user']);
      _currentUser = user;
      _authStateController.add(_currentUser);
      return user;
    } else {
      throw Exception('Perfil não encontrado');
    }
  }

  void setCurrentUserFromMap(Map<String, dynamic> json) {
    _currentUser = UserModel.fromJson(json);
    _authStateController.add(_currentUser);
  }

  // Atualizar dados do utilizador
  Future<void> updateUserProfile(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/profile/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    ).timeout(const Duration(seconds: 7));

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Erro ao atualizar perfil');
    }
  }

  // Logout
  Future<void> logout() async {
    _currentUser = null;
    _authStateController.add(null);
  }
}