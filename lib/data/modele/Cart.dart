class Cart {
  final String idPrice;
  final String idQuincaillerie;
  final String productName;
  final String storeName;
  final bool inPromotion;
  final double? pricePromo;
  final double price;
  int quantity;
  final String imageUrl;

  Cart({
    required this.idPrice,
    required this.idQuincaillerie,
    required this.productName,
    required this.storeName,
    required this.inPromotion,
    required this.pricePromo,
    required this.price,
    required this.quantity,
    required this.imageUrl,
  });


  Map<String, dynamic> toMap() {
    return {
      'idPrice': idPrice,
      'idQuincaillerie': idQuincaillerie,
      'productName': productName,
      'storeName': storeName,
      'inPromotion': inPromotion,
      'pricePromo': pricePromo,
      'price': price,
      'quantity': quantity,
      'imageUrl': imageUrl,
    };
  }


  factory Cart.fromMap(Map<dynamic, dynamic> map) {
    return Cart(
      idPrice: map['idPrice'],
      idQuincaillerie: map['idQuincaillerie'],
      productName: map['productName'],
      storeName: map['storeName'],
      inPromotion: map['inPromotion'],
      pricePromo: map['pricePromo'],
      price: map['price'],
      quantity: map['quantity'],
      imageUrl: map['imageUrl']
    );
  }

  factory Cart.fromJson(Map<String , dynamic> json) {
    return Cart(
      idPrice: json['idPrice'],
      idQuincaillerie: json['idQuincaillerie'],
      productName: json['productName'],
      storeName: json['storeName'],
      inPromotion: json['inPromotion'],
      pricePromo: json['pricePromo'],
      price: json['price'],
      quantity: json['quantity'],
      imageUrl: json['imageUrl']
    );
  }
}