
import 'package:brixel/data/dto/quincaillerie/RegisterQuincaillerieDTO.dart';
import 'package:brixel/data/modele/ProductRecommended.dart';
import 'package:brixel/data/modele/ProductSuggestion.dart';
import 'package:brixel/service/DioClient.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../Exception/AppException.dart';
import '../Exception/NoInternetConnectionException.dart';
import '../data/modele/QuincaillerieDetail.dart';


class QuincaillerieService {
  final _dio = DioClient().dio;
  final FirebaseAuth _auth = FirebaseAuth.instance;


  Future<void> registerQuincaillerie(RegisterQuincaillerieDTO registerQuincaillerieDTO) async {
    String? uid = _auth.currentUser?.uid;

    if(uid != null ){
      Map<String , dynamic> data = registerQuincaillerieDTO.toJson();
      data["uid"] = uid;

      await _dio.post('/auth/registerUser', data: data);
    }
  }


  Future<QuincaillerieDetail?> getDetailQuincaillerie(String idQuincaillerie) async {
    try{
      final response = await _dio.get('/quincaillerie/details', queryParameters: {'idQuincaillerie': idQuincaillerie});

      if(response.statusCode == 200 ){
        return QuincaillerieDetail.fromJson(response.data);
      }

    } on DioException catch(e){
      if(e.response == null ) {
        throw NoInternetConnectionException("Vérifiez votre connexion internet");
      }

      throw AppException("Une erreur est survenue. Réessayez plus tard.");

    }
    return null;
  }


  /*
  Future<QuincaillerieDetail?> getDetailQuincaillerie(String idQuincaillerie) async {
    try {
      final response = await _dio.get('/quincaillerie/details', queryParameters: {'idQuincaillerie': idQuincaillerie});

      if (response.statusCode == 200) {
        if (response.data == null) {
          throw AppException("Le serveur a renvoyé une réponse vide.");
        }
        return QuincaillerieDetail.fromJson(response.data);
      }

      // Cas où le code n'est pas 200 (ex: 404, 500 etc. si non capturés par DioException)
      throw AppException("Erreur serveur (Code: ${response.statusCode})");

    } on DioException catch (e) {
      if (e.response == null) {
        throw NoInternetConnectionException("Vérifiez votre connexion internet");
      }
      // Si l'ID n'existe pas, l'API renvoie souvent un 404
      if (e.response?.statusCode == 404) {
        return null; // Ici, null signifie explicitement "Non trouvé"
      }
      throw AppException("Erreur réseau : ${e.message}");
    }
  }

   */
}