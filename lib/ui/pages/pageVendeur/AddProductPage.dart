import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:brixel/Exception/AppException.dart';
import 'package:brixel/Exception/NoInternetConnectionException.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import '../../../Exception/ProductAlreadyExistsException.dart';
import '../../../data/modele/Category.dart';
import '../../../data/dto/product/AddProductDTO.dart';
import '../../../provider/UserProvider.dart';
import '../../../provider/SuggestionProvider.dart';
import '../../../service/ProductService.dart';
import '../../../service/CategoryService.dart';
import 'package:image_picker/image_picker.dart';

import '../../widgets/MainNavigation.dart';
import 'UpdateStockPage.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  bool _isLoading = false;

  // Contrôleurs
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _descController = TextEditingController();
  final _buyPriceController = TextEditingController();
  final _sellPriceController = TextEditingController();
  final _stockController = TextEditingController();

  Category? _selectedCategory;
  String _selectedUnit = 'Unité';
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  late ColorScheme colorScheme;

  List<Category?> _categories = [];

  final List<String> _units = ['Unité', 'Sac', 'Kilo', 'Mètre', 'Litre', 'Paquet', 'Tonne', 'Bar'];

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getAllCategory();
      if (mounted) {
        setState(() => _categories = categories);
      }
    } catch (e) {
      print("Erreur chargement catégories : $e");
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _brandController.dispose();
    _descController.dispose();
    _buyPriceController.dispose();
    _sellPriceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_isLoading) return;
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();



    // Vérification prix
    final buyPrice = double.tryParse(_buyPriceController.text.trim()) ?? 0;
    final sellPrice = double.tryParse(_sellPriceController.text.trim()) ?? 0;

    if (sellPrice < buyPrice) {
      final confirmed = await AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        animType: AnimType.scale,
        title: "Prix de vente inférieur",
        desc: "Le prix de vente est inférieur au prix d'achat.\nConfirmer quand même ?",
        btnOkText: "Confirmer",
        btnOkColor: Colors.green,
        //btnOkOnPress: () => Navigator.pop(context, true),
        btnOkOnPress: (){},
        btnCancelText: "Annuler",
        btnCancelOnPress: () => Navigator.pop(context, false),
      ).show() ?? false;

      if (!confirmed) return;
    }

    setState(() => _isLoading = true);

    final dto = AddProductDTO(
      name: name,
      imageUrl: "",
      brand: _brandController.text.trim(),
      categoryId: _selectedCategory?.id ?? "",
      purchasePrice: _buyPriceController.text.trim(),
      sellingPrice: _sellPriceController.text.trim(),
      quantite: int.tryParse(_stockController.text.trim()) ?? 0,
      unite: _selectedUnit,
      descriptionProduit: _descController.text.trim(),
    );

    try {

      await _productService.addProduct(dto);

      if (!mounted) return;

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: "Succès !",
        desc: "Produit $name ajouté avec succès",
        btnOkText: "OK",
        btnOkColor: Colors.green,
        btnOkOnPress: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigation()),
                (route) => false,
          );
        },
      ).show();
    } on ProductAlreadyExistsException catch (e) {
      if (!mounted) return;

      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        title: "Produit déjà existant",
        desc: e.message,
        btnOkText: "Modifier le nom",
        btnOkColor: colorScheme.surface,
        btnOkOnPress: () {

        },
        btnCancelText: "Mettre à jour le stock",
        btnCancelColor: colorScheme.secondary,
        btnCancelOnPress: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UpdateStockPage(),
            ),
          );

        },
      ).show();

    } on NoInternetConnectionException catch (e) {

      if(!mounted) return;

      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: "Pas de connexion",
        desc: e.message,
        btnOkText: "OK",
        btnOkColor: colorScheme.error,
        btnOkOnPress: (){

        },
      ).show();

    } on AppException catch (e) {
      if(!mounted) return;

      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: "Erreur",
        desc: e.message,
        btnOkText: "OK",
        btnOkColor: Colors.red,
      ).show();

    } catch (e) {
      if (!mounted) return;

      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: "Erreur inattendue",
        desc: "Quelque chose s'est mal passé. Réessayez.",
        btnOkText: "OK",
        btnOkColor: Colors.red,
      ).show();

    }  finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(title: const Text("Créer un Nouveau Produit")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle("INFORMATIONS GÉNÉRALES"),
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 110,
                    width: 110,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
                    ),
                    child: _imageFile != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(_imageFile!, fit: BoxFit.cover),
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_rounded,
                            color: colorScheme.primary, size: 30),
                        const Text("PHOTO",
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _buildField(_nameController, "Nom du produit", Icons.shopping_bag_outlined),
              const SizedBox(height: 15),
              _buildField(_brandController, "Marque / Fabricant", Icons.branding_watermark_outlined),
              const SizedBox(height: 15),

              DropdownButtonFormField<Category?>(
                value: _selectedCategory,
                isExpanded: true,
                decoration: _inputDecoration("Catégorie", Icons.category_outlined),
                items: _categories.map((c) => DropdownMenuItem<Category?>(
                  value: c,
                  child: Text(c?.name ?? 'Inconnu'),
                )).toList(),
                onChanged: _isLoading ? null : (v) => setState(() => _selectedCategory = v),
                validator: (v) => v == null ? "Obligatoire" : null,
              ),

              const SizedBox(height: 15),
              _buildField(_descController, "Description", Icons.description_outlined, maxLines: 2),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Divider(),
              ),

              _buildSectionTitle("INVENTAIRE & PRIX"),

              Row(
                children: [
                  Expanded(
                    child: _buildField(_buyPriceController, "Prix d'achat", Icons.monetization_on_outlined, isNumber: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(_sellPriceController, "Prix de vente", Icons.sell_outlined, isNumber: true),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildField(_stockController, "Quantité", Icons.inventory_2_outlined, isNumber: true),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      isExpanded: true,
                      decoration: _inputDecoration("Unité", Icons.straighten_rounded),
                      items: _units.map((u) => DropdownMenuItem(value: u, child: Text(u))).toList(),
                      onChanged: (v) => setState(() => _selectedUnit = v!),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                    "CRÉER ET AJOUTER AU STOCK",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 12,
          color: Colors.blueGrey,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
    );
  }

  Widget _buildField(
      TextEditingController controller,
      String label,
      IconData icon, {
        int maxLines = 1,
        bool isNumber = false,
      }) {
    return TextFormField(
      controller: controller,
      enabled: !_isLoading,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: _inputDecoration(label, icon),
      validator: (v) => v!.isEmpty ? "Obligatoire" : null,
    );
  }
}