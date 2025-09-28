class Order {
  final String id;
  final String userId;
  final String canteenId;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;  // 'pending', 'ready', 'completed'
  final String tokenNumber;
  final String? paymentId;
  final String? billPdf;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.userId,
    required this.canteenId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.tokenNumber,
    this.paymentId,
    this.billPdf,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => Order(
    id: json['_id'],
    userId: json['user'],
    canteenId: json['canteen'],
    items: (json['items'] as List).map((i) => OrderItem.fromJson(i)).toList(),
    totalAmount: json['totalAmount'].toDouble(),
    status: json['status'],
    tokenNumber: json['tokenNumber'],
    paymentId: json['paymentId'],
    billPdf: json['billPdf'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}

class OrderItem {
  final String menuItemId;
  final int quantity;
  final double price;

  OrderItem({required this.menuItemId, required this.quantity, required this.price});

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    menuItemId: json['menuItem'],
    quantity: json['quantity'],
    price: json['price'].toDouble(),
  );
}