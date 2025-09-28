// lib/blocs/menu_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dio/dio.dart' as dio;
import '../blocs/menu_bloc.dart';  // Import MenuItem model
import 'package:cms_flutter_app/services/api_service.dart';  // For API calls (add, update, delete, get menu)
import '../services/image_upload_service.dart';  // Optional: For handling image uploads (implement if needed)

part 'menu_event.dart';
part 'menu_state.dart';

/// MenuBloc manages the state for menu operations in the Owner panel.
/// It handles loading menus for a specific canteen, adding/editing/deleting items,
/// and ensures ownership via backend checks.
/// Usage: Wrap screens with BlocProvider<MenuBloc> and dispatch events like LoadMenu(canteenId).
class MenuBloc extends Bloc<MenuEvent, MenuState> {
  MenuBloc() : super(const MenuInitial()) {
    on<LoadMenu>(_onLoadMenu);
    on<AddMenuItem>(_onAddMenuItem);
    on<UpdateMenuItem>(_onUpdateMenuItem);
    on<DeleteMenuItem>(_onDeleteMenuItem);
    on<RefreshMenu>(_onRefreshMenu);  // For pulling to refresh
  }

  /// Loads all available menu items for a given canteen ID.
  /// Dispatches MenuLoading, then MenuLoaded or MenuError.
  Future<void> _onLoadMenu(LoadMenu event, Emitter<MenuState> emit) async {
    emit(const MenuLoading());
    try {
      final menus = await ApiService.getMenu(event.canteenId);
      emit(MenuLoaded(menus));
    } catch (error) {
      emit(MenuError('Failed to load menu: ${error.toString()}'));
    }
  }

  /// Adds a new menu item for the owner's canteen.
  /// Supports optional image upload (multipart form data).
  /// On success, reloads the menu list.
  Future<void> _onAddMenuItem(AddMenuItem event, Emitter<MenuState> emit) async {
    if (state is! MenuLoaded) return;  // Ensure menu is loaded first

    emit(const MenuLoading());  // Or use a separate Adding state if needed
    try {
      Map<String, dynamic> menuData = {
        'canteen': event.canteenId,
        'name': event.name,
        'price': event.price,
        'description': event.description,
        'isAvailable': event.isAvailable,
      };

      String? imageUrl;
      if (event.imagePath != null) {
        // Upload image first (implement ImageUploadService for Cloudinary/AWS)
        imageUrl = await ImageUploadService.uploadImage(event.imagePath!);
        menuData['image'] = imageUrl;
      }

      final newItem = await ApiService.addMenuItem(menuData);
      // Reload to include new item
      add(LoadMenu(event.canteenId));
      emit(const MenuSuccess('Menu item added successfully'));
    } catch (error) {
      emit(MenuError('Failed to add menu item: ${error.toString()}'));
    }
  }

  /// Updates an existing menu item.
  /// Similar to add, but uses PUT /api/menu/:id.
  /// On success, reloads the menu.
  Future<void> _onUpdateMenuItem(UpdateMenuItem event, Emitter<MenuState> emit) async {
    if (state is! MenuLoaded) return;

    emit(const MenuLoading());
    try {
      Map<String, dynamic> menuData = {
        'name': event.name,
        'price': event.price,
        'description': event.description,
        'isAvailable': event.isAvailable,
      };

      String? imageUrl;
      if (event.imagePath != null) {
        imageUrl = await ImageUploadService.uploadImage(event.imagePath!);
        menuData['image'] = imageUrl;
      }

      await ApiService.updateMenuItem(event.itemId, menuData);
      // Reload to reflect changes
      add(LoadMenu(event.canteenId));
      emit(const MenuSuccess('Menu item updated successfully'));
    } catch (error) {
      emit(MenuError('Failed to update menu item: ${error.toString()}'));
    }
  }

  /// Deletes a menu item by ID.
  /// On success, reloads the menu.
  Future<void> _onDeleteMenuItem(DeleteMenuItem event, Emitter<MenuState> emit) async {
    if (state is! MenuLoaded) return;

    emit(const MenuLoading());
    try {
      await ApiService.deleteMenuItem(event.itemId);
      // Reload to remove item
      add(LoadMenu(event.canteenId));
      emit(const MenuSuccess('Menu item deleted successfully'));
    } catch (error) {
      emit(MenuError('Failed to delete menu item: ${error.toString()}'));
    }
  }

  /// Refreshes the current menu (e.g., for pull-to-refresh).
  Future<void> _onRefreshMenu(RefreshMenu event, Emitter<MenuState> emit) async {
    if (state is MenuLoaded) {
      add(LoadMenu(event.canteenId));
    }
  }
}