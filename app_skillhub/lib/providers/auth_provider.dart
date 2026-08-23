import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  UserModel? _userModel;
  bool _isLoading = false;

  UserModel? get userModel => _userModel ?? _authService.currentUser;
  UserModel? get currentUser => userModel;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => userModel != null;

  bool get isOwner => userModel?.role == 'owner';
  bool get isClient => userModel?.role == 'client';

  AuthProvider() {
    _init();
  }

  void _init() {
    _userModel = _authService.currentUser;
    _authService.authStateChanges.listen((UserModel? user) {
      _userModel = user;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<UserModel> login(String email, String password) async {
    _setLoading(true);
    try {
      final user = await _authService.login(email, password);
      _userModel = user;
      notifyListeners();
      return user;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String role,
    String? phone,
  }) async {
    _setLoading(true);
    try {
      _userModel = await _authService.register(
        email: email,
        password: password,
        name: name,
        role: role,
        phone: phone,
      );
      notifyListeners();
    } catch (e) {
      _userModel = null;
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchUserProfile(int id) async {
    try {
      _userModel = await _authService.getUserProfile(id);
    } catch (e) {
      _userModel = null;
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> updateProfile({String? name, String? phone}) async {
    if (_userModel == null) return;
    _setLoading(true);
    try {
      await _authService.updateUserProfile(_userModel!.id, {
        if (name != null && name.isNotEmpty) 'name': name,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
      });
      await fetchUserProfile(_userModel!.id);
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
    notifyListeners();
    _setLoading(false);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}