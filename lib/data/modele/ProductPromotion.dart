
class ProductPromotion {
  final String id;
  final String nom;
  final String category;
  final String imageUrl;
  final double price;

  ProductPromotion({required this.id , required this.nom , required this.category , required this.imageUrl , required this.price});

  factory ProductPromotion.fromJson(Map<String , dynamic> json ){
    return ProductPromotion(
        id: json["id"],
        nom: json["nom"],
        category: json["category"],
        imageUrl: json["imageUrl"],
        price: json["price"]
    );
  }
}