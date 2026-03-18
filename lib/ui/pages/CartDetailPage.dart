import 'package:brixel/Exception/AppException.dart';
import 'package:brixel/Exception/NoInternetConnectionException.dart';
import 'package:brixel/Exception/UserNotConnectedException.dart';
import 'package:brixel/service/PanierService.dart';
import 'package:brixel/ui/widgets/ErrorWidgets.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/modele/Cart.dart';
import '../../hive/CartService.dart';
import 'authPages/client/RegisterPage.dart';

class CartDetailPage extends StatefulWidget {
  final String storeName;
  final String idQuincaillerie;
  final bool fromQuincaillerie;

  const CartDetailPage({
    super.key,
    required this.storeName,
    required this.idQuincaillerie,
    this.fromQuincaillerie = false,
  });

  @override
  State<CartDetailPage> createState() => _CartDetailPageState();
}

class _CartDetailPageState extends State<CartDetailPage> {
  final CartService _cartService = CartService();
  final PanierService _panierService = PanierService();
  final String _boxName = "productBox";
  late Future<List<Cart>> _panierFuture;

  @override
  void initState() {
    super.initState();
    _panierFuture = _loadPanier();
  }


  Future<List<Cart>> _loadPanier() async {

    final articles = await _panierService.getAllProduct();


    await _cartService.clearCart();

    for (final cart in articles) {
      await Hive.box(_boxName).put(cart.idPrice, cart.toMap());
    }


    return articles.where((item) => item.idQuincaillerie == widget.idQuincaillerie).toList();
  }


  void _retry() {
    setState(() {
      _panierFuture = _loadPanier();
    });
  }

  Future<void> _rollbackItems(List<Cart> items) async {
    for (final item in items) {
      await _cartService.addToCart(item);
    }
  }


  Future<void> _clearStoreCart(BuildContext context) async {
    final confirm = await _showConfirmDialog(
      context,
      title: "Vider ce panier ?",
      content: "Voulez-vous retirer tous les articles de '${widget.storeName}' ?",
      confirmLabel: "VIDER",
      isDangerous: true,
    );

    if (confirm == true) {

      final box = Hive.box(_boxName);
      final savedItems = box.values.map((i) => Cart.fromMap(Map<dynamic, dynamic>.from(i)))
          .where((item) => item.idQuincaillerie == widget.idQuincaillerie).toList();

      for (final item in savedItems) {
        await _cartService.removeItem(item.idPrice);
      }


      try {
        await _panierService.deletePanierByQuincaillerie(widget.idQuincaillerie);
        _showStyledSnackBar(message: "Panier supprimer avec succes", icon: Icons.check_circle, color: Colors.green);

      } on NoInternetConnectionException catch (e) {
        _showStyledSnackBar(message: e.message, icon: Icons.wifi_off, color: Colors.red);
      } on AppException catch (e) {

        await _rollbackItems(savedItems);
        _showStyledSnackBar(message: e.message, icon: Icons.error, color: Colors.red);
      } catch (e) {

        await _rollbackItems(savedItems);
        _showStyledSnackBar(message: "Erreur", icon: Icons.error, color: Colors.red);
      }
    }
  }


  Future<void> _removeProduct(BuildContext context, Cart item) async {
    final confirm = await _showConfirmDialog(
      context,
      title: "Supprimer l'article ?",
      content: "Retirer '${item.productName}' de votre panier ?",
      confirmLabel: "SUPPRIMER",
      isDangerous: true,
    );
    if (confirm == true) {
      await _cartService.removeItem(item.idPrice);

      _showStyledSnackBar(message: "Produit supprimer du panier avec succes", icon: Icons.check_circle, color: Colors.green);

      try {
        await _panierService.deleteProductToPanier(item.idPrice);
      } on NoInternetConnectionException catch(e) {
        await _cartService.addToCart(item);
        _showStyledSnackBar(message: e.message, icon: Icons.wifi_off, color: Colors.red);
      } on UserNotConnectedException catch(e) {
        await _cartService.addToCart(item);
        _showStyledSnackBar(message: e.message, icon: Icons.no_accounts, color: Colors.red);
      } on AppException catch (e) {
        await _cartService.addToCart(item);
        _showStyledSnackBar(message: e.message, icon: Icons.error, color: Colors.red);
      } catch (e) {
        await _cartService.addToCart(item);
        _showStyledSnackBar(message: "Erreur", icon: Icons.error, color: Colors.red);
      }
    }
  }


  void _confirmOrder(BuildContext context, double total) async {
    final confirm = await _showConfirmDialog(
      context,
      title: "Confirmer la commande",
      content: "Commander ces articles pour ${total.toStringAsFixed(0)} FCFA chez ${widget.storeName} ?",
      confirmLabel: "COMMANDER",
    );
    if (confirm == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Commande validée avec succès !")),
      );
    }
  }


  Future<bool?> _showConfirmDialog(
      BuildContext context, {
        required String title,
        required String content,
        required String confirmLabel,
        bool isDangerous = false,
      }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Text(content,
            style: const TextStyle(color: Colors.black87)),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("ANNULER",
                style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDangerous ? Colors.redAccent : Colors.orange[800],
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              "Panier de chez ${widget.storeName}",
              style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  letterSpacing: -0.5),
            ),
            const Text(
              "Détails de ma commande",
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => _clearStoreCart(context),
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.redAccent),
            tooltip: "Vider le panier",
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: FutureBuilder<List<Cart>>(
        future: _panierFuture,
        builder: (context, snapshot) {


          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }


          if (snapshot.hasError) {
            final error = snapshot.error;
            if(error is NoInternetConnectionException){
              return ErrorWidgets(message: error.message, iconData: Icons.wifi_off, onRetry: () {_retry();},);
            }
            if(error is UserNotConnectedException){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RegisterPage(
                    label: "Creer un compte pour gérer votre panier",
                  ),
                ),
              );
            } if (error is AppException) {
              return ErrorWidgets(message: error.message, iconData: Icons.error, onRetry: () {_retry();},);
            } else {
              return ErrorWidgets(message: "Erreur", iconData: Icons.error, onRetry: () {_retry();},);

            }
          }


          final filteredItems = snapshot.data ?? [];
          if (filteredItems.isEmpty) {
            return _buildEmptyState();
          }


          return ValueListenableBuilder(
            valueListenable: Hive.box(_boxName).listenable(),
            builder: (context, Box box, _) {
              final liveItems = box.values.map((i) => Cart.fromMap(Map<dynamic, dynamic>.from(i)))
                  .where((item) => item.idQuincaillerie == widget.idQuincaillerie).toList();

              if (liveItems.isEmpty) {
                if (widget.fromQuincaillerie) return _buildEmptyState();
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (Navigator.canPop(context)) Navigator.pop(context);
                });
                return const SizedBox();
              }

              double total = liveItems.fold(0, (sum, item) => sum + (item.price * item.quantity));

              return Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: liveItems.length,
                      itemBuilder: (context, index) {
                        return _buildProductCard(context, liveItems[index], colorScheme.primary);
                      },
                    ),
                  ),
                  _buildCheckoutSection(context, total, liveItems),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Cart item, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Icons.handyman_rounded, color: primaryColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                      letterSpacing: -0.3),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  "${item.price.toStringAsFixed(0)} FCFA",
                  style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 14),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                _quantityCircleBtn(Icons.remove, () {
                  if (item.quantity > 1) {
                    _cartService.updateQuantity(item.idPrice, item.quantity - 1);
                  }
                }),
                SizedBox(
                  width: 32,
                  child: Text(
                    "${item.quantity}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 14),
                  ),
                ),
                _quantityCircleBtn(Icons.add, () {
                  _cartService.updateQuantity(item.idPrice, item.quantity + 1);
                }),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _removeProduct(context, item),
            style: IconButton.styleFrom(
              backgroundColor: Colors.red.shade50,
              visualDensity: VisualDensity.compact,
            ),
            icon: const Icon(Icons.delete_outline_rounded,
                color: Colors.redAccent, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _quantityCircleBtn(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)
            ]),
        child: Icon(icon, size: 14, color: Colors.black87),
      ),
    );
  }

  Widget _buildCheckoutSection(
      BuildContext context, double total, List<Cart> items) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -5),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "TOTAL À PAYER",
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: Colors.grey.shade500,
                    letterSpacing: 1.0),
              ),
              Text(
                "${total.toStringAsFixed(0)} FCFA",
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                    letterSpacing: -1),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
              onPressed: () => _confirmOrder(context, total),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 20),
                  SizedBox(width: 12),
                  Text(
                    "VALIDER LA COMMANDE",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(45),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade100, width: 2),
            ),
            child: Icon(Icons.shopping_bag_outlined,
                size: 90, color: Colors.grey.shade200),
          ),
          const SizedBox(height: 30),
          const Text(
            "Votre panier est vide",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
                letterSpacing: -0.5),
          ),
          const SizedBox(height: 10),
          Text(
            "Commencez vos achats pour voir\nvos paniers ici.",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.grey.shade400, fontSize: 16, height: 1.4),
          ),
        ],
      ),
    );
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
                child: Text(message, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white))
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.only(bottom: 100),
      ),
    );
  }
}