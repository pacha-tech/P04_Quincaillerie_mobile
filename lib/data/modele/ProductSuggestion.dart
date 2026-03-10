class ProductSuggestion {
  final String id;
  final String nom;
  final String? categorieId;
  final String? categoryName;
  final String? descriptionProduit;
  final String? descriptionCategorie;
  final String? brand;
  final String unite;

  ProductSuggestion({
    required this.id,
    required this.nom,
    required this.categorieId,
    required this.categoryName,
    required this.descriptionProduit,
    required this.descriptionCategorie,
    required this.brand,
    required this.unite
  });

  factory ProductSuggestion.fromJson(Map<String, dynamic> json) {
    return ProductSuggestion(
      id: json['id'].toString(),
      nom: json['nom'] ?? '',
      categorieId: json['categorieId'],
      categoryName: json['categoryName'],
      descriptionProduit: json['descriptionProduit'],
      descriptionCategorie: json['descriptionCategorie'],
      brand: json['brand'],
        unite: json['unite']
    );
  }
}