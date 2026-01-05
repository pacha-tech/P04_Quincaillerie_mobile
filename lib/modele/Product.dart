
import 'Price.dart';

class Product {
  final String name;
  final String description;
  final List<Price> prices;

  Product({required this.name, required this.description, required this.prices});

  factory Product.fromJson(Map<String, dynamic> json) {
    var list = json['priceSearchProductsDTO'] as List;
    List<Price> priceList = list.map((i) => Price.fromJson(i)).toList();

    return Product(
      name: json['name'],
      description: json['description'],
      prices: priceList,
    );
  }
}