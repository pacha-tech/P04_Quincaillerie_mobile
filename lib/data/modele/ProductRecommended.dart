
class ProductRecommended {
  final String idPrice;
  final String name;
  final double price;
  final String description;
  final int stock;
  final int score;
  final String unite;
  final double pricePromo;
  final bool inPromo;
  final String imageUrl;
  final String taux;

  ProductRecommended({required this.idPrice , required this.name , required this.price , required this.description , required this.stock , required this.score , required this.unite , required this.pricePromo , required this.inPromo , required this.imageUrl , required this.taux});


  factory ProductRecommended.fromJson(Map<String , dynamic> json){
    return ProductRecommended (
      idPrice: json['idPrice'],
      name: json['name'],
      price: json['price'],
      description: json['description'],
      stock: json['stock'],
      score: json['score'],
      unite: json['unite']!,
      pricePromo: json['pricePromo'],
      inPromo: json['inPromo'],
      imageUrl: json['imageUrl'],
      taux: json['taux'],
    );
  }
}