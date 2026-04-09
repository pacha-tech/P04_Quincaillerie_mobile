
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/modele/Cart.dart';

class PanierHiveService {
  static const String _boxName = 'productBox';


  static Future<void> init() async {

    await Hive.initFlutter();
    await Hive.openBox(_boxName);
    await Hive.openBox("userBox");
  }

  /// Récupère un item spécifique du panier Hive par son idPrice
  Cart? getItem(String idPrice) {
    var box = Hive.box(_boxName);
    var data = box.get(idPrice);
    if (data != null) {
      return Cart.fromMap(Map<dynamic, dynamic>.from(data));
    }
    return null;
  }

  /// Ajoute ou met à jour un produit dans le panier Hive
  Future<void> addToCart(Cart item) async {
    var box = Hive.box(_boxName);

    await box.put(item.idPrice, item.toMap());
  }

  /// Met à jour uniquement la quantité d'un produit existant
  Future<void> updateQuantity(String idPrice, int newQuantity) async {
    var box = Hive.box(_boxName);
    var data = box.get(idPrice);
    if (data != null) {
      var item = Cart.fromMap(Map<dynamic, dynamic>.from(data));
      item.quantity = newQuantity;
      await box.put(idPrice, item.toMap());
    }
  }

  List<Cart> getCartItems() {
    var box = Hive.box(_boxName);
    return box.values.map((item) => Cart.fromMap(Map<dynamic, dynamic>.from(item))).toList();
  }

  Future<void> removeItem(String idPrice) async {
    var box = Hive.box(_boxName);
    await box.delete(idPrice);
  }

  double getTotal() {
    var items = getCartItems();
    return items.fold(0, (sum, item) {

      double effectivePrice = (item.inPromotion && item.pricePromo != null)
          ? item.pricePromo!
          : item.price;
      return sum + (effectivePrice * item.quantity);
    });
  }

  Future<void> clearCart() async {
    var box = Hive.box(_boxName);
    await box.clear();
  }
}