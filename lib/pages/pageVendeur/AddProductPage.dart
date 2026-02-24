import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:brixel/service/ApiService.dart';
import 'package:provider/provider.dart';
import '../../modele/Category.dart';
import '../../provider/UserProvider.dart';
import '../../widgets/MainNavigation.dart';

class AddProductPage extends StatefulWidget {
  const AddProductPage({super.key});

  @override
  State<AddProductPage> createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _buyPriceController = TextEditingController();
  final TextEditingController _sellPriceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  Category? _selectedCategory;
  String _selectedUnit = 'Unité';
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  final List<Category> _categories = [
    Category(id: "CAT-OUT", name: "Outillage", description: "pour les outils"),
    Category(id: "CAT-PLM", name: "Plomberie", description: "pour le plomberie"),
    Category(id: "CAT-ELE", name: "Électricité", description: "Pour l'electricite"),
    Category(id: "CAT-PEI", name: "Peinture", description: "pour le peinture"),
    Category(id: "CAT-MAC", name: "Maçonnerie", description: "pour la maconnerie"),
    Category(id: "CAT-QUI", name: "Quincaillerie", description: "pour le quincaillerie"),
  ];

  final List<String> _units = ['Unité', 'Sac', 'Kilo', 'Mètre', 'Litre', 'Paquet', 'Tonne' , 'Bar'];

  Future<void> _pickImage() async {
    if(_isLoading){
      return;
    }
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final String? qId = userProvider.quincaillerieId;

    if (qId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erreur: ID Quincaillerie introuvable")),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      print("Debut de l'appel de l'api pour enregistrer un produit");

      await _apiService.addProduct(
        _nameController.text,
        "",
        _brandController.text,
        _selectedCategory!.id,
        _buyPriceController.text,
        _sellPriceController.text,
        int.tryParse(_stockController.text) ?? 0,
        _selectedUnit,
        qId,
        _descController.text,
      );
      if (!mounted) return;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: "Produit ${_nameController.text} Ajouter avec succes au Stock",
        desc: 'Votre Stock a ete mis a jour',
        btnOkText: "Ok",
        btnOkColor: Colors.yellow[700],
        buttonsTextStyle: const TextStyle(color: Colors.black),
        btnOkOnPress: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainNavigation()),
                (route) => false,
          );
        },
        dismissOnTouchOutside: false,
        dismissOnBackKeyPress: false,
        onDismissCallback: (type) {
          //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainNavigation()));
          //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => widget.page));
          //Navigator.of(context).pop();
        },
      ).show();
    } catch (e) {
      debugPrint("Erreur lors de l'enregistrement : $e");
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: 'Oups !',
        desc: 'Erreur : $e',
        btnOkColor: Colors.red,
      ).show();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
                    height: 110, width: 110,
                    decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colorScheme.primary.withOpacity(0.2))
                    ),
                    child: _imageFile != null
                        ? ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.file(_imageFile!, fit: BoxFit.cover))
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo_rounded, color: colorScheme.primary, size: 30),
                        const Text("PHOTO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
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
              DropdownButtonFormField<Category>(
                value: _selectedCategory,
                isExpanded: true,
                decoration: _inputDecoration("Catégorie", Icons.category_outlined),
                items: _categories.map((Category c) => DropdownMenuItem<Category>(value: c, child: Text(c.name))).toList(),
                onChanged: _isLoading ? null : (Category? c) => setState(() => _selectedCategory = c),
                validator: (v) => v == null ? "Obligatoire" : null,
              ),
              const SizedBox(height: 15),
              _buildField(_descController, "Description", Icons.description_outlined, maxLines: 2),
              const Padding(padding: EdgeInsets.symmetric(vertical: 20), child: Divider()),
              _buildSectionTitle("INVENTAIRE & PRIX"),
              Row(
                children: [
                  Expanded(child: _buildField(_buyPriceController, "Prix d'achat", Icons.monetization_on_outlined, isNumber: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildField(_sellPriceController, "Prix de vente", Icons.sell_outlined, isNumber: true)),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
                  ),
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("CRÉER ET AJOUTER AU STOCK", style: TextStyle(fontWeight: FontWeight.bold)),
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
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.blueGrey, letterSpacing: 1.1)),
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

  Widget _buildField(TextEditingController controller, String label, IconData icon, {int maxLines = 1, bool isNumber = false}) {
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