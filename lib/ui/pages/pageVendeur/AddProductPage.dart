import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../../../Exception/AppException.dart';
import '../../../Exception/NoInternetConnectionException.dart';
import '../../../Exception/ProductAlreadyExistsException.dart';
import '../../../data/modele/Category.dart';
import '../../../data/dto/product/AddProductDTO.dart';
import '../../../service/ProductService.dart';
import '../../../service/CategoryService.dart';
import '../../theme/AppColors.dart';
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
  List<Category?> _categories = [];

  final List<String> _units = [
    'Unité', 'Sac', 'Kilo', 'Mètre', 'Litre', 'Paquet', 'Tonne', 'Barre'
  ];

  @override
  void initState() {
    super.initState();
    _loadCategories();
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

  Future<void> _loadCategories() async {
    try {
      final categories = await _categoryService.getAllCategory();
      if (mounted) setState(() => _categories = categories);
    } catch (e) {
      debugPrint("Erreur chargement catégories : $e");
    }
  }

  Future<void> _pickImage() async {
    if (_isLoading) return;
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      imageQuality: 85,
    );
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final double buyPrice = double.tryParse(_buyPriceController.text.trim()) ?? 0;
    final double sellPrice = double.tryParse(_sellPriceController.text.trim()) ?? 0;

    if (_imageFile == null) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.question,
        title: "Image manquante",
        desc: "Souhaitez-vous enregistrer ce produit sans image ?",
        btnCancelText: "Ajouter une photo",
        btnOkText: "Continuer sans photo",
        btnCancelOnPress: () {},
        btnOkOnPress: () => _checkPrices(buyPrice, sellPrice),
      ).show();
      return;
    }
    _checkPrices(buyPrice, sellPrice);
  }

  void _checkPrices(double buyPrice, double sellPrice) {
    if (sellPrice < buyPrice) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        title: "Prix de vente inférieur",
        desc: "Le prix de vente est inférieur au prix d'achat.\nConfirmer quand même ?",
        btnOkText: "Confirmer",
        btnOkColor: AppColors.priceGreen,
        btnCancelText: "Annuler",
        btnCancelOnPress: () {},
        btnOkOnPress: () => _executeAddProduct(),
      ).show();
    } else {
      _executeAddProduct();
    }
  }

  Future<void> _executeAddProduct() async {
    setState(() => _isLoading = true);

    final dto = AddProductDTO(
      name: _nameController.text.trim(),
      brand: _brandController.text.trim(),
      categoryId: _selectedCategory?.id ?? "",
      purchasePrice: _buyPriceController.text.trim(),
      sellingPrice: _sellPriceController.text.trim(),
      quantite: int.tryParse(_stockController.text.trim()) ?? 0,
      unite: _selectedUnit,
      descriptionProduit: _descController.text.trim(),
    );

    try {
      await _productService.addProduct(dto, _imageFile);
      if (!mounted) return;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        title: "Succès !",
        desc: "Produit ajouté avec succès",
        btnOkText: "OK",
        btnOkColor: AppColors.priceGreen,
        btnOkOnPress: () => Navigator.pop(context, true),
      ).show();
    } on ProductAlreadyExistsException catch (e) {
      if (!mounted) return;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        title: "Produit déjà existant",
        desc: e.message,
        btnOkText: "Modifier",
        btnOkOnPress: () {},
        btnCancelText: "Mettre à jour stock",
        btnCancelColor: AppColors.accent,
        btnCancelOnPress: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UpdateStockPage()),
        ),
      ).show();
    } on NoInternetConnectionException catch (e) {
      _showErrorDialog("Pas de connexion", e.message);
    } on AppException catch (e) {
      _showErrorDialog("Erreur", e.message);
    } catch (_) {
      _showErrorDialog("Erreur inattendue", "Une erreur est survenue.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String title, String desc) {
    if (!mounted) return;
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      title: title,
      desc: desc,
      btnOkText: "OK",
      btnOkColor: AppColors.accent,
      btnOkOnPress: () {},
    ).show();
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Ajouter un produit",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 17,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              "Remplissez les informations",
              style: TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Photo picker ────────────────────────────────────────
              _buildPhotoSection(),
              const SizedBox(height: 20),

              // ── Section infos générales ─────────────────────────────
              _buildSectionHeader("Informations générales", Icons.info_outline_rounded),
              const SizedBox(height: 12),

              _buildField(_nameController, "Nom du produit",
                  Icons.shopping_bag_outlined),
              const SizedBox(height: 12),
              _buildField(_brandController, "Marque / Fabricant",
                  Icons.branding_watermark_outlined),
              const SizedBox(height: 12),
              _buildCategoryDropdown(),
              const SizedBox(height: 12),
              _buildField(_descController, "Description",
                  Icons.description_outlined,
                  maxLines: 3),

              const SizedBox(height: 20),

              // ── Section inventaire ──────────────────────────────────
              _buildSectionHeader("Inventaire & Prix", Icons.payments_outlined),
              const SizedBox(height: 12),

              // Ligne prix
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      _buyPriceController,
                      "Prix d'achat",
                      Icons.monetization_on_outlined,
                      isNumber: true,
                      suffix: "FCFA",
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildField(
                      _sellPriceController,
                      "Prix de vente",
                      Icons.sell_outlined,
                      isNumber: true,
                      suffix: "FCFA",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Ligne stock + unité
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildField(
                      _stockController,
                      "Quantité",
                      Icons.inventory_2_outlined,
                      isNumber: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 3,
                    child: _buildUnitDropdown(),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Indicateur marge bénéficiaire
              _buildMargeIndicator(),

              const SizedBox(height: 28),

              // ── Bouton principal ────────────────────────────────────
              _buildSubmitButton(),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ── Photo section ──────────────────────────────────────────────────────────
  Widget _buildPhotoSection() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _imageFile != null
                ? AppColors.primary.withOpacity(0.3)
                : Colors.grey.shade200,
            width: _imageFile != null ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: _imageFile != null
            ? Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(19),
              child: Image.file(
                _imageFile!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            // Overlay modifier
            Positioned(
              right: 10,
              bottom: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.edit_rounded,
                        color: Colors.white, size: 13),
                    SizedBox(width: 4),
                    Text(
                      "Modifier",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.07),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.add_a_photo_rounded,
                  color: AppColors.primary, size: 26),
            ),
            const SizedBox(height: 10),
            const Text(
              "Ajouter une photo du produit",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              "Appuyez pour choisir depuis la galerie",
              style: TextStyle(
                  fontSize: 11, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }

  // ── En-tête de section (cohérent avec StockPage et DashboardVendeur) ────────
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 11,
            color: AppColors.primary,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  // ── Indicateur de marge ────────────────────────────────────────────────────
  Widget _buildMargeIndicator() {
    final double buy = double.tryParse(_buyPriceController.text) ?? 0;
    final double sell = double.tryParse(_sellPriceController.text) ?? 0;

    if (buy <= 0 || sell <= 0) return const SizedBox.shrink();

    final double marge = sell - buy;
    final double taux = (marge / buy) * 100;
    final bool positive = marge >= 0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: positive ? AppColors.greenLight : AppColors.closedLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: positive
              ? AppColors.statusOpen.withOpacity(0.3)
              : AppColors.accent.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            positive
                ? Icons.trending_up_rounded
                : Icons.trending_down_rounded,
            size: 18,
            color: positive ? AppColors.statusOpen : AppColors.accent,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              positive
                  ? "Marge : +${marge.toStringAsFixed(0)} FCFA (${taux.toStringAsFixed(1)}%)"
                  : "Attention : marge négative de ${marge.toStringAsFixed(0)} FCFA",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color:
                positive ? AppColors.greenDark : AppColors.closedDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dropdown catégorie ─────────────────────────────────────────────────────
  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<Category?>(
      value: _selectedCategory,
      isExpanded: true,
      decoration: _inputDecoration("Catégorie", Icons.category_outlined),
      items: _categories
          .map((c) => DropdownMenuItem<Category?>(
        value: c,
        child: Text(c?.name ?? "Sélectionner une catégorie",
            style: const TextStyle(fontSize: 13)),
      ))
          .toList(),
      onChanged: _isLoading ? null : (v) => setState(() => _selectedCategory = v),
      validator: (v) => v == null ? "Veuillez choisir une catégorie" : null,
    );
  }

  // ── Dropdown unité ─────────────────────────────────────────────────────────
  Widget _buildUnitDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedUnit,
      isExpanded: true,
      decoration: _inputDecoration("Unité", Icons.straighten_rounded),
      items: _units
          .map((u) => DropdownMenuItem(
        value: u,
        child: Text(u, style: const TextStyle(fontSize: 13)),
      ))
          .toList(),
      onChanged: (v) => setState(() => _selectedUnit = v!),
    );
  }

  // ── Bouton submit ──────────────────────────────────────────────────────────
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _submitForm,
        icon: _isLoading
            ? const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
              color: Colors.white, strokeWidth: 2),
        )
            : const Icon(Icons.add_circle_outline_rounded,
            color: Colors.white, size: 18),
        label: Text(
          _isLoading ? "Enregistrement..." : "CRÉER ET AJOUTER AU STOCK",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
      ),
    );
  }

  // ── Champ texte ────────────────────────────────────────────────────────────
  Widget _buildField(
      TextEditingController controller,
      String label,
      IconData icon, {
        int maxLines = 1,
        bool isNumber = false,
        String? suffix,
      }) {
    return TextFormField(
      controller: controller,
      enabled: !_isLoading,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary),
      onChanged: isNumber ? (_) => setState(() {}) : null,
      decoration: _inputDecoration(label, icon).copyWith(
        suffixText: suffix,
        suffixStyle: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500),
      ),
      validator: (v) =>
      v!.trim().isEmpty ? "Ce champ est obligatoire" : null,
    );
  }

  // ── Décoration input (cohérente avec AddPromotionPage) ─────────────────────
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle:
      const TextStyle(fontSize: 13, color: AppColors.textMuted),
      prefixIcon: Icon(icon, size: 18, color: AppColors.primary),
      filled: true,
      fillColor: AppColors.cardBg,
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
        const BorderSide(color: AppColors.accent, width: 1.5),
      ),
    );
  }
}