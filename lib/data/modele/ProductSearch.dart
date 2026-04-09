
import 'Price.dart';

class ProductSearch {
  final String idProduct;
  final String idCategory;
  final String name;
  final String unite;
  final String? description;
  final String imageUrl;
  final List<Price> prices;


  ProductSearch({required this.idProduct , required this.idCategory , required this.name, required this.unite , required this.description, required this.imageUrl, required this.prices});

  factory ProductSearch.fromJson(Map<String, dynamic> json) {
    var list = json['priceSearchProductsDTO'] as List;
    List<Price> priceList = list.map((i) => Price.fromJson(i)).toList();

    return ProductSearch(
      idProduct: json['idProduct'],
      idCategory: json['idCategory'],
      name: json['name'],
      unite: json['unite'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      prices: priceList,
    );
  }
  
}