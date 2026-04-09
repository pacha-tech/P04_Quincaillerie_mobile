

import 'package:brixel/Exception/UserNotConnectedException.dart';
import 'package:brixel/service/DioClient.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';

import '../Exception/AppException.dart';
import '../Exception/NoInternetConnectionException.dart';
import '../Exception/ProductAlreadyExistsException.dart';
import '../Exception/ProductNotFoundException.dart';
import '../data/modele/Cart.dart';

class PanierService {
  final _dio = DioClient().dio;

  Future<void> addProductToPanier(String idPrice) async{
    try{
      await _dio.get('/panier/addToPanier' , queryParameters: {'idPrice':idPrice});

    } on DioException catch (e) {
      if (e.response == null) {
        throw NoInternetConnectionException("Vérifiez votre connexion internet");
      }

      final status = e.response!.statusCode;
      final message = e.response!.data['message'] ?? "Erreur inconnue";

      if (status == 409) {
        throw ProductAlreadyExistsException(message);
      } else if(status == 401){
        throw UserNotConnectedException(message);
      } else {
        throw AppException("Une erreur est survenue. Réessayez plus tard.");
      }
    }
  }

  Future<void> deleteProductToPanier(String idPrice) async {
    try {
      await _dio.delete("/panier/product/$idPrice");
    }on DioException catch(e) {
      if(e.response == null){
        throw NoInternetConnectionException("Verifier votre connexion internet");
      }

      final status = e.response!.statusCode;
      final message = e.response!.data['message'];

      if(status == 404 ){
        throw ProductNotFoundException(message);
      }else if(status == 401){
        throw UserNotConnectedException(message);
      } else {
        throw AppException("Une erreur est survenue. Réessayez plus tard.");
      }
    }
  }

  Future<int> getquantityInPanier(String idPrice) async {
    try {
      final response = await _dio.get("/panier/product/getQuantityInPanier", queryParameters: {'idPrice': idPrice});

      if (response.statusCode == 200) {
        return int.tryParse(response.data.toString()) ?? 0;
      }
      return 0;
    } on DioException catch (e) {
      if (e.response == null) {
        throw NoInternetConnectionException("Vérifiez votre connexion internet");
      }

      final status = e.response!.statusCode;

      final message = e.response!.data['message'] ?? "Erreur inconnue";

      if (status == 404) {
        return 0;
      } else if (status == 401) {
        throw UserNotConnectedException(message);
      } else {
        throw AppException("Une erreur est survenue. Réessayez plus tard.");
      }
    } catch (e) {
      return 0;
    }
  }

  Future<void> deletePanierByQuincaillerie(String idQuincaillerie) async {
    try {
      await _dio.delete("/panier/$idQuincaillerie");
    } on DioException catch(e) {
      if(e.response == null){
        throw NoInternetConnectionException("Verifier votre connexion internet");
      }

      final status = e.response!.statusCode;
      final message = e.response!.data['message'];

      if(status == 404 ){
        throw ProductNotFoundException(message);
      }else if(status == 401){
        throw UserNotConnectedException(message);
      } else {
        throw AppException("Une erreur est survenue. Réessayez plus tard.");
      }
    }
  }

  Future<void> deleteAllPaniersByUser() async {
    try {
      await _dio.delete("/panier/all");
    } on DioException catch(e) {
      if(e.response == null){
        throw NoInternetConnectionException("Verifier votre connexion internet");
      }

      final status = e.response!.statusCode;
      final message = e.response!.data['message'];

      if(status == 404 ){
        throw ProductNotFoundException(message);
      }else if(status == 401){
        throw UserNotConnectedException(message);
      } else {
        throw AppException("Une erreur est survenue. Réessayez plus tard.");
      }
    }
  }

  Future<List<Cart>> getAllProductInPanier() async{
    try {
      final resultat = await _dio.get('/panier/getAllProductInPanier');
      print("TOUS LES PRODUITS DU OANIER $resultat");
      if (resultat.statusCode == 200) {

        return (resultat.data as List)
            .map((i) => Cart.fromJson(i))
            .toList();
      }
    } on DioException catch (e) {
      if (e.response == null) {
        throw NoInternetConnectionException("Vérifiez votre connexion internet");
      }

      final message = e.response!.data['message'];
      final status = e.response!.statusCode;

      if(status == 401){
        throw UserNotConnectedException(message);
      }

      throw AppException("Une erreur est survenue. Réessayez plus tard.");
    }
    return [];
  }

  Future<void> addQuantityToPanier(String idPrice) async{
    try {
      await _dio.get('/panier/addQuantityToPanier' , queryParameters: {'idPrice' : idPrice});

    } on DioException catch (e) {
      if (e.response == null) {
        throw NoInternetConnectionException("Vérifiez votre connexion internet");
      }

      final message = e.response!.data['message'];
      final status = e.response!.statusCode;

      if (status == 401) {
        throw UserNotConnectedException(message);
      } else if (status == 404) {
        throw ProductNotFoundException("Produit introuvable dans le panier");
      }

      throw AppException("Une erreur est survenue. Réessayez plus tard.");
    }
  }

  Future<void> removeQuantityToPanier(String idPrice) async{
    try {
      await _dio.get('/panier/removeQuantityToPanier' , queryParameters: {'idPrice' : idPrice});

    } on DioException catch (e) {
      if (e.response == null) {
        throw NoInternetConnectionException("Vérifiez votre connexion internet");
      }

      final message = e.response!.data['message'];
      final status = e.response!.statusCode;

      if (status == 401) {
        throw UserNotConnectedException(message);
      } else if (status == 404) {
        throw ProductNotFoundException("Produit introuvable dans le panier");
      }

      throw AppException("Une erreur est survenue. Réessayez plus tard.");
    }
  }
}