import 'package:firebase_auth/firebase_auth.dart';
import 'ApiService.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  ApiService _apiService = ApiService();

  Future<UserCredential?> registeToFirebase(String email, String password) async{
    return await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  // INSCRIPTION
  Future<void> registerCustomer(String email, String password, String name, String phone , String role) async {
    // 1. Création sur Firebase
    UserCredential? result = await registeToFirebase(email, password);
    String uid = result?.user?.uid ?? "";

    print("UID de l'user : $uid ");
    // 2. Envoi vers Spring Boot / MySQL
    print("AVANT L'APPEL D'API DU BACKEND");
    await _apiService.RegisterCustomer(name, uid, email, phone, role , "");
    print("APRES L'API DU BANKEND");

    }

  // CONNEXION
  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);

  }

  Future<String?> getUserRole() async {
    final user = _auth.currentUser;
    if (user == null) return "GUEST";

    final idTokenResult = await user.getIdTokenResult(true);

    return idTokenResult.claims?['role'] as String?;
  }

  Future<void> registerQuincaillerie(String storeName , String region , String ville , String quartier , String precision , String description , double latitude , double longitude , String phone) async {
    String? uid = _auth.currentUser?.uid;

    if(uid != null ){
      await _apiService.registerQuincaillerie(uid, storeName, region, ville, quartier, precision, "", description, latitude, longitude, phone);
    }
  }

  Future<void> registerSeller(String password , String name , String email, String phone, String role , String imageUserUrl , String storeName , String region , String ville , String quartier , String precision , String photoStoreUrl , String description , double latitude , double longitude)async{
    UserCredential? result = await registeToFirebase(email, password);
    String uid = result?.user?.uid ?? "";

    await _apiService.registerSeller(name, uid , email, phone, role , imageUserUrl , storeName , region , ville , quartier , precision , photoStoreUrl , description , latitude , longitude);
    }
}

