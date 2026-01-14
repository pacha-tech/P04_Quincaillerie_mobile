import 'package:flutter/material.dart';

// Import la page détail (ajuste le chemin selon ton projet)
import 'category_detail_page.dart';

class AllCategoriesPage extends StatelessWidget {
  const AllCategoriesPage({super.key});

  final List<Map<String, dynamic>> allCategories = const [
    {'icon': Icons.build, 'label': 'Outils'},
    {'icon': Icons.format_paint, 'label': 'Peinture'},
    {'icon': Icons.bolt, 'label': 'Electricité'},
    {'icon': Icons.water_drop, 'label': 'Plomberie'},
    {'icon': Icons.security, 'label': 'Sécurité'},
    {'icon': Icons.straighten, 'label': 'Mesure'},
    {'icon': Icons.inventory_2, 'label': 'Stockage'},
    {'icon': Icons.cleaning_services, 'label': 'Nettoyage'},
    {'icon': Icons.handyman, 'label': 'Serrage & fixation'},
    {'icon': Icons.build, 'label': 'Perçage & vissage'},
    {'icon': Icons.auto_awesome, 'label': 'Façonnage & finition'},
    {'icon': Icons.content_cut, 'label': 'Coupe & sciage'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toutes les catégories'),
        backgroundColor: const Color(0xFFF8F9FA),
        foregroundColor: Colors.black45,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.9,
          ),
          itemCount: allCategories.length,
          itemBuilder: (context, index) {
            final cat = allCategories[index];
            return GestureDetector(
              onTap: () {
                // Navigation corrigée : chaque icône mène à sa page spécifique
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryDetailPage(
                      categoryName: cat['label'] as String,
                    ),
                  ),
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundColor: const Color(0xFFF8F9FA),
                    child: Icon(
                      cat['icon'] as IconData,
                      size: 28,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    cat['label'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}