/*
import 'package:brixel/Exception/AppException.dart';
import 'package:brixel/Exception/NoInternetConnectionException.dart';
import 'package:brixel/service/cloudinary/CloudinaryService.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:brixel/service/ProductService.dart';
import 'package:brixel/data/modele/ProductSearch.dart';
import 'package:provider/provider.dart';
import '../../data/modele/Price.dart';
import '../../provider/LocationProvider.dart';
import '../../utils/DistanceUtils.dart';
import '../widgets/ErrorWidgets.dart';
import 'QuincaillerielDetailsPage.dart';

class SearchResultsPage extends StatefulWidget {
  final String searchQuery;

  const SearchResultsPage({
    super.key,
    required this.searchQuery,
  });

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage>
    with SingleTickerProviderStateMixin {
  final ProductService _productService = ProductService();
  CloudinaryService _cloudinaryService = CloudinaryService();
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
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));
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
      _errorMessage = null;
    });

    try {
      final results = await _productService.searchProduct(query);

      final Map<String, ProductSearch> mergedProducts = {};
      for (var product in results) {
        if (mergedProducts.containsKey(product.name)) {
          mergedProducts[product.name]!.prices.addAll(product.prices);
        } else {
          mergedProducts[product.name] = product;
        }
      }

      setState(() {
        _results = mergedProducts.values.toList();
        _isLoading = false;
      });
    } on NoInternetConnectionException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
        _icon = Icons.wifi_off_outlined;
      });
    } on AppException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
        _icon = Icons.error_outline_rounded;
      });
    } catch (e) {
      print("ERREUR DE RECHERCHE $e");
      setState(() {
        _isLoading = false;
        _errorMessage = "Erreur interne";
        _icon = Icons.error_outline_rounded;
      });
    }
  }

  // ── Tri — location reçu en paramètre depuis build() ───────────────────────
  List<ProductSearch> _getSortedResults(LocationProvider location) {
    final List<ProductSearch> sorted = List.from(_results);

    for (var product in sorted) {
      product.prices.sort((a, b) {
        if (_activeFilter == "Prix croissant") {
          if(b.inPromotion) {
            return a.price.compareTo(b.pricePromo);
          }else{
            return a.price.compareTo(b.price);
          }
        }
        if (_activeFilter == "Prix décroissant") {
          if(a.inPromotion){
            return b.price.compareTo(a.pricePromo);
          }else{
            return b.price.compareTo(a.price);
          }
        }
        if (_activeFilter == "Plus proche" && location.hasPosition) {
          final distA = DistanceUtils.calculateKm(location.userPosition!,
              a.latitudeQuincaillerie, a.longitudeQuincaillerie);
          final distB = DistanceUtils.calculateKm(location.userPosition!,
              b.latitudeQuincaillerie, b.longitudeQuincaillerie);
          return distA.compareTo(distB);
        }
        return 0;
      });
    }

    sorted.sort((a, b) {
      if (a.prices.isEmpty) return 1;
      if (b.prices.isEmpty) return -1;

      if (_activeFilter == "Prix croissant") {
        return a.prices.first.price.compareTo(b.prices.first.price);
      }
      if (_activeFilter == "Prix décroissant") {
        return b.prices.first.price.compareTo(a.prices.first.price);
      }
      if (_activeFilter == "Plus proche" && location.hasPosition) {
        final distA = DistanceUtils.calculateKm(
            location.userPosition!,
            a.prices.first.latitudeQuincaillerie,
            a.prices.first.longitudeQuincaillerie);
        final distB = DistanceUtils.calculateKm(
            location.userPosition!,
            b.prices.first.latitudeQuincaillerie,
            b.prices.first.longitudeQuincaillerie);
        return distA.compareTo(distB);
      }
      return 0;
    });

    return sorted;
  }

  // ── Distance — plus de context, location reçu en paramètre ───────────────
  String _distance(double toLat, double toLng, LocationProvider location) {
    if (!location.hasPosition) return "";
    return DistanceUtils.formatDistance(location.userPosition!, toLat, toLng);
  }

  @override
  Widget build(BuildContext context) {
    colorScheme = Theme.of(context).colorScheme;

    final location = context.watch<LocationProvider>();

    final sortedResults = _isLoading || _errorMessage != null || _results.isEmpty
        ? <ProductSearch>[]
        : _getSortedResults(location);

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
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
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


          SliverToBoxAdapter(
            child: _isLoading ? const SizedBox.shrink() : _buildFilterBar(),
          ),


          if (_isLoading)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildSkeletonCard(),
                childCount: 7,
              ),
            )
          else if (_errorMessage != null)
            SliverFillRemaining(
              child: ErrorWidgets(
                message: _errorMessage,
                iconData: _icon,
                onRetry: () => _performSearch(widget.searchQuery),
              ),
            )
          else if (_results.isEmpty)
              SliverFillRemaining(child: _buildEmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) =>
                        _buildProductCard(sortedResults[index], location),
                    childCount: sortedResults.length,
                  ),
                ),
              ),
        ],
      ),
    );
  }


  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
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
              colors: [
                Colors.grey[200]!,
                Colors.grey[100]!,
                Colors.grey[200]!
              ],
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
    final bool isActive = _activeFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        selected: isActive,
        onSelected: (_) => setState(() => _activeFilter = label),
        avatar: Icon(icon,
            size: 14, color: isActive ? Colors.white : Colors.grey[600]),
        backgroundColor: Colors.white,
        selectedColor: colorScheme.primary,
        checkmarkColor: Colors.white,
        labelStyle:
        TextStyle(color: isActive ? Colors.white : Colors.black87),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!)),
      ),
    );
  }


  Widget _buildProductCard(ProductSearch product, LocationProvider location) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
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
                  child: Icon(Icons.inventory_2_outlined,
                      color: colorScheme.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: -0.4),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "${product.prices.length} point${product.prices.length > 1 ? 's' : ''} de vente disponible${product.prices.length > 1 ? 's' : ''}",
                        style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: product.prices.length,
            separatorBuilder: (_, __) =>
            const Divider(height: 1, indent: 68, thickness: 0.5),
            itemBuilder: (context, index) =>
                _storeTile(product.prices[index], product, location),
          ),
        ],
      ),
    );
  }


  Widget _storeTile(Price p, ProductSearch product, LocationProvider location) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuincaillerieDetailsPage(quincaillerieId: p.idQuincaillerie, product: product),),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [

            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(

                  imageUrl: _cloudinaryService.getThumbnailUrl(product.imageUrl),
                  fit: BoxFit.cover,

                  placeholder: (context, url) => Container(
                    color: Colors.grey[50],
                    child: const Center(
                      child: SizedBox(
                        width: 15,
                        height: 15,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),

                  errorWidget: (context, url, error) => Container(
                    color: Colors.grey[100],
                    child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey[400],
                        size: 20
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Le reste de ton code (Expanded pour les textes et prix)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.quincaillerieName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Color(0xFF2D3436)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (p.inPromotion)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "-${p.taux}%",
                            style: TextStyle(
                                color: Colors.red.shade700,
                                fontWeight: FontWeight.bold,
                                fontSize: 9
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star_rounded,
                          size: 12, color: Colors.orange.shade700),
                      const SizedBox(width: 2),
                      Text("4.5",
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700])),
                      const SizedBox(width: 8),
                      Icon(Icons.location_on_outlined,
                          size: 11, color: Colors.blueGrey.shade400),
                      const SizedBox(width: 2),
                      Text(
                        _distance(p.latitudeQuincaillerie,
                            p.longitudeQuincaillerie, location),
                        style: TextStyle(
                            color: Colors.blueGrey.shade600, fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (p.inPromotion) ...[
                  Text(
                    "${p.pricePromo} F",
                    style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w800,
                        fontSize: 13),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "${p.price} F",
                    style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                        decoration: TextDecoration.lineThrough),
                  ),
                ] else ...[
                  Text(
                    "${p.price}",
                    style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w800,
                        fontSize: 13),
                  ),
                  Text(
                    "Fcfa",
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 9),
                  ),
                ],
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
          const Text("Aucun résultat",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
 */

