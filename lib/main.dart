import 'package:flutter/material.dart';
import 'package:p04_mobile/widgets/MainNavigation.dart';

void main() {
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
      home: MainNavigation(),
      debugShowCheckedModeBanner: false,
    );
  }
}
