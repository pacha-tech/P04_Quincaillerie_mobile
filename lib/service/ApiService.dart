import 'dart:convert';
import 'package:brixel/modele/Category.dart';
import 'package:brixel/modele/ProductStock.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import '../modele/ProductSearch.dart';
import '../modele/ProductSuggestion.dart';
import '../modele/QuincaillerieDetail.dart';
import '../modele/UserInfos.dart';

class ApiService {
  const ApiService();

  //static const String baseUrl = 'https://p04-quincaillerie.onrender.com/quincaillerie'; //URL pour le serveur render
  static const String baseUrl = 'http://192.168.0.109:9010/quincaillerie';

  /// Récupère le token Firebase actuel
  Future<String?> getToken() async {
    return await FirebaseAuth.instance.currentUser?.getIdToken();
  }

  /// Génère les headers automatiquement avec ou sans Token
  Future<Map<String, String>> _getHeaders() async {
    String? token = await getToken();
    Map<String, String> headers = {
      "Content-Type": "application/json",
    };
    if (token != null) {
      headers["Authorization"] = "Bearer $token";
    }
    return headers;
  }

  // --- RECHERCHE ET SUGGESTIONS ---

  Future<List<ProductSearch>> searchProducts(String query) async {
    try {
      final url = Uri.parse('$baseUrl/products/search?name=${Uri.encodeComponent(query)}');
      final response = await http.get(url, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => ProductSearch.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("Erreur recherche: $e");
      throw Exception('Erreur de connexion au serveur');
    }
  }

  Future<List<ProductSuggestion>> getSuggestions() async {
    try {
      final url = Uri.parse('$baseUrl/products/suggestions');
      final response = await http.get(url, headers: await _getHeaders());

      if (response.statusCode == 200) {
        List<dynamic> body = json.decode(response.body);
        return body.map((item) => ProductSuggestion.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("Erreur suggestions: $e");
      throw Exception('Erreur de connexion au serveur');
    }
  }

  // --- UTILISATEUR ET AUTHENTIFICATION ---

  Future<UserInfos?> getUserInfo() async {
    try {
      final url = Uri.parse('$baseUrl/users/profile');
      final response = await http.get(url, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return UserInfos.fromJson(body);
      }
      return null;
    } catch (e) {
      print("Erreur profil : $e");
      throw Exception('Erreur de connexion au serveur');
    }
  }

  Future<void> RegisterCustomer(String name, String uid, String email, String phone, String role, String imageUrl) async {
    try {
      final url = Uri.parse('$baseUrl/auth/registerCustomer');
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({
          "id_user": uid,
          "name": name,
          "email": email,
          "phone": phone,
          "role": role,
          "imageUrl": imageUrl
        }),
      );
      if (response.statusCode != 200 && response.statusCode != 201) throw Exception("Erreur ${response.statusCode}");
    } catch (e) {
      print("Erreur inscription client: $e");
      throw Exception("Erreur lors de l'inscription");
    }
  }

  // --- QUINCAILLERIE ET VENDEUR ---

  Future<QuincaillerieDetail?> getDetailQuincaillerie(String idQuincaillerie) async {
    try {
      final url = Uri.parse('$baseUrl/quincaillerie/details?idQuincaillerie=${Uri.encodeComponent(idQuincaillerie)}');
      final response = await http.get(url, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return QuincaillerieDetail.fromJson(body);
      }
      return null;
    } catch (e) {
      print("Erreur détails quincaillerie: $e");
      throw Exception('Erreur de connexion au serveur');
    }
  }

  Future<void> registerQuincaillerie(String uid , String storeName , String region , String ville , String quartier , String precision , String photoUrl , String description , double latitude , double longitude , String phone) async {

    try{

      final url = Uri.parse('$baseUrl/auth/registerUser');

      await http.post(
        url,
        headers: await _getHeaders(),
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



  Future<void> registerSeller(String name, String uid, String email, String phone, String role, String imageUserUrl, String storeName, String region, String ville, String quartier, String precision, String photoStoreUrl, String description, double latitude, double longitude) async {
    try {
      final url = Uri.parse('$baseUrl/auth/registerSeller');
      await http.post(
          url,
          headers: await _getHeaders(),
          body: jsonEncode({
            "user": {
              "id_user": uid, "name": name, "email": email, "phone": phone, "role": role, "imageUrl": imageUserUrl
            },
            "quincaillerie": {
              "idUser": uid, "storeName": storeName, "region": region, "ville": ville, "quartier": quartier, "precision": precision, "photoUrl": photoStoreUrl, "description": description, "latitude": latitude, "longitude": longitude, "phone": phone
            }
          })
      );
    } catch (e) {
      print("Erreur enregistrement vendeur: $e");
      throw Exception("Erreur lors de l'inscription");
    }
  }

  // --- CATÉGORIES ---

  Future<List<Category?>> getAllCategory() async {
    try {
      final url = Uri.parse('$baseUrl/category/allCategory');
      final response = await http.get(url, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body.map((item) => Category.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print("Erreur catégories: $e");
      throw Exception('Erreur de connexion au serveur');
    }
  }

  Future<void> addCategory(String name) async {
    try {
      final url = Uri.parse('$baseUrl/category/addCategory');
      await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({"name": name}),
      );
    } catch (e) {
      print("Erreur enregistrement catégorie: $e");
      throw Exception("Erreur lors de l'ajout");
    }
  }


  Future<void> addProduct(String name , String imageUrl , String brand , String categoryId , String purchasePrice , String sellingPrice , int quantite , String unite , quincaillerieId , String descriptionProduit) async{
    try{
      final url = Uri.parse('$baseUrl/products/addProduct');
      await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({
          "name":name,
          "imageUrl":imageUrl,
          "brand":brand,
          "categoryId":categoryId,
          "purchasePrice":purchasePrice,
          "sellingPrice":sellingPrice,
          "stock":quantite,
          "unite":unite,
          "idQuincaillerie":quincaillerieId,
          "description":descriptionProduit
        }),
      );
    }catch(e) {
      print("Erreur lors de l'enregistrement de produit : $e");
      throw Exception("Erreur lors de l'ajout du produit");
    }
  }

  Future<List<ProductStock?>> getProductsByQuincaillerie() async {
    try{
      final url = Uri.parse('$baseUrl/products/getStock');
      final response = await http.get(url, headers: await _getHeaders());

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((item) => ProductStock.fromJson(item)).toList();
      }
      return [];
    }catch(e){
      print("Erreur lors de la recuperation du stock: $e");
      throw Exception("Exeption lors de la recuperation du stock ");
    }
  }
}