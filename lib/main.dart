
/*
import 'package:brixel/data/modele/Cart.dart';
import 'package:brixel/provider/ConversationProvider.dart';
import 'package:brixel/provider/LocationProvider.dart';
import 'package:brixel/provider/SuggestionProvider.dart';
import 'package:brixel/ui/theme/AppTheme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'service/hive/PanierHiveService.dart';
import 'provider/UserProvider.dart';
import 'ui/widgets/MainNavigation.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
    debugPrint("Firebase initialisé avec succès");
  } catch (e) {
    debugPrint("Erreur Firebase init: $e");
  }

  await PanierHiveService.init();
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
        ),
        ChangeNotifierProvider(
            create: (context) => LocationProvider()
        ),
        ChangeNotifierProvider(
            create: (context) => ConversationProvider()
        )
      ],
      child: MaterialApp(
        title: 'Brixel',
        navigatorObservers: [routeObserver],
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainNavigation(),
      ),
    );
  }
}
 */

import 'package:brixel/data/modele/Cart.dart';
import 'package:brixel/provider/ConversationProvider.dart';
import 'package:brixel/provider/LocationProvider.dart';
import 'package:brixel/provider/SuggestionProvider.dart';
import 'package:brixel/ui/theme/AppTheme.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart'; // <--- INDISPENSABLE pour kIsWeb

import 'service/hive/PanierHiveService.dart';
import 'provider/UserProvider.dart';
import 'ui/widgets/MainNavigation.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      // Configuration spécifique pour le WEB
      await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: "AIzaSyCDXZBATvtoYH3p8EZ1LTtG7hMixxxgLbg",
            authDomain: "quincaillerie-423ea.firebaseapp.com",
            projectId: "quincaillerie-423ea",
            storageBucket: "quincaillerie-423ea.firebasestorage.app",
            messagingSenderId: "45227920622",
            appId: "1:45227920622:web:f3b3d64b115119ef4bb7ff",
            measurementId: "G-T0VB30K6DD"
        ),
      );
    } else {
      // Configuration standard pour MOBILE (Android/iOS)
      await Firebase.initializeApp();
    }
    debugPrint("Firebase initialisé avec succès");
  } catch (e) {
    debugPrint("Erreur Firebase init: $e");
  }

  await PanierHiveService.init();
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
        ),
        ChangeNotifierProvider(
            create: (context) => LocationProvider()
        ),
        ChangeNotifierProvider(
            create: (context) => ConversationProvider()
        )
      ],
      child: MaterialApp(
        title: 'Brixel',
        navigatorObservers: [routeObserver],
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const MainNavigation(),
      ),
    );
  }
}