
/*
import 'package:brixel/ui/pages/CartOverviewPage.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../../provider/UserProvider.dart';
import '../widgets/FooterHomePage.dart';
import '../theme/AppColors.dart';
import 'PromotionsPage.dart';
import 'recommended_products_page.dart';
import '../widgets/CategoryWidget.dart';
import '../widgets/SearchBarWidget.dart';
import 'SearchResultPage.dart';
import 'AllCategoryPage.dart';
import 'ProfilePage.dart';
import 'notifications_page.dart';
import 'CatalogPage.dart';
import 'authPages/vendeur/RegisterVendeur1.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final String _boxName = 'productBox';
  bool _hasSearched = false;
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _hasSearched = false);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SearchResultsPage(searchQuery: query)),
    );
    _searchController.clear();
    setState(() {
      _hasSearched = false;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final bool isConnected = userProvider.isAuthenticated;
        final String role = userProvider.role ?? "GUEST";

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: _buildAppBar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Catégories ─────────────────────────────────────────
                _buildSectionHeader(
                  "Catégories",
                  Icons.grid_view_rounded,
                      () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const AllCategoriesPage())),
                ),
                const SizedBox(height: 10),
                _buildCategoryList(),
                const SizedBox(height: 20),

                // ── Bannière dynamique ─────────────────────────────────
                if (!isConnected)
                  _buildGuestBanner()
                else if (role == "VENDEUR")
                  _buildVendeurBanner()
                else
                  _buildClientBanner(),

                const SizedBox(height: 24),

                // ── Produits recommandés ───────────────────────────────
                _buildSectionHeader(
                  "Pour vous",
                  Icons.auto_awesome_rounded,
                      () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const RecommendedProductsPage())),
                ),
                const SizedBox(height: 10),
                _buildProductCard("Fer à béton 12mm", "6 500 FCFA"),
                _buildProductCard("Ciment Dangote 42.5", "5 100 FCFA"),
                const SizedBox(height: 20),

                // ── Promotions ─────────────────────────────────────────
                _buildSectionHeader(
                  "Promotions",
                  Icons.local_offer_outlined,
                      () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const PromotionsPage())),
                ),
                const SizedBox(height: 10),
                _buildProductCard("Perceuse 750W", "28 000 FCFA", isPromo: true),

                const SizedBox(height: 24),
                FooterHomePage(isloging: isConnected),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      titleSpacing: 12,
      title: Row(
        children: [
          // Logo / nom app
          if (!_isSearching)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.construction_rounded,
                        color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Brixel',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),

          // Barre de recherche
          Expanded(
            child: SearchBarWidget(
              controller: _searchController,
              hasSearched: _hasSearched,
              onSearch: _handleSearch,
              onClear: () => _searchController.clear(),
              onFocusChanged: (focused) => setState(() => _isSearching = focused),
            ),
          ),

          // Icônes
          if (!_isSearching) ...[
            _buildAppBarIcon(
              Icons.person_outline_rounded,
                  () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProfilePage())),
            ),
            _buildAppBarIcon(
              Icons.notifications_outlined,
                  () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const NotificationsPage())),
            ),
            _buildCartBadge(),
          ],
        ],
      ),
    );
  }

  Widget _buildAppBarIcon(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: Colors.white70, size: 22),
      onPressed: onPressed,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      constraints: const BoxConstraints(),
    );
  }

  // ── En-tête de section ─────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, IconData icon, VoidCallback onTap) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: 0.2,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.07),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Text(
                  "Voir plus",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 3),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 9, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Liste catégories ───────────────────────────────────────────────────────
  Widget _buildCategoryList() {
    return SizedBox(
      height: 82,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          CategoryWidget(icon: Icons.build_rounded, name: "Outils"),
          CategoryWidget(icon: Icons.format_paint_rounded, name: "Peinture"),
          CategoryWidget(icon: Icons.electric_bolt_rounded, name: "Électricité"),
          CategoryWidget(icon: Icons.water_drop_rounded, name: "Plomberie"),
          CategoryWidget(icon: Icons.cleaning_services_rounded, name: "Nettoyage"),
        ],
      ),
    );
  }

  // ── Bannières ──────────────────────────────────────────────────────────────
  Widget _buildGuestBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Cameroun · Yaoundé & Douala",
              style: TextStyle(
                  color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Tout pour vos chantiers,\nau meilleur prix",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Comparez les prix des quincailleries. Outils, matériaux, équipement...",
            style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildBannerButton(
                  label: "Explorer",
                  icon: Icons.search_rounded,
                  bgColor: AppColors.accent,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CatalogPage())),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildBannerButton(
                  label: "Vendre ici",
                  icon: Icons.storefront_rounded,
                  bgColor: Colors.white.withOpacity(0.12),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const RegisterVendeur1())),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.inventory_2_outlined,
                color: Colors.white70, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.starYellow.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Espace Gestionnaire",
                    style: TextStyle(
                        color: AppColors.starYellow,
                        fontSize: 10,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Mettez à jour vos stocks pour apparaître en tête.",
                  style: TextStyle(
                      color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "Gérer",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.priceGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.waving_hand_rounded,
                color: AppColors.priceGreen, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bon retour parmi nous !",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 3),
                Text(
                  "Consultez vos commandes en cours.",
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerButton({
    required String label,
    required IconData icon,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 15),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Carte produit ──────────────────────────────────────────────────────────
  Widget _buildProductCard(String title, String price, {bool isPromo = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isPromo
                  ? AppColors.accent.withOpacity(0.08)
                  : AppColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isPromo ? Icons.local_offer_rounded : Icons.star_rounded,
              color: isPromo ? AppColors.accent : AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                ),
                if (isPromo)
                  Container(
                    margin: const EdgeInsets.only(top: 3),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "EN PROMOTION",
                      style: TextStyle(
                          color: AppColors.accent,
                          fontSize: 9,
                          fontWeight: FontWeight.w900),
                    ),
                  ),
              ],
            ),
          ),
          Text(
            price,
            style: TextStyle(
              color: isPromo ? AppColors.accent : AppColors.priceGreen,
              fontWeight: FontWeight.w900,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 12,
            color: Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  // ── Badge panier ───────────────────────────────────────────────────────────
  Widget _buildCartBadge() {
    return ValueListenableBuilder(
      valueListenable: Hive.box(_boxName).listenable(),
      builder: (context, Box box, _) {
        final int count =
            box.values.map((item) => item['idQuincaillerie']).toSet().length;
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_rounded,
                  color: Colors.white70, size: 22),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartOverviewPage()),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              constraints: const BoxConstraints(),
            ),
            if (count > 0)
              Positioned(
                right: 2,
                top: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      '$count',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w900),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
 */

