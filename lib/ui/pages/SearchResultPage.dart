import 'package:brixel/Exception/AppException.dart';
import 'package:brixel/Exception/NoInternetConnectionException.dart';
import 'package:flutter/material.dart';
import 'package:brixel/service/ProductService.dart';
import 'package:brixel/data/modele/ProductSearch.dart';
import '../widgets/ErrorWidgets.dart';
import 'ProductDetaiByQuincaillerielPage.dart';

class SearchResultsPage extends StatefulWidget {
  final String searchQuery;

  const SearchResultsPage({
    super.key,
    required this.searchQuery,
  });

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> with SingleTickerProviderStateMixin {
  final ProductService _productService = ProductService();
  late ColorScheme colorScheme;
  late AnimationController _shimmerController;

  List<ProductSearch> _results = [];
  bool _isLoading = true;
  String? _errorMessage;
  IconData _icon = Icons.error_outline_rounded;
  String _activeFilter = "Prix croissant";

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController.unbounded(vsync: this)..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));
    _performSearch(widget.searchQuery);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
    });

    try {

      //await Future.delayed(Duration(seconds: 15));

      final results = await _productService.searchProduct(query);

      // LOGIQUE DE FUSION : Regrouper par nom de produit identique
      final Map<String, ProductSearch> mergedProducts = {};

      for (var product in results) {
        if (mergedProducts.containsKey(product.name)) {
          // Si le produit existe déjà, on ajoute ses prix à la liste existante
          mergedProducts[product.name]!.prices.addAll(product.prices);
        } else {
          // Sinon on crée une nouvelle entrée
          mergedProducts[product.name] = product;
        }
      }

      setState(() {
        _results = mergedProducts.values.toList();
        _isLoading = false;
      });
    } on NoInternetConnectionException catch(e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
        _icon = Icons.wifi_off_outlined;
      });
    } on AppException catch(e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Erreur interne";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 80.0,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 56, bottom: 14),
              title: Text(
                widget.searchQuery,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              centerTitle: true,
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colorScheme.primary, colorScheme.secondary],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: _isLoading ? const SizedBox.shrink() : _buildFilterBar()),
          if (_isLoading)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildSkeletonCard(),
                childCount: 7,
              ),
            )
          else if (_errorMessage != null)
            SliverFillRemaining(child: ErrorWidgets(message: _errorMessage , iconData: _icon, onRetry: () {_performSearch(widget.searchQuery);},))
          else if (_results.isEmpty)
              SliverFillRemaining(child: _buildEmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final sortedResults = _getSortedResults();
                      return _buildProductCard(sortedResults[index]);
                    },
                    childCount: _results.length,
                  ),
                ),
              ),
        ],
      ),
    );
  }

  List<ProductSearch> _getSortedResults() {
    List<ProductSearch> sorted = List.from(_results);

    // Tri des quincailleries à l'intérieur de chaque carte produit
    for (var product in sorted) {
      product.prices.sort((a, b) {
        if (_activeFilter == "Prix croissant") return a.price.compareTo(b.price);
        if (_activeFilter == "Prix décroissant") return b.price.compareTo(a.price);
        return 0;
      });
    }

    // Tri des cartes produits entre elles (basé sur le prix le plus bas dispo)
    sorted.sort((a, b) {
      double minA = a.prices.isNotEmpty ? a.prices.first.price.toDouble() : double.infinity;
      double minB = b.prices.isNotEmpty ? b.prices.first.price.toDouble() : double.infinity;
      if (_activeFilter == "Prix croissant") return minA.compareTo(minB);
      if (_activeFilter == "Prix décroissant") return minB.compareTo(minA);
      return 0;
    });
    return sorted;
  }

  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          _skeletonBox(50, 50),
          const SizedBox(width: 12),
          Expanded(child: _skeletonBox(14, double.infinity)),
        ],
      ),
    );
  }

  Widget _skeletonBox(double height, double width) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          height: height,
          width: width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.grey[200]!, Colors.grey[100]!, Colors.grey[200]!],
              stops: [0.0, _shimmerController.value, 1.0],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFilterBar() {
    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _filterChip("Prix croissant", Icons.trending_up),
          _filterChip("Prix décroissant", Icons.trending_down),
          _filterChip("Plus proche", Icons.near_me_outlined),
        ],
      ),
    );
  }

  Widget _filterChip(String label, IconData icon) {
    bool isActive = _activeFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: TextStyle(fontSize: 12, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        selected: isActive,
        onSelected: (val) => setState(() => _activeFilter = label),
        avatar: Icon(icon, size: 14, color: isActive ? Colors.white : Colors.grey[600]),
        backgroundColor: Colors.white,
        selectedColor: colorScheme.primary,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(color: isActive ? Colors.white : Colors.black87),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey[200]!)),
      ),
    );
  }

  Widget _buildProductCard(ProductSearch product) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header Produit
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.inventory_2_outlined, color: colorScheme.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, letterSpacing: -0.4),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 10),
                      Text(
                        "${product.prices.length} point${product.prices.length > 1 ? 's' : ''} de vente disponible${product.prices.length > 1 ? 's' : ''}",
                        style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w600, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          // Liste des quincailleries
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: product.prices.length,
            separatorBuilder: (context, index) => const Divider(height: 1, indent: 68, thickness: 0.5),
            itemBuilder: (context, index) => _storeTile(product.prices[index], product),
          ),
        ],
      ),
    );
  }

  Widget _storeTile(var p, ProductSearch product) {
    return InkWell(
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => QuincaillerieDetailsPage(quincaillerieId: p.idQuincaillerie, product: product))
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade100)
              ),
              child: Icon(Icons.image, color: colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.quincaillerieName,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF2D3436)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star_rounded, size: 12, color: Colors.orange.shade700),
                      const SizedBox(width: 2),
                      Text("4.5", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[700])),
                      const SizedBox(width: 8),
                      Icon(Icons.location_on_outlined, size: 11, color: Colors.blueGrey.shade400),
                      const SizedBox(width: 2),
                      Text("2.4 km", style: TextStyle(color: Colors.blueGrey.shade600, fontSize: 10)),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${p.price}",
                  style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.w800, fontSize: 13),
                ),
                Text(
                  "Fcfa",
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 9),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text("Aucun résultat", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

}