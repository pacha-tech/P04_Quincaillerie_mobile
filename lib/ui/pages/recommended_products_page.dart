import 'package:flutter/material.dart';

class RecommendedProductsPage extends StatelessWidget {
  const RecommendedProductsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produits recommandés pour vous'),
      ),
      body: const Center(
        child: Text(
          'Liste des produits recommandés\n(à implémenter)',
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}