import 'package:brixel/Exception/AppException.dart';
import 'package:brixel/Exception/NoInternetConnectionException.dart';
import 'package:brixel/service/cloudinary/CloudinaryService.dart';
import 'package:brixel/ui/theme/AppColors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:brixel/service/ProductService.dart';
import 'package:brixel/data/modele/ProductSearch.dart';
import 'package:provider/provider.dart';
import '../../data/modele/Price.dart';
import '../../provider/LocationProvider.dart';
import '../../utils/DistanceUtils.dart';
import '../widgets/ErrorWidgets.dart';
import 'QuincaillerielDetailsPage.dart';

class SearchResultsPage extends StatefulWidget {
  final String searchQuery;

  const SearchResultsPage({
    super.key,
    required this.searchQuery,
  });

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage>
    with SingleTickerProviderStateMixin {
  final ProductService _productService = ProductService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  late AnimationController _shimmerController;

  List<ProductSearch> _results = [];
  bool _isLoading = true;
  String? _errorMessage;
  IconData _icon = Icons.error_outline_rounded;
  String _activeFilter = "Prix croissant";

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(
          min: -0.5, max: 1.5, period: const Duration(milliseconds: 1000));
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
      _errorMessage = null;
    });
    try {
      final results = await _productService.searchProduct(query);
      final Map<String, ProductSearch> mergedProducts = {};
      for (var product in results) {
        if (mergedProducts.containsKey(product.name)) {
          mergedProducts[product.name]!.prices.addAll(product.prices);
        } else {
          mergedProducts[product.name] = product;
        }
      }
      setState(() {
        _results = mergedProducts.values.toList();
        _isLoading = false;
      });
    } on NoInternetConnectionException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
        _icon = Icons.wifi_off_outlined;
      });
    } on AppException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
        _icon = Icons.error_outline_rounded;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Erreur interne";
        _icon = Icons.error_outline_rounded;
      });
    }
  }


  List<ProductSearch> _getSortedResults(LocationProvider location) {
    final List<ProductSearch> sorted = List.from(_results);

    for (var product in sorted) {
      product.prices.sort((a, b) {
        if (_activeFilter == "Prix croissant") {
          final pa = a.inPromotion ? a.pricePromo : a.price;
          final pb = b.inPromotion ? b.pricePromo : b.price;
          return pa.compareTo(pb);
        }
        if (_activeFilter == "Prix décroissant") {
          final pa = a.inPromotion ? a.pricePromo : a.price;
          final pb = b.inPromotion ? b.pricePromo : b.price;
          return pb.compareTo(pa);
        }
        if (_activeFilter == "Plus proche" && location.hasPosition) {
          final distA = DistanceUtils.calculateKm(location.userPosition!,
              a.latitudeQuincaillerie, a.longitudeQuincaillerie);
          final distB = DistanceUtils.calculateKm(location.userPosition!,
              b.latitudeQuincaillerie, b.longitudeQuincaillerie);
          return distA.compareTo(distB);
        }
        return 0;
      });
    }

    sorted.sort((a, b) {
      if (a.prices.isEmpty) return 1;
      if (b.prices.isEmpty) return -1;
      if (_activeFilter == "Prix croissant") {
        return a.prices.first.price.compareTo(b.prices.first.price);
      }
      if (_activeFilter == "Prix décroissant") {
        return b.prices.first.price.compareTo(a.prices.first.price);
      }
      if (_activeFilter == "Plus proche" && location.hasPosition) {
        final distA = DistanceUtils.calculateKm(
            location.userPosition!,
            a.prices.first.latitudeQuincaillerie,
            a.prices.first.longitudeQuincaillerie);
        final distB = DistanceUtils.calculateKm(
            location.userPosition!,
            b.prices.first.latitudeQuincaillerie,
            b.prices.first.longitudeQuincaillerie);
        return distA.compareTo(distB);
      }
      return 0;
    });
    return sorted;
  }

  String _distance(
      double toLat, double toLng, LocationProvider location) {
    if (!location.hasPosition) return "";
    return DistanceUtils.formatDistance(
        location.userPosition!, toLat, toLng);
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationProvider>();
    final sortedResults = _isLoading || _errorMessage != null || _results.isEmpty
        ? <ProductSearch>[]
        : _getSortedResults(location);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          // ── AppBar ────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 80.0,
            floating: true,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
              const EdgeInsets.only(left: 56, bottom: 14),
              title: Text(
                widget.searchQuery,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 0.3),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primary, Color(0xFF16213E)],
                  ),
                ),
              ),
            ),
          ),


          SliverToBoxAdapter(
            child: _isLoading
                ? const SizedBox.shrink()
                : _buildFilterBar(),
          ),


          if (_isLoading)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildSkeletonCard(),
                childCount: 7,
              ),
            )
          else if (_errorMessage != null)
            SliverFillRemaining(
              child: ErrorWidgets(
                message: _errorMessage,
                iconData: _icon,
                onRetry: () => _performSearch(widget.searchQuery),
              ),
            )
          else if (_results.isEmpty)
              SliverFillRemaining(child: _buildEmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.only(bottom: 24),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                        _buildProductCard(sortedResults[index], location),
                    childCount: sortedResults.length,
                  ),
                ),
              ),
        ],
      ),
    );
  }


  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ]),
      child: Row(
        children: [
          _skeletonBox(50, 50),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _skeletonBox(14, double.infinity),
                const SizedBox(height: 8),
                _skeletonBox(10, 120),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeletonBox(double height, double width,
      {double borderRadius = 8}) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) => Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.grey[200]!,
              Colors.grey[100]!,
              Colors.grey[200]!
            ],
            stops: [0.0, _shimmerController.value, 1.0],
          ),
        ),
      ),
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
    final bool isActive = _activeFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label, style: TextStyle(
                fontSize: 12,
                fontWeight:
                isActive ? FontWeight.bold : FontWeight.normal)),
        selected: isActive,
        onSelected: (_) => setState(() => _activeFilter = label),
        avatar: Icon(icon,
            size: 14,
            color: isActive ? Colors.white : Colors.grey[600]),
        backgroundColor: AppColors.cardBg,
        selectedColor: AppColors.accent,
        checkmarkColor: Colors.red,
        labelStyle: TextStyle(color: isActive ? Colors.white : AppColors.textSecondary),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!)),
      ),
    );
  }

  // ── Carte produit ─────────────────────────────────────────────────────────
  Widget _buildProductCard(ProductSearch product, LocationProvider location) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header produit ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                // Image produit
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: CachedNetworkImage(
                      imageUrl: _cloudinaryService.getThumbnailUrl(product.imageUrl),
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                          color: Colors.grey[50],
                          child: const Center(
                              child: SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2)))),
                      errorWidget: (_, __, ___) => Icon(
                          Icons.inventory_2_outlined,
                          color: AppColors.primary.withOpacity(0.4),
                          size: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: AppColors.primary,
                            letterSpacing: -0.3),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: AppColors.statusOpen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            "${product.prices.length} point${product.prices.length > 1 ? 's' : ''} de vente",
                            style: const TextStyle(
                                color: AppColors.priceGreen,
                                fontWeight: FontWeight.w600,
                                fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, thickness: 0.5, color: Colors.grey.shade100),

          // ── Liste quincailleries ────────────────────────────────────────
          ListView.separated(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: product.prices.length,
            separatorBuilder: (_, __) => Divider(
                height: 1,
                indent: 72,
                thickness: 0.5,
                color: Colors.grey.shade100),
            itemBuilder: (context, index) => _storeTile(product.prices[index], product, location),
          ),
        ],
      ),
    );
  }

  // ── Tile quincaillerie ────────────────────────────────────────────────────
  Widget _storeTile(Price p, ProductSearch product, LocationProvider location) {
    return InkWell(
      borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(20)),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuincaillerieDetailsPage(
              quincaillerieId: p.idQuincaillerie,
              product: product),
        ),
      ),
      child: Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        child: Row(
          children: [
            // ── Photo quincaillerie ───────────────────────────────────────
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl:
                  _cloudinaryService.getThumbnailUrl(product.imageUrl),
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: Colors.grey[50],
                    child: const Center(
                      child: SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                              strokeWidth: 2)),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Icon(
                      Icons.store_rounded,
                      color: Colors.grey[400],
                      size: 20),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // ── Infos quincaillerie ───────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          p.quincaillerieName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: AppColors.textSecondary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (p.inPromotion) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            "-${p.taux}%",
                            style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w900,
                                fontSize: 10),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          size: 12, color: AppColors.starYellow),
                      const SizedBox(width: 2),
                      Text("4.5",
                          style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: AppColors.starTextBrown)),
                      const SizedBox(width: 10),
                      Icon(Icons.location_on_rounded,
                          size: 11, color: Colors.grey[400]),
                      const SizedBox(width: 2),
                      Text(
                        _distance(p.latitudeQuincaillerie,
                            p.longitudeQuincaillerie, location),
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 10),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ── Prix ──────────────────────────────────────────────────────
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (p.inPromotion) ...[
                  Text(
                    "${p.pricePromo.toStringAsFixed(0)} F",
                    style: const TextStyle(
                        color: AppColors.priceGreen,
                        fontWeight: FontWeight.w900,
                        fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${p.price.toStringAsFixed(0)} F",
                    style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 11,
                        decoration: TextDecoration.lineThrough),
                  ),
                ] else ...[
                  Text(
                    "${p.price.toStringAsFixed(0)} F",
                    style: const TextStyle(
                        color: AppColors.priceGreen,
                        fontWeight: FontWeight.w900,
                        fontSize: 14),
                  ),
                  Text(
                    "Fcfa",
                    style: TextStyle(
                        color: Colors.grey[400], fontSize: 9),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── État vide ─────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.search_off_rounded,
                size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text("Aucun résultat",
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary)),
          const SizedBox(height: 6),
          Text(
            "Aucun produit ne correspond à votre recherche",
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}