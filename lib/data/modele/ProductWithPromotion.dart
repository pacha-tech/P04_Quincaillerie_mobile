class ProductWithPromotion {
  final String idPrice;
  final String productName;
  final String idCategory;
  final double priceOriginal;
  final double pricePromo;
  final String taux;
  final int quantity;
  final String imageUrl;
  final String unite;

  ProductWithPromotion({
    required this.idPrice,
    required this.productName,
    required this.idCategory,
    required this.priceOriginal,
    required this.pricePromo,
    required this.taux,
    required this.quantity,
    required this.imageUrl,
    required this.unite,
  });

  factory ProductWithPromotion.fromMap(Map<String, dynamic> map) {
    return ProductWithPromotion(
      idPrice: map['idPrice'] ?? '',
      productName: map['productName'] ?? '',
      idCategory: map['idCategory'] ?? '',
      priceOriginal: (map['priceOriginal'] as num?)?.toDouble() ?? 0.0,
      pricePromo: (map['pricePromo'] as num?)?.toDouble() ?? 0.0,
      taux: map['taux'] ?? '0%',
      quantity: map['quantity'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      unite: map['unite'] ?? '',
    );
  }
}