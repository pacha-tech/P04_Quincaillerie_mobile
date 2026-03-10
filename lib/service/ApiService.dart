import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:brixel/data/modele/Category.dart';
import 'package:brixel/data/modele/ProductStock.dart';
import '../data/modele/ProductSearch.dart';
import '../data/modele/ProductSuggestion.dart';
import '../data/modele/QuincaillerieDetail.dart';
import '../data/modele/UserInfos.dart';

class ApiService {
  final Dio _dio = Dio();

  // static const String baseUrl = 'https://p04-quincaillerie.onrender.com/quincaillerie';
  static const String baseUrl = 'http://192.168.0.109:9010/quincaillerie';

  ApiService() {
    // Configuration de base de Dio
    _dio.options.baseUrl = baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);

    // INTERCEPTEUR : Ajoute automatiquement le token Firebase à chaque requête
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        String? token = await FirebaseAuth.instance.currentUser?.getIdToken();
        if (token != null) {
          options.headers["Authorization"] = "Bearer $token";
        }
        options.headers["Content-Type"] = "application/json";
        return handler.next(options);
      },
      onError: (DioException e, handler) {
        print("Erreur API [${e.response?.statusCode}] : ${e.message}");
        return handler.next(e);
      },
    ));
  }

  // --- RECHERCHE ET SUGGESTIONS ---

  /*
  Future<List<ProductSearch>> searchProducts(String query) async {
    try {
      final response = await _dio.get('/products/search', queryParameters: {'name': query});
      return (response.data as List).map((item) => ProductSearch.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Erreur de connexion au serveur');
    }
  }
   */

  Future<List<ProductSuggestion>> getSuggestions() async {
    try {
      final response = await _dio.get('/products/suggestions');
      return (response.data as List).map((item) => ProductSuggestion.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Erreur de connexion au serveur');
    }
  }

  // --- UTILISATEUR ET AUTHENTIFICATION ---

  /*
  Future<UserInfos?> getUserInfo() async {
    try {
      final response = await _dio.get('/users/profile');
      return UserInfos.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }
   */

  /*
  Future<void> registerCustomer(String email, String password, String name, String phone, String role, String imageUrl) async {
    try {
      await _dio.post('/auth/registerCustomer', data: {
        "email": email,
        "password": password,
        "name": name,
        "phone": phone,
        "role": role,
        "imageUrl": imageUrl
      });
    } catch (e) {
      throw Exception("Erreur lors de l'inscription");
    }
  }
   */


  // --- QUINCAILLERIE ET VENDEUR ---

  /*
  Future<QuincaillerieDetail?> getDetailQuincaillerie(String idQuincaillerie) async {
    try {
      final response = await _dio.get('/quincaillerie/details', queryParameters: {'idQuincaillerie': idQuincaillerie});
      return QuincaillerieDetail.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

*/
  /*

  Future<void> registerQuincaillerie(String uid, String storeName, String region, String ville, String quartier, String precision, String photoUrl, String description, double latitude, double longitude, String phone) async {
    try {
      await _dio.post('/auth/registerUser', data: {
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
        "phone": phone
      });
    } catch (e) {
      throw Exception("Erreur lors de l'inscription");
    }
  }

   */
  /*

  Future<void> registerSeller(String name, String uid, String email, String phone, String role, String imageUserUrl, String storeName, String region, String ville, String quartier, String precision, String photoStoreUrl, String description, double latitude, double longitude) async {
    try {
      await _dio.post('/auth/registerSeller', data: {
        "user": {
          "id_user": uid, "name": name, "email": email, "phone": phone, "role": role, "imageUrl": imageUserUrl
        },
        "quincaillerie": {
          "idUser": uid, "storeName": storeName, "region": region, "ville": ville, "quartier": quartier, "precision": precision, "photoUrl": photoStoreUrl, "description": description, "latitude": latitude, "longitude": longitude, "phone": phone
        }
      });
    } catch (e) {
      throw Exception("Erreur lors de l'inscription");
    }
  }
   */

  // --- CATÉGORIES ---

  Future<List<Category?>> getAllCategory() async {
    try {
      final response = await _dio.get('/category/allCategory');
      return (response.data as List).map((item) => Category.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addCategory(String name) async {
    try {
      await _dio.post('/category/addCategory', data: {"name": name});
    } catch (e) {
      throw Exception("Erreur lors de l'ajout");
    }
  }

  // --- PRODUITS ET STOCK ---

  /*
  Future<void> addProduct(String name, String imageUrl, String brand, String categoryId, String purchasePrice, String sellingPrice, int quantite, String unite, dynamic quincaillerieId, String descriptionProduit) async {
    try {
      await _dio.post('/products/addProduct', data: {
        "name": name,
        "imageUrl": imageUrl,
        "brand": brand,
        "categoryId": categoryId,
        "purchasePrice": purchasePrice,
        "sellingPrice": sellingPrice,
        "stock": quantite,
        "unite": unite,
        "idQuincaillerie": quincaillerieId,
        "description": descriptionProduit
      });
    } catch (e) {
      throw Exception("Erreur lors de l'ajout du produit");
    }
  }

   */

  /*

  Future<List<ProductStock?>> getProductsByQuincaillerie() async {
    try {
      final response = await _dio.get('/products/getStock');
      // Avec Dio, response.data est déjà un objet JSON (Map ou List) décodé
      return (response.data as List).map((item) => ProductStock.fromJson(item)).toList();
    } catch (e) {
      print("Erreur lors de la récupération du stock: $e");
      throw Exception("Exception lors de la récupération du stock");
    }
  }

   */
}