import 'package:brixel/Exception/AppException.dart';
import 'package:brixel/Exception/NoInternetConnectionException.dart';
import 'package:brixel/data/modele/ProductRecommended.dart';
import 'package:brixel/data/modele/QuincaillerieDetail.dart';
import 'package:brixel/data/modele/Cart.dart';
import 'package:brixel/hive/CartService.dart';
import 'package:brixel/provider/UserProvider.dart';
import 'package:brixel/service/PanierService.dart';
import 'package:brixel/service/ProductService.dart';
import 'package:brixel/service/QuincaillerieService.dart';
import 'package:brixel/ui/pages/CartDetailPage.dart';
import 'package:brixel/ui/pages/authPages/client/RegisterPage.dart';
import 'package:brixel/ui/widgets/ErrorWidgets.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../../Exception/UserNotConnectedException.dart';
import '../../data/modele/Price.dart';
import '../../data/modele/ProductSearch.dart';

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

class _QuincaillerieDetailsPageState
    extends State<QuincaillerieDetailsPage> {
  late Future<dynamic> _storeFuture;
  late Future<List<ProductRecommended>> _recommandationFuture;

  final ProductService _productService = ProductService();
  final QuincaillerieService _quincaillerieService = QuincaillerieService();
  final CartService _cartService = CartService();
  final PanierService _panierService = PanierService();
  final TextEditingController _searchController = TextEditingController();
  final String _boxName = 'productBox';
  bool _isHiveReady = false;
  final Set<String> _loadingItems = {};
  bool _showCart = false;

  final Map<String, bool> _cartStatus = {};

  String _dynamicStoreName = "Chargement...";

  @override
  void initState() {
    super.initState();

    final priceEntry = widget.product.prices.firstWhere(
          (p) => p.idQuincaillerie == widget.quincaillerieId,
      orElse: () => widget.product.prices.first,
    );
    _dynamicStoreName = priceEntry.quincaillerieName;


    _storeFuture = _quincaillerieService.getDetailQuincaillerie(widget.quincaillerieId).then((value) {
      if (value is QuincaillerieDetail && mounted) {
        setState(() {
          _dynamicStoreName = value.name;
          _showCart = true;
        });
      }
      return value;
    });


    _loadRecommandations(priceEntry.idPrice);

    _initHive();
  }


  void _loadRecommandations(String mainProductIdPrice) {
    _recommandationFuture = _productService.getRecommandationByProductAndStore(widget.product.idProduct, widget.quincaillerieId)
        .then((value) => value.cast<ProductRecommended>())
        .then((suggestions) async {

      final List<String> allIds = [
        mainProductIdPrice,
        ...suggestions.map((s) => s.idPrice),
      ];


      await _loadCartStatus(allIds);

      return suggestions;
    });
  }


  Future<void> _loadCartStatus(List<String> ids) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);


    if (!userProvider.isAuthenticated) {
      if (mounted) {
        setState(() {
          for (final id in ids) {
            _cartStatus[id] = false;
          }
        });
      }
      return;
    }

    await Future.wait(
      ids.map((id) async {
        try {
          final exists =
          await _panierService.checkIfProductExistInPanierByUser(id);
          if (mounted) _cartStatus[id] = exists ?? false;
        } on UserNotConnectedException {
          if (mounted) _cartStatus[id] = false;
        } on NoInternetConnectionException {
          if (mounted) _cartStatus[id] = false;
        } catch (_) {
          if (mounted) _cartStatus[id] = false;
        }
      }),
    );

    if (mounted) setState(() {});
  }


  void _retry() {
    final priceEntry = widget.product.prices.firstWhere(
          (p) => p.idQuincaillerie == widget.quincaillerieId,
      orElse: () => widget.product.prices.first,
    );

    setState(() {
      _showCart = false;

      _storeFuture = _quincaillerieService
          .getDetailQuincaillerie(widget.quincaillerieId)
          .then((value) {
        if (value is QuincaillerieDetail && mounted) {
          setState(() {
            _dynamicStoreName = value.name;
            _showCart = true;
          });
        }
        return value;
      });

      _loadRecommandations(priceEntry.idPrice);
    });
  }

  Future<void> _initHive() async {
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
    if (mounted) {
      setState(() {
        _isHiveReady = true;
      });
    }
  }

  Future<void> _handleCartAction(
      String idPrice, String productName, double price) async {
    setState(() => _loadingItems.add(idPrice));

    final bool currentlyInCart = _cartStatus[idPrice] ?? false;

    Cart cart = Cart(
      idPrice: idPrice,
      idQuincaillerie: widget.quincaillerieId,
      productName: productName,
      storeName: _dynamicStoreName,
      price: price,
      quantity: 1,
    );

    try {
      if (currentlyInCart) {

        await _cartService.removeItem(idPrice);
        if (mounted) setState(() => _cartStatus[idPrice] = false);


        await _panierService.deleteProductToPanier(idPrice);

        _showStyledSnackBar(
          message: "$productName retiré du panier",
          icon: Icons.remove_shopping_cart,
          color: Colors.green,
        );
      } else {

        await _cartService.addToCart(cart);
        if (mounted) setState(() => _cartStatus[idPrice] = true);


        await _panierService.addProductToPanier(idPrice);

        _showStyledSnackBar(
          message: "$productName ajouté au panier",
          icon: Icons.check_circle,
          color: Colors.green,
        );
      }
    } on NoInternetConnectionException catch (e) {

      if (currentlyInCart) {
        await _cartService.addToCart(cart);
      } else {
        await _cartService.removeItem(idPrice);
      }
      if (mounted) setState(() => _cartStatus[idPrice] = currentlyInCart);

      _showStyledSnackBar(
          message: e.message, icon: Icons.wifi_off, color: Colors.red);
    } on UserNotConnectedException {

      if (currentlyInCart) {
        await _cartService.addToCart(cart);
      } else {
        await _cartService.removeItem(idPrice);
      }
      if (mounted) setState(() => _cartStatus[idPrice] = currentlyInCart);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RegisterPage(
            label: "Creer un compte pour gérer votre panier",
          ),
        ),
      );
    } on AppException catch (e) {

      if (currentlyInCart) {
        await _cartService.addToCart(cart);
      } else {
        await _cartService.removeItem(idPrice);
      }
      if (mounted) setState(() => _cartStatus[idPrice] = currentlyInCart);

      _showStyledSnackBar(
          message: e.message, icon: Icons.error_outline, color: Colors.red);
    } finally {
      if (mounted) setState(() => _loadingItems.remove(idPrice));
    }
  }

  void _showStyledSnackBar({required String message, required IconData icon, required Color color}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
                child: Text(message, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white))),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (!_isHiveReady) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }

    final priceEntry = widget.product.prices.firstWhere(
          (p) => p.idQuincaillerie == widget.quincaillerieId,
      orElse: () => widget.product.prices.first,
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 80,
            pinned: true,
            elevation: 0,
            backgroundColor: colorScheme.primary,
            actions: [
              if (_showCart)
                _buildCartBadge(
                    _dynamicStoreName, widget.quincaillerieId, colorScheme),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              title: Text(_dynamicStoreName,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white)),
              background: Container(color: colorScheme.primary),
            ),
          ),
          FutureBuilder<dynamic>(
            future: _storeFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()));
              }

              if (snapshot.hasError) {
                final error = snapshot.error;

                if (error is NoInternetConnectionException) {
                  return SliverFillRemaining(
                    child: ErrorWidgets(
                        message: error.message,
                        iconData: Icons.wifi_off_outlined,
                        onRetry: _retry),
                  );
                } else if (error is AppException) {
                  return SliverFillRemaining(
                    child: ErrorWidgets(
                        message: error.message,
                        iconData: Icons.error_outline,
                        onRetry: _retry),
                  );
                } else {
                  return SliverFillRemaining(
                    child: ErrorWidgets(
                        message: "Erreur interne",
                        iconData: Icons.error_outline,
                        onRetry: _retry),
                  );
                }
              }

              QuincaillerieDetail store = snapshot.data;

              return SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.white,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildInfoItem(
                            Icons.location_on, store.quartier, Colors.blue),
                        _buildInfoItem(
                            Icons.phone, store.telephone, Colors.green),
                        _buildInfoItem(
                            Icons.star, "${store.averageRating}", Colors.orange),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("PRODUIT SÉLECTIONNÉ",
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey)),
                        const SizedBox(height: 12),
                        _buildMainProductCard(priceEntry, colorScheme),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: "Rechercher des compléments...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                    child: Text("SUGGESTIONS",
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey)),
                  ),
                  SizedBox(
                    height: 215,
                    child: FutureBuilder<List<ProductRecommended>>(
                      future: _recommandationFuture,
                      builder: (context, suggSnapshot) {
                        if (suggSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        if (suggSnapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("Erreur de chargement des recommandations", style: TextStyle(fontSize: 12, color: Colors.grey)),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    final entry =
                                    widget.product.prices.firstWhere(
                                          (p) =>
                                      p.idQuincaillerie ==
                                          widget.quincaillerieId,
                                      orElse: () =>
                                      widget.product.prices.first,
                                    );
                                    setState(() =>
                                        _loadRecommandations(entry.idPrice));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(12)),
                                  ),
                                  child: const Text("Réessayer"),
                                ),
                              ],
                            ),
                          );
                        }

                        if (suggSnapshot.data == null ||
                            suggSnapshot.data!.isEmpty) {
                          return const Center(
                              child: Text(
                                  "Aucune recommendation disponible",
                                  style: TextStyle(
                                      fontSize: 12, color: Colors.grey)));
                        }

                        final suggestions = suggSnapshot.data!;

                        return ListView.builder(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 12),
                          scrollDirection: Axis.horizontal,
                          itemCount: suggestions.length,
                          itemBuilder: (context, index) {
                            return _buildRecommendationItem(
                                suggestions[index], colorScheme);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                ]),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMainProductCard(Price price, ColorScheme colorScheme) {
    bool isProcessing = _loadingItems.contains(price.idPrice);
    bool inCart = _cartStatus[price.idPrice] ?? false;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.05), blurRadius: 10)
          ]),
      child: Row(
        children: [
          CircleAvatar(
              backgroundColor: colorScheme.primary.withOpacity(0.1),
              child: const Icon(Icons.image)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("${price.price} FCFA",
                    style: const TextStyle(
                        color: Colors.green, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
              "${price.stock} ${widget.product.unite}${price.stock > 1 ? 's' : ''}"),
          const SizedBox(width: 20),
          ElevatedButton(
            onPressed: isProcessing
                ? null
                : () => _handleCartAction(price.idPrice,
                widget.product.name, price.price),
            style: ElevatedButton.styleFrom(
              backgroundColor:
              inCart ? Colors.green.shade50 : colorScheme.primary,
              foregroundColor: inCart ? Colors.green : Colors.white,
              elevation: inCart ? 0 : 2,
              padding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: isProcessing
                ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
                : Icon(
                inCart ? Icons.check_circle : Icons.add_shopping_cart,
                size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(
      ProductRecommended product, ColorScheme colorScheme) {
    bool isProcessing = _loadingItems.contains(product.idPrice);
    bool inCart = _cartStatus[product.idPrice] ?? false;

    return Container(
      width: 120,
      height: 210,
      margin: const EdgeInsets.symmetric(horizontal: 6),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 80,
            width: double.infinity,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.image_outlined, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Text(product.name,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Text("${product.price} Fcfa",
              style: const TextStyle(
                  color: Colors.green,
                  fontSize: 13,
                  fontWeight: FontWeight.bold)),
          Text(
              "${product.stock} ${product.unite}${product.stock > 1 ? 's' : ''}",
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isProcessing ? null
                  : () => _handleCartAction(product.idPrice, product.name, product.price),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                inCart ? Colors.green.shade50 : colorScheme.primary,
                foregroundColor: inCart ? Colors.green : Colors.white,
                elevation: inCart ? 0 : 2,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: isProcessing ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
                  : Icon(
                  inCart ? Icons.check_circle : Icons.add_shopping_cart,
                  size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartBadge(String storeName, String idQuincaillerie, ColorScheme colorScheme) {
    return ValueListenableBuilder(
      valueListenable: Hive.box(_boxName).listenable(),
      builder: (context, Box box, _) {
        final items = box.values.where((v) {
          final c = Cart.fromMap(Map<dynamic, dynamic>.from(v));
          return c.idQuincaillerie == idQuincaillerie;
        }).length;

        return Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.shopping_cart, color: Colors.white),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => CartDetailPage(
                          storeName: storeName,
                          idQuincaillerie: idQuincaillerie,
                        fromQuincaillerie: true,
                      )
                  )
              ),
            ),
            if (items > 0)
              Positioned(
                right: 8,
                top: 8,
                child: CircleAvatar(
                    radius: 8,
                    backgroundColor: Colors.red,
                    child: Text("$items", style: const TextStyle(fontSize: 10, color: Colors.white))),
              )
          ],
        );
      },
    );
  }

  Widget _buildInfoItem(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }
}