import 'dart:async';
import 'package:brixel/data/modele/Price.dart';
import 'package:brixel/data/modele/ProductSearch.dart';
import 'package:brixel/ui/pages/CartOverviewPage.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../../data/modele/QuincaillerieWithProductInPromotion.dart';
import '../../provider/UserProvider.dart';
import '../../service/PromotionService.dart';
import '../widgets/FooterHomePage.dart';
import '../theme/AppColors.dart';
import 'PromotionsPage.dart';
import 'QuincaillerielDetailsPage.dart';
import 'recommended_products_page.dart';
import '../widgets/CategoryWidget.dart';
import '../widgets/SearchBarWidget.dart';
import 'SearchResultPage.dart';
import 'AllCategoryPage.dart';
import 'ProfilePage.dart';
import 'notifications_page.dart';
import 'CatalogPage.dart';
import 'authPages/vendeur/RegisterVendeur1.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final String _boxName = 'productBox';
  bool _hasSearched = false;
  bool _isSearching = false;

  late Future<List<ProductSearch>> _promotionFuture;

  @override
  void initState() {
    super.initState();
    _promotionFuture = PromotionService().getAllProductInPromotion();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _hasSearched = false);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => SearchResultsPage(searchQuery: query)),
    );
    _searchController.clear();
    setState(() {
      _hasSearched = false;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        final bool isConnected = userProvider.isAuthenticated;
        final String role = userProvider.role ?? "GUEST";

        return Scaffold(
          backgroundColor: AppColors.surface,
          appBar: _buildAppBar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(
                  "Catégories",
                  Icons.grid_view_rounded,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AllCategoriesPage()),
                  ),
                ),
                const SizedBox(height: 10),
                _buildCategoryList(),
                const SizedBox(height: 20),

                if (!isConnected)
                  _buildGuestBanner()
                else if (role == "VENDEUR")
                  _buildVendeurBanner()
                else
                  _buildClientBanner(),

                const SizedBox(height: 24),

                _buildSectionHeader(
                  "Pour vous",
                  Icons.auto_awesome_rounded,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RecommendedProductsPage()),
                  ),
                ),
                const SizedBox(height: 10),
                _buildProductCard("Fer à béton 12mm", "6 500 FCFA", onTap: () {}),
                _buildProductCard("Ciment Dangote 42.5", "5 100 FCFA", onTap: () {}),
                const SizedBox(height: 20),

                // ── SECTION PROMOTIONS DYNAMIQUE ───────────────────────
                _buildSectionHeader(
                  "Promotions",
                  Icons.local_offer_outlined,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PromotionsPage()),
                  ),
                ),
                const SizedBox(height: 10),

                FutureBuilder<List<ProductSearch>>(
                  future: _promotionFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return _buildProductCard("Aucune promotion active", "-- FCFA", isPromo: true);
                    }

                    // On prend les 3 premiers produits en promotion
                    final List<ProductSearch> allPromoProducts = snapshot.data!.take(3).toList();

                    return Column(
                      children: allPromoProducts.map((product) {
                        // On récupère le premier prix dispo (car c'est une liste dans le nouveau DTO)
                        final firstPrice = product.prices.isNotEmpty ? product.prices.first : null;

                        return _buildProductCard(
                          product.name,
                          firstPrice != null
                              ? "${firstPrice.pricePromo.toInt()} FCFA"
                              : "Prix indisponible",
                          isPromo: true,
                          imageUrl: product.imageUrl,
                          oldPrice: firstPrice != null ? "${firstPrice.price.toInt()} FCFA" : null,
                          discountTag: firstPrice != null ? "-${firstPrice.taux}%" : null,
                          onTap: () {
                            if (firstPrice != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => QuincaillerieDetailsPage(
                                    quincaillerieId: firstPrice.idQuincaillerie,
                                    product: product,
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      }).toList(),
                    );
                  },
                ),

                const SizedBox(height: 24),
                FooterHomePage(isloging: isConnected),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      titleSpacing: 12,
      title: Row(
        children: [
          if (!_isSearching)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.construction_rounded,
                        color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Brixel',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: SearchBarWidget(
              controller: _searchController,
              hasSearched: _hasSearched,
              onSearch: _handleSearch,
              onClear: () => _searchController.clear(),
              onFocusChanged: (focused) => setState(() => _isSearching = focused),
            ),
          ),

          if (!_isSearching) ...[
            _buildAppBarIcon(
              Icons.person_outline_rounded,
                  () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const ProfilePage())),
            ),
            _buildAppBarIcon(
              Icons.notifications_outlined,
                  () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const NotificationsPage())),
            ),
            _buildCartBadge(),
          ],
        ],
      ),
    );
  }

  Widget _buildAppBarIcon(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, color: Colors.white70, size: 22),
      onPressed: onPressed,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      constraints: const BoxConstraints(),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, VoidCallback onTap) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: 0.2,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.07),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: const [
                Text(
                  "Voir plus",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 3),
                Icon(Icons.arrow_forward_ios_rounded,
                    size: 9, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryList() {
    return SizedBox(
      height: 82,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          CategoryWidget(icon: Icons.build_rounded, name: "Outils"),
          CategoryWidget(icon: Icons.format_paint_rounded, name: "Peinture"),
          CategoryWidget(icon: Icons.electric_bolt_rounded, name: "Électricité"),
          CategoryWidget(icon: Icons.water_drop_rounded, name: "Plomberie"),
          CategoryWidget(icon: Icons.cleaning_services_rounded, name: "Nettoyage"),
        ],
      ),
    );
  }

  Widget _buildGuestBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Cameroun · Yaoundé & Douala",
              style: TextStyle(
                  color: AppColors.accent, fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            "Tout pour vos chantiers,\nau meilleur prix",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Comparez les prix des quincailleries. Outils, matériaux, équipement...",
            style: TextStyle(color: Colors.white60, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildBannerButton(
                  label: "Explorer",
                  icon: Icons.search_rounded,
                  bgColor: AppColors.accent,
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CatalogPage())),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildBannerButton(
                  label: "Vendre ici",
                  icon: Icons.storefront_rounded,
                  bgColor: Colors.white.withOpacity(0.12),
                  onTap: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const RegisterVendeur1())),
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.inventory_2_outlined,
                color: Colors.white70, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.starYellow.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "Espace Gestionnaire",
                    style: TextStyle(
                        color: AppColors.starYellow,
                        fontSize: 10,
                        fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Mettez à jour vos stocks pour apparaître en tête.",
                  style: TextStyle(
                      color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.accent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "Gérer",
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClientBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.priceGreen.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.waving_hand_rounded,
                color: AppColors.priceGreen, size: 24),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bon retour parmi nous !",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 3),
                Text(
                  "Consultez vos commandes en cours.",
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerButton({
    required String label,
    required IconData icon,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 15),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── CARTE PRODUIT MISE À JOUR (CLIQUABLE) ───────────────────────────────────────────────
  Widget _buildProductCard(String title, String price, {bool isPromo = false, String? imageUrl, String? oldPrice, String? discountTag, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Image
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: isPromo
                        ? AppColors.accent.withOpacity(0.08)
                        : AppColors.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    image: (imageUrl != null && imageUrl.isNotEmpty)
                        ? DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)
                        : null,
                  ),
                  child: (imageUrl == null || imageUrl.isEmpty)
                      ? Icon(
                    isPromo ? Icons.local_offer_rounded : Icons.star_rounded,
                    color: isPromo ? AppColors.accent : AppColors.primary,
                    size: 22,
                  )
                      : null,
                ),
                const SizedBox(width: 12),
                // Infos (Titre + Badge + Taux)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          if (isPromo)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                "EN PROMOTION",
                                style: TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900),
                              ),
                            ),
                          // Taux de réduction entre infos et prix
                          if (discountTag != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              discountTag,
                              style: const TextStyle(
                                color: AppColors.priceGreen,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                // Section Prix (Promo + Barré)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        color: isPromo ? AppColors.accent : AppColors.priceGreen,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                    if (oldPrice != null)
                      Text(
                        oldPrice,
                        style: TextStyle(
                          color: Colors.grey.shade400,
                          fontSize: 11,
                          decoration: TextDecoration.lineThrough,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 10,
                  color: Colors.grey.shade300,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCartBadge() {
    return ValueListenableBuilder(
      valueListenable: Hive.box(_boxName).listenable(),
      builder: (context, Box box, _) {
        final int count =
            box.values.map((item) => item['idQuincaillerie']).toSet().length;
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_rounded,
                  color: Colors.white70, size: 22),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartOverviewPage()),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6),
              constraints: const BoxConstraints(),
            ),
            if (count > 0)
              Positioned(
                right: 2,
                top: 6,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  child: Center(
                    child: Text(
                      '$count',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w900),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}