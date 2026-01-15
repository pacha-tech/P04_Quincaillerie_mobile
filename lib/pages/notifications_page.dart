import 'package:flutter/material.dart';

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications_none, size: 100, color: Colors.yellow[800]),
            const SizedBox(height: 24),
            const Text(
              'Aucune notification pour le moment',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.brown),
            ),
            const SizedBox(height: 16),
            const Text(
              'Vous serez averti des promotions, commandes et nouveautés',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                foregroundColor: Colors.brown,
              ),
              child: const Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }
}