
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;

  factory DioClient() => _instance;

  DioClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: 'http://192.168.1.177:9010/quincaillerie',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final token = await user.getIdToken();
          options.headers["Authorization"] = "Bearer $token";
        }
        options.headers["Content-Type"] = "application/json";
        return handler.next(options);
      },
      onError: (e, handler) {
        print("🚨 Erreur API [${e.response?.statusCode}]: ${e.message}");


        return handler.next(e);
      },
    ));
  }
}