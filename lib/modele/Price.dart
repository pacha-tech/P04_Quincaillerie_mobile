
import 'package:decimal/decimal.dart';

class Price {
  final double price;
  final String stock;
  final String? promotion;
  final String quincaillerieName;

  Price({required this.price, required this.stock, this.promotion, required this.quincaillerieName});

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      price: json['price'],
      stock: json['stock'],
      promotion: json['promotionRating'],
      quincaillerieName: json['quincaillerieName'],
    );
  }

}
