import 'package:firebase_auth/firebase_auth.dart';
import 'ApiService.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  ApiService apiService = ApiService();
  final String backendUrl = "http://ton-ip-serveur:8080/api/users";

  // INSCRIPTION
  Future<void> register(String email, String password, String name, String phone) async {
    // 1. Création sur Firebase
    UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    String? uid = result.user?.uid;

    print("UID de l'user : $uid ");
    // 2. Envoi vers Spring Boot / MySQL
    if (uid != null) {
      print("AVANT L'APPEL D'API DU BACKEND");
      await apiService.RegisterUser(name, uid, email, phone, "CLIENT" , "");
      print("APRES L'API DU BANKEND");
    }
  }

  // CONNEXION
  Future<void> login(String email, String password) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }
}

