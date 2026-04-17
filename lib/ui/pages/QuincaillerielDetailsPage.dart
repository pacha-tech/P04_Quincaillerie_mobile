import 'package:brixel/Exception/AppException.dart';
import 'package:brixel/Exception/NoInternetConnectionException.dart';
import 'package:brixel/data/modele/ProductRecommended.dart';
import 'package:brixel/data/modele/QuincaillerieDetail.dart';
import 'package:brixel/data/modele/Cart.dart';
import 'package:brixel/service/cloudinary/CloudinaryService.dart';
import 'package:brixel/service/hive/PanierHiveService.dart';
import 'package:brixel/service/PanierService.dart';
import 'package:brixel/service/ProductService.dart';
import 'package:brixel/service/QuincaillerieService.dart';
import 'package:brixel/ui/pages/CartDetailPage.dart';
import 'package:brixel/ui/pages/authPages/client/RegisterPage.dart';
import 'package:brixel/ui/widgets/ErrorWidgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../Exception/UserNotConnectedException.dart';
import '../../data/modele/ProductSearch.dart';
import '../../main.dart';
import '../theme/AppColors.dart';
import 'QuincaillerieInfoSheet.dart';

class QuincaillerieDetailsPage extends StatefulWidget {
  final String quincaillerieId;
  final ProductSearch product;

  const QuincaillerieDetailsPage({
    super.key,
    required this.quincaillerieId,
    required this.product,
  });

  @override
  State<QuincaillerieDetailsPage> createState() =>
      _QuincaillerieDetailsPageState();
}

class _QuincaillerieDetailsPageState extends State<QuincaillerieDetailsPage> with RouteAware {
  late Future<dynamic> _storeFuture;
  late Future<List<ProductRecommended>> _recommandationFuture;

  final ProductService _productService = ProductService();
  final QuincaillerieService _quincaillerieService = QuincaillerieService();
  final PanierHiveService _panierHiveService = PanierHiveService();
  final PanierService _panierService = PanierService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final String _boxName = 'productBox';

  bool _isHiveReady = false;
  final Set<String> _loadingItems = {};
  bool _showCart = false;

