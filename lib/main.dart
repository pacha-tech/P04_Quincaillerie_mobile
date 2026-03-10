import 'package:brixel/provider/SuggestionProvider.dart';
import 'package:brixel/ui/theme/AppTheme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'provider/UserProvider.dart';
import 'ui/widgets/MainNavigation.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    debugPrint("Firebase initialisé avec succès");
  } catch (e) {
    debugPrint("Erreur Firebase init: $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => UserProvider(),
        ),
        ChangeNotifierProvider(
            create: (context) => SuggestionProvider()
        )
      ],
      child: MaterialApp(
        title: 'Nom De l’App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainNavigation(),
      ),
    );
  }
}