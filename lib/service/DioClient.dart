
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;

  factory DioClient() => _instance;

  DioClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: kIsWeb ? 'http://localhost:9010/quincaillerie' : 'http://192.168.0.109:9010/quincaillerie',
      //baseUrl: 'https://p04-quincaillerie.onrender.com/quincaillerie',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      //sendTimeout: const Duration(seconds: 30),
      sendTimeout: kIsWeb ? null : Duration(seconds: 30),
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