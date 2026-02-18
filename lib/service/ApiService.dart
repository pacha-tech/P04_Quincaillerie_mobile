import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:p04_mobile/modele/ProductSuggestion.dart';
import 'package:p04_mobile/modele/QuincaillerieDetail.dart';
import 'package:p04_mobile/modele/UserInfos.dart';
import '../modele/Product.dart';

class ApiService {
  const ApiService();
  // Utiliser 10.0.2.2 pour l'émulateur Android Studio
  static const String baseUrl = 'https://p04-quincaillerie.onrender.com/quincaillerie';  //URL pour le serveur render
  static const String baseUrlPhone = 'http://192.168.0.109:9010/quincaillerie'; //pour le telephone reel
  //static const String baseUrl = 'http://10.0.2.2:9010/quincaillerie'; //pour le telephone virtuel
  //static const String baseUrlLocal = 'http://localhost:9010/quincaillerie'; //pour le serveur local


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

  Future<void> RegisterUser(String name,String uid , String email, String phone, String role , String imageUrl) async {
    try {
      final url = Uri.parse('$baseUrlPhone/auth/registerUser');
      await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "id_user": uid,
          "name": name,
          "email": email,
          "phone": phone,
          "role": role,
          "imageUrl": imageUrl
        }),
      );
    }catch(e){
      print("Details de l'erreur lors de l'inscription: $e");
      throw Exception("Erreur lors de l'inscription");
    }
  }

  Future<UserInfos?> getUserInfo() async { // On n'a plus besoin de passer l'UID en paramètre !
    try {
      String? token = await FirebaseAuth.instance.currentUser?.getIdToken();

      final url = Uri.parse('$baseUrlPhone/users/profile');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return UserInfos.fromJson(body);
      }
      return null;
    } catch (e) {
      print("Détails de l'erreur du profil : $e");
      throw Exception('Erreur de connexion au serveur');
    }
  }

}