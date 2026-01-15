import 'dart:convert';
import 'package:http/http.dart' as http;
import '../modele/Product.dart';

class ApiService {
  // Utiliser 10.0.2.2 pour l'émulateur Android Studio
  static const String baseUrl = 'http://192.168.0.108:9010/quincaillerie';

  Future<List<Product>> searchProducts(String query) async {
    try {
      final url = Uri.parse('$baseUrl/products/search?name=${Uri.encodeComponent(query)}');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => Product.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Erreur de connexion au serveur');
    }
  }
}