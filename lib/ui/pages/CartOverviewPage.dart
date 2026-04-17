import 'package:brixel/Exception/NoInternetConnectionException.dart';
import 'package:brixel/service/PanierService.dart';
import 'package:flutter/material.dart';
import 'package:brixel/ui/theme/AppColors.dart';
import 'package:brixel/data/modele/Cart.dart';
import 'package:brixel/service/hive/PanierHiveService.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'CartDetailPage.dart';

class CartOverviewPage extends StatefulWidget {
  const CartOverviewPage({super.key});

  @override
  State<CartOverviewPage> createState() => _CartOverviewPageState();
}

class _CartOverviewPageState extends State<CartOverviewPage> {
  final PanierService _panierService = PanierService();

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

    if (confirm) {
      final box = Hive.box('productBox');

      final Map<dynamic, dynamic> backupData = box.toMap();

      await box.clear();

      try {
        await _panierService.deleteAllPaniersByUser();
      } catch (e) {

        await box.putAll(backupData);

        if(e is NoInternetConnectionException) {
          _notify(Icons.wifi_off, e.message, Colors.red);
        }else {
          _notify(Icons.error_outline_rounded,"Erreur", Colors.red);

        }

      }
    }
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

class _StoreCartCard extends StatefulWidget {
  final String idQuincaillerie;
  final List<Cart> items;

  const _StoreCartCard({required this.idQuincaillerie, required this.items});

  @override
  State<_StoreCartCard> createState() => _StoreCartCardState();
}

class _StoreCartCardState extends State<_StoreCartCard> {
  final PanierService _panierService = PanierService();

  double get _total => widget.items.fold(
    0,
        (sum, i) => sum + ((i.inPromotion ? (i.pricePromo ?? 0) : i.price) * i.quantity),
  );

  int get _totalQty => widget.items.length;

  @override
  Widget build(BuildContext context) {
    final String storeName = widget.items.first.storeName;

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
                  onPressed: () => _deleteStoreCart(context, widget.idQuincaillerie, storeName),
                ),
              ],
            ),
          ),

          if (widget.items.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: SizedBox(
                height: 44,
                child: Stack(
                  children: [
                    for (int i = 0; i < widget.items.length.clamp(0, 4); i++)
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
                            child: widget.items[i].imageUrl.isNotEmpty
                                ? Image.network(
                              widget.items[i].imageUrl,
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
                    if (widget.items.length > 4)
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
                              "+${widget.items.length - 4}",
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
                        idQuincaillerie: widget.idQuincaillerie,
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
        title: const Text(
          "Supprimer ?",
          style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary),
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

      // 1. SAUVEGARDE POUR LE ROLLBACK
      final Map<dynamic, dynamic> backupData = {};
      for (var k in keys) {
        backupData[k] = box.get(k);
      }

      // 2. MISE À JOUR OPTIMISTE (Suppression locale immédiate)
      for (var k in keys) {
        await box.delete(k);
      }

      // 3. SYNCHRONISATION SERVEUR
      try {
        await _panierService.deletePanierByQuincaillerie(idQ);
      } catch (e) {
        // 4. ROLLBACK EN CAS D'ÉCHEC
        for (var k in keys) {
          await box.put(k, backupData[k]); // Restauration des objets
        }

        if(e is NoInternetConnectionException) {
          _notify(Icons.wifi_off, e.message, Colors.red);
        }else {
          _notify(Icons.error_outline_rounded,"Erreur", Colors.red);

        }
      }
    }
  }

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