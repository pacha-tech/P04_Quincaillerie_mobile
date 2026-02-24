
import 'Price.dart';

class ProductSearch {
  final String idProduct;
  final String idCategory;
  final String name;
  final String? description;
  final List<Price> prices;

  ProductSearch({required this.idProduct , required this.idCategory , required this.name, required this.description, required this.prices});

  factory ProductSearch.fromJson(Map<String, dynamic> json) {
    var list = json['priceSearchProductsDTO'] as List;
    List<Price> priceList = list.map((i) => Price.fromJson(i)).toList();

    return ProductSearch(
      idProduct: json['idProduct'],
      idCategory: json['idCategory'],
      name: json['name'],
      description: json['description'],
      prices: priceList,
    );
  }
  
}