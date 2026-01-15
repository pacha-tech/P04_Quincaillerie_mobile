
import 'package:flutter/material.dart';
import '../modele/Product.dart';

class SearchResultsPage extends StatelessWidget {
  final List<Product> results;
  final String searchQuery;

  const SearchResultsPage({
    super.key,
    required this.results,
    required this.searchQuery
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Résultats pour "$searchQuery"'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: results.isEmpty
          ? _buildEmptyState()
          : _buildList(),
    );
  }

  Widget _buildEmptyState() {
    return const Center(child: Text("Aucun produit trouvé"));
  }

  Widget _buildList() {
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ExpansionTile(
            title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(product.description, maxLines: 1),
            children: product.prices.map((p) => ListTile(
              leading: const Icon(Icons.storefront, color: Colors.blue),
              title: Text(p.quincaillerieName),
              trailing: Text("${p.price} FCFA", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            )).toList(),
          ),
        );
      },
    );
  }
}
