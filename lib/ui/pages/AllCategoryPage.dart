import 'package:brixel/service/CategoryService.dart';
import 'package:flutter/material.dart';
import 'package:brixel/ui/theme/AppColors.dart';
import 'package:brixel/data/modele/Category.dart';
import 'category_detail_page.dart';


class AllCategoriesPage extends StatefulWidget {
  const AllCategoriesPage({super.key});

  @override
  State<AllCategoriesPage> createState() => _AllCategoriesPageState();
}

class _AllCategoriesPageState extends State<AllCategoriesPage> {
  late Future<List<Category?>> _categoriesFuture;
  final CategoryService _categoryService = CategoryService();

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _categoryService.getAllCategory();
  }

  // Utilitaire pour mapper les noms de catégories à des icônes
  IconData _getIconForCategory(String name) {
    name = name.toLowerCase();
    if (name.contains('outil')) return Icons.build_rounded;
    if (name.contains('peinture')) return Icons.format_paint_rounded;
    if (name.contains('electri')) return Icons.bolt_rounded;
    if (name.contains('plomb')) return Icons.water_drop_rounded;
    if (name.contains('secu')) return Icons.security_rounded;
    if (name.contains('mesure')) return Icons.straighten_rounded;
    if (name.contains('nettoyage')) return Icons.cleaning_services_rounded;
    return Icons.category_rounded; // Icône par défaut
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text(
          'Catégories',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: FutureBuilder<List<Category?>>(
        future: _categoriesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorState();
          }

          final categories = snapshot.data?.whereType<Category>().toList() ?? [];

          if (categories.isEmpty) {
            return const Center(child: Text("Aucune catégorie disponible"));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 15,
              mainAxisSpacing: 20,
              childAspectRatio: 0.85,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              return _buildCategoryItem(context, cat);
            },
          );
        },
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, Category cat) {
    return Column(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CategoryDetailPage(
                        categoryName: cat.name,
                      ),
                    ),
                  );
                },
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIconForCategory(cat.name),
                      size: 30,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          cat.name,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off_rounded, size: 60, color: AppColors.notifError),
          const SizedBox(height: 16),
          const Text("Erreur de connexion au serveur"),
          TextButton(
            onPressed: () => setState(() {
              _categoriesFuture = _categoryService.getAllCategory();
            }),
            child: const Text("Réessayer", style: TextStyle(color: AppColors.accent)),
          )
        ],
      ),
    );
  }
}