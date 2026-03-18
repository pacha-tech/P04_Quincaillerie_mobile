import 'package:brixel/data/dto/user/RegisterCustomerDTO.dart';
import 'package:brixel/data/dto/user/RegisterSellerDTO.dart';
import 'package:brixel/service/DioClient.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../Exception/AppException.dart';
import '../Exception/NoInternetConnectionException.dart';
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
    try {
      await _dio.post('/auth/registerCustomer' , data: registerCustomerDTO.toJson());
    }on DioException catch(e){
      if(e.response == null ){
        throw NoInternetConnectionException("Vérifiez votre connexion internet");
      }


      throw AppException("Une erreur est survenue.");

    }
  }

  /*
    Future<void> addProduct(AddProductDTO addProductDTO) async {
    try {
      await _dio.post('/products/addProduct', data: addProductDTO.toJson());
    } on DioException catch (e) {
      if (e.response == null) {

      }

      final status = e.response!.statusCode;
      final message = e.response!.data['message'] ?? "Erreur inconnue";

      if (status == 409) {
        throw ProductAlreadyExistsException(message);
      } else {
        throw AppException("Une erreur est survenue. Réessayez plus tard.");
      }
    }
  }
  */



  Future<void> registerSeller(RegisterSellerDTO registerSellerDTO)async{
    print("json: ${registerSellerDTO.toJson()}");
    try {
      await _dio.post('/auth/registerSeller' , data: registerSellerDTO.toJson());
    }on DioException catch(e){
      if(e.response == null ){
        throw NoInternetConnectionException("Vérifiez votre connexion internet");
      }


      throw AppException("Une erreur est survenue.");

    }
  }

  Future<UserInfos?> getUserInfo() async {
      final response = await _dio.get('/users/profile');
      return UserInfos.fromJson(response.data);
  }
}

