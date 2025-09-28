import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../models/canteen.dart';
import '../../providers/cart_provider.dart';  // Implement similar to AuthProvider for cart state

class BrowseCanteensScreen extends StatefulWidget {
  @override
  _BrowseCanteensScreenState createState() => _BrowseCanteensScreenState();
}

class _BrowseCanteensScreenState extends State<BrowseCanteensScreen> {
  List<Canteen> _canteens = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCanteens();
  }

  Future<void> _loadCanteens() async {
    try {
      _canteens = await ApiService.getCanteens();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Browse Canteens')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _canteens.length,
        itemBuilder: (context, index) {
          final canteen = _canteens[index];
          return ListTile(
            title: Text(canteen.name),
            subtitle: Text(canteen.address),
            trailing: Icon(Icons.arrow_forward),
            onTap: () => Navigator.pushNamed(context, '/user/menu', arguments: {'canteenId': canteen.id}),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Provider.of<CartProvider>(context, listen: false).clearCart(),  // If multi-session
        child: Icon(Icons.shopping_cart),
      ),
    );
  }
}