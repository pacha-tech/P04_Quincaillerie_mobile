import 'package:flutter/material.dart';
import 'package:brixel/service/SuggestionService.dart';
import '../../modele/ProductSuggestion.dart';
import 'AddProductPage.dart';

class UpdateStockPage extends StatefulWidget {
  const UpdateStockPage({super.key});

  @override
  State<UpdateStockPage> createState() => _UpdateStockPageState();
}

class _UpdateStockPageState extends State<UpdateStockPage> {
  final SuggestionService _suggestionService = SuggestionService();
  final TextEditingController _searchController = TextEditingController();

  ProductSuggestion? _selectedProduct;
  List<ProductSuggestion> _allProductsCache = [];
  bool _isLoading = true;
  bool _showCreateButton = false;

  final TextEditingController _buyPriceController = TextEditingController();
  final TextEditingController _sellPriceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  String _selectedUnit = 'Unité';

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    try {
      final products = await _suggestionService.getAllSuggestions();
      setState(() {
        _allProductsCache = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text("Mise à jour du Stock")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("1. Rechercher le produit", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
            const SizedBox(height: 10),

            // --- BARRE DE RECHERCHE (AUTOCOMPLETE) ---
            Autocomplete<ProductSuggestion>(
              displayStringForOption: (option) => option.nom,
              optionsBuilder: (textValue) {
                if (textValue.text.isEmpty) {
                  setState(() => _showCreateButton = false);
                  return const Iterable.empty();
                }
                final matches = _allProductsCache.where((p) =>
                    p.nom.toLowerCase().contains(textValue.text.toLowerCase()));

                // Si aucune correspondance, on affiche le bouton de création
                Future.delayed(Duration.zero, () {
                  setState(() => _showCreateButton = matches.isEmpty);
                });

                return matches;
              },
              onSelected: (selection) {
                setState(() {
                  _selectedProduct = selection;
                  _showCreateButton = false;
                  _selectedUnit = (selection.unite != null) ? selection.unite! : 'Unité';
                });
              },
              fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                return TextFormField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: _inputDecoration("Nom du produit...", Icons.search),
                );
              },
            ),

            // --- BOUTON SI PRODUIT INEXISTANT ---
            if (_showCreateButton) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    const Text("Ce produit n'existe pas dans Brixel"),
                    TextButton.icon(
                      onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProductPage())),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text("CRÉER LE NOUVEAU PRODUIT"),
                    )
                  ],
                ),
              ),
            ],

            // --- FORMULAIRE DE MISE À JOUR (Affiché seulement si produit choisi) ---
            if (_selectedProduct != null) ...[
              const SizedBox(height: 30),
              const Divider(),
              const SizedBox(height: 20),
              const Text("2. Détails du stock", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(child: _buildTextForm(_buyPriceController, "Prix d'achat", Icons.download)),
                  const SizedBox(width: 10),
                  Expanded(child: _buildTextForm(_sellPriceController, "Prix de vente", Icons.sell)),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(flex: 2, child: _buildTextForm(_stockController, "Quantité", Icons.inventory_2)),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      isExpanded: true,
                      decoration: _inputDecoration("Unité", Icons.straighten),
                      items: ['Unité', 'Sac', 'Kilo', 'Litre', 'Mètre'].map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                      onChanged: (v) => setState(() => _selectedUnit = v!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                  onPressed: () { /* API Update */ },
                  child: const Text("VALIDER LA MISE À JOUR"),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) => InputDecoration(
    labelText: label, prefixIcon: Icon(icon, size: 20),
    filled: true, fillColor: Colors.white,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
  );

  Widget _buildTextForm(TextEditingController controller, String label, IconData icon) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: _inputDecoration(label, icon),
    );
  }
}