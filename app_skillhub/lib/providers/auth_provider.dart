import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart'; // Import em falta corrigido

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _userModel;
  bool _isLoading = true;

  // Getters
  UserModel? get userModel => _userModel;
  User? get currentUser => _authService.currentUser; // Getter em falta adicionado
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _authService.currentUser != null && _userModel != null;

  // Verificações de Role
  bool get isOwner => _userModel?.role == 'owner';
  bool get isClient => _userModel?.role == 'client';

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((User? user) async {
      if (user != null) {
        await fetchUserProfile(user.uid);
      } else {
        _userModel = null;
      }
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> fetchUserProfile(String uid) async {
    try {
      final doc = await _authService.getUserProfile(uid);
      if (doc.exists) {
        _userModel = UserModel.fromDocument(doc);
      } else {
        _userModel = null;
      }
    } catch (e) {
      _userModel = null;
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      UserCredential? credential = await _authService.login(email, password);
      if (credential?.user != null) {
        await fetchUserProfile(credential!.user!.uid);
      }
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String role,
  }) async {
    _setLoading(true);
    try {
      UserCredential? credential = await _authService.register(
        email: email,
        password: password,
        name: name,
        role: role,
      );
      if (credential?.user != null) {
        await fetchUserProfile(credential!.user!.uid);
      }
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Método updateProfile adicionado para suportar o ProfileScreen
  Future<void> updateProfile({String? name, String? phone}) async {
    if (_authService.currentUser == null) return;
    _setLoading(true);
    try {
      await _authService.updateUserProfile(_authService.currentUser!.uid, {
        if (name != null && name.isNotEmpty) 'name': name,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      });
      await fetchUserProfile(_authService.currentUser!.uid);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    await _authService.logout();
    _userModel = null;
    _setLoading(false);
  }



  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}