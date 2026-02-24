import 'package:flutter/material.dart';
import '../modele/ProductSearch.dart';
import 'ProductDetaiByQuincaillerielPage.dart';

class SearchResultsPage extends StatefulWidget {
  final List<ProductSearch> results;
  final String searchQuery;

  const SearchResultsPage({
    super.key,
    required this.results,
    required this.searchQuery,
  });

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  // Cette variable vit dans l'état, elle peut donc changer
  String _activeFilter = "Prix croissant";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F9),
      appBar: AppBar(
        title: Row(
          children: [
            const Text('Résultats pour ', style: TextStyle(fontSize: 14, color: Colors.grey)),
            Text('"${widget.searchQuery}"', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      // On utilise widget.results car results appartient à la classe parente
      body: widget.results.isEmpty ? _buildEmptyState() : _buildList(),
    );
  }

  Widget _buildFilterBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip("Prix croissant", Icons.arrow_upward),
            const SizedBox(width: 8),
            _buildFilterChip("Prix décroissant", Icons.arrow_downward),
            const SizedBox(width: 8),
            _buildFilterChip("Plus proche", Icons.near_me_outlined),
            const SizedBox(width: 8),
            _buildFilterChip("Mieux noté", Icons.star_border),
            const SizedBox(width: 8),
            _buildFilterChip("Services", Icons.filter_list),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    // Correction de la faute de frappe _ativeFilter -> _activeFilter
    bool isActive = _activeFilter == label;

    return ActionChip(
      avatar: Icon(icon, size: 18, color: isActive ? Colors.white : Colors.grey.shade700),
      label: Text(label),
      labelStyle: TextStyle(
        color: isActive ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w500,
      ),
      backgroundColor: isActive ? Colors.blue : Colors.grey.shade200,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: isActive ? BorderSide.none : BorderSide(color: Colors.grey.shade300),
      ),
      onPressed: () {
        setState(() {
          _activeFilter = label;
        });
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text("Aucun produit trouvé pour '${widget.searchQuery}'",
              style: const TextStyle(fontSize: 16, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildList() {
    // On trie la liste en fonction du filtre sélectionné
    List<ProductSearch> sortedResults = List.from(widget.results);

    sortedResults.sort((a, b) {
      double minA = a.prices.isNotEmpty ? a.prices.map((p) => p.price.toDouble()).reduce((c, n) => c < n ? c : n) : double.infinity;
      double minB = b.prices.isNotEmpty ? b.prices.map((p) => p.price.toDouble()).reduce((c, n) => c < n ? c : n) : double.infinity;

      if (_activeFilter == "Prix croissant") {
        return minA.compareTo(minB);
      } else if (_activeFilter == "Prix décroissant") {
        return minB.compareTo(minA);
      }
      return 0;
    });

    return Column(
      children: [
        _buildFilterBar(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: sortedResults.length,
            itemBuilder: (context, index) {
              final product = sortedResults[index];
              final bool hasPrices = product.prices.isNotEmpty;

              double? minPrice = hasPrices
                  ? product.prices.map((p) => p.price.toDouble()).reduce((a, b) => a < b ? a : b)
                  : null;

              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ... (Le reste de ton code de design pour la Card reste identique)
                      // N'oublie pas d'utiliser widget.searchQuery si besoin à l'intérieur
                      _buildProductContent(product, hasPrices, minPrice),
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  // J'ai créé un petit helper pour plus de clarté
  Widget _buildProductContent(ProductSearch product, bool hasPrices, double? minPrice) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.image, color: Colors.grey),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(product.name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Icon(Icons.favorite_border, size: 22, color: Colors.redAccent),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(product.description ?? "Aucune description",
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        hasPrices ? "${minPrice!.toInt()} FCFA" : "Prix non disponible",
                        style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 15,
                          color: hasPrices ? Colors.blue[800] : Colors.red,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.blue.shade100),
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.blue.shade50.withOpacity(0.3),
                        ),
                        child: Text("${product.prices.length} magasins",
                            style: TextStyle(fontSize: 11, color: Colors.blue.shade700, fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(height: 1, thickness: 1, color: Colors.grey),
        ),
        _buildStoreList(product, hasPrices),
      ],
    );
  }

  Widget _buildStoreList(ProductSearch product, bool hasPrices) {
    if (!hasPrices) {
      return const Text("Aucune quincaillerie disponible",
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey, fontSize: 13));
    }
    return Column(
      children: product.prices.asMap().entries.map((entry) {
        int idx = entry.key;
        var p = entry.value;
        bool isLast = idx == product.prices.length - 1;

        return Container(
          decoration: BoxDecoration(
            border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey.shade300, width: 0.3)),
          ),
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuincaillerieDetailsPage(quincaillerieId: p.idQuincaillerie , product: product),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.quincaillerieName,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 4),
                        Row(
                          children: const [
                            Icon(Icons.location_on, size: 12, color: Colors.black),
                            SizedBox(width: 2),
                            Text("...Km", style: TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text("${p.price}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      const Text("FCFA", style: TextStyle(fontSize: 9, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.near_me_outlined, color: Colors.blue, size: 20),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}