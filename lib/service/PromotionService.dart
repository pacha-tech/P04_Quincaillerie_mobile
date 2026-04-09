

import 'package:brixel/data/dto/promotion/AddPromotionDTO.dart';
import 'package:brixel/data/modele/ProductPromotion.dart';
import 'package:brixel/data/modele/ProductSearch.dart';
import 'package:brixel/service/DioClient.dart';
import 'package:dio/dio.dart';
import '../Exception/AppException.dart';
import '../Exception/NoInternetConnectionException.dart';
import '../Exception/ProductNotFoundException.dart';
import '../data/modele/Promotion.dart';
import '../data/modele/QuincaillerieWithProductInPromotion.dart';

class PromotionService {
  final _dio = DioClient().dio;

  Future<void> addPromotion(AddPromotionDTO addPromotion) async {
    try {
      print(addPromotion.nom);
      print(addPromotion.toJson());
      await _dio.post("/promotion/addPromotion", data: addPromotion.toJson());
    } on DioException catch (e) {
      print("type: ${e.type}");
      print("error: ${e.error}");
      print("message: ${e.message}");

      if (e.response == null) {
        throw NoInternetConnectionException("Vérifiez votre connexion internet");
      }

      final status = e.response!.statusCode;
      final message = e.response!.data['message'] ?? "Erreur inconnue";

      throw AppException("Une erreur est survenue. Réessayez plus tard.");

    }
  }

  Future<List<ProductPromotion>> getAllProductOutPromotion() async{
    try {
      final result = await _dio.get("/promotion/allProductOutPromotion");
      return (result.data as List).map((item) => ProductPromotion.fromJson(item)).toList();
    } on DioException catch(e) {
      if(e.response == null){
        throw NoInternetConnectionException("Verifier votre connexion internet");
      }

      final status = e.response!.statusCode;
      final message = e.response!.data['message'];

      if(status == 404 ){
        throw ProductNotFoundException(message);
      } else {
        throw AppException("Une erreur est survenue. Réessayez plus tard.");
      }
    }
  }

  Future<List<ProductSearch>> getAllProductInPromotion() async {
    try {

      final result = await _dio.get("/promotion/allProductInPromotion");

      return (result.data as List).map((item) => ProductSearch.fromJson(item)).toList();

    } on DioException catch (e) {
      if (e.response == null) {
        throw NoInternetConnectionException("Vérifiez votre connexion internet");
      }

      final status = e.response!.statusCode;


      final message = e.response!.data is Map ? e.response!.data['message'] : "Erreur serveur";

      if (status == 404) {
        throw ProductNotFoundException(message);
      } else if (status == 403) {
        throw AppException("Vous n'avez pas l'autorisation d'accéder à ces promotions.");
      } else {
        throw AppException("Une erreur est survenue lors de la récupération des promotions.");
      }
    } catch (e) {
      throw AppException("Erreur de traitement des données.");
    }
  }


  Future<List<Promotion>> getAllPromotion() async{
    try {
      final result = await _dio.get("/promotion/allPromotion");
      return (result.data as List).map((item) => Promotion.fromJson(item)).toList();
    } on DioException catch(e) {
      if(e.response == null){
        throw NoInternetConnectionException("Verifier votre connexion internet");
      }

      final status = e.response!.statusCode;
      final message = e.response!.data['message'];

      if(status == 404 ){
        throw ProductNotFoundException(message);
      } else {
        throw AppException("Une erreur est survenue. Réessayez plus tard.");
      }
    }
  }
}