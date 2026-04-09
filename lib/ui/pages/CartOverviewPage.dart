
/*
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/modele/Cart.dart';
import 'CartDetailPage.dart';

class CartOverviewPage extends StatefulWidget {
  const CartOverviewPage({super.key});

  @override
  _CartOverviewPageState createState() => _CartOverviewPageState();
}

class _CartOverviewPageState extends State<CartOverviewPage> {
  final String _boxName = 'productBox';


  Future<void> _clearAllCarts() async {
    final confirm = await _showConfirmDialog(
      title: "Vider tout le panier ?",
      content: "Cette action supprimera tous les articles de toutes les quincailleries.",
      confirmLabel: "TOUT SUPPRIMER",
    );

    if (confirm == true) {
      await Hive.box(_boxName).clear();
      _showSuccessSnackBar("Le panier a été entièrement vidé");
    }
  }

  Future<void> _deleteStoreCart(String idQuincaillerie, String storeName) async {
    final confirm = await _showConfirmDialog(
      title: "Supprimer ce magasin ?",
      content: "Voulez-vous retirer tous les articles de '$storeName' ?",
      confirmLabel: "SUPPRIMER",
    );

    if (confirm == true) {
      final box = Hive.box(_boxName);
      final keysToDelete = box.keys.where((key) {
        final item = box.get(key);
        return item['idQuincaillerie'] == idQuincaillerie;
      }).toList();

      for (var key in keysToDelete) {
        await box.delete(key);
      }
      _showSuccessSnackBar("Panier de $storeName supprimé");
    }
  }

  // --- UI HELPERS ---

  Future<bool?> _showConfirmDialog({
    required String title,
    required String content,
    required String confirmLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("ANNULER", style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text(confirmLabel, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w600)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF43A047),
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          "Mes Paniers",
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -0.8),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,

        actions: [
          ValueListenableBuilder(
            valueListenable: Hive.box(_boxName).listenable(),
            builder: (context, Box box, _) {
              if (box.isEmpty) return const SizedBox.shrink();
              return IconButton(
                onPressed: _clearAllCarts,
                icon: const Icon(Icons.delete_sweep_outlined, color: Colors.white, size: 26),
                tooltip: "Vider tout",
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box(_boxName).listenable(),
        builder: (context, Box box, _) {
          List<Cart> allItems = [];
          try {
            allItems = box.values.map((i) {
              return Cart.fromMap(Map<dynamic, dynamic>.from(i));
            }).toList();
          } catch (e) {
            debugPrint("Erreur Hive: $e");
          }

          if (allItems.isEmpty) return _buildEmptyState();

          // Groupement par boutique
          Map<String, List<Cart>> groupedItems = {};
          for (var item in allItems) {
            if (item.idQuincaillerie.isNotEmpty) {
              groupedItems.putIfAbsent(item.idQuincaillerie, () => []).add(item);
            }
          }

          final storeIds = groupedItems.keys.toList();
          double grandTotal = allItems.fold(0, (sum, item) => sum + (item.price * item.quantity));

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
                  itemCount: storeIds.length,
                  itemBuilder: (context, index) {
                    final idQ = storeIds[index];
                    final products = groupedItems[idQ]!;
                    final storeName = products.first.storeName;
                    final storeTotal = products.fold(0.0, (sum, item) => sum + (item.price * item.quantity));

                    return _buildStoreCard(idQ, storeName, products.length, storeTotal, colorScheme);
                  },
                ),
              ),
              _buildBottomSummary(storeIds.length, grandTotal, colorScheme),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStoreCard(String idQ, String name, int count, double total, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: InkWell(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CartDetailPage(storeName: name, idQuincaillerie: idQ),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      height: 56,
                      width: 56,
                      decoration: BoxDecoration(
                        color: colorScheme.secondary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(Icons.store_mall_directory_rounded, color: colorScheme.secondary, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, letterSpacing: -0.4),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              "$count Produit${count > 1 ? 'S' : ''}",
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 10, fontWeight: FontWeight.w800),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => _deleteStoreCart(idQ, name),
                      style: IconButton.styleFrom(backgroundColor: Colors.red.shade50),
                      icon: Icon(Icons.delete_outline_rounded, color: Colors.red.shade400, size: 22),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.secondary.withOpacity(0.05), colorScheme.secondary.withOpacity(0.1)],
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Sous-total",
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 14),
                    ),
                    Text(
                      "${total.toStringAsFixed(0)} FCFA",
                      style: TextStyle(fontWeight: FontWeight.w900, color: colorScheme.secondary, fontSize: 17),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSummary(int storeCount, double total, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 34),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(35)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 40, offset: const Offset(0, -5)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "TOTAL PANIERS ($storeCount)",
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Montant cumulé",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Colors.black87),
                    ),
                  ],
                ),
                Text(
                  "${total.toStringAsFixed(0)} FCFA",
                  style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w900, fontSize: 26, letterSpacing: -1.2),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 8,
                  shadowColor: colorScheme.primary.withOpacity(0.4),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("VALIDER TOUS LES ACHATS", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    SizedBox(width: 12),
                    Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
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
            padding: const EdgeInsets.all(45),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade100, width: 2),
            ),
            child: Icon(Icons.shopping_bag_outlined, size: 90, color: Colors.grey.shade200),
          ),
          const SizedBox(height: 30),
          const Text(
            "Votre panier est vide",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black87, letterSpacing: -0.5),
          ),
          const SizedBox(height: 10),
          Text(
            "Commencez vos achats pour voir\nvos paniers ici.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade400, fontSize: 16, height: 1.4),
          ),
        ],
      ),
    );
  }
}
 */

import 'package:flutter/material.dart';
import 'package:brixel/ui/theme/AppColors.dart';
import 'package:brixel/data/modele/Cart.dart';
import 'package:brixel/service/hive/PanierHiveService.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'CartDetailPage.dart';

class CartOverviewPage extends StatelessWidget {
  const CartOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Mes Paniers",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 17,
            letterSpacing: 0.3,
          ),
        ),
        actions: [
          ValueListenableBuilder(
            valueListenable: Hive.box('productBox').listenable(),
            builder: (context, Box box, _) {
              if (box.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.delete_forever_rounded, color: AppColors.accent),
                onPressed: () => _clearAllCarts(context),
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('productBox').listenable(),
        builder: (context, Box box, _) {
          final allItems = box.values
              .map((e) => Cart.fromMap(Map<String, dynamic>.from(e)))
              .toList();

          final Map<String, List<Cart>> grouped = {};
          for (var item in allItems) {
            grouped.putIfAbsent(item.idQuincaillerie, () => []).add(item);
          }

          if (grouped.isEmpty) return _buildEmptyState();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: grouped.length,
            itemBuilder: (context, index) {
              final String idQ = grouped.keys.elementAt(index);
              return _StoreCartCard(
                idQuincaillerie: idQ,
                items: grouped[idQ]!,
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _clearAllCarts(BuildContext context) async {
    final confirm = await _showConfirm(
      context,
      "Vider tout ?",
      "Supprimer tous les articles de tous les magasins ?",
    );
    if (confirm) await Hive.box('productBox').clear();
  }

  Future<bool> _showConfirm(BuildContext context, String title, String content) async =>
      await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary)),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("ANNULER", style: TextStyle(color: AppColors.textMuted)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("SUPPRIMER", style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ) ??
          false;

  Widget _buildEmptyState() => Center(
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
          child: const Icon(Icons.shopping_cart_outlined, size: 38, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        const Text(
          "Aucun panier en cours",
          style: TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Ajoutez des articles depuis les magasins",
          style: TextStyle(color: Colors.grey[400], fontSize: 13),
        ),
      ],
    ),
  );
}


class _StoreCartCard extends StatelessWidget {
  final String idQuincaillerie;
  final List<Cart> items;

  const _StoreCartCard({required this.idQuincaillerie, required this.items});

  double get _total => items.fold(0,
        (sum, i) => sum + ((i.inPromotion ? (i.pricePromo ?? 0) : i.price) * i.quantity),
  );

  //int get _totalQty => items.fold(0, (sum, i) => sum + i.quantity);
  int get _totalQty => items.length;


  @override
  Widget build(BuildContext context) {
    final String storeName = items.first.storeName;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Column(
        children: [

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.store_rounded, color: Colors.white70, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        storeName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          letterSpacing: 0.2,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 1),
                      Text(
                        "$_totalQty article${_totalQty > 1 ? 's' : ''}",
                        style: const TextStyle(color: Colors.white, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.accent, size: 20),
                  onPressed: () => _deleteStoreCart(context, idQuincaillerie, storeName),
                ),
              ],
            ),
          ),

          if (items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: SizedBox(
                height: 44,
                child: Stack(
                  children: [
                    for (int i = 0; i < items.length.clamp(0, 4); i++)
                      Positioned(
                        left: i * 30.0,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white, width: 2),
                            color: AppColors.surface,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: items[i].imageUrl.isNotEmpty
                                ? Image.network(
                              items[i].imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.grey,
                                size: 16,
                              ),
                            )
                                : const Icon(Icons.image_not_supported_outlined, color: Colors.grey, size: 16),
                          ),
                        ),
                      ),
                    if (items.length > 4)
                      Positioned(
                        left: 4 * 30.0,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white, width: 2),
                            color: AppColors.primary.withOpacity(0.08),
                          ),
                          child: Center(
                            child: Text(
                              "+${items.length - 4}",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

          // ── Footer : total + bouton ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Total estimé",
                      style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "${_total.toStringAsFixed(0)} FCFA",
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.priceGreen,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CartDetailPage(
                        storeName: storeName,
                        idQuincaillerie: idQuincaillerie,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.shopping_cart_rounded, size: 15, color: Colors.white),
                  label: const Text(
                    "Gérer",
                    style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteStoreCart(BuildContext context, String idQ, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          "Supprimer ?",
          style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary),
        ),
        content: Text("Retirer le panier de '$name' ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("ANNULER", style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("SUPPRIMER", style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final box = Hive.box('productBox');
      final keys = box.keys.where((k) => box.get(k)['idQuincaillerie'] == idQ).toList();
      for (var k in keys) await box.delete(k);
    }
  }
}