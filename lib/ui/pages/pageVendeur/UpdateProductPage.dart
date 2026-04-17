import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:brixel/Exception/NoInternetConnectionException.dart';
import 'package:brixel/service/ProductService.dart';
import 'package:brixel/ui/theme/AppColors.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:brixel/data/modele/ProductStock.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class UpdateProductPage extends StatefulWidget {
  final ProductStock product;

  const UpdateProductPage({super.key, required this.product});

  @override
  State<UpdateProductPage> createState() => _UpdateProductPageState();
}

class _UpdateProductPageState extends State<UpdateProductPage> {
  late final TextEditingController nameCtrl;
  late final TextEditingController brandCtrl;
  late final TextEditingController descCtrl;
  late final TextEditingController buyPriceCtrl;
  late final TextEditingController sellPriceCtrl;
  late final TextEditingController stockCtrl;
  late String selectedUnit;

  bool _isLoading = false;

  final ProductService _productService = ProductService();
  final ImagePicker _picker = ImagePicker();
  File? _newImageFile;

  static const List<String> _units = [
    'Unité', 'Sac', 'Kilo', 'Mètre', 'Litre', 'Paquet', 'Tonne', 'Bar'
  ];

  @override
  void initState() {
    super.initState();
    nameCtrl     = TextEditingController(text: widget.product.name);
    brandCtrl    = TextEditingController(text: widget.product.brand);
    descCtrl     = TextEditingController(text: widget.product.descriptionProduit ?? '');
    buyPriceCtrl = TextEditingController(text: widget.product.purchasePrice.toString());
    sellPriceCtrl= TextEditingController(text: widget.product.sellPrice.toString());
    stockCtrl    = TextEditingController(text: widget.product.stock.toString());
    selectedUnit = widget.product.unit ?? 'Unité';
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    brandCtrl.dispose();
    descCtrl.dispose();
    buyPriceCtrl.dispose();
    sellPriceCtrl.dispose();
    stockCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_isLoading) return;
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1080,
      imageQuality: 85,
    );
    if (picked != null) setState(() => _newImageFile = File(picked.path));
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.product.name,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: 0.3,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const Text(
              "Modifier le produit",
              style: TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Photo ───────────────────────────────────────────────
            _buildPhotoSection(),
            const SizedBox(height: 20),

            // ── Infos générales ─────────────────────────────────────
            _buildSectionHeader("Informations générales", Icons.info_outline_rounded),
            const SizedBox(height: 12),

            _buildTextField(nameCtrl, "Nom du produit",
                Icons.shopping_bag_outlined),
            const SizedBox(height: 12),
            _buildTextField(brandCtrl, "Marque / Fabricant",
                Icons.branding_watermark_outlined),
            const SizedBox(height: 12),
            _buildTextField(descCtrl, "Description",
                Icons.description_outlined, maxLines: 3),

            const SizedBox(height: 20),

            // ── Inventaire & Prix ───────────────────────────────────
            _buildSectionHeader("Inventaire & Prix", Icons.payments_outlined),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    buyPriceCtrl,
                    "Prix d'achat",
                    Icons.monetization_on_outlined,
                    keyboardType: TextInputType.number,
                    suffix: "FCFA",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTextField(
                    sellPriceCtrl,
                    "Prix de vente",
                    Icons.sell_outlined,
                    keyboardType: TextInputType.number,
                    suffix: "FCFA",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    stockCtrl,
                    "Quantité",
                    Icons.inventory_2_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    value: selectedUnit,
                    isExpanded: true,
                    decoration:
                    _inputDecoration("Unité", Icons.straighten_rounded),
                    items: _units
                        .map((u) => DropdownMenuItem(
                      value: u,
                      child: Text(u,
                          style: const TextStyle(fontSize: 13)),
                    ))
                        .toList(),
                    onChanged:
                    _isLoading ? null : (v) => setState(() => selectedUnit = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Indicateur de marge (même pattern que AddProductPage)
            _buildMargeIndicator(),

            const SizedBox(height: 28),

            // ── Boutons ─────────────────────────────────────────────
            _buildActions(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Photo section (cohérente avec AddProductPage, full-width) ─────────────
  Widget _buildPhotoSection() {
    final bool hasNewImage = _newImageFile != null;
    final bool hasExistingImage =
        widget.product.imageUrl != null && widget.product.imageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: (hasNewImage || hasExistingImage)
                ? AppColors.primary.withOpacity(0.3)
                : Colors.grey.shade200,
            width: (hasNewImage || hasExistingImage) ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: (hasNewImage || hasExistingImage)
            ? Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(19),
              child: hasNewImage
                  ? Image.file(
                _newImageFile!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              )
                  : Image.network(
                widget.product.imageUrl!,
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image_outlined,
                      color: Colors.grey, size: 36),
                ),
              ),
            ),
            // Overlay "Modifier" — identique à AddProductPage
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
            // Badge "Nouvelle photo" si image fraîchement choisie
            if (hasNewImage)
              Positioned(
                left: 10,
                bottom: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.priceGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline_rounded,
                          color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text(
                        "Nouvelle photo",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
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
              style:
              TextStyle(fontSize: 11, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }

  // ── En-tête section (identique à AddProductPage / StockPage) ──────────────
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

  // ── Indicateur de marge (identique à AddProductPage) ──────────────────────
  Widget _buildMargeIndicator() {
    final double buy  = double.tryParse(buyPriceCtrl.text)  ?? 0;
    final double sell = double.tryParse(sellPriceCtrl.text) ?? 0;
    if (buy <= 0 || sell <= 0) return const SizedBox.shrink();

    final double marge = sell - buy;
    final double taux  = (marge / buy) * 100;
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
                color: positive ? AppColors.greenDark : AppColors.closedDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Boutons bas de page ────────────────────────────────────────────────────
  Widget _buildActions() {
    return Column(
      children: [
        // Bouton principal
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : _updateProduct,
            icon: _isLoading
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2),
            )
                : const Icon(Icons.save_rounded,
                color: Colors.white, size: 18),
            label: Text(
              _isLoading ? "Enregistrement..." : "ENREGISTRER LES MODIFICATIONS",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
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
        ),
        const SizedBox(height: 10),
        // Bouton secondaire Annuler
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: const Text(
              "Annuler",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Champ texte (aligné avec AddProductPage) ───────────────────────────────
  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
        String? suffix,
      }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      enabled: !_isLoading,
      keyboardType: keyboardType,
      onChanged: (keyboardType == TextInputType.number)
          ? (_) => setState(() {})
          : null,
      style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary),
      decoration: _inputDecoration(label, icon).copyWith(
        suffixText: suffix,
        suffixStyle: const TextStyle(
            fontSize: 11,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500),
      ),
    );
  }

  // ── InputDecoration (identique à AddProductPage) ───────────────────────────
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

  // ── Logique métier (inchangée) ─────────────────────────────────────────────
  Future<void> _updateProduct() async {
    final initial = {
      'name': widget.product.name,
      'brand': widget.product.brand,
      'descriptionProduit': widget.product.descriptionProduit ?? '',
      'purchasePrice': widget.product.purchasePrice.toString(),
      'sellingPrice': widget.product.sellPrice.toString(),
      'quantite': widget.product.stock.toString(),
      'unite': widget.product.unit,
      'imageUrl': widget.product.imageUrl,
    };

    final modified = {
      'name': nameCtrl.text,
      'brand': brandCtrl.text,
      'descriptionProduit': descCtrl.text,
      'purchasePrice': buyPriceCtrl.text,
      'sellingPrice': sellPriceCtrl.text,
      'quantite': stockCtrl.text,
      'unite': selectedUnit,
      'imageFile': _newImageFile,
      'imageUrl': widget.product.imageUrl,
    };

    final changes = <String, dynamic>{};
    modified.forEach((key, value) {
      if (key == 'imageFile') {
        if (value != null) changes['imageFile'] = value;
      } else if (value != initial[key]) {
        changes[key] = value;
      }
    });

    if (changes.isEmpty) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _productService.updateProduct(widget.product.id, changes);
      if (!mounted) return;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        title: "Succès !",
        desc: "Produit modifié avec succès",
        btnOkText: "OK",
        btnOkColor: AppColors.priceGreen,
        btnOkOnPress: () => Navigator.pop(context, true),
      ).show();
    } on NoInternetConnectionException catch (e) {
      _showErrorDialog("Pas de connexion", e.message);
    } on DioException catch (e) {
      final msg = (e.response?.data is Map &&
          e.response!.data['message'] != null)
          ? e.response!.data['message']
          : "Erreur lors de la modification";
      _showErrorDialog("Erreur", msg);
    } catch (e) {
      _showErrorDialog("Erreur inattendue", e.toString());
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
}