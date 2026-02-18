import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../service/ApiService.dart';
import '../../widgets/FooterHomePage.dart';
import '../PromotionsPage.dart';
import '../recommended_products_page.dart';
import '../../widgets/CategoryWidget.dart';
import '../../widgets/SearchBarWidget.dart';
import '../SearchResultPage.dart';
import '../AllCategoryPage.dart';
import '../PanierPage.dart';
import '../profile_page.dart';
import '../notifications_page.dart';
import '../catalog_page.dart';
import '../authPages/vendeur/become_seller_page.dart';


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
  bool _islogin = false;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    print("isLogin1 vaut: $_islogin");
  }

  void _checkLoginStatus(){
    setState(() {
      _islogin = FirebaseAuth.instance.currentUser != null ;
    });
  }


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
                  if(!_islogin)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20), // Plus d'espace pour respirer
                      decoration: BoxDecoration(
                        // Utilisation d'un dégradé pour un aspect plus "Premium"
                        gradient: LinearGradient(
                          colors: [Colors.brown.shade700, Colors.brown.shade900],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15), // Bords plus arrondis
                        boxShadow: [
                          BoxShadow(
                            color: Colors.brown.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Aligné à gauche
                        children: [
                          const Text(
                            "Tout pour vos chantiers,\nau meilleur prix",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22, // Légèrement plus grand
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            "Comparez les prix des quincailleries au Cameroun. Outils, matériaux, équipement...",
                            style: TextStyle(
                              color: Colors.white70, // Blanc cassé pour le texte secondaire
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              // BOUTON EXPLORER
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => const CatalogPage()),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange.shade700,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: const Text("Explorer", style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              // BOUTON DEVENIR VENDEUR (Conditionnel)
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    // Si pas connecté, on envoie au login, sinon vers BecomeSeller
                                    if (!_islogin) {
                                      // Tu peux afficher un petit message ou rediriger
                                      ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Veuillez vous connecter d'abord"))
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const BecomeSellerPage()),
                                      );
                                    }
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.white54),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                  ),
                                  child: const Text("Vendre ici"),
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
                  AppFooter(isloging: _islogin),

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