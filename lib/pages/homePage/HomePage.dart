import 'package:flutter/material.dart';
import '../../service/ApiService.dart';
import '../../widgets/app_footer.dart';
import '../PromotionsPage.dart';
import '../recommended_products_page.dart';
import '../../widgets/CategoryWidget.dart';
import '../../widgets/SearchBarWidget.dart';
import '../SearchResultPage.dart';
import '../all_categories_page.dart';
import '../PanierPage.dart';
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
  bool _isSearching = false;
  bool _isloading = false;

  Future<void> _handleSearch(String query) async {
    print("debut de la recherche pour: $query");
    if (query.trim().isEmpty) {
      setState(() {
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isloading = true;
      _hasSearched = true;
    });

    try {
      print("Appel de l'API ...");
      final results = await _apiService.searchProducts(query);
      print("Le resultat recu: ${results.length}");

      if (mounted) {
        _isloading = false;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SearchResultsPage(
              results: results,
              searchQuery: query,
            ),
          ),
        );

        setState(() {
          _searchController.clear(); // Vide le texte
          _hasSearched = false;      // Réinitialise l'état
          _isSearching = false;      // Enlève le focus si nécessaire
        });
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
            if(!_isSearching && !_isloading)
              const Text('LOGO',
                  style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(
              child: SearchBarWidget(
                controller: _searchController,
                hasSearched: _hasSearched,
                onSearch: _handleSearch,
                isloading: _isloading,
                onClear: () {
                  _isloading = false;
                  _searchController.clear();
                  _handleSearch("");
                },
                onFocusChanged: (focused) {
                  setState(() {
                    _isSearching = focused;
                  });
                },
              ),
            ),
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

            if (!_isloading && !_isSearching)
              IconButton(
                icon: const Icon(Icons.person, color: Colors.black, size: 20),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                ),
              ),
            if (!_isloading && !_isSearching)
              IconButton(
                icon: const Icon(Icons.notifications,
                    color: Colors.black, size: 20),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NotificationsPage())),
              ),
            if (!_isloading && !_isSearching)
              IconButton(
                icon: const Icon(Icons.shopping_cart,
                    color: Colors.black, size: 20),
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartPage())),
              ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(5),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Catégories",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const AllCategoriesPage())),
                          child: const Text("Voir plus")),
                    ],
                  ),
                  SizedBox(
                    height: 80,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: const [
                        CategoryWidget(icon: Icons.build, name: "Outils"),
                        CategoryWidget(icon: Icons.format_paint, name: "Peinture"),
                        CategoryWidget(icon: Icons.electric_bolt, name: "Electricite"),
                        CategoryWidget(icon: Icons.water_drop_outlined, name: "Plomberie"),
                        CategoryWidget(icon: Icons.cleaning_services, name: "Nettoyage"),
                        CategoryWidget(icon: Icons.content_cut, name: "Coupe & sciage"),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: Colors.brown,
                        borderRadius: BorderRadius.circular(5)),
                    child: Column(
                      children: [
                        const Text("Tout pour vos chantiers, au meilleur prix",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height:0),
                        const Text(
                            "Comparez les prix de certaines quincailleries au Cameroun. Outils, matériaux, équipement, tout est la.",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.normal)),
                        const SizedBox(height: 15),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const CatalogPage()),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.yellow[800],
                                  foregroundColor: Colors.black,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 0),
                                  minimumSize: const Size(double.infinity, 40),
                                ),
                                child: const Text("Explorer le catalogue", style: TextStyle(fontSize: 15)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const BecomeSellerPage()),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: Colors.black,
                                  elevation: 0,
                                  side: BorderSide(
                                    color: Colors.yellow.shade800,
                                    width: 1.5,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 0),
                                  minimumSize: const Size(double.infinity, 40),
                                ),
                                child: const Text(
                                  "Devenir vendeur",
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                            ),

                          ],
                        ),
                      ],
                    ),
                  ),

                  // --- SECTION POUR VOUS ---
                  Padding(
                    padding: const EdgeInsets.only(top: 15, bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Pour vous",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        TextButton(
                            onPressed: () {
                              // Tu peux créer cette page ou la renommer
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                      const RecommendedProductsPage()));
                            },
                            child: const Text("Voir plus")),
                      ],
                    ),
                  ),
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.star, color: Colors.blue),
                      title: Text("Fer à béton 12mm"),
                      trailing: Text("6.500 FCFA",
                          style: TextStyle(
                              color: Colors.green, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const Card(
                    child: ListTile(
                      leading: Icon(Icons.star, color: Colors.blue),
                      title: Text("Fer à béton 12mm"),
                      trailing: Text("6.500 FCFA",
                          style: TextStyle(
                              color: Colors.green, fontWeight: FontWeight.bold)),
                    ),
                  ),


                  // --- SECTION PROMOTIONS ---
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Promotions",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PromotionsPage(),
                              ),
                            );
                          },
                          child: const Text("Voir plus"),
                        ),

                      ],
                    ),
                  ),
                  const Card(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: ListTile(
                      leading: Icon(Icons.discount, color: Colors.red),
                      title: Text("Perceuse 750W"),
                      trailing: Text("28.000 FCFA",
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Card(
                    margin: EdgeInsets.symmetric(horizontal: 16),
                    child: ListTile(
                      leading: Icon(Icons.discount, color: Colors.red),
                      title: Text("Perceuse 750W"),
                      trailing: Text("28.000 FCFA",
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  const AppFooter(),

                ],
              ),
            ),
          ),
          if (_isloading)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Colors.blue,
                      ),
                      SizedBox(height: 10),
                      Text("Patientez..." , style: TextStyle(color: Colors.white))
                    ]
                ),
              )
            ),
        ]
      ),
    );
  }
}