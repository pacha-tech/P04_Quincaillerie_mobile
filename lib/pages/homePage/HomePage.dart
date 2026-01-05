import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Product.dart';
import 'Category.dart';

class ProductSearch {
  final String name;
  final String description;
  final List<dynamic> prices;

  ProductSearch({required this.name, required this.description, required this.prices});

  factory ProductSearch.fromJson(Map<String, dynamic> json) {
    return ProductSearch(
      name: json['name'],
      description: json['description'],
      prices: json['priceSearchProductsDTO'],
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<ProductSearch> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  Future<void> _handleSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _hasSearched = false;
        _searchResults = [];
      });
      return;
    }
    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });
    try {
      final url = Uri.parse('http://10.0.2.2:9010/quincaillerie/products/search?name=${Uri.encodeComponent(query)}');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        setState(() {
          _searchResults = body.map((item) => ProductSearch.fromJson(item)).toList();
          _isSearching = false;
        });
      }
    } catch (e) {
      setState(() => _isSearching = false);
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
            const Text('LOGO', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 42,
                decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: _handleSearch,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un matériel...',
                    prefixIcon: const Icon(Icons.search, color: Colors.blue, size: 20),
                    suffixIcon: _hasSearched ? IconButton(icon: const Icon(Icons.close, size: 18), onPressed: () {
                      _searchController.clear();
                      _handleSearch("");
                    }) : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.shopping_cart_rounded , color: Colors.brown),
            const SizedBox(width: 10),
            const Icon(Icons.person , color: Colors.brown),
          ],
        ),
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : _hasSearched ? _buildSearchResults() : _buildDefaultHome(),
    );
  }

  Widget _buildStyledCard({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }

  // --- RÉSULTATS DE RECHERCHE ---
  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône appropriée quand rien n'est trouvé
            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "Oups ! Produit introuvable",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            const Text(
              "Essayez avec d'autres mots-clés",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final product = _searchResults[index];
        return _buildStyledCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                    Text(product.description, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  ],
                ),
              ),
              const Divider(height: 1),
              ...product.prices.map((p) {
                // LOGIQUE DE STOCK UNIQUEMENT ICI (PAGE RECHERCHE)
                bool isAvailable = p['stock'].toString().toUpperCase() == "DISPONIBLE";
                return ListTile(
                  leading: const Icon(Icons.storefront, color: Colors.blueGrey),
                  title: Text(p['quincaillerieName'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    isAvailable ? "En stock" : "Épuisé",
                    style: TextStyle(color: isAvailable ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  trailing: Text("${p['price']} FCFA", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  // --- ACCUEIL PAR DÉFAUT ---
  Widget _buildDefaultHome() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Text('Catégories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          _buildHorizontalCategories(),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Text('Les plus populaires', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          _buildStyledCard(
            child: Column(
              children: [
                _buildSimpleRow(Icons.architecture, "Fer à béton 12mm", "6.500 FCFA"),
                const Divider(indent: 50, height: 1),
                _buildSimpleRow(Icons.format_paint, "Peinture à huile (5L)", "14.200 FCFA"),
                const Divider(indent: 50, height: 1),
                _buildSimpleRow(Icons.bolt, "Disjoncteur Merlin Gerin", "4.800 FCFA"),
                const Divider(indent: 50, height: 1),
                _buildSimpleRow(Icons.water_drop, "Robinet mitigeur Cuisine", "12.500 FCFA"),
                const Divider(indent: 50, height: 1),
                _buildSimpleRow(Icons.grid_view, "Carreaux Grès Cérame (m²)", "8.900 FCFA"),
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Text('Promotions Flash', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red)),
          ),
          _buildStyledCard(
            child: Column(
              children: [
                _buildSimpleRow(Icons.construction, "Perceuse à percussion 750W", "28.000 FCFA", isPromo: true),
                const Divider(indent: 50, height: 1),
                _buildSimpleRow(Icons.shopping_bag, "Sac Ciment CPJ (x5)", "23.500 FCFA", isPromo: true),
                const Divider(indent: 50, height: 1),
                _buildSimpleRow(Icons.lightbulb, "Pack 10 Lampes LED 9W", "7.500 FCFA", isPromo: true),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSimpleRow(IconData icon, String title, String price, {bool isPromo = false}) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isPromo ? Colors.red[50] : Colors.blue[50],
        child: Icon(icon, color: isPromo ? Colors.red : Colors.blue, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(price, style: TextStyle(fontWeight: FontWeight.bold, color: isPromo ? Colors.red : Colors.green, fontSize: 14)),
          if (isPromo) const Text("-15%", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
      onTap: () {},
    );
  }

  Widget _buildHorizontalCategories() {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        children: [
          _buildCatItem(Icons.build, "Outils"),
          _buildCatItem(Icons.bolt, "Élec"),
          _buildCatItem(Icons.water_drop, "Plomberie"),
          _buildCatItem(Icons.format_paint, "Peinture"),
          _buildCatItem(Icons.grid_view, "Carrelage"),
          _buildCatItem(Icons.architecture, "Gros Œuvre"),
          _buildCatItem(Icons.straighten, "Mesure"),
          _buildCatItem(Icons.window, "Menuiserie"),
          _buildCatItem(Icons.grass, "Jardin"),
        ],
      ),
    );
  }

  Widget _buildCatItem(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 5)],
            ),
            child: Icon(icon, color: Colors.blueGrey),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}