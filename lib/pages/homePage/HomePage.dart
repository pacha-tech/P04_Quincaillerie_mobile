import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/UserProvider.dart';
import '../../service/ApiService.dart';
import '../../widgets/FooterHomePage.dart';
import '../PromotionsPage.dart';
import '../authPages/client/LoginPage.dart';
import '../recommended_products_page.dart';
import '../../widgets/CategoryWidget.dart';
import '../../widgets/SearchBarWidget.dart';
import '../SearchResultPage.dart';
import '../AllCategoryPage.dart';
import '../PanierPage.dart';
import '../ProfilePage.dart';
import '../notifications_page.dart';
import '../catalog_page.dart';
import '../authPages/vendeur/RegisterVendeur1.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService _apiService = ApiService();

  bool _hasSearched = false;
  bool _isSearching = false;
  bool _isloading = false;

  Future<void> _handleSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _hasSearched = false);
      return;
    }

    setState(() {
      _isloading = true;
      _hasSearched = true;
    });

    try {
      final results = await _apiService.searchProducts(query);
      if (mounted) {
        setState(() => _isloading = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchResultsPage(
              results: results,
              searchQuery: query,
            ),
          ),
        );
        _searchController.clear();
        _hasSearched = false;
        _isSearching = false;
      }
    } catch (e) {
      setState(() => _isloading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erreur de connexion au serveur')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final bool isConnected = userProvider.isAuthenticated;
        final String role = userProvider.role ?? "GUEST";

        return Scaffold(
          backgroundColor: const Color(0xFFF8F9FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Row(
              children: [
                if (!_isSearching && !_isloading)
                  const Text(
                    'LOGO',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                const SizedBox(width: 12),
                Expanded(
                  child: SearchBarWidget(
                    controller: _searchController,
                    hasSearched: _hasSearched,
                    onSearch: _handleSearch,
                    isloading: _isloading,
                    onClear: () {
                      setState(() => _isloading = false);
                      _searchController.clear();
                    },
                    onFocusChanged: (focused) => setState(() => _isSearching = focused),
                  ),
                ),
                if (!_isloading && !_isSearching) ...[
                  _buildAppBarIcon(
                    Icons.person,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProfilePage()),
                    ),
                  ),
                  _buildAppBarIcon(
                    Icons.notifications,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NotificationsPage()),
                    ),
                  ),
                  _buildAppBarIcon(
                    Icons.shopping_cart,
                        () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CartPage()),
                    ),
                  ),
                ],
                if (_isloading)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isloading = false;
                      });
                      _searchController.clear();
                    },
                    child: const Text("Annuler", style: TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Catégories
                    _buildSectionHeader(
                      "Catégories",
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AllCategoriesPage()),
                      ),
                    ),
                    _buildCategoryList(),

                    const SizedBox(height: 15),

                    // Bannière dynamique
                    if (!isConnected)
                      _buildGuestBanner()
                    else if (role == "VENDEUR" || role == "ADMIN_STORE")
                      _buildVendeurBanner()
                    else
                      _buildClientBanner(),

                    const SizedBox(height: 20),

                    // Produits recommandés
                    _buildSectionHeader(
                      "Pour vous",
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RecommendedProductsPage()),
                      ),
                    ),
                    _buildProductCard("Fer à béton 12mm", "6.500 FCFA"),
                    _buildProductCard("Ciment Dangote 42.5", "5.100 FCFA"),

                    // Promotions
                    _buildSectionHeader(
                      "Promotions",
                          () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const PromotionsPage()),
                      ),
                    ),
                    _buildProductCard("Perceuse 750W", "28.000 FCFA", isPromo: true),

                    const SizedBox(height: 15),
                    AppFooter(isloging: isConnected),
                  ],
                ),
              ),
              if (_isloading) _buildLoadingOverlay(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAppBarIcon(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: Colors.black, size: 22),
      onPressed: onPressed,
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onPressed) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        TextButton(onPressed: onPressed, child: const Text("Voir plus")),
      ],
    );
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 80,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          CategoryWidget(icon: Icons.build, name: "Outils"),
          CategoryWidget(icon: Icons.format_paint, name: "Peinture"),
          CategoryWidget(icon: Icons.electric_bolt, name: "Electricite"),
          CategoryWidget(icon: Icons.water_drop_outlined, name: "Plomberie"),
          CategoryWidget(icon: Icons.cleaning_services, name: "Nettoyage"),
        ],
      ),
    );
  }

  Widget _buildGuestBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.brown.shade700, Colors.brown.shade900]),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Tout pour vos chantiers,\nau meilleur prix",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          const Text(
            "Comparez les prix des quincailleries au Cameroun. Outils, matériaux, équipement...",
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildBannerButton(
                  "Explorer",
                  Colors.orange.shade700,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CatalogPage()),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildBannerButton(
                  "Vendre ici",
                  Colors.white10,
                      () {
                    // Meilleure UX : rediriger vers la connexion
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterVendeur1()
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVendeurBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade900,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Espace Gestionnaire", style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
          const Text(
            "Mettez à jour vos stocks pour apparaître en tête de liste.",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 15),
          _buildBannerButton("Gérer mon stock", Colors.blueAccent, () {
            // À implémenter selon ta logique
          }),
        ],
      ),
    );
  }

  Widget _buildClientBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade800,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Bon retour parmi nous !", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          Text("Consultez vos commandes en cours dans votre historique.", style: TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildBannerButton(String label, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label),
    );
  }

  Widget _buildProductCard(String title, String price, {bool isPromo = false}) {
    return Card(
      child: ListTile(
        leading: Icon(isPromo ? Icons.discount : Icons.star, color: isPromo ? Colors.red : Colors.blue),
        title: Text(title),
        trailing: Text(
          price,
          style: TextStyle(color: isPromo ? Colors.red : Colors.green, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.blue),
            SizedBox(height: 10),
            Text("Patientez...", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}