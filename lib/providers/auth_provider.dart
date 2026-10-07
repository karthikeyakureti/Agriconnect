import 'package:flutter/material.dart';
import '../core/storage/storage_service.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  bool get isFarmer => _currentUser?.isFarmer ?? (StorageService.getRole() == 'FARMER');
  bool get isBuyer => _currentUser?.isBuyer ?? (StorageService.getRole() == 'BUYER');

  Future<bool> tryAutoLogin() async {
    await StorageService.init();
    final savedToken = StorageService.getToken();
    if (savedToken != null && savedToken.isNotEmpty) {
      _token = savedToken;
      try {
        _currentUser = await ApiService.getMe();
        notifyListeners();
        return true;
      } catch (e) {
        // Token might have expired
        await logout();
        return false;
      }
    }
    return false;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiService.login(email.trim(), password);
      _token = res['access_token'];
      final role = res['role'];
      final userId = res['user_id'];
      final name = res['name'];

      await StorageService.saveAuthData(
        token: _token!,
        role: role,
        userId: userId,
        name: name,
        email: email,
      );

      _currentUser = await ApiService.getMe();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    String? phone,
    required String password,
    required String role,
    String? location,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await ApiService.register(
        name: name.trim(),
        email: email.trim(),
        phone: phone?.trim(),
        password: password,
        role: role.toUpperCase(),
        location: location?.trim(),
      );

      _token = res['access_token'];
      final userRole = res['role'];
      final userId = res['user_id'];
      final userName = res['name'];

      await StorageService.saveAuthData(
        token: _token!,
        role: userRole,
        userId: userId,
        name: userName,
        email: email,
      );

      _currentUser = await ApiService.getMe();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshProfile() async {
    if (!isAuthenticated) return;
    try {
      _currentUser = await ApiService.getMe();
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? location,
    String? profileImage,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await ApiService.updateProfile(
        name: name,
        phone: phone,
        location: location,
        profileImage: profileImage,
      );
      _currentUser = updated;
      if (name != null && _token != null) {
        await StorageService.saveAuthData(
          token: _token!,
          role: updated.role,
          userId: updated.id,
          name: updated.name,
          email: updated.email,
        );
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await StorageService.clear();
    _token = null;
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
