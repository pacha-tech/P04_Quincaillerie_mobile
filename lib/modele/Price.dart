
import 'package:decimal/decimal.dart';

class Price {
  final double price;
  final String stock;
  final String? promotion;
  final String quincaillerieName;
  final String idQuincaillerie;


  Price({required this.price, required this.stock, this.promotion, required this.quincaillerieName , required this.idQuincaillerie});

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      price: json['price'],
      stock: json['stock'],
      promotion: json['promotionRating']??"",
      quincaillerieName: json['quincaillerieName'],
      idQuincaillerie: json['idQuincaillerie'],
    );
  }

}
