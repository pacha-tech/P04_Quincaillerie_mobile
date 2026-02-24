class ProductStock {
  final String id;
  final String name;
  final String brand;
  final String category;
  final int stock;
  final String unit;
  final String sellPrice;
  final String? imageUrl;

  ProductStock({
    required this.id, required this.name, required this.brand,
    required this.category, required this.stock, required this.unit,
    required this.sellPrice, this.imageUrl
  });

  factory ProductStock.fromJson(Map<String, dynamic> json) {
    return ProductStock(
      id: json['id'].toString(),
      name: json['name'],
      brand: json['brand'] ?? '',
      category: json['categoryName'] ?? '',
      stock: json['stock'] ?? 0,
      unit: json['unit'] ?? 'Unité',
      sellPrice: json['sellPrice'].toString(),
      imageUrl: json['imageUrl'],
    );
  }
}