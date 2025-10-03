import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../src/models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<void> register(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService.register(email, password);
      // Handle OTP navigation in UI
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> verifyOtpAndLogin(String email, String otp, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.verifyOtp(email, otp, password);
      await _saveToken(response['token'], response['role']);
      _user = User.fromJson(response['user'] ?? {'_id': 'temp', 'email': email, 'role': response['role']});
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiService.login(email, password);
      await _saveToken(response['token'], response['role']);
      _user = User.fromJson(response['user'] ?? {'_id': 'temp', 'email': email, 'role': response['role']});
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> logout() async {
    await SharedPreferences.getInstance().then((prefs) {
      prefs.remove('token');
      prefs.remove('role');
    });
    _user = null;
    notifyListeners();
  }

  Future<void> _saveToken(String token, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
    await prefs.setString('role', role);
  }

  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final role = prefs.getString('role');
    if (token != null && role != null) {
      _user = User(id: 'loaded', email: '', role: role);
    }
    notifyListeners();
  }
}