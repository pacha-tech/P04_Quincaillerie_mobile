
/*
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:brixel/Exception/NoInternetConnectionException.dart';
import 'package:brixel/service/ProductService.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:brixel/data/modele/ProductStock.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class UpdateProductPage extends StatefulWidget {
  final ProductStock product;

  const UpdateProductPage({
    super.key,
    required this.product,
  });

  @override
  State<UpdateProductPage> createState() => _UpdateProductPageState();
}

class _UpdateProductPageState extends State<UpdateProductPage> {
  late TextEditingController nameCtrl;
  late TextEditingController brandCtrl;
  late TextEditingController descCtrl;
  late TextEditingController buyPriceCtrl;
  late TextEditingController sellPriceCtrl;
  late TextEditingController stockCtrl;
  late String selectedUnit;

  late ColorScheme colorScheme;

  bool _isLoading = false;

  final ProductService _productService = ProductService();

  final ImagePicker _picker = ImagePicker();
  File? _newImageFile;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.product.name);
    brandCtrl = TextEditingController(text: widget.product.brand);
    descCtrl = TextEditingController(text: widget.product.descriptionProduit ?? '');
    buyPriceCtrl = TextEditingController(text: widget.product.purchasePrice.toString());
    sellPriceCtrl = TextEditingController(text: widget.product.sellPrice.toString());
    stockCtrl = TextEditingController(text: widget.product.stock.toString());
    selectedUnit = widget.product.unit ?? 'Unité';
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    colorScheme = Theme.of(context).colorScheme;
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
    final XFile? picked = await _picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _newImageFile = File(picked.path));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text("Modifier ${widget.product.name}"),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo
            GestureDetector(
              onTap: _pickImage,
              child: Center(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
                  ),
                  child: _newImageFile != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(_newImageFile!, fit: BoxFit.cover),
                  )
                      : (widget.product.imageUrl != null && widget.product.imageUrl!.isNotEmpty)
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.network(widget.product.imageUrl!, fit: BoxFit.cover),
                  )
                      : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_a_photo_rounded, color: colorScheme.primary, size: 40),
                      const SizedBox(height: 8),
                      Text("Changer photo", style: TextStyle(color: colorScheme.primary, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Champs
            _buildTextField(nameCtrl, "Nom du produit", Icons.label_outline),
            const SizedBox(height: 16),
            _buildTextField(brandCtrl, "Marque", Icons.branding_watermark),
            const SizedBox(height: 16),
            _buildTextField(descCtrl, "Description", Icons.description, maxLines: 4),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(buyPriceCtrl, "Prix d'achat", Icons.attach_money, keyboardType: TextInputType.number),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(sellPriceCtrl, "Prix de vente", Icons.attach_money, keyboardType: TextInputType.number),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTextField(stockCtrl, "Quantité", Icons.inventory_2, keyboardType: TextInputType.number),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedUnit,
                    decoration: InputDecoration(
                      labelText: "Unité",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      filled: true,
                      fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
                    ),
                    items: ['Unité', 'Sac', 'Kilo', 'Mètre', 'Litre', 'Paquet', 'Tonne', 'Bar']
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (value) => setState(() => selectedUnit = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),


            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Annuler",
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : () async {

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
                        if (value != null) {
                          changes['imageFile'] = value; // Il y a un nouveau fichier à envoyer
                        }
                      } else if (value != initial[key]) {
                        changes[key] = value;
                      }
                    });


                    if (changes.isNotEmpty) {
                      try {
                        setState(() {
                          _isLoading = true;
                        });

                        //await Future.delayed(Duration(seconds: 15));
                        await _productService.updateProduct(widget.product.id, changes);

                        if (!mounted) return;

                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.success,
                          animType: AnimType.bottomSlide,
                          title: "Succès !",
                          desc: "Produit modifié avec succès",
                          btnOkText: "OK",
                          btnOkColor: Colors.green,
                          btnOkOnPress: () {
                            if (mounted) Navigator.pop(context , true);
                          },
                        ).show();

                      } on NoInternetConnectionException catch(e){
                        if (!mounted) return;

                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.error,
                          title: "Erreur inattendue",
                          desc: e.message,
                          btnOkText: "OK",
                          btnOkColor: colorScheme.error,
                        ).show();
                      } on DioException catch (e) {
                        if (!mounted) return;

                        String errorMsg = "Erreur réseau";

                        if (e.response != null) {
                          final status = e.response!.statusCode;
                          final data = e.response!.data;

                          if (data is Map<String, dynamic> && data['message'] != null) {
                            errorMsg = data['message'];
                          }

                          if (status == 404) {
                            errorMsg = "Produit non trouvé";
                          } else if (status == 401) {
                            errorMsg = "Session expirée";
                          } else if (status == 403) {
                            errorMsg = "Accès interdit";
                          } else if (status! >= 500) {
                            errorMsg = "Erreur serveur";
                          }
                        }

                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.error,
                          title: "Erreur",
                          desc: errorMsg,
                          btnOkText: "OK",
                          btnOkColor: colorScheme.error,
                        ).show();

                      } catch (e) {
                        if (!mounted) return;

                        print("Erreur lors de la modif de l'image $e");

                        AwesomeDialog(
                          context: context,
                          dialogType: DialogType.error,
                          title: "Erreur inattendue",
                          desc: e.toString(),
                          btnOkText: "OK",
                          btnOkColor: colorScheme.error,
                        ).show();
                      }finally{
                        setState(() {
                          _isLoading = false;
                        });
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    minimumSize: const Size(160, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.save, size: 18),
                      SizedBox(width: 8),
                      Text("Modifier"),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      enabled: !_isLoading,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: colorScheme.surfaceVariant.withOpacity(0.4),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
 */

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:brixel/Exception/NoInternetConnectionException.dart';
import 'package:brixel/service/ProductService.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:brixel/data/modele/ProductStock.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import '../../../ui/theme/AppColors.dart';

class UpdateProductPage extends StatefulWidget {
  final ProductStock product;

  const UpdateProductPage({
    super.key,
    required this.product,
  });

  @override
  State<UpdateProductPage> createState() => _UpdateProductPageState();
}

class _UpdateProductPageState extends State<UpdateProductPage> {
  late TextEditingController nameCtrl;
  late TextEditingController brandCtrl;
  late TextEditingController descCtrl;
  late TextEditingController buyPriceCtrl;
  late TextEditingController sellPriceCtrl;
  late TextEditingController stockCtrl;
  late String selectedUnit;

  bool _isLoading = false;

  final ProductService _productService = ProductService();
  final ImagePicker _picker = ImagePicker();
  File? _newImageFile;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.product.name);
    brandCtrl = TextEditingController(text: widget.product.brand);
    descCtrl = TextEditingController(text: widget.product.descriptionProduit ?? '');
    buyPriceCtrl = TextEditingController(text: widget.product.purchasePrice.toString());
    sellPriceCtrl = TextEditingController(text: widget.product.sellPrice.toString());
    stockCtrl = TextEditingController(text: widget.product.stock.toString());
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
    if (picked != null) {
      setState(() => _newImageFile = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: Text(
          "Modifier ${widget.product.name}",
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            letterSpacing: 0.3,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo avec icône de modification
            GestureDetector(
              onTap: _pickImage,
              child: Center(
                child: Stack(
                  children: [
                    Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.18),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 15,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: _newImageFile != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.file(_newImageFile!, fit: BoxFit.cover),
                      )
                          : (widget.product.imageUrl != null && widget.product.imageUrl!.isNotEmpty)
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.network(
                          widget.product.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.broken_image_rounded,
                            size: 50,
                            color: Colors.grey,
                          ),
                        ),
                      )
                          : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            color: AppColors.primary.withOpacity(0.5),
                            size: 45,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Aucune photo",
                            style: TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Icône de modification
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.cardBg, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            _buildSectionTitle("INFORMATIONS GÉNÉRALES"),
            const SizedBox(height: 12),

            _buildTextField(nameCtrl, "Nom du produit", Icons.shopping_bag_outlined),
            const SizedBox(height: 14),
            _buildTextField(brandCtrl, "Marque / Fabricant", Icons.branding_watermark_outlined),
            const SizedBox(height: 14),
            _buildTextField(descCtrl, "Description", Icons.description_outlined, maxLines: 3),

            const SizedBox(height: 24),

            _buildSectionTitle("INVENTAIRE & PRIX"),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    buyPriceCtrl,
                    "Prix d'achat (FCFA)",
                    Icons.monetization_on_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildTextField(
                    sellPriceCtrl,
                    "Prix de vente (FCFA)",
                    Icons.monetization_on_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    stockCtrl,
                    "Quantité en stock",
                    Icons.inventory_2_outlined,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedUnit,
                    isExpanded: true,
                    decoration: _inputDecoration("Unité", Icons.straighten_rounded),
                    items: ['Unité', 'Sac', 'Kilo', 'Mètre', 'Litre', 'Paquet', 'Tonne', 'Bar']
                        .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                        .toList(),
                    onChanged: (value) => setState(() => selectedUnit = value!),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            // Boutons d'action
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textMuted,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: const Text(
                    "Annuler",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _updateProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    minimumSize: const Size(160, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                      : const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.save_rounded, size: 20),
                      SizedBox(width: 10),
                      Text(
                        "Enregistrer",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ====================== Helpers ======================

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 14,
        color: AppColors.primary,
        letterSpacing: 1.0,
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, size: 22, color: AppColors.primary.withOpacity(0.75)),
      filled: true,
      fillColor: AppColors.cardBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.grey.withOpacity(0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: AppColors.primary, width: 2.2),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        int maxLines = 1,
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      enabled: !_isLoading,
      keyboardType: keyboardType,
      decoration: _inputDecoration(label, icon),
      style: const TextStyle(fontSize: 15.5),
    );
  }

  // Méthode _updateProduct et _showErrorDialog restent identiques à la version précédente
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
      String errorMsg = "Erreur lors de la modification";
      if (e.response?.data is Map && e.response!.data['message'] != null) {
        errorMsg = e.response!.data['message'];
      }
      _showErrorDialog("Erreur", errorMsg);
    } catch (e) {
      _showErrorDialog("Erreur inattendue", e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String title, String desc) {
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