
class ProductSuggestion {

  final String label;
  final String type;

  ProductSuggestion({required this.label, required this.type});

  factory ProductSuggestion.fromJson(Map<String, dynamic> json) {
    return ProductSuggestion(
      label: json['label'],
      type: json['type'],
    );
  }
}