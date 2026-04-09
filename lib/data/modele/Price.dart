

class Price {
  final String idPrice;
  final double price;
  final int stock;
  final String? promotion;
  final String quincaillerieName;
  final String idQuincaillerie;
  final double longitudeQuincaillerie;
  final double latitudeQuincaillerie;
  final double pricePromo;
  final bool inPromotion;
  final String taux;


  Price({required this.idPrice , required this.price, required this.stock, this.promotion, required this.quincaillerieName , required this.idQuincaillerie , required this.latitudeQuincaillerie , required this.longitudeQuincaillerie , required this.pricePromo , required this.inPromotion , required this.taux});

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      idPrice: json['idPrice'],
      price: json['price'],
      stock: json['stock'],
      promotion: json['promotionRating']??"",
      quincaillerieName: json['quincaillerieName'],
      idQuincaillerie: json['idQuincaillerie'],
      latitudeQuincaillerie: json['latitudeQuincaillerie'],
      longitudeQuincaillerie: json['longitudeQuincaillerie'],
      pricePromo: json['pricePromo'],
      inPromotion: json['inPromotion'],
      taux: json['taux'],
    );
  }

}
