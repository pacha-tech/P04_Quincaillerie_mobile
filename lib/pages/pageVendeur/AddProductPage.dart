import 'dart:io';
import 'package:flutter/material.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:image_picker/image_picker.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _buyPriceController = TextEditingController();
  final TextEditingController _sellPriceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _descController = TextEditingController();

  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  bool _isExistingProduct = false; // Verrouillage si produit trouvé en BD
  String _selectedCategory = 'Outillage';

  final List<String> _categories = [
    'Outillage', 'Plomberie', 'Électricité', 'Peinture', 'Maçonnerie', 'Quincaillerie'
  ];

  // Simulation de ta base de données globale Brixel
  final List<Map<String, String>> _globalProductsDB = [
    {'name': 'Ciment CPJ45 Cimencam', 'category': 'Maçonnerie', 'desc': 'Sac de 50kg haute résistance'},
    {'name': 'Marteau Arrache-clou 500g', 'category': 'Outillage', 'desc': 'Manche en fibre de verre'},
    {'name': 'Peinture Glycéro Blanche 5L', 'category': 'Peinture', 'desc': 'Finition brillante, intérieur/extérieur'},
  ];

  void _resetForm() {
    setState(() {
      _nameController.clear();
      _buyPriceController.clear();
      _sellPriceController.clear();
      _stockController.clear();
      _descController.clear();
      _imageFile = null;
      _isExistingProduct = false;
      _selectedCategory = 'Outillage';
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text("Ajouter au Stock"),
        actions: [
          if (_isExistingProduct || _nameController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: _resetForm,
              tooltip: "Réinitialiser",
            )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- SECTION RECHERCHE / NOM ---
              _buildSectionTitle("Rechercher dans Brixel"),
              Autocomplete<Map<String, String>>(
                displayStringForOption: (option) => option['name']!,
                optionsBuilder: (textValue) {
                  if (textValue.text.isEmpty) return const Iterable.empty();
                  return _globalProductsDB.where((product) =>
                      product['name']!.toLowerCase().contains(textValue.text.toLowerCase()));
                },
                onSelected: (selection) {
                  setState(() {
                    _isExistingProduct = true;
                    _nameController.text = selection['name']!;
                    _selectedCategory = selection['category']!;
                    _descController.text = selection['desc']!;
                  });
                },
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  // Synchroniser le controller de l'Autocomplete avec le nôtre
                  if (_nameController.text != controller.text && _isExistingProduct) {
                    controller.text = _nameController.text;
                  }
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: _inputDecoration("Nom du produit", Icons.search_rounded),
                    onChanged: (val) {
                      _nameController.text = val;
                      if (_isExistingProduct) setState(() => _isExistingProduct = false);
                    },
                    validator: (v) => v!.isEmpty ? "Le nom est requis" : null,
                  );
                },
              ),

              const SizedBox(height: 25),

              // --- ZONE IMAGE (Version Ultra-Stable) ---
              Center(
                child: Opacity(
                  opacity: _isExistingProduct ? 0.6 : 1.0,
                  child: GestureDetector(
                    onTap: _isExistingProduct ? null : () => _pickImage(ImageSource.gallery),
                    child: Container(
                      height: 130,
                      width: 130,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(25),
                        // Une bordure simple mais élégante au lieu des pointillés
                        border: Border.all(
                          color: colorScheme.primary.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: _imageFile != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(23),
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      )
                          : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_a_photo_rounded,
                              color: colorScheme.primary, size: 35),
                          const SizedBox(height: 8),
                          Text("PHOTO",
                              style: TextStyle(
                                  color: colorScheme.primary,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold
                              )
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              // --- INFOS VERROUILLABLES ---
              IgnorePointer(
                ignoring: _isExistingProduct,
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedCategory,
                      decoration: _inputDecoration("Catégorie", Icons.category_outlined),
                      items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descController,
                      maxLines: 2,
                      decoration: _inputDecoration("Description technique", Icons.description_outlined),
                    ),
                  ],
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(),
              ),

              // --- PRIX ET QUANTITÉ (Toujours libres) ---
              _buildSectionTitle("Vos chiffres (Privé)"),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _buyPriceController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration("Prix d'achat", Icons.download_outlined),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _sellPriceController,
                      keyboardType: TextInputType.number,
                      decoration: _inputDecoration("Prix de vente", Icons.sell_outlined),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockController,
                keyboardType: TextInputType.number,
                decoration: _inputDecoration("Quantité en stock", Icons.inventory_2_outlined),
                validator: (v) => v!.isEmpty ? "Indiquez le stock" : null,
              ),

              const SizedBox(height: 40),

              // --- BOUTON VALIDER ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 4,
                  ),
                  child: Text(
                    _isExistingProduct ? "METTRE À JOUR MON STOCK" : "CRÉER ET AJOUTER",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(title.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.grey, letterSpacing: 1.2)),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide(color: Colors.grey.withOpacity(0.1))),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isExistingProduct ? "Stock mis à jour !" : "Nouveau produit créé !"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }
}