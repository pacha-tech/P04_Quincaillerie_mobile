import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:p04_mobile/widgets/MainNavigation.dart';

void main() async {
  // 2. Indispensable pour l'initialisation asynchrone
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Connexion au SDK Firebase
  await Firebase.initializeApp();
  print("🚀 Firebase est connecté : ${Firebase.app().name}");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nom De l’App',
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        scaffoldBackgroundColor: Colors.white,
      ),
      // Tu pourras ajouter un StreamBuilder ici plus tard
      // pour rediriger vers Login() si l'user n'est pas connecté
      home: MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}
