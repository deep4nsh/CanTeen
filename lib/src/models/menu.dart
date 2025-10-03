class MenuItem {
  final String id;
  final String canteenId;
  final String name;
  final double price;
  final String description;
  final String? image;
  final bool isAvailable;

  MenuItem({
    required this.id,
    required this.canteenId,
    required this.name,
    required this.price,
    this.description = '',
    this.image,
    this.isAvailable = true,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
    id: json['_id'],
    canteenId: json['canteen'],
    name: json['name'],
    price: json['price'].toDouble(),
    description: json['description'] ?? '',
    image: json['image'],
    isAvailable: json['isAvailable'] ?? true,
  );
}