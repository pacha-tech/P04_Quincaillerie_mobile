import 'package:brixel/data/modele/Cart.dart';
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