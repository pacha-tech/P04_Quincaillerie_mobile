import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:p04_mobile/modele/ProductSuggestion.dart';
import 'package:p04_mobile/modele/QuincaillerieDetail.dart';
import '../modele/Product.dart';

class ApiService {
  // Utiliser 10.0.2.2 pour l'émulateur Android Studio
  static const String baseUrl = 'https://p04-quincaillerie.onrender.com/quincaillerie';  //URL pour le serveur render
  //static const String baseUrl = 'http://192.168.0.108:9010/quincaillerie'; //pour le telephone reel
  //static const String baseUrl = 'http://10.0.2.2:9010/quincaillerie'; //pour le telephone virtuel


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
      print("Details de l'erreur lors de la recherche: $e");
      throw Exception('Erreur de connexion au serveur');
    }
  }
  
  Future<QuincaillerieDetail?> getDetailQuincaillerie(String idQuincaillerie) async {
    try {
      final url = Uri.parse('$baseUrl/quincaillerie/details?idQuincaillerie=${Uri.encodeComponent(idQuincaillerie)}');
      final response = await http.get(url);

      if(response.statusCode == 200){
        final body = jsonDecode(response.body);
        return QuincaillerieDetail.fromJson(body);
      }
      return null;
    }catch (e) {
      print("Details de l'erreur lors des details quincaillerie: $e");
      throw Exception('Erreur de connexion au serveur');
    }
  }

  Future<List<ProductSuggestion>> getSearchSuggestions(String query) async {

    if (query.length < 2) return [];

    try{
      final url = Uri.parse('$baseUrl/products/suggestions?query=${Uri.encodeComponent(query)}');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        return body.map((item) => ProductSuggestion.fromJson(item)).toList();
      } else {
        return [];
      }
    }catch (e) {
      print("Details de l'erreur lors de la recuperation des suggestions: $e");
      throw Exception('Erreur de connexion au serveur');
    }

  }

}