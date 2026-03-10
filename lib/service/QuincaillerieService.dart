
import 'package:brixel/data/dto/quincaillerie/RegisterQuincaillerieDTO.dart';
import 'package:brixel/service/DioClient.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      final response = await _dio.get('/quincaillerie/details', queryParameters: {'idQuincaillerie': idQuincaillerie});
      return QuincaillerieDetail.fromJson(response.data);
  }
}