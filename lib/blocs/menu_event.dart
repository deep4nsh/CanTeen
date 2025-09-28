part of 'menu_bloc.dart';

/// Base event for menu operations.
abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object?> get props => [];
}

/// Loads menu items for a specific canteen.
class LoadMenu extends MenuEvent {
  final String canteenId;

  const LoadMenu(this.canteenId);

  @override
  List<Object?> get props => [canteenId];
}

/// Adds a new menu item.
class AddMenuItem extends MenuEvent {
  final String canteenId;
  final String name;
  final double price;
  final String description;
  final bool isAvailable;
  final String? imagePath;  // Local path from image_picker

  const AddMenuItem({
    required this.canteenId,
    required this.name,
    required this.price,
    required this.description,
    this.isAvailable = true,
    this.imagePath,
  });

  @override
  List<Object?> get props => [canteenId, name, price, description, isAvailable, imagePath];
}

/// Updates an existing menu item.
class UpdateMenuItem extends MenuEvent {
  final String itemId;
  final String canteenId;
  final String name;
  final double price;
  final String description;
  final bool isAvailable;
  final String? imagePath;  // New image if updating

  const UpdateMenuItem({
    required this.itemId,
    required this.canteenId,
    required this.name,
    required this.price,
    required this.description,
    this.isAvailable = true,
    this.imagePath,
  });

  @override
  List<Object?> get props => [itemId, canteenId, name, price, description, isAvailable, imagePath];
}

/// Deletes a menu item.
class DeleteMenuItem extends MenuEvent {
  final String itemId;
  final String canteenId;

  const DeleteMenuItem({
    required this.itemId,
    required this.canteenId,
  });

  @override
  List<Object?> get props => [itemId, canteenId];
}

/// Refreshes the menu list.
class RefreshMenu extends MenuEvent {
  final String canteenId;

  const RefreshMenu(this.canteenId);

  @override
  List<Object?> get props => [canteenId];
}