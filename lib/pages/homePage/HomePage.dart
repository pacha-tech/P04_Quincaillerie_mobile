import 'package:flutter/material.dart';
import 'package:p04_mobile/pages/widgets/SearchBarWidget.dart';
import 'package:p04_mobile/widgets/CategoryWidget.dart';
import '../../modele/Product.dart';
import '../../service/ApiService.dart';

// Imports des pages de redirection
import '../SearchResultPage.dart';
import '../category_detail_page.dart';
import '../all_categories_page.dart';
import '../cart_page.dart';
import '../profile_page.dart';
import '../notifications_page.dart';
import '../catalog_page.dart';
import '../become_seller_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _hasSearched = false;

  Future<void> _handleSearch(String query) async {
    print("debut de la recherche pour: $query");
    if (query
        .trim()
        .isEmpty) {
      setState(() {
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _hasSearched = true;
    });

    try {
      print("Appel de l'API ...");
      final results = await _apiService.searchProducts(query);
      print("Le resultat recu: ${results.length}");

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SearchResultsPage(
                  results: results,
                  searchQuery: query,
                ),
          ),
        );
      }
    } catch (e) {
      print("Erreur API ");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur de connexion au serveur')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Text('LOGO', style: TextStyle(
                color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(
                child: SearchBarWidget(
                  controller: _searchController,
                  hasSearched: _hasSearched,
                  onSearch: _handleSearch,
                  onClear: () {
                    _searchController.clear();
                    _handleSearch("");
                  },
                )
            ),
            IconButton(
              icon: const Icon(Icons.person, color: Colors.black, size: 20),
              onPressed: () =>
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => const ProfilePage())),
            ),
            IconButton(
              icon: const Icon(
                  Icons.shopping_cart, color: Colors.black, size: 20),
              onPressed: () =>
                  Navigator.push(context, MaterialPageRoute(
                      builder: (context) => const CartPage())),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER CATÉGORIES ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Catégories", style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(
                      onPressed: () =>
                          Navigator.push(context, MaterialPageRoute(
                              builder: (context) => const AllCategoriesPage())),
                      child: const Text("Voir plus")
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [
                  CategoryWidget(icon: Icons.build, name: "Outils"),
                  CategoryWidget(icon: Icons.format_paint, name: "Peinture"),
                  CategoryWidget(icon: Icons.format_paint, name: "Peinture"),
                  CategoryWidget(icon: Icons.format_paint, name: "Peinture"),
                  CategoryWidget(icon: Icons.format_paint, name: "Peinture"),
                  CategoryWidget(icon: Icons.format_paint, name: "Peinture"),
                  CategoryWidget(icon: Icons.format_paint, name: "Peinture"),
                  CategoryWidget(icon: Icons.format_paint, name: "Peinture"),
                  CategoryWidget(icon: Icons.format_paint, name: "Peinture"),
                ],
              ),
            ),
            // --- BANNIÈRE PRINCIPALE ---
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.brown, borderRadius: BorderRadius.circular(15)),
              child: Column(
                children: [
                  const Text("Tout pour vos chantiers", style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(child: ElevatedButton(
                          onPressed: () {}, child: const Text("Catalogue"))),
                      const SizedBox(width: 10),
                      Expanded(child: OutlinedButton(onPressed: () {},
                          child: const Text("Vendre", style: TextStyle(
                              color: Colors.white)))),
                    ],
                  )
                ],
              ),
            ),

            // --- SECTION POUR VOUS ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Pour vous", style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () {}, child: const Text("Voir plus")),
                ],
              ),
            ),
            const Card(
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                leading: Icon(Icons.star, color: Colors.blue),
                title: Text("Fer à béton 12mm"),
                trailing: Text("6.500 FCFA", style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),

            // --- SECTION PROMOTIONS ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Promotions", style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
                  TextButton(onPressed: () {}, child: const Text("Voir plus")),
                ],
              ),
            ),
            const Card(
              margin: EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                leading: Icon(Icons.discount, color: Colors.red),
                title: Text("Perceuse 750W"),
                trailing: Text("28.000 FCFA", style: TextStyle(
                    color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}