import 'package:flutter/material.dart';
import '../src/models/menu.dart';

class CartProvider extends ChangeNotifier {
  Map<String, int> _cart = {};  // menuId -> quantity
  String? _currentCanteenId;
  double get total => _cart.entries.fold(0, (sum, e) => sum + (e.value * /*price from menu*/ 0));  // Fetch prices

  void addItem(MenuItem item, int qty) {
    if (_currentCanteenId != null && item.canteenId != _currentCanteenId) {
      // Enforce single canteen
      throw Exception('Switch to new canteen cart');
    }
    _currentCanteenId = item.canteenId;
    _cart[item.id] = (_cart[item.id] ?? 0) + qty;
    notifyListeners();
  }

  // clearCart, removeItem, getItems, etc.
  List<Map<String, dynamic>> get orderData => _cart.entries.map((e) => {'menuItem': e.key, 'quantity': e.value}).toList();
}