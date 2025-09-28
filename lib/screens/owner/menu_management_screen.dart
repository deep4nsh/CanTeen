import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/menu.dart';
import 'package:cms_flutter_app/blocs/menu_bloc.dart';

class MenuManagementScreen extends StatelessWidget {
  final String canteenId;  // Passed via route
  const MenuManagementScreen({Key? key, required this.canteenId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MenuBloc()..add(LoadMenu(canteenId)),
      child: Scaffold(
        appBar: AppBar(title: Text('Manage Menu')),
        body: BlocBuilder<MenuBloc, MenuState>(
          builder: (context, state) {
            if (state is MenuLoading) return Center(child: CircularProgressIndicator());
            if (state is MenuLoaded) {
              return ListView.builder(
                itemCount: state.menus.length,
                itemBuilder: (context, index) {
                  final item = state.menus[index];
                  return Card(
                    child: ListTile(
                      title: Text(item.name),
                      subtitle: Text('₹${item.price}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(icon: Icon(Icons.edit), onPressed: () => _editItem(context, item)),
                          IconButton(icon: Icon(Icons.delete), onPressed: () => _deleteItem(context, item.id)),
                        ],
                      ),
                    ),
                  );
                },
              );
            }
            if (state is MenuError) return Center(child: Text('Error: ${state.message}'));
            return Center(child: ElevatedButton(
              onPressed: () => _addItemDialog(context),
              child: Text('Add Item'),
            ));
          },
        ),
      ),
    );
  }

  void _addItemDialog(BuildContext context) {
    // Show dialog with TextFields for name, price, desc, image picker
    // On save: context.read<MenuBloc>().add(AddMenuItem(data, canteenId));
  }

  void _editItem(BuildContext context, MenuItem item) {
    // Similar dialog for update
  }

  void _deleteItem(BuildContext context, String id) {
    // Confirm and call API delete
  }
}