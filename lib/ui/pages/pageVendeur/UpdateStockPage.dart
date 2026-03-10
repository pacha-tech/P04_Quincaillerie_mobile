import 'package:brixel/data/modele/ProductStock.dart';
import 'package:brixel/service/ProductService.dart';
import 'package:flutter/material.dart';

class UpdateStockPage extends StatefulWidget {
  const UpdateStockPage({super.key});

  @override
  State<UpdateStockPage> createState() => _StockPageState();
}

class _StockPageState extends State<UpdateStockPage> {
  final ProductService _productService = ProductService();
  late ColorScheme colorScheme;

  // Contrôleur pour la barre de recherche
  final TextEditingController _searchController = TextEditingController();

  // Liste complète des produits (chargée une fois)
  List<ProductStock?> _allProducts = [];

  // Liste filtrée (mise à jour quand on tape)
  List<ProductStock?> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();

    // Listener sur la recherche (en temps réel)
    _searchController.addListener(() {
      _filterProducts(_searchController.text);
    });
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _productService.getProductsByQuincaillerie();
      setState(() {
        _allProducts = products ?? [];
        _filteredProducts = _allProducts; // Au départ tout est affiché
      });
    } catch (e) {
      // Géré dans le FutureBuilder
    }
  }

  // Filtre les produits selon le texte tapé (insensible à la casse)
  void _filterProducts(String query) {
    if (query.isEmpty) {
      setState(() => _filteredProducts = _allProducts);
      return;
    }

    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((p) {
        return p != null &&
            (p!.name.toLowerCase().contains(lowerQuery) ||
                p!.brand.toLowerCase().contains(lowerQuery) ||
                p!.category.toLowerCase().contains(lowerQuery));
      }).toList();
    });
  }

  // Ouvre la popup de modification avec champs pré-remplis
  void _showUpdatePopup(ProductStock product) {
    // Contrôleurs pour la popup (pré-remplis)
    final nameCtrl = TextEditingController(text: product.name);
    final brandCtrl = TextEditingController(text: product.brand);
    final descCtrl = TextEditingController(text: product.descriptionProduit ?? '');
    final buyPriceCtrl = TextEditingController(text: product.purchasePrice.toString());
    final sellPriceCtrl = TextEditingController(text: product.sellPrice.toString());
    final stockCtrl = TextEditingController(text: product.stock.toString());
    String selectedUnit = product.unit ?? 'Unité';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Modifier le produit"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: "Nom du produit"),
                ),
                TextField(
                  controller: brandCtrl,
                  decoration: const InputDecoration(labelText: "Marque"),
                ),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(labelText: "Description"),
                  maxLines: 3,
                ),
                TextField(
                  controller: buyPriceCtrl,
                  decoration: const InputDecoration(labelText: "Prix d'achat (FCFA)"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: sellPriceCtrl,
                  decoration: const InputDecoration(labelText: "Prix de vente (FCFA)"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: stockCtrl,
                  decoration: const InputDecoration(labelText: "Quantité en stock"),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  value: selectedUnit,
                  items: ['Unité', 'Sac', 'Kilo', 'Mètre', 'Litre', 'Paquet', 'Tonne', 'Bar']
                      .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                      .toList(),
                  onChanged: (value) => selectedUnit = value!,
                  decoration: const InputDecoration(labelText: "Unité"),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                // Logique de mise à jour (à implémenter dans ton service)
                // Exemple :
                // await _productService.updateProduct(product.id, {
                //   'name': nameCtrl.text,
                //   'brand': brandCtrl.text,
                //   'descriptionProduit': descCtrl.text,
                //   'purchasePrice': buyPriceCtrl.text,
                //   'sellingPrice': sellPriceCtrl.text,
                //   'stock': stockCtrl.text,
                //   'unit': selectedUnit,
                // });

                Navigator.pop(context); // Ferme popup
                setState(() {}); // Rafraîchit la liste
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Produit mis à jour !")),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.primary),
              child: const Text("Modifier"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text("Mon Stock", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadProducts, // Recharge les produits
          )
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche en haut
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Rechercher un produit...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),

          // Résumé stock
          _buildStockSummary(_filteredProducts.length, colorScheme),

          // Liste des produits filtrés
          Expanded(
            child: FutureBuilder<List<ProductStock?>>(
              future: _productService.getProductsByQuincaillerie(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _buildErrorState(snapshot.error.toString());
                }

                // On utilise la liste filtrée
                final products = _filteredProducts;

                if (products.isEmpty) {
                  return _buildEmptyState(colorScheme);
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index]!;
                    return GestureDetector(
                      onTap: () => _showUpdatePopup(product), // Clic ouvre la popup
                      child: _buildProductCard(product, colorScheme),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- UI COMPONENTS (inchangés sauf le GestureDetector ajouté) ---

  Widget _buildStockSummary(int count, ColorScheme color) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.primary, color.secondary],
          begin: Alignment.bottomLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: color.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Total Produits", style: TextStyle(color: Colors.white70, fontSize: 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text("$count", style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductStock product, ColorScheme color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 4))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 65, height: 65,
              decoration: BoxDecoration(
                color: color.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: (product.imageUrl != null && product.imageUrl!.isNotEmpty)
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(product.imageUrl!, fit: BoxFit.cover),
              )
                  : Icon(Icons.inventory_2_outlined, color: color.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text("${product.brand} • ${product.category}", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${product.stock} ${product.unit}",
                      style: TextStyle(color: color.primary, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "${product.sellPrice} FCFA",
                  style: TextStyle(color: color.primary, fontWeight: FontWeight.w900, fontSize: 15),
                ),
                const Text("Prix Vente", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 80, color: color.primary.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text("Aucun produit en stock", style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
            const SizedBox(height: 16),
            Text("Erreur : $error", textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent)),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}