class Cart {
  final String idPrice;
  final String idQuincaillerie;
  final String productName;
  final String storeName;
  final double price;
  int quantity;

  Cart({
    required this.idPrice,
    required this.idQuincaillerie,
    required this.productName,
    required this.storeName,
    required this.price,
    required this.quantity,
  });


  Map<String, dynamic> toMap() {
    return {
      'idPrice': idPrice,
      'idQuincaillerie': idQuincaillerie,
      'productName': productName,
      'storeName': storeName,
      'price': price,
      'quantity': quantity,
    };
  }


  factory Cart.fromMap(Map<dynamic, dynamic> map) {
    return Cart(
      idPrice: map['idPrice'],
      idQuincaillerie: map['idQuincaillerie'],
      productName: map['productName'],
      storeName: map['storeName'],
      price: map['price'],
      quantity: map['quantity'],
    );
  }

  factory Cart.fromJson(Map<String , dynamic> json) {
    return Cart(
      idPrice: json['idPrice'],
      idQuincaillerie: json['idQuincaillerie'],
      productName: json['productName'],
      storeName: json['storeName'],
      price: json['price'],
      quantity: json['quantity'],
    );
  }
}