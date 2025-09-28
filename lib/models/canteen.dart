class Canteen {
  final String id;
  final String name;
  final String ownerId;
  final String address;
  final bool isActive;

  Canteen({required this.id, required this.name, required this.ownerId, required this.address, this.isActive = true});

  factory Canteen.fromJson(Map<String, dynamic> json) => Canteen(
    id: json['_id'],
    name: json['name'],
    ownerId: json['owner'],
    address: json['address'] ?? '',
    isActive: json['isActive'] ?? true,
  );
}
