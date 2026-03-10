
class AddProductDTO {
  final String name;
  final String imageUrl;
  final String brand;
  final String categoryId;
  final String purchasePrice;
  final String sellingPrice;
  final int quantite;
  final String unite;
  //final String quincaillerieId;
  final String descriptionProduit;

  AddProductDTO({required this.name , required this.imageUrl , required this.brand , required this.categoryId , required this.purchasePrice , required this.sellingPrice , required this.quantite , required this.unite , required this.descriptionProduit});

  Map<String , dynamic> toJson() => {
    "name": name,
    "imageUrl": imageUrl,
    "brand": brand,
    "categoryId": categoryId,
    "purchasePrice": purchasePrice,
    "sellingPrice": sellingPrice,
    "stock": quantite,
    "unite": unite,
    //"quincaillerieId": quincaillerieId,
    "description": descriptionProduit
  };
}