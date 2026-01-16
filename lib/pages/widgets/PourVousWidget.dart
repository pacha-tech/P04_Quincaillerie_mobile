import 'package:flutter/material.dart';

class PourVousWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  final int price;

  const PourVousWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.price
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(label),
        trailing: Text(
            "$price FCFA",
            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)
        ),
      ),
    );
  }
}
