

import 'package:brixel/data/modele/Message.dart';
import 'package:dio/dio.dart';
import '../../Exception/AppException.dart';
import '../../Exception/NoInternetConnectionException.dart';
import '../DioClient.dart';


class MessageService {
  final _dio = DioClient().dio;


  Future<List<Message>> getMessageByConversation(String idConversation) async {
    try {
      final result = await _dio.get('/message/getAllMessage' , queryParameters: {'idConversation':idConversation});
      print(result);
      return (result.data as List).map((item) => Message.fromJson(item)).toList();
    } on DioException catch (e) {
      if (e.response == null) {
        throw NoInternetConnectionException("Vérifiez votre connexion internet");
      }

      throw AppException("Une erreur est survenue. Réessayez plus tard.");
    }
  }

  Future<void> markRead(List<String> idMessages) async {
    try {
      await _dio.post(
          "/message/markRead",
          data: idMessages,
          options: Options(contentType: Headers.jsonContentType),
      );
    } on DioException catch (e) {

      if (e.response == null) {
        throw NoInternetConnectionException("Vérifiez votre connexion internet");
      }

      final status = e.response!.statusCode;
      final message = e.response!.data['message'] ?? "Erreur inconnue";

      throw AppException("Une erreur est survenue. Réessayez plus tard.");

    }
  }

}