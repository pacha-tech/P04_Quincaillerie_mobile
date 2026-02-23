import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../modele/Product.dart';
import '../modele/ProductSuggestion.dart';
import '../modele/QuincaillerieDetail.dart';
import '../modele/UserInfos.dart';

class ApiService {
  const ApiService();
  // Utiliser 10.0.2.2 pour l'émulateur Android Studio
  //static const String baseUrl = 'https://p04-quincaillerie.onrender.com/quincaillerie';  //URL pour le serveur render
  static const String baseUrl = 'http://192.168.0.109:9010/quincaillerie'; //pour local

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

  Future<void> RegisterCustomer(String name,String uid , String email, String phone, String role , String imageUrl) async {
    try {
      final url = Uri.parse('$baseUrl/auth/registerCustomer');
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

  Future<UserInfos?> getUserInfo() async {
    try {
      String? token = await FirebaseAuth.instance.currentUser?.getIdToken();

      final url = Uri.parse('$baseUrl/users/profile');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        print(body);
        return UserInfos.fromJson(body);
      }
      return null;
    } catch (e) {
      print("Détails de l'erreur du profil : $e");
      throw Exception('Erreur de connexion au serveur');
    }
  }


  Future<void> registerQuincaillerie(String uid , String storeName , String region , String ville , String quartier , String precision , String photoUrl , String description , double latitude , double longitude , String phone) async {
    try{
      final url = Uri.parse('$baseUrl/auth/registerUser');
      await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "idUser": uid,
          "storeName": storeName,
          "region": region,
          "ville": ville,
          "quartier": quartier,
          "precision": precision,
          "photoUrl": photoUrl,
          "description": description,
          "latitude": latitude,
          "longitude": longitude,
          "phone":phone
        }),
      );
    }catch(e){
      print("Details de l'erreur lors de l'enregistrement de la quincaillerie: $e");
      throw Exception("Erreur lors de l'inscription");
    }
  }

  Future<void> registerSeller(String name,String uid , String email, String phone, String role , String imageUserUrl , String storeName , String region , String ville , String quartier , String precision , String photoStoreUrl , String description , double latitude , double longitude) async {
    try{
      final url = Uri.parse('$baseUrl/auth/registerSeller');
      await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "user": {
            "id_user": uid,
            "name": name,
            "email": email,
            "phone": phone,
            "role": role,
            "imageUrl": imageUserUrl
          },
          "quincaillerie": {
            "idUser": uid,
            "storeName": storeName,
            "region": region,
            "ville": ville,
            "quartier": quartier,
            "precision": precision,
            "photoUrl": photoStoreUrl,
            "description": description,
            "latitude": latitude,
            "longitude": longitude,
            "phone":phone
          }
        })
      );
    }catch(e){
      print("Details de l'erreur lors de l'enregistrement d'un vendeur: $e");
      throw Exception("Erreur lors de l'inscription");
    }
  }

}