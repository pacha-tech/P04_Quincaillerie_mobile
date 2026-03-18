
import 'package:brixel/Exception/ProductNotFoundException.dart';
import 'package:brixel/data/dto/product/AddProductDTO.dart';
import 'package:brixel/service/DioClient.dart';
import 'package:dio/dio.dart';
import '../Exception/AppException.dart';
import '../Exception/NoInternetConnectionException.dart';
import '../Exception/ProductAlreadyExistsException.dart';
import '../data/modele/ProductRecommended.dart';
import '../data/modele/ProductSearch.dart';
import '../data/modele/ProductStock.dart';


class ProductService {
  final _dio = DioClient().dio;

  Future<List<ProductSearch>> searchProduct(String query) async {
    try {
      final resultat = await _dio.get('/products/search', queryParameters: {'name': query});

      if (resultat.statusCode == 200) {
        print("LES RESULTAT DE LA RECHERCHE DE $query EST: $resultat");
        return (resultat.data as List)
            .map((i) => ProductSearch.fromJson(i))
            .toList();
      }
    } on DioException catch (e) {
      if (e.response == null) {
        throw NoInternetConnectionException("Vérifiez votre connexion internet");
      }

      throw AppException("Une erreur est survenue. Réessayez plus tard.");
    }
    return [];
  }


  Future<void> addProduct(AddProductDTO addProductDTO) async {
    try {
      await _dio.post('/products/addProduct', data: addProductDTO.toJson());
    } on DioException catch (e) {
      if (e.response == null) {
        throw NoInternetConnectionException("Vérifiez votre connexion internet");
      }

      final status = e.response!.statusCode;
      final message = e.response!.data['message'] ?? "Erreur inconnue";

      if (status == 409) {
        throw ProductAlreadyExistsException(message);
      } else {
        throw AppException("Une erreur est survenue. Réessayez plus tard.");
      }
    }
  }

  Future<List<ProductStock?>> getProductsByQuincaillerie() async {
    try {
      final result = await _dio.get('/products/getStock');
      return (result.data as List)
          .map((item) => ProductStock.fromJson(item))
          .toList();
    } on DioException catch (e) {
      if (e.response == null) {
        throw NoInternetConnectionException("Vérifiez votre connexion internet");
      }

      throw AppException("Une erreur est survenue. Réessayez plus tard.");
    }
  }


  Future<void> updateProduct(String idProduit, Map<String, dynamic> data) async {
    try {
      await _dio.patch('/products/$idProduit', data: data);
    } on DioException catch (e) {
      if (e.response == null) {
        throw NoInternetConnectionException("Verifier votre connexion internet");
      }

      throw AppException("Erreur lors de la modification du produit");
    }
  }

  Future<void> deleteProduct(String idProduct) async{
    try{
      await _dio.delete('/products/$idProduct');
    }on DioException catch(e){
      if(e.response == null ){
        throw NoInternetConnectionException("Verifier votre connexion internet");
      }

      final status = e.response!.statusCode;
      final message = e.response!.data['message'] ?? "Erreur Inconuue";

      if(status == 404){
        throw ProductNotFoundException(message);
      }
    }
  }

  Future<List<ProductRecommended>> getRecommandationByProductAndStore(String idProduct , String idQuincaillerie) async {
    try {
      final results = await _dio.get("/products/recommendations" , queryParameters: {"idProduct":idProduct , "idQuincaillerie":idQuincaillerie});

      return (results.data as List )
          .map((item) => ProductRecommended.fromJson(item))
          .toList();
    }on DioException catch (e) {
      if (e.response == null) {
        throw NoInternetConnectionException("Vérifiez votre connexion internet");
      }

      throw AppException("Une erreur est survenue. Réessayez plus tard.");
    }
  }
}