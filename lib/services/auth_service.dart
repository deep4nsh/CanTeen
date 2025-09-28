// lib/services/auth_service.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';  // Assuming ApiService is your base HTTP client with Dio
import 'fcm_service.dart';  // To update FCM token after auth

/// AuthService handles all authentication-related API calls and local token management.
/// It integrates with the backend's /api/auth routes and manages JWT tokens via SharedPreferences.
/// Usage: Call methods like AuthService.register(), then AuthService.login() after OTP verification.
class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _roleKey = 'user_role';
  static const String _userIdKey = 'user_id';
  static const String _fcmTokenKey = 'fcm_token';

  // Private Dio instance for auth-specific calls (uses ApiService's base config)
  static final Dio _dio = ApiService.dio;  // Reuse ApiService's Dio with interceptors

  /// Registers a new user with email and password.
  /// Sends OTP to email. Returns success message or throws DioException on error.
  /// Role defaults to 'user'; specify 'owner' or 'admin' if needed (admin approval required).
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String role = 'user',
  }) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {'email': email, 'password': password, 'role': role},
      );
      return response.data;  // { message: 'OTP sent' }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Verifies OTP and sets/completes the password for registration.
  /// On success, logs in the user and returns token + user data.
  /// Throws DioException on invalid OTP or server error.
  static Future<Map<String, dynamic>> verifyOtpAndLogin({
    required String email,
    required String otp,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/verify-otp',
        data: {'email': email, 'otp': otp, 'password': password},
      );
      final data = response.data;  // { token, user: { id, email, role } }

      // Persist token and user info
      await _saveAuthData(data['token'], data['user']['role'], data['user']['id']);

      // Update FCM token on backend after successful auth
      final fcmToken = await FCMService.getCurrentToken();
      if (fcmToken != null) {
        await updateFCMToken(fcmToken);
      }

      return data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Logs in an existing user with email and password.
  /// Checks verification and approval (for owner/admin). Returns token + user data.
  /// Throws DioException on invalid credentials or unapproved account.
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final data = response.data;  // { token, user: { id, email, role } }

      // Persist token and user info
      await _saveAuthData(data['token'], data['user']['role'], data['user']['id']);

      // Update FCM token on backend
      final fcmToken = await FCMService.getCurrentToken();
      if (fcmToken != null) {
        await updateFCMToken(fcmToken);
      }

      return data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Updates the user's FCM token on the backend after login/register.
  /// Endpoint: POST /api/auth/update-fcm (add this to backend if not present).
  /// Throws DioException on failure.
  static Future<void> updateFCMToken(String fcmToken) async {
    try {
      final token = await _getToken();
      if (token == null) throw Exception('No auth token available');

      await _dio.post(
        '/auth/update-fcm',
        data: {'fcmToken': fcmToken},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );
    } on DioException catch (e) {
      // Non-critical; log but don't throw (FCM can retry later)
      print('Failed to update FCM token: ${e.response?.data['error']}');
    }
  }

  /// Logs out the user: Clears local tokens and notifies backend (optional).
  /// Call this before navigating to login screen.
  static Future<void> logout() async {
    try {
      final token = await _getToken();
      if (token != null) {
        // Optional: Notify backend to invalidate token (POST /api/auth/logout)
        await _dio.post('/auth/logout', options: Options(headers: {'Authorization': 'Bearer $token'}));
      }
    } catch (e) {
      print('Logout backend call failed: $e');  // Non-critical
    }

    // Clear local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_fcmTokenKey);

    // Clear any cached API data if using interceptors
    ApiService.clearCache();  // Implement if needed in ApiService
  }

  /// Checks if user is authenticated (has valid token).
  /// Returns true if token exists; validate with backend on app start if needed.
  static Future<bool> isAuthenticated() async {
    final token = await _getToken();
    return token != null && token.isNotEmpty;
  }

  /// Gets the current user's role (e.g., 'user', 'owner', 'admin').
  /// Returns null if not logged in.
  static Future<String?> getCurrentRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  /// Gets the current user's ID.
  /// Returns null if not logged in.
  static Future<String?> getCurrentUser Id() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  /// Gets the stored JWT token for API headers.
  /// Used by Dio interceptors in ApiService.
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Private: Saves auth data to SharedPreferences after successful login/register.
  static Future<void> _saveAuthData(String token, String role, String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_roleKey, role);
    await prefs.setString(_userIdKey, userId);
  }

  /// Private: Handles Dio errors and throws user-friendly exceptions.
  static Exception _handleDioError(DioException e) {
    if (e.response?.statusCode == 401) {
      return Exception('Invalid credentials or token expired. Please log in again.');
    } else if (e.response?.statusCode == 403) {
      return Exception('Access denied. Account may need approval.');
    } else if (e.response?.statusCode == 400) {
      return Exception(e.response?.data['error'] ?? 'Invalid input');
    } else {
      return Exception('Network error: ${e.message}');
    }
  }
}