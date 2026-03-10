import 'package:flutter/material.dart';

class CategoryDetailPage extends StatelessWidget {
  final String categoryName;

  const CategoryDetailPage({super.key, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName),
        backgroundColor: Colors.white,
        foregroundColor: Colors.brown,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconForCategory(categoryName),
              size: 100,
              color: Colors.yellow[800],
            ),
            const SizedBox(height: 24),
            Text(
              categoryName,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Liste des produits de cette catégorie\n(bientôt disponible)",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                foregroundColor: Colors.brown,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              ),
              child: const Text("Retour", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForCategory(String name) {
    final Map<String, IconData> icons = {
      'Outils': Icons.build,
      'Peinture': Icons.format_paint,
      'Electricité': Icons.bolt,
      'Plomberie': Icons.water_drop,
      'Sécurité': Icons.security,
      'Mesure': Icons.straighten,
      'Stockage': Icons.inventory_2,
      'Nettoyage': Icons.cleaning_services,
      'Serrage & fixation': Icons.handyman,
      'Perçage & vissage': Icons.build,
      'Façonnage & finition': Icons.auto_awesome,
      'Coupe & sciage': Icons.content_cut,
    };
    return icons[name] ?? Icons.category;
  }
}