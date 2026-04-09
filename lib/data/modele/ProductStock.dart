class ProductStock {
  final String id;
  final String name;
  final String brand;
  final String category;
  final int stock;
  final String unit;
  final double sellPrice;
  final String? imageUrl;
  final String descriptionProduit;
  final double purchasePrice;
  final double? pricepromo;
  final bool inPromotion;
  final double? taux;


  ProductStock({
    required this.id, required this.name, required this.brand,
    required this.category, required this.stock, required this.unit,
    required this.sellPrice, this.imageUrl , required this.descriptionProduit , required this.purchasePrice,required this.pricepromo,
    required this.inPromotion , required this.taux
  });

  factory ProductStock.fromJson(Map<String, dynamic> json) {
    return ProductStock(
      id: json['id'].toString(),
      name: json['name'],
      brand: json['brand'] ?? '',
      category: json['categoryName'] ?? '',
      stock: json['stock'] ?? 0,
      unit: json['unit'] ?? 'Unité',
      sellPrice: double.tryParse(json['sellPrice'].toString())?? 0.0,
      imageUrl: json['imageUrl'],
      descriptionProduit: json['description'] ?? '',
      purchasePrice: double.tryParse(json['purchasePrice'].toString())?? 0.0,
      pricepromo: double.tryParse(json['pricePromo'].toString()),
      inPromotion: json['inPromotion'],
      taux: double.tryParse(json['taux'].toString()),
    );
  }
}