// lib/widgets/product_card_vertical.dart
import 'package:flutter/material.dart';

class Product extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const Product({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.yellow[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.yellow[200]!),
      ),
      child: Row( // On utilise Row pour mettre l'icône à gauche et le texte/bouton à droite
        children: [
          Icon(icon, size: 60, color: Colors.brown[800]),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Text("Disponible immédiatement", style: TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.yellow),
            child: const Text('Voir'),
          ),
        ],
      ),
    );
  }
}
