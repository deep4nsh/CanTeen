import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/helpers/token_helper.dart';
import 'order_status_screen.dart';

class CartScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cart;
  final String canteenId;

  const CartScreen({
    super.key,
    required this.cart,
    required this.canteenId,
  });

  int get total => cart.fold(0,
          (sum, item) => sum + (item['price'] as int) * (item['qty'] as int));

  Future<void> _placeOrder(BuildContext context) async {
    if (cart.isEmpty) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to place an order")),
      );
      return;
    }

    final token = TokenHelper.generateToken();

    final orderRef = FirebaseFirestore.instance.collection('orders').doc();

    await orderRef.set({
      'orderId': orderRef.id,
      'userId': user.uid,
      'canteenId': canteenId,
      'items': cart,
      'total': total,
      'token': token,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => OrderStatusScreen(
          orderId: orderRef.id,
          token: token,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: Column(
        children: [
          Expanded(
            child: cart.isEmpty
                ? const Center(child: Text("Your cart is empty"))
                : ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final item = cart[index];
                return ListTile(
                  title: Text('${item['name']} (x${item['qty']})'),
                  subtitle: Text('₹${item['price']}'),
                );
              },
            ),
          ),
          if (cart.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Total: ₹$total',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => _placeOrder(context),
                    child: const Text('Place Order'),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
