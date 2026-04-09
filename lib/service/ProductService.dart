
import 'dart:convert';
import 'dart:io';

import 'package:brixel/Exception/ProductNotFoundException.dart';
import 'package:brixel/data/dto/product/AddProductDTO.dart';
import 'package:brixel/service/DioClient.dart';
import 'package:dio/dio.dart';
import 'package:http/http.dart' hide MultipartFile;
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


  Future<void> addProduct(AddProductDTO addProductDTO, File? imageFile) async {
    try {
      String jsonString = jsonEncode(addProductDTO.toJson());

      FormData formData = FormData();


      formData.files.add(MapEntry(
        "data",
        MultipartFile.fromString(
          jsonString,
          contentType: MediaType('application', 'json'),
        ),
      ));


      if (imageFile != null) {
        String fileName = imageFile.path.split('/').last;
        String extension = fileName.split('.').last.toLowerCase();

        String mimeType = 'image/jpeg';
        if (extension == 'png') mimeType = 'image/png';
        if (extension == 'gif') mimeType = 'image/gif';

        formData.files.add(MapEntry(
          "image",
          await MultipartFile.fromFile(
            imageFile.path,
            filename: fileName,
            contentType: MediaType.parse(mimeType),
          ),
        ));
      }


      await _dio.post('/products/addProduct', data: formData);

    } on DioException catch (e) {
      if (e.response == null) {
        throw NoInternetConnectionException("Vérifiez votre connexion internet");
      }

      final status = e.response!.statusCode;

      final responseData = e.response!.data;
      final message = (responseData is Map) ? (responseData['message'] ?? "Erreur inconnue") : "Erreur serveur";

      if (status == 409) {
        throw ProductAlreadyExistsException(message);
      } else if (status == 415) {
        throw AppException("Format de données non supporté (415). Vérifiez le Content-Type du JSON.");
      } else {
        throw AppException(message);
      }
    }
  }


  Future<List<ProductStock?>> getProductsByQuincaillerie() async {
    try {
      final result = await _dio.get('/products/getStock');
      print(result.data);
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

  Future<void> updateProduct(String idProduit, Map<String, dynamic> changes) async {
    try {
      FormData formData = FormData();

      final Map<String, dynamic> dataToEncode = Map.from(changes);


      File? imageFile;
      if (dataToEncode.containsKey('imageFile') && dataToEncode['imageFile'] is File) {
        imageFile = dataToEncode['imageFile'] as File;


        dataToEncode.remove('imageFile');
      }


      String jsonString = jsonEncode(dataToEncode);

      formData.files.add(MapEntry(
        "data",
        MultipartFile.fromString(
          jsonString,
          contentType: MediaType('application', 'json'),
        ),
      ));


      if (imageFile != null) {
        String fileName = imageFile.path.split('/').last;

        formData.files.add(MapEntry(
          "image",
          await MultipartFile.fromFile(
            imageFile.path,
            filename: fileName,

            contentType: MediaType('image', fileName.split('.').last == 'png' ? 'png' : 'jpeg'),
          ),
        ));
      }

      await _dio.patch('/products/$idProduit', data: formData);

    } on DioException catch (e) {
      if (e.response == null) {
        throw NoInternetConnectionException("Vérifiez votre connexion internet");
      }

      final status = e.response!.statusCode;
      final responseData = e.response!.data;
      final message = (responseData is Map) ? (responseData['message'] ?? "Erreur inconnue") : "Erreur serveur";

      if (status == 404) {
        throw AppException("Produit non trouvé (404)");
      } else if (status == 415) {
        throw AppException("Format de données non supporté (415).");
      } else if (status == 409) {
        throw ProductAlreadyExistsException(message);
      } else {
        throw AppException(message);
      }
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

      throw AppException(message);
    }
  }

  Future<List<ProductRecommended>> getRecommandationByProductAndStore(String idProduct , String idQuincaillerie) async {
    try {
      final results = await _dio.get("/products/recommendations" , queryParameters: {"idProduct":idProduct , "idQuincaillerie":idQuincaillerie});
      print("LES RECOMMANDATIONS: $results");
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