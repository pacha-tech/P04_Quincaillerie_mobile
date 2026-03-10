import 'package:flutter/material.dart';

class Category extends StatelessWidget {
  final IconData icon;
  final String label;

  const Category({
    super.key,
    required this.icon,
    required this.label
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.yellow[100],
            child: Icon(icon, size: 30, color: Colors.brown),
          ),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
