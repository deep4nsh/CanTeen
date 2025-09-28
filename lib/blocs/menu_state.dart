// lib/blocs/menu_state.dart
part of 'menu_bloc.dart';

/// Base state for menu operations.
abstract class MenuState extends Equatable {
  const MenuState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any operation.
class MenuInitial extends MenuState {
  const MenuInitial();
}

/// Loading state during API calls.
class MenuLoading extends MenuState {
  const MenuLoading();
}

/// Loaded state with list of menu items.
class MenuLoaded extends MenuState {
  final List<MenuItem> menus;

  const MenuLoaded(this.menus);

  @override
  List<Object?> get props => [menus];
}

/// Error state with message.
class MenuError extends MenuState {
  final String message;

  const MenuError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Success state for operations like add/update/delete.
class MenuSuccess extends MenuState {
  final String message;

  const MenuSuccess(this.message);

  @override
  List<Object?> get props => [message];
}