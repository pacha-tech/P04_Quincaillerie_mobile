import 'ProductWithPromotion.dart';

class QuincaillerieWithProductInPromotion {
  final String idQuincaillerie;
  final String storeName;
  final double lat;
  final double lon;
  final List<ProductWithPromotion> products;

  QuincaillerieWithProductInPromotion({
    required this.idQuincaillerie,
    required this.storeName,
    required this.lat,
    required this.lon,
    required this.products,
  });

  factory QuincaillerieWithProductInPromotion.fromMap(Map<String, dynamic> map) {
    return QuincaillerieWithProductInPromotion(
      idQuincaillerie: map['idQuincaillerie'] ?? '',
      storeName: map['storeName'] ?? '',
      lat: (map['lat'] as num?)?.toDouble() ?? 0.0,
      lon: (map['lon'] as num?)?.toDouble() ?? 0.0,
      products: (map['productWithPromotionDTOList'] as List?)?.map((p) => ProductWithPromotion.fromMap(p)).toList() ?? [],
    );
  }
}