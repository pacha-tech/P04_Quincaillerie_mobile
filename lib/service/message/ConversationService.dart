

import 'package:brixel/Exception/UserNotConnectedException.dart';
import 'package:brixel/data/modele/Conversation.dart';
import 'package:brixel/service/DioClient.dart';
import 'package:dio/dio.dart';
import '../../Exception/AppException.dart';
import '../../Exception/NoInternetConnectionException.dart';

class ConversationService {
  final _dio = DioClient().dio;

  Future<List<Conversation>> getAllConversation() async {
    try {
      final result = await _dio.get('/conversation/getAllConversationByUser');

      return (result.data as List).map((item) => Conversation.fromJson(item)).toList();
    } on DioException catch (e) {
      if (e.response == null) {
        throw NoInternetConnectionException("Vérifiez votre connexion internet");
      }

      if(e.response?.statusCode == 404 ){
        throw UserNotConnectedException(e.response!.data['message']);
      }

      throw AppException("Une erreur est survenue. Réessayez plus tard.");
    }
  }
}