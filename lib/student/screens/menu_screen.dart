import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/widgets/app_loader.dart';
import '../../../core/widgets/app_empty.dart';
import 'cart_screen.dart';

class MenuScreen extends StatefulWidget {
  final String canteenId;
  final String canteenName;

  const MenuScreen({
    super.key,
    required this.canteenId,
    required this.canteenName,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final List<Map<String, dynamic>> cart = [];

  void _addToCart(DocumentSnapshot item) {
    setState(() {
      cart.add({
        'itemId': item.id,
        'name': item['name'],
        'price': item['price'],
        'qty': 1,
      });
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${item['name']} added to cart')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.canteenName} - Menu'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CartScreen(
                    cart: cart,
                    canteenId: widget.canteenId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('canteens')
            .doc(widget.canteenId)
            .collection('menu')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const AppLoader();
          final items = snapshot.data!.docs;
          if (items.isEmpty) return const AppEmpty(message: 'No menu items available');

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(item['name']),
                  subtitle: Text('₹${item['price']}'),
                  trailing: ElevatedButton(
                    onPressed: () => _addToCart(item),
                    child: const Text('Add'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