  final Map<String, int> _cartQuantities = {};
  String _dynamicStoreName = "Chargement...";
  QuincaillerieDetail? _storeDetail;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null) routeObserver.subscribe(this, modalRoute);
  }

  @override
  void didPopNext() => setState(() => _initializeData());

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }


  void _initializeData() {
    final priceEntry = widget.product.prices.firstWhere(
          (p) => p.idQuincaillerie == widget.quincaillerieId,
      orElse: () => widget.product.prices.first,
    );
    _dynamicStoreName = priceEntry.quincaillerieName;

    _initHive();

    _storeFuture = _quincaillerieService.getDetailQuincaillerie(widget.quincaillerieId).then((value) {
      if (value is QuincaillerieDetail && mounted) {
        setState(() {
          _storeDetail = value;
          _dynamicStoreName = value.name;
          _showCart = true;
        });
      }
      return value;
    });

    _loadRecommandations(priceEntry.idPrice);
  }

  void _loadRecommandations(String mainProductIdPrice) {
    _recommandationFuture = _productService.getRecommandationByProductAndStore(widget.product.idProduct, widget.quincaillerieId)
        .then((v) => v.cast<ProductRecommended>())
        .then((suggestions) async {
      await _loadCartStatus([
        mainProductIdPrice,
        ...suggestions.map((s) => s.idPrice),
      ]);
      return suggestions;
    });
  }


  Future<void> _loadCartStatus(List<String> ids) async {
    try {

      final futures = ids.map((id) => _panierService.getquantityInPanier(id));
      final quantities = await Future.wait(futures);

      final Map<String, int> temp = {};

      for (int i = 0; i < ids.length; i++) {
        final String id = ids[i];
        final int serverQty = quantities[i];

        temp[id] = serverQty;

        final localItem = _panierHiveService.getItem(id);

        if (serverQty > 0) {
          if (localItem != null && localItem.quantity != serverQty) {

            localItem.quantity = serverQty;
            await _panierHiveService.addToCart(localItem);
          }

        } else {

          if (localItem != null) {
            await _panierHiveService.removeItem(id);
          }
        }
      }

      if (mounted) {
        setState(() {
          _cartQuantities.addAll(temp);
        });
      }

    } catch (e) {

      final Map<String, int> fallback = {
        for (final id in ids)
          id: _panierHiveService.getItem(id)?.quantity ?? 0
      };

      if (mounted) {
        setState(() {
          _cartQuantities.addAll(fallback);
        });
      }

      if (e is UserNotConnectedException && mounted) {

      }
    }
  }

  Future<void> _initHive() async {
    if (!Hive.isBoxOpen(_boxName)) await Hive.openBox(_boxName);
    if (mounted) setState(() => _isHiveReady = true);
  }


  Future<void> _handleCartAction(ProductRecommended product, int delta) async {
    final String idPrice = product.idPrice;
    if (_loadingItems.contains(idPrice)) return;

    final int oldQty = _cartQuantities[idPrice] ?? 0;
    final Cart? oldCartItem = _panierHiveService.getItem(idPrice);
    final int newQty = oldQty + delta;

    setState(() {
      _cartQuantities[idPrice] = newQty;
      _loadingItems.add(idPrice);
    });

    try {
      if (newQty <= 0) {
        await _panierHiveService.removeItem(idPrice);
        await _panierService.deleteProductToPanier(idPrice);
        _notify(Icons.delete_outline, "${product.name} retiré du panier", AppColors.notifSuccess);
      } else if (oldQty == 0 && delta > 0) {
        await _panierHiveService.addToCart(Cart(
          idPrice: idPrice,
          idQuincaillerie: widget.quincaillerieId,
          productName: product.name,
          storeName: _dynamicStoreName,
          price: product.price,
          quantity: 1,
          inPromotion: product.inPromo,
          pricePromo: product.pricePromo,
          imageUrl: product.imageUrl,
        ));
        await _panierService.addProductToPanier(idPrice);
        _notify(Icons.check_circle, "${product.name} ajouté au panier", AppColors.notifSuccess);
      } else {
        if (product.stock < newQty) {
          _notify(Icons.warning_amber_rounded, "Stock insuffisant", AppColors.notifWarning);
          setState(() {
            _cartQuantities[idPrice] = oldQty;
            _loadingItems.remove(idPrice);
          });
          return;
        }
        if (oldCartItem != null) {
          oldCartItem.quantity = newQty;
          await _panierHiveService.addToCart(oldCartItem);
        }
        if (delta > 0) {
          await _panierService.addQuantityToPanier(idPrice);
          _notify(Icons.check_circle, "+1 ${product.name}", AppColors.notifSuccess);
        } else {
          await _panierService.removeQuantityToPanier(idPrice);
          _notify(Icons.check_circle, "-1 ${product.name}", AppColors.notifWarning);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _cartQuantities[idPrice] = oldQty);
        if (oldQty == 0) {
          await _panierHiveService.removeItem(idPrice);
        } else if (oldCartItem != null) {
          await _panierHiveService.addToCart(oldCartItem);
        }
      }
      if (e is UserNotConnectedException) {
        Navigator.push(context, MaterialPageRoute(
            builder: (_) => const RegisterPage(label: "Connectez-vous")));
      } else if (e is NoInternetConnectionException) {
        _notify(Icons.wifi_off, e.message, AppColors.notifError);
      } else {
        _notify(Icons.error_outline_rounded, "Erreur lors de l'opération", AppColors.notifError);
      }
    } finally {
      if (mounted) setState(() => _loadingItems.remove(idPrice));
    }
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!_isHiveReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 70,
            pinned: true,
            elevation: 0,
            centerTitle: true,
            backgroundColor: AppColors.primary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(_dynamicStoreName,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  fontSize: 17,
                  letterSpacing: 0.3,
                )),
            actions: [
              if (_storeDetail != null)
                TextButton.icon(
                  onPressed: () =>
                      QuincaillerieInfoSheet.show(context, _storeDetail!),
                  icon: const Icon(Icons.info_outline_rounded,
                      color: Colors.white70, size: 17),
                  label: const Text("Infos",
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                  style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact),
                ),
              if (_showCart)
                _buildCartBadge(_dynamicStoreName, widget.quincaillerieId),
              const SizedBox(width: 4),
            ],
          ),

          SliverToBoxAdapter(
            child: FutureBuilder<dynamic>(
              future: _storeFuture,
              builder: (context, snapshot) {
                // Chargement → SizedBox (RenderBox ✓)
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 400,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError) {
                  final error = snapshot.error;

                  if(error is NoInternetConnectionException){
                    return Center(
                      child: ErrorWidgets(message: error.message , iconData: Icons.wifi_off, onRetry: _initializeData),
                    );
                  }else if(error is AppException){
                    return Center(
                      child: ErrorWidgets(message: error.message , iconData: Icons.wifi_off, onRetry: _initializeData),
                    );
                  }
                  return SizedBox(
                    height: 400,
                    child: ErrorWidgets(
                      message: "Erreur de chargement",
                      iconData: Icons.error_outline_rounded,
                      onRetry: _initializeData,
                    ),
                  );
                }

                final QuincaillerieDetail store = snapshot.data;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStoreHeader(store),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
                      child: _buildSectionLabel("PRODUIT RECHERCHÉ"),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: _buildMainProductCard(widget.product, colorScheme),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 22, 16, 6),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildSectionLabel("SUGGESTIONS"),
                          GestureDetector(
                            onTap: () {},
                            child: Text("Voir tout",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.primary)),
                          ),
                        ],
                      ),
                    ),
                    _buildSuggestionsList(colorScheme),
                    const SizedBox(height: 48),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildStoreHeader(QuincaillerieDetail store) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: CachedNetworkImage(
              imageUrl: store.photoUrl,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              errorWidget: (_, __, ___) => Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.store_rounded,
                    color: AppColors.accent, size: 26),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(store.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              color: AppColors.primary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusBadge(store.status),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded,
                        size: 13, color: Colors.grey[400]),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        "${store.quartier}, ${store.ville}",
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.star_rounded,
                        size: 14, color: AppColors.starYellow),
                    const SizedBox(width: 2),
                    Text(store.averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.starTextBrown)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final bool isOpen =
        status.toLowerCase() == 'ouvert' || status.toLowerCase() == 'open';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen ? AppColors.greenLight : AppColors.closedLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isOpen ? AppColors.statusOpen : AppColors.statusClosed,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(isOpen ? "Ouvert" : "Fermé",
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isOpen ? AppColors.greenDark : AppColors.closedDark)),
        ],
      ),
    );
  }


  Widget _buildMainProductCard(
      ProductSearch product, ColorScheme colorScheme) {
    final price = widget.product.prices.firstWhere(
          (p) => p.idQuincaillerie == widget.quincaillerieId,
      orElse: () => widget.product.prices.first,
    );
    final productMap = ProductRecommended(
      idPrice: price.idPrice,
      name: widget.product.name,
      price: price.price,
      pricePromo: price.pricePromo,
      inPromo: price.inPromotion,
      stock: price.stock,
      unite: widget.product.unite,
      description: product.description ?? "",
      score: 0,
      imageUrl: product.imageUrl,
      taux: price.taux,
    );

    return Container(
      padding: const EdgeInsets.all(14),
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
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: const Color(0xFFF5F5F5)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: CachedNetworkImage(
                    imageUrl:
                    _cloudinaryService.getThumbnailUrl(product.imageUrl),
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                        color: Colors.grey[50],
                        child: const Center(
                            child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2)))),
                    errorWidget: (_, __, ___) => Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey[400],
                        size: 22),
                  ),
                ),
              ),
              if (price.inPromotion)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 2),
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(14),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Text("-${price.taux}%",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w900)),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.product.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: AppColors.primary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                if (price.inPromotion) ...[
                  Row(children: [
                    Text("${price.pricePromo.toStringAsFixed(0)} FCFA",
                        style: const TextStyle(
                            color: AppColors.priceGreen,
                            fontWeight: FontWeight.w900,
                            fontSize: 14)),
                    const SizedBox(width: 6),
                    Text("${price.price.toStringAsFixed(0)} FCFA",
                        style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                            fontSize: 11)),
                  ])
                ] else
                  Text("${price.price.toStringAsFixed(0)} FCFA",
                      style: const TextStyle(
                          color: AppColors.priceGreen,
                          fontWeight: FontWeight.w900,
                          fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                    "${price.stock} ${product.unite}${price.stock > 1 ? "s" : ""} en stock",
                    style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          const SizedBox(width: 8),

          SizedBox(
              width: 110,
              child:
              _buildCartButton(price.idPrice, colorScheme, productMap)),
        ],
      ),
    );
  }


  Widget _buildSuggestionsList(ColorScheme colorScheme) {
    return SizedBox(
      height: 270,
      child: FutureBuilder<List<ProductRecommended>>(
        future: _recommandationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              scrollDirection: Axis.horizontal,
              itemCount: 5,
              itemBuilder: (_, __) => _buildSkeleton(),
            );
          }
          if (snapshot.hasError) {
            final e = snapshot.error;
            return e is NoInternetConnectionException
                ? ErrorWidgets(
                message: e.message,
                iconData: Icons.wifi_off,
                onRetry: () => _loadRecommandations(
                    widget.product.prices.first.idPrice))
                : ErrorWidgets(
                message: "Erreur suggestions",
                iconData: Icons.error_outline_rounded,
                onRetry: () => _loadRecommandations(
                    widget.product.prices.first.idPrice));
          }
          if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aucune suggestion"));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            scrollDirection: Axis.horizontal,
            itemCount: snapshot.data!.length,
            itemBuilder: (_, i) =>
                _buildSuggestionCard(snapshot.data![i], colorScheme),
          );
        },
      ),
    );
  }

  Widget _buildSuggestionCard(
      ProductRecommended product, ColorScheme colorScheme) {
    return Container(
      width: 150,
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
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
        children: [
          Stack(
            children: [
              Container(
                height: 112,
                width: double.infinity,
                margin: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(16)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl:
                    _cloudinaryService.getThumbnailUrl(product.imageUrl),
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Center(
                        child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.primary.withOpacity(0.3))),
                    errorWidget: (_, __, ___) => const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                        size: 28),
                  ),
                ),
              ),
              if (product.inPromo)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(8)),
                    child: Text("-${product.taux}%",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w900)),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 2, 10, 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                    "${product.stock} ${product.unite}${product.stock > 1 ? "s" : ""} dispo",
                    style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic)),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Text(
                        "${(product.inPromo ? product.pricePromo : product.price).toStringAsFixed(0)} FCFA",
                        style: const TextStyle(
                            color: AppColors.priceGreen,
                            fontWeight: FontWeight.w900,
                            fontSize: 13)),
                    if (product.inPromo) ...[
                      const SizedBox(width: 4),
                      Text("${product.price.toStringAsFixed(0)}",
                          style: const TextStyle(
                              decoration: TextDecoration.lineThrough,
                              color: Colors.grey,
                              fontSize: 10)),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: _buildCartButton(product.idPrice, colorScheme, product),
          ),
        ],
      ),
    );
  }


  Widget _buildCartButton(
      String idPrice, ColorScheme colorScheme, ProductRecommended product) {
    final int qty = _cartQuantities[idPrice] ?? 0;
    final bool isProcessing = _loadingItems.contains(idPrice);

    if (qty == 0) {
      return SizedBox(
        height: 38,
        // Pas de width: double.infinity — le parent contraint la largeur
        child: ElevatedButton(
          onPressed:
          isProcessing ? null : () => _handleCartAction(product, 1),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            padding: EdgeInsets.zero,
            elevation: 0,
          ),
          child: isProcessing
              ? const SizedBox(
              width: 15,
              height: 15,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Colors.white))
              : const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_shopping_cart_rounded,
                  size: 15, color: Colors.white),
              SizedBox(width: 4),
              Text("Ajouter",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.primary.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 32,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.remove_rounded,
                  size: 16, color: Colors.red),
              onPressed: isProcessing
                  ? null
                  : () => _handleCartAction(product, -1),
            ),
          ),
          Expanded(
            child: Center(
              child: Text("$qty",
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: colorScheme.primary)),
            ),
          ),
          SizedBox(
            width: 32,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.add_rounded,
                  size: 16, color: AppColors.priceGreen),
              onPressed: isProcessing
                  ? null
                  : () => _handleCartAction(product, 1),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildCartBadge(String storeName, String idQuincaillerie) {
    return ValueListenableBuilder(
      valueListenable: Hive.box(_boxName).listenable(),
      builder: (context, Box box, _) {
        final int count = box.values.where((v) =>
        Cart.fromMap(Map<dynamic, dynamic>.from(v)).idQuincaillerie == idQuincaillerie).length;
        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart_rounded,
                  color: Colors.white),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => CartDetailPage(
                          storeName: storeName,
                          idQuincaillerie: idQuincaillerie,
                          fromQuincaillerie: true))),
            ),
            if (count > 0)
              Positioned(
                right: 5,
                top: 5,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    border:
                    Border.all(color: AppColors.primary, width: 1.5),
                  ),
                  child: Center(
                    child: Text("$count",
                        style: const TextStyle(
                            fontSize: 8,
                            color: Colors.white,
                            fontWeight: FontWeight.w900)),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }


  Widget _buildSectionLabel(String label) => Text(label,
      style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.grey.shade500,
          letterSpacing: 1.4));

  Widget _buildSkeleton() => Container(
    width: 150,
    margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _shimmer(height: 112, borderRadius: 16),
      const SizedBox(height: 10),
      _shimmer(height: 12, width: 90),
      const SizedBox(height: 6),
      _shimmer(height: 10, width: 60),
      const SizedBox(height: 8),
      _shimmer(height: 36, borderRadius: 12),
    ]),
  );

  Widget _shimmer(
      {required double height, double? width, double borderRadius = 8}) =>
      Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(borderRadius)),
      );

  void _notify(IconData icon, String text, Color color) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: 50,
        left: 20,
        right: 20,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
              decoration: BoxDecoration(
                color: color.withOpacity(0.92),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: Colors.white, size: 17),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(text,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), () => entry.remove());
  }
}