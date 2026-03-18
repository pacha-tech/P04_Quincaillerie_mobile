import 'package:brixel/service/PanierService.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../data/modele/Cart.dart';

class CartService {
  static const String _boxName = 'productBox';
  PanierService _panierService = PanierService();


  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
    await Hive.openBox("userBox");
  }


  Future<void> addToCart(Cart item) async {

    var box = Hive.box(_boxName);


    if (box.containsKey(item.idPrice)) {
      /*
      var existingMap = box.get(item.idPrice);
      var existingItem = Cart.fromMap(existingMap);
      existingItem.quantity += item.quantity;
      await box.put(item.idPrice, existingItem.toMap());
       */
      return;
    } else {
      await box.put(item.idPrice, item.toMap());

    }
  }


  Future<void> updateQuantity(String idPrice, int newQuantity) async {
    var box = Hive.box(_boxName);
    if (box.containsKey(idPrice)) {
      var map = box.get(idPrice);
      var item = Cart.fromMap(map);
      item.quantity = newQuantity;
      await box.put(idPrice, item.toMap());
    }
  }




  List<Cart> getCartItems() {
    var box = Hive.box(_boxName);
    return box.values.map((item) => Cart.fromMap(item)).toList();
  }


  Future<void> removeItem(String idPrice) async {
    var box = Hive.box(_boxName);
    await box.delete(idPrice);
  }


  double getTotal() {
    var items = getCartItems();
    return items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }


  Future<void> clearCart() async {
    var box = Hive.box(_boxName);
    await box.clear();
  }
}