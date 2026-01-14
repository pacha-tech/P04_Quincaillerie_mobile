import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Imports des pages (ajuste les chemins selon ton projet)
import 'category_detail_page.dart';
import 'all_categories_page.dart';
import 'cart_page.dart';
import 'profile_page.dart';
import 'notifications_page.dart';
import 'catalog_page.dart';           // pour Explorer le catalogue
import 'become_seller_page.dart';     // pour Devenir vendeur

class ProductSearch {
  final String name;
  final String description;
  final List<dynamic> prices;

  ProductSearch({
    required this.name,
    required this.description,
    required this.prices,
  });

  factory ProductSearch.fromJson(Map<String, dynamic> json) {
    return ProductSearch(
      name: json['name'] ?? 'Sans nom',
      description: json['description'] ?? '',
      prices: json['priceSearchProductsDTO'] ?? [],
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
      final url = Uri.parse(
        'http://172.17.0.1:9010/quincaillerie/products/search?name=${Uri.encodeComponent(query)}',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        setState(() {
          _searchResults = body.map((item) => ProductSearch.fromJson(item)).toList();
          _isSearching = false;
        });
      } else {
        setState(() => _isSearching = false);
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
            const Text(
              'LOGO',
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 18),
            ),
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
                    hintText: 'Rechercher un produit, une marque,...',
                    prefixIcon: const Icon(Icons.search, color: Colors.black54, size: 20),
                    suffixIcon: _hasSearched
                        ? IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _handleSearch("");
                      },
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 5),
            // Profil
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.person, color: Colors.black, size: 20),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              },
              tooltip: 'Profil',
            ),
            const SizedBox(width: 0),
            // Panier
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.shopping_cart_rounded, color: Colors.black, size: 20),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const CartPage()),
                );
              },
              tooltip: 'Panier',
            ),
            const SizedBox(width: 0),
            // Notifications
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: const Icon(Icons.notifications_outlined, color: Colors.black, size: 20),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NotificationsPage()),
                );
              },
              tooltip: 'Notifications',
            ),
          ],
        ),
      ),
      body: _isSearching
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : _hasSearched
          ? _buildSearchResults()
          : _buildDefaultHome(),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "Oups ! Produit introuvable",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            const Text("Essayez avec d'autres mots-clés", style: TextStyle(color: Colors.grey)),
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
                bool isAvailable = (p['stock'] ?? '').toString().toUpperCase() == "DISPONIBLE";
                return ListTile(
                  leading: const Icon(Icons.storefront, color: Colors.blueGrey),
                  title: Text(p['quincaillerieName'] ?? 'Inconnu', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    isAvailable ? "En stock" : "Épuisé",
                    style: TextStyle(color: isAvailable ? Colors.green : Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  trailing: Text("${p['price'] ?? '?'} FCFA", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDefaultHome() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Catégories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AllCategoriesPage()),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Voir plus',
                    style: TextStyle(color: Colors.blue, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

          _buildHorizontalCategories(),

          Padding(
            padding: const EdgeInsets.fromLTRB(1, 0, 1, 10),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.brown,
                borderRadius: BorderRadius.circular(11),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tout pour vos chantiers, au meilleur prix',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Comparez les prix de certaines quincailleries au Cameroun. Outils, matériaux, équipement, tout est là.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CatalogPage()),
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.yellow[800],
                            side: BorderSide(color: Colors.yellow[800]!),
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Explorer le catalogue'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const BecomeSellerPage()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            side: BorderSide(color: Colors.yellow[800]!),
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Devenir vendeur'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: Text('Pour vous', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            child: Text('Promotions ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
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

          // ── BLOC FINAL AMÉLIORÉ (juste après Promotions) ────────────────────────
          Container(
            width: double.infinity,
            color: Colors.brown,
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 60),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre appel à l'action vendeur
                const Text(
                  'Vous avez une quincaillerie ?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Rejoignez QuincaMarket et touchez des milliers de clients au Cameroun. Inscription gratuite, commissions transparentes.',
                  style: TextStyle(fontSize: 14, color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 24),

                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const BecomeSellerPage()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[800],
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Commencer à vendre',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Présentation QuincaMarket
                Center(
                  child: Text(
                    'QuincaMarket',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow[800],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'La première marketplace de quincaillerie au Cameroun.\nTrouvez tous vos outils et matériaux de construction.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white70, height: 1.4),
                  ),
                ),

                const SizedBox(height: 40),

                // Liens rapides
                const Text(
                  'Liens rapides',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 24,
                  runSpacing: 12,
                  children: [
                    TextButton(onPressed: () {}, child: const Text('Service client', style: TextStyle(color: Colors.white70))),
                    TextButton(onPressed: () {}, child: const Text('Contact', style: TextStyle(color: Colors.white70))),
                    TextButton(onPressed: () {}, child: const Text('Catalogue', style: TextStyle(color: Colors.white70))),
                    TextButton(onPressed: () {}, child: const Text('Promotion', style: TextStyle(color: Colors.white70))),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const BecomeSellerPage()),
                        );
                      },
                      child: const Text('Devenir vendeur', style: TextStyle(color: Colors.white70)),
                    ),
                    TextButton(onPressed: () {}, child: const Text('À propos', style: TextStyle(color: Colors.white70))),
                    TextButton(onPressed: () {}, child: const Text('Centre d’aide', style: TextStyle(color: Colors.white70))),
                    TextButton(onPressed: () {}, child: const Text('Livraison', style: TextStyle(color: Colors.white70))),
                    TextButton(onPressed: () {}, child: const Text('Retour et remboursement', style: TextStyle(color: Colors.white70))),
                    TextButton(onPressed: () {}, child: const Text('Conditions générales', style: TextStyle(color: Colors.white70))),
                  ],
                ),

                const SizedBox(height: 40),

                // Contacts
                const Text('Douala, Cameroun', style: TextStyle(fontSize: 14, color: Colors.white70)),
                const Text('+237 6XX XXX XXX', style: TextStyle(fontSize: 14, color: Colors.white70)),
                const Text('contact@quincamarket.cm', style: TextStyle(fontSize: 14, color: Colors.white70)),

                const SizedBox(height: 24),

                const Text(
                  'Paiements sécurisés',
                  style: TextStyle(fontSize: 14, color: Colors.white70, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    Text('Orange Money   •   ', style: TextStyle(color: Colors.white70)),
                    Text('MTN MoMo', style: TextStyle(color: Colors.white70)),
                  ],
                ),

                const SizedBox(height: 48),

                const Center(
                  child: Text(
                    '© 2024 QuincaMarket. Tous droits réservés.',
                    style: TextStyle(fontSize: 12, color: Colors.white60),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
          Text(
            price,
            style: TextStyle(fontWeight: FontWeight.bold, color: isPromo ? Colors.red : Colors.green, fontSize: 14),
          ),
          if (isPromo) const Text("-15%", style: TextStyle(color: Colors.red, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
      onTap: () {},
    );
  }

  Widget _buildHorizontalCategories() {
    final List<Map<String, dynamic>> categories = [
      {'icon': Icons.build, 'label': 'Outils'},
      {'icon': Icons.format_paint, 'label': 'Peinture'},
      {'icon': Icons.bolt, 'label': 'Electricité'},
      {'icon': Icons.water_drop, 'label': 'Plomberie'},
      {'icon': Icons.security, 'label': 'Sécurité'},
      {'icon': Icons.straighten, 'label': 'Mesure'},
      {'icon': Icons.inventory_2, 'label': 'Stockage'},
      {'icon': Icons.cleaning_services, 'label': 'Nettoyage'},
      {'icon': Icons.handyman, 'label': 'Serrage & fixation'},
    ];

    return SizedBox(
      height: 95,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryDetailPage(categoryName: cat['label'] as String),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white,
                    child: Icon(
                      cat['icon'] as IconData,
                      size: 28,
                      color: Colors.brown,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cat['label'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}