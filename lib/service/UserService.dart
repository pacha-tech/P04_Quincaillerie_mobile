import 'package:brixel/data/dto/user/RegisterCustomerDTO.dart';
import 'package:brixel/data/dto/user/RegisterSellerDTO.dart';
import 'package:brixel/service/DioClient.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/modele/UserInfos.dart';
import 'ApiService.dart';

class UserService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  ApiService _apiService = ApiService();

  final _dio = DioClient().dio;


  Future<UserCredential?> registeToFirebase(String email, String password) async{
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }


  // CONNEXION
  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);

  }

  Future<void> registerCustomer(RegisterCustomerDTO registerCustomerDTO ) async {
    await _dio.post('/auth/registerCustomer' , data: registerCustomerDTO.toJson());
  }




  Future<void> registerSeller(RegisterSellerDTO registerSellerDTO)async{
    print("json: ${registerSellerDTO.toJson()}");

    await _dio.post('/auth/registerSeller' , data: registerSellerDTO.toJson());
  }

  Future<UserInfos?> getUserInfo() async {
      final response = await _dio.get('/users/profile');
      return UserInfos.fromJson(response.data);
  }
}

