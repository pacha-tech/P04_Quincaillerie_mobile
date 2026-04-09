
import 'package:brixel/Exception/AppException.dart';
import 'package:brixel/data/modele/ProductStock.dart';
import 'package:brixel/service/ProductService.dart';
import 'package:brixel/service/cloudinary/CloudinaryService.dart';
import 'package:brixel/ui/pages/pageVendeur/AddProductPage.dart';
import 'package:brixel/ui/widgets/DeleteProductPopup.dart';
import 'package:brixel/ui/widgets/ErrorWidgets.dart';
import 'package:brixel/ui/theme/AppColors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../Exception/NoInternetConnectionException.dart';
import '../../../main.dart';
import 'UpdateProductPage.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage>{
  final ProductService _productService = ProductService();
  final CloudinaryService _cloudinaryService = CloudinaryService();

  late Future<List<ProductStock?>> _productsFuture;
  final TextEditingController _searchController = TextEditingController();
  bool _showSearchBar = false;
  String _sortOption = "Date d'ajout";

  @override
  void initState() {
    super.initState();
    _productsFuture = _productService.getProductsByQuincaillerie();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshProducts() {
    setState(() {
      _productsFuture = _productService.getProductsByQuincaillerie();
    });
  }

  void _showFilterMenu() {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(100, 60, 20, 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      items: [
        _menuItem("Date d'ajout", Icons.calendar_today_outlined),
        _menuItem("Ordre croissant", Icons.sort_by_alpha_rounded),
        _menuItem("Ordre décroissant", Icons.sort_rounded),
        _menuItem("Prix croissant", Icons.arrow_upward_rounded),
        _menuItem("Prix décroissant", Icons.arrow_downward_rounded),
      ],
    );
  }

  PopupMenuItem<String> _menuItem(String value, IconData icon) {
    final bool selected = _sortOption == value;
    return PopupMenuItem(
      value: value,
      onTap: () => setState(() => _sortOption = value),
      child: Row(
        children: [
          Icon(icon, size: 16, color: selected ? AppColors.primary : Colors.grey),
          const SizedBox(width: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              color: selected ? AppColors.primary : AppColors.textMuted,
            ),
          ),
          if (selected) ...[
            const Spacer(),
            const Icon(Icons.check_rounded, size: 14, color: AppColors.primary),
          ],
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final hasChanged = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddProductPage()),
          );
          if (hasChanged == true) {
            _refreshProducts();
          }
        },
        backgroundColor: AppColors.primary,
        elevation: 2,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          "Ajouter",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: FutureBuilder<List<ProductStock?>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }

          if (snapshot.hasError) {
            final error = snapshot.error;
            if (error is NoInternetConnectionException || error is AppException) {
              return ErrorWidgets(
                message: (error as dynamic).message,
                iconData: Icons.wifi_off,
                onRetry: _refreshProducts,
              );
            }
            if (error is DioException) {
              final msg = error.type == DioExceptionType.connectionTimeout
                  ? "Le serveur met trop de temps à répondre"
                  : "Erreur réseau";
              return ErrorWidgets(
                message: msg,
                iconData: Icons.error_outline_rounded,
                onRetry: _refreshProducts,
              );
            }
            return ErrorWidgets(
              message: "Une erreur est survenue",
              iconData: Icons.error_outline_rounded,
              onRetry: _refreshProducts,
            );
          }

          final allProducts = snapshot.data ?? [];
          final query = _searchController.text.trim().toLowerCase();
          List<ProductStock?> filtered = List.from(allProducts);

          if (query.isNotEmpty) {
            filtered = filtered
                .where((p) => p != null && p.name.toLowerCase().contains(query))
                .toList();
          }

          switch (_sortOption) {
            case 'Ordre croissant':
              filtered.sort((a, b) => a!.name.compareTo(b!.name));
              break;
            case 'Ordre décroissant':
              filtered.sort((a, b) => b!.name.compareTo(a!.name));
              break;
            case 'Prix croissant':
              filtered.sort((a, b) => a!.sellPrice.compareTo(b!.sellPrice));
              break;
            case 'Prix décroissant':
              filtered.sort((a, b) => b!.sellPrice.compareTo(a!.sellPrice));
              break;
          }

          if (filtered.isEmpty) return _buildEmptyState();

          final int promoCount = filtered.where((p) => p?.inPromotion == true).length;
          final double avgPrice = filtered.isEmpty
              ? 0
              : filtered.fold(0.0, (s, p) => s + (p?.sellPrice ?? 0)) / filtered.length;

          return Column(
            children: [
              _buildSummaryBanner(filtered.length, promoCount, avgPrice),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) =>
                      _buildProductCard(filtered[index]!),
                ),
              ),
            ],
          );
        },
      ),
    );
  }


  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      centerTitle: true,
      title: _showSearchBar
          ? TextField(
        controller: _searchController,
        autofocus: true,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        cursorColor: Colors.white70,
        decoration: const InputDecoration(
          hintText: "Rechercher un produit...",
          hintStyle: TextStyle(color: Colors.white54),
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search_rounded, color: Colors.white70, size: 20),
        ),
      )
          : const Text(
        "Mon Stock",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 17,
          letterSpacing: 0.3,
        ),
      ),
      actions: [
        if (!_showSearchBar) ...[
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.white70),
            onPressed: () => setState(() => _showSearchBar = true),
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: Colors.white70),
            onPressed: _showFilterMenu,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: _refreshProducts,
          ),
        ] else
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white70),
            onPressed: () => setState(() {
              _showSearchBar = false;
              _searchController.clear();
            }),
          ),
      ],
    );
  }


  Widget _buildSummaryBanner(int total, int promoCount, double avgPrice) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(1),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildBannerStat(
            icon: Icons.inventory_2_outlined,
            label: "Produits",
            value: "$total",
            color: AppColors.primary,
          ),
          _buildDivider(),
          _buildBannerStat(
            icon: Icons.local_offer_outlined,
            label: "En promo",
            value: "$promoCount",
            color: AppColors.accent,
          ),
          _buildDivider(),
          _buildBannerStat(
            icon: Icons.payments_outlined,
            label: "Prix moy.",
            value: "${avgPrice.toStringAsFixed(0)} F",
            color: AppColors.priceGreen,
          ),
        ],
      ),
    );
  }

  Widget _buildBannerStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color),
          ),
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
        ],
      ),
    );
  }

  Widget _buildDivider() => Container(
    width: 0.5,
    height: 36,
    color: Colors.grey.shade200,
  );


  Widget _buildProductCard(ProductStock product) {
    final bool hasPromo = product.inPromotion && product.pricepromo != null;
    final double displayPrice = hasPromo ? product.pricepromo! : product.sellPrice;
    final int discount = hasPromo
        ? ((1 - (product.pricepromo! / product.sellPrice)) * 100).round()
        : 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [

            GestureDetector(
              onTap: () {
                if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
                  _showFullImage(context, product.imageUrl!, product.name);
                }
              },
              child: Stack(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                          ? CachedNetworkImage(
                        imageUrl: _cloudinaryService.getThumbnailUrl(product.imageUrl),
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Center(
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary.withOpacity(0.4),
                            ),
                          ),
                        ),
                        errorWidget: (_, __, ___) => const Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey,
                          size: 24,
                        ),
                      )
                          : const Icon(
                        Icons.inventory_2_outlined,
                        color: AppColors.primary,
                        size: 26,
                      ),
                    ),
                  ),
                  // Badge promo — cohérent avec CartDetailPage
                  if (hasPromo)
                    Positioned(
                      top: 0,
                      left: 0,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: const BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(14),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        child: Text(
                          "-$discount%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // ── Infos produit ─────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${product.brand} · ${product.category}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[500], fontSize: 11),
                  ),
                  const SizedBox(height: 7),
                  // Badge stock — cohérent avec _buildStatusBadge de QuincaillerieDetailsPage
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: AppColors.statusOpen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          "${product.stock} ${product.unit}",
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // ── Prix ──────────────────────────────────────────────────
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (hasPromo) ...[
                  Text(
                    "${product.sellPrice.toStringAsFixed(0)} FCFA",
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  const SizedBox(height: 1),
                ],
                Text(
                  "${displayPrice.toStringAsFixed(0)} FCFA",
                  style: TextStyle(
                    color: hasPromo ? AppColors.priceGreen : AppColors.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 4),


            PopupMenuButton<String>(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              icon: const Icon(Icons.more_vert_rounded, color: AppColors.textMuted, size: 20),
              onSelected: (value) async {
                if (value == 'modifier') {

                  final hasChanged = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => UpdateProductPage(product: product)),
                  );
                  if (hasChanged == true) {
                    _refreshProducts();
                  }

                } else if (value == 'supprimer') {
                  showDialog(
                    context: context,
                    builder: (_) => DeleteProductPopup(
                      productId: product.id,
                      name: product.name,
                    ),
                  );
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'modifier',
                  child: Row(
                    children: const [
                      Icon(Icons.edit_outlined, size: 16, color: AppColors.primary),
                      SizedBox(width: 10),
                      Text("Modifier", style: TextStyle(fontSize: 13, color: AppColors.primary)),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'supprimer',
                  child: Row(
                    children: const [
                      Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.accent),
                      SizedBox(width: 10),
                      Text("Supprimer",
                          style: TextStyle(color: AppColors.accent, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        height: 92,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 68,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 12,
                    width: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 10,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
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
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.inventory_2_outlined, size: 38, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          const Text(
            "Aucun produit trouvé",
            style: TextStyle(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Ajoutez votre premier produit au stock",
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddProductPage()),
            ),
            icon: const Icon(Icons.add_rounded, color: Colors.white, size: 18),
            label: const Text(
              "Ajouter un produit",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ],
      ),
    );
  }


  void _showFullImage(BuildContext context, String url, String title) {
    final screenSize = MediaQuery.of(context).size;
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: screenSize.height * 0.45,
                maxWidth: screenSize.width * 0.9,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: _cloudinaryService.getThumbnailUrl(url),
                  fit: BoxFit.contain,
                  placeholder: (_, __) => const Center(
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (_, __, ___) => const Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}