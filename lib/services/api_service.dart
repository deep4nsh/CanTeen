import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/*.dart';
import '../models/canteen.dart';
import '../models/menu.dart';
import '../models/order.dart';  // Import models

class ApiService {
  static final Dio _dio = Dio(BaseOptions(baseUrl: 'http://your-backend-url:5000/api'));

  static void init() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = SharedPreferences.getInstance().then((prefs) => prefs.getString('token'));
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
    ));
  }

  // Auth
  static Future<Map<String, dynamic>> register(String email, String password) async {
    final response = await _dio.post('/auth/register', data: {'email': email, 'password': password});
    return response.data;
  }

  static Future<Map<String, dynamic>> verifyOtp(String email, String otp, String password) async {
    final response = await _dio.post('/auth/verify-otp', data: {'email': email, 'otp': otp, 'password': password});
    return response.data;
  }

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _dio.post('/auth/login', data: {'email': email, 'password': password});
    if (response.data['token'] != null) {
      await SharedPreferences.getInstance().then((prefs) => prefs.setString('token', response.data['token']));
      await SharedPreferences.getInstance().then((prefs) => prefs.setString('role', response.data['role']));
    }
    return response.data;
  }

  // Canteens & Menus
  static Future<List<Canteen>> getCanteens() async {
    final response = await _dio.get('/menu/canteens');
    return (response.data as List).map((json) => Canteen.fromJson(json)).toList();
  }

  static Future<List<MenuItem>> getMenu(String canteenId) async {
    final response = await _dio.get('/menu/canteen/$canteenId');
    return (response.data as List).map((json) => MenuItem.fromJson(json)).toList();
  }

  // Orders
  static Future<Order> placeOrder(Map<String, dynamic> orderData) async {
    final response = await _dio.post('/orders', data: orderData);
    return Order.fromJson(response.data);
  }

  static Future<Order> updateOrderStatus(String orderId, String status) async {
    final response = await _dio.put('/orders/$orderId/status', data: {'status': status});
    return Order.fromJson(response.data);
  }

  static Future<List<Order>> getOrderHistory() async {
    final role = await SharedPreferences.getInstance().then((prefs) => prefs.getString('role') ?? 'user');
    final response = await _dio.get('/orders/history?role=$role');
    return (response.data as List).map((json) => Order.fromJson(json)).toList();
  }

  // Menu Management (Owner)
  static Future<MenuItem> addMenuItem(Map<String, dynamic> menuData) async {
    final response = await _dio.post('/menu', data: menuData);
    return MenuItem.fromJson(response.data);
  }



  static Future<void> updateMenuItem(String itemId, Map<String, dynamic> menuData) async {
    await _dio.put('/menu/$itemId', data: menuData);
  }

  static Future<void> deleteMenuItem(String itemId) async {
    await _dio.delete('/menu/$itemId');
  }


// Admin: Similar endpoints for managing canteens/users
}