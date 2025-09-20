import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'menu_screen.dart';

class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CanTeen - Canteens')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('canteens').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final canteens = snapshot.data!.docs;
          if (canteens.isEmpty) {
            return const Center(child: Text('No canteens found'));
          }
          return ListView.builder(
            itemCount: canteens.length,
            itemBuilder: (context, index) {
              final doc = canteens[index];
              return ListTile(
                title: Text(doc['name']),
                subtitle: Text(doc['location'] ?? 'Unknown location'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MenuScreen(canteenId: doc.id, canteenName: doc['name']),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
