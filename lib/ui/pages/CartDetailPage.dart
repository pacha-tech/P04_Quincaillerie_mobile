
import 'package:brixel/service/cloudinary/CloudinaryService.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:brixel/ui/theme/AppColors.dart';
import 'package:brixel/data/modele/Cart.dart';
import 'package:brixel/service/hive/PanierHiveService.dart';
import 'package:brixel/service/PanierService.dart';
import '../../data/modele/Conversation.dart';
import 'ChatPage.dart';

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
  final PanierHiveService _panierHive = PanierHiveService();
  final PanierService _panierService = PanierService();
  CloudinaryService _cloudinaryService = CloudinaryService();
  static const String _boxName = "productBox";


  String _generateChatMessage(List<Cart> items, double total) {
    final buffer = StringBuffer(
      "Bonjour 👋, je souhaiterais négocier pour les articles suivants chez ${widget.storeName} :\n\n",
    );
    for (var item in items) {
      final double price = item.inPromotion ? (item.pricePromo ?? 0) : item.price;
      buffer.writeln("• ${item.productName} (Qté: ${item.quantity}) - ${price.toStringAsFixed(0)} FCFA/u");
    }
    buffer.write("\n💰 *Total actuel : ${total.toStringAsFixed(0)} FCFA*");
    return buffer.toString();
  }


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
        title:Text(
          "Panier de ${widget.storeName}",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.accent),
            onPressed: _confirmClearStoreCart,
            tooltip: "Vider ce panier",
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box(_boxName).listenable(),
        builder: (context, Box box, _) {
          final List<Cart> items = box.values
              .map((e) => Cart.fromMap(Map<String, dynamic>.from(e)))
              .where((item) => item.idQuincaillerie == widget.idQuincaillerie)
              .toList();

          if (items.isEmpty) return _buildEmptyState();

          final double total = items.fold(0, (sum, item) {
            final double p = item.inPromotion ? (item.pricePromo ?? 0) : item.price;
            return sum + (p * item.quantity);
          });

          return Column(
            children: [

              _buildSummaryBanner(items, total),

              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) => _buildProductCard(items[index]),
                ),
              ),

              _buildBottomAction(items, total),
            ],
          );
        },
      ),
    );
  }


  Widget _buildSummaryBanner(List<Cart> items, double total) {
    final int totalQty = items.fold(0, (s, i) => s + i.quantity);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          _buildBannerStat(
            icon: Icons.inventory_2_outlined,
            label: "Produit${items.length > 1 ? "s":""}",
            value: "${items.length}",
            color: AppColors.primary,
          ),
          _buildDivider(),
          _buildBannerStat(
            icon: Icons.shopping_bag_outlined,
            label: "Quantité",
            value: "$totalQty",
            color: AppColors.infoVille,
          ),
          _buildDivider(),
          _buildBannerStat(
            icon: Icons.payments_outlined,
            label: "Total",
            value: "${total.toStringAsFixed(0)} F",
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


  Widget _buildProductCard(Cart item) {
    final double unitPrice = item.inPromotion ? (item.pricePromo ?? 0) : item.price;
    final double subTotal = unitPrice * item.quantity;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [

          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CachedNetworkImage(
                  imageUrl: _cloudinaryService.getThumbnailUrl(item.imageUrl),
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => Container(
                    width: 72,
                    height: 72,
                    color: AppColors.surface,
                    child: const Icon(Icons.image_not_supported_outlined, color: Colors.grey),
                  ),
                ),
              ),
              if (item.inPromotion)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(14),
                        bottomRight: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      "PROMO",
                      style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),


          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.primary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      "${unitPrice.toStringAsFixed(0)} FCFA/u",
                      style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                    if (item.inPromotion && item.price > 0) ...[
                      const SizedBox(width: 4),
                      Text(
                        item.price.toStringAsFixed(0),
                        style: const TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  "${subTotal.toStringAsFixed(0)} FCFA",
                  style: const TextStyle(
                    color: AppColors.priceGreen,
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.delete_outline_rounded, color: AppColors.accent, size: 20),
                onPressed: () => _confirmDeleteItem(item),
              ),
              const SizedBox(height: 8),
              _buildQtySelector(item),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildQtySelector(Cart item) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 30,
            height: 30,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.remove_rounded, size: 15, color: AppColors.accent),
              onPressed: () => _updateQty(item, -1),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              "${item.quantity}",
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: AppColors.primary,
              ),
            ),
          ),
          SizedBox(
            width: 30,
            height: 30,
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.add_rounded, size: 15, color: AppColors.priceGreen),
              onPressed: () => _updateQty(item, 1),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBottomAction(List<Cart> items, double total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "TOTAL ESTIMÉ",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textMuted,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "${total.toStringAsFixed(0)} FCFA",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.greenLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
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
                      "${items.length} article${items.length > 1 ? 's' : ''}",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.greenDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),


          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                final String msg = _generateChatMessage(items, total);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatPage(
                      initialMessage: msg,
                      conversation: Conversation(
                        idConversation: widget.idQuincaillerie,
                        nameReceiver: widget.storeName,
                        lastMessage: "Demande de panier...",
                        updateAt: DateTime.now(),
                      ),
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 18),
              label: const Text(
                "NÉGOCIER PAR CHAT",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }


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
          "Votre panier est vide",
          style: TextStyle(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Ajoutez des articles depuis le magasin",
          style: TextStyle(color: Colors.grey[400], fontSize: 13),
        ),
      ],
    ),
  );


  Future<void> _updateQty(Cart item, int delta) async {
    if (item.quantity + delta <= 0) {
      _confirmDeleteItem(item);
    } else {
      item.quantity += delta;
      await _panierHive.addToCart(item);
      if (delta > 0) {
        await _panierService.addQuantityToPanier(item.idPrice);
      } else {
        await _panierService.removeQuantityToPanier(item.idPrice);
      }
    }
  }

  void _confirmDeleteItem(Cart item) async {
    final bool? res = await _showConfirm(
      "Supprimer l'article ?",
      "Voulez-vous retirer ${item.productName} du panier ?",
    );
    if (res == true) {
      await _panierHive.removeItem(item.idPrice);
      await _panierService.deleteProductToPanier(item.idPrice);
    }
  }

  void _confirmClearStoreCart() async {
    final bool? res = await _showConfirm(
      "Vider le panier ?",
      "Supprimer TOUS les articles de ${widget.storeName} ?",
    );
    if (res == true) {
      final box = Hive.box(_boxName);
      final keys = box.keys
          .where((k) => box.get(k)['idQuincaillerie'] == widget.idQuincaillerie)
          .toList();
      for (var k in keys) await box.delete(k);
    }
  }

  Future<bool?> _showConfirm(String title, String content) => showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary),
      ),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text("ANNULER", style: TextStyle(color: AppColors.textMuted)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text(
            "SUPPRIMER",
            style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}