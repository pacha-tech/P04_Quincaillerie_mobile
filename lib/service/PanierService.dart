

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

  Future<bool?> checkIfProductExistInPanierByUser(String idPrice) async {
    try{
      final response = await _dio.get("/panier/product/check" , queryParameters: {'idPrice':idPrice});

      if(response.statusCode == 200 ){
        return response.data;
      }
    }on DioException catch(e) {
      if(e.response == null ){
        throw NoInternetConnectionException("Verifier votre connection internet");
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
    return null;
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

  Future<List<Cart>> getAllProduct() async{
    try {
      final resultat = await _dio.get('/panier/getAllProductInPanier');

      if (resultat.statusCode == 200) {

        return (resultat.data as List)
            .map((i) => Cart.fromJson(i))
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
}