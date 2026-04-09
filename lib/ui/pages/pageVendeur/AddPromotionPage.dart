/*
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../Exception/AppException.dart';
import '../../../Exception/NoInternetConnectionException.dart';
import '../../../data/dto/promotion/AddPromotionDTO.dart';
import '../../../data/modele/ProductPromotion.dart';
import '../../../service/PromotionService.dart';

class _ProductItem {
  final String idPrice;
  final String name;
  final double price;
  final String category;
  final String imageUrl;
  bool isSelected;

  _ProductItem({
    required this.idPrice,
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.isSelected = false,
  });
}

class _CategoryItem {
  final String name;
  bool isSelected;
  _CategoryItem({required this.name, this.isSelected = false});
}

class AddPromotionPage extends StatefulWidget {
  const AddPromotionPage({super.key});

  @override
  State<AddPromotionPage> createState() => _AddPromotionPageState();
}

class _AddPromotionPageState extends State<AddPromotionPage> {
  final PageController _pageController = PageController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _nomCampagneController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final PromotionService _promotionService = PromotionService();

  late ColorScheme colorScheme;

  int _currentPage = 0;
  double _discount = 0.0;
  DateTime? _dateDebut;
  DateTime? _dateFin;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  String _searchQuery = '';

  String? _errNom;
  String? _errDiscount;
  String? _errSelection;
  String? _errDateDebut;
  String? _errDateFin;

  List<_ProductItem> _products = [];
  List<_CategoryItem> _categoryList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProducts());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _discountController.dispose();
    _nomCampagneController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _getThumbnailUrl(String? url) {
    if (url == null || url.isEmpty) return "";
    if (!url.contains("cloudinary.com")) return url;
    return url.replaceAll("/upload/", "/upload/w_150,h_150,c_fill,g_auto,q_auto/");
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final List<ProductPromotion> result = await _promotionService.getAllProductOutPromotion();

      final products = result.map((p) => _ProductItem(
        idPrice: p.id,
        name: p.nom,
        price: p.price,
        category: p.category,
        imageUrl: p.imageUrl,
      )).toList();

      final categories = products
          .map((p) => p.category)
          .toSet()
          .map((name) => _CategoryItem(name: name))
          .toList();

      setState(() {
        _products = products;
        _categoryList = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = (e is AppException || e is NoInternetConnectionException)
            ? e.toString()
            : "Erreur lors du chargement des produits";
      });
    }
  }

  List<_ProductItem> get _filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    final query = _searchQuery.toLowerCase();
    return _products.where((p) =>
    p.name.toLowerCase().contains(query) ||
        p.category.toLowerCase().contains(query)
    ).toList();
  }

  int get _selectionCount => _products.where((p) => p.isSelected).length;

  void _onProductToggled(_ProductItem product, bool selected) {
    setState(() {
      product.isSelected = selected;
      _errSelection = null;

      final productsInCat = _products.where((p) => p.category == product.category).toList();
      final allSelected = productsInCat.every((p) => p.isSelected);
      final catIndex = _categoryList.indexWhere((c) => c.name == product.category);
      if (catIndex != -1) _categoryList[catIndex].isSelected = allSelected;
    });
  }

  void _onCategoryToggled(_CategoryItem cat, bool selected) {
    setState(() {
      cat.isSelected = selected;
      for (var p in _products.where((p) => p.category == cat.name)) {
        p.isSelected = selected;
      }
      _errSelection = null;
    });
  }

  void _toggleAllStore() {
    bool isAllSelected = _products.every((p) => p.isSelected);
    setState(() {
      bool targetState = !isAllSelected;
      for (var p in _products) { p.isSelected = targetState; }
      for (var c in _categoryList) { c.isSelected = targetState; }
      _errSelection = null;
    });
  }

  Future<void> _pickDate({required bool isDebut}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isDebut ? (_dateDebut ?? now) : (_dateFin ?? _dateDebut ?? now),
      firstDate: isDebut ? now : (_dateDebut ?? now),
      lastDate: DateTime(now.year + 5),
    );

    if (picked != null) {
      setState(() {
        if (isDebut) {
          _dateDebut = picked;
          _errDateDebut = null;
        } else {
          _dateFin = picked;
          _errDateFin = null;
        }
      });
    }
  }

  bool _validate() {
    setState(() {
      _errNom = _nomCampagneController.text.trim().isEmpty ? "Nom requis" : null;
      _errDiscount = (_discount <= 0 || _discount > 100) ? "Entre 1-100%" : null;
      _errSelection = _selectionCount == 0 ? "Veuillez sélectionner au moins un produit" : null;
      _errDateDebut = _dateDebut == null ? "Date requise" : null;
      _errDateFin = _dateFin == null ? "Date requise" : null;
    });

    return _errNom == null && _errDiscount == null && _errSelection == null && _errDateDebut == null && _errDateFin == null;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final dto = AddPromotionDTO(
        nom: _nomCampagneController.text.trim(),
        taux: _discount,
        dateDebut: _dateDebut!,
        dateFin: _dateFin!,
        idsPrices: _products.where((p) => p.isSelected).map((p) => p.idPrice).toList(),
      );

      await _promotionService.addPromotion(dto);
      if (!mounted) return;

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        title: "Succès",
        desc: "Promotion activée sur $_selectionCount produit(s).",
        btnOkOnPress: () => Navigator.pop(context),
      ).show();
    } catch (e) {
      AwesomeDialog(context: context, dialogType: DialogType.error, title: "Erreur", desc: e.toString(), btnOkOnPress: () {}).show();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Nouvelle Promotion", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildTopMenu(),
          _buildFormHeader(),
          Expanded(child: _buildMainContent()),
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildTopMenu() {
    final tabs = ["PRODUITS", "CATÉGORIES", "TOUT"];
    return Container(
      color: colorScheme.primary,
      child: Row(
        children: List.generate(3, (i) => Expanded(
          child: InkWell(
            onTap: () => _pageController.animateToPage(i, duration: const Duration(milliseconds: 300), curve: Curves.ease),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(tabs[i], style: TextStyle(color: _currentPage == i ? Colors.white : Colors.white60, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                AnimatedContainer(duration: const Duration(milliseconds: 200), height: 3, width: 40, color: _currentPage == i ? colorScheme.secondary : Colors.transparent),
              ],
            ),
          ),
        )),
      ),
    );
  }

  Widget _buildFormHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _nomCampagneController,
            decoration: InputDecoration(
              labelText: "Nom de la campagne",
              prefixIcon: const Icon(Icons.campaign),
              errorText: _errNom,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _discountController,
                  keyboardType: TextInputType.number,
                  onChanged: (v) => setState(() => _discount = double.tryParse(v) ?? 0),
                  decoration: InputDecoration(
                    labelText: "Remise %",
                    prefixIcon: const Icon(Icons.percent),
                    errorText: _errDiscount,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _dateTile("Début", _dateDebut, () => _pickDate(isDebut: true), _errDateDebut != null),
                    const SizedBox(height: 4),
                    _dateTile("Fin", _dateFin, () => _pickDate(isDebut: false), _errDateFin != null),
                  ],
                ),
              ),
            ],
          ),

          // --- ZONE DU MESSAGE D'ERREUR DE SÉLECTION ---
          if (_errSelection != null)
            Padding(
              padding: const EdgeInsets.only(top: 12, left: 4),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 16),
                  const SizedBox(width: 6),
                  Text(_errSelection!, style: const TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),

          const SizedBox(height: 12),
          if (_currentPage != 2)
            TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: "Rechercher un produit ou catégorie...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: EdgeInsets.zero,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
        ],
      ),
    );
  }

  Widget _dateTile(String label, DateTime? date, VoidCallback onTap, bool error) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: error ? Colors.red : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Text(date == null ? "--/--/--" : "${date.day}/${date.month}/${date.year}",
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Text(_errorMessage!));

    return PageView(
      controller: _pageController,
      onPageChanged: (i) => setState(() => _currentPage = i),
      children: [
        _buildProductList(),
        _buildCategoryList(),
        _buildStoreView(),
      ],
    );
  }

  Widget _buildProductList() {
    final list = _filteredProducts;
    if (list.isEmpty) return const Center(child: Text("Tout vos produits sont en promotion"));
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, i) {
        final p = list[i];
        return CheckboxListTile(
          value: p.isSelected,
          onChanged: (v) => _onProductToggled(p, v!),
          activeColor: colorScheme.secondary,
          secondary: Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: _getThumbnailUrl(p.imageUrl),
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => const Icon(Icons.image, color: Colors.grey),
              ),
            ),
          ),
          title: Text(p.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          subtitle: Text("${p.price.toInt()} F • ${p.category}", style: const TextStyle(fontSize: 12)),
        );
      },
    );
  }

  Widget _buildCategoryList() {
    return ListView.builder(
      itemCount: _categoryList.length,
      itemBuilder: (context, i) {
        final c = _categoryList[i];
        final count = _products.where((p) => p.category == c.name).length;
        return CheckboxListTile(
          value: c.isSelected,
          onChanged: (v) => _onCategoryToggled(c, v!),
          activeColor: colorScheme.secondary,
          title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("$count produit${count > 1 ? "s" : ""}"),
        );
      },
    );
  }

  Widget _buildStoreView() {
    bool isAllSelected = _products.isNotEmpty && _products.every((p) => p.isSelected);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.storefront, size: 80, color: isAllSelected ? Colors.green : Colors.grey[300]),
          const SizedBox(height: 24),
          const Text("OFFRE GÉNÉRALE", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text(
            "Appliquer la promotion à l'ensemble des ${_products.length} produits de votre quincaillerie.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          const SizedBox(height: 32),

          // --- BOUTON DE SÉLECTION DESIGN ---
          SizedBox(
            width: double.infinity,
            height: 60,
            child: OutlinedButton.icon(
              onPressed: _toggleAllStore,
              icon: Icon(isAllSelected ? Icons.remove_circle_outline : Icons.add_circle_outline),
              label: Text(isAllSelected ? "DÉSELECTIONNER TOUT" : "SÉLECTIONNER TOUTE LA BOUTIQUE",
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                foregroundColor: isAllSelected ? Colors.red : colorScheme.primary,
                side: BorderSide(color: isAllSelected ? Colors.red : colorScheme.primary, width: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _isSubmitting ? null : _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          child: _isSubmitting
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Text("ACTIVER POUR $_selectionCount PRODUIT(S)", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
 */

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:brixel/ui/theme/AppColors.dart';
import '../../../Exception/AppException.dart';
import '../../../Exception/NoInternetConnectionException.dart';
import '../../../data/dto/promotion/AddPromotionDTO.dart';
import '../../../data/modele/ProductPromotion.dart';
import '../../../service/PromotionService.dart';

class _ProductItem {
  final String idPrice;
  final String name;
  final double price;
  final String category;
  final String imageUrl;
  bool isSelected;

  _ProductItem({
    required this.idPrice,
    required this.name,
    required this.price,
    required this.category,
    required this.imageUrl,
    this.isSelected = false,
  });
}

class _CategoryItem {
  final String name;
  bool isSelected;
  _CategoryItem({required this.name, this.isSelected = false});
}

class AddPromotionPage extends StatefulWidget {
  const AddPromotionPage({super.key});

  @override
  State<AddPromotionPage> createState() => _AddPromotionPageState();
}

class _AddPromotionPageState extends State<AddPromotionPage> {
  final PageController _pageController = PageController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _nomCampagneController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final PromotionService _promotionService = PromotionService();

  int _currentPage = 0;
  double _discount = 0.0;
  DateTime? _dateDebut;
  DateTime? _dateFin;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  String _searchQuery = '';

  String? _errNom;
  String? _errDiscount;
  String? _errSelection;
  String? _errDateDebut;
  String? _errDateFin;

  List<_ProductItem> _products = [];
  List<_CategoryItem> _categoryList = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProducts());
  }

  @override
  void dispose() {
    _pageController.dispose();
    _discountController.dispose();
    _nomCampagneController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  String _getThumbnailUrl(String? url) {
    if (url == null || url.isEmpty) return "";
    if (!url.contains("cloudinary.com")) return url;
    return url.replaceAll("/upload/", "/upload/w_150,h_150,c_fill,g_auto,q_auto/");
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final List<ProductPromotion> result =
      await _promotionService.getAllProductOutPromotion();

      final products = result
          .map((p) => _ProductItem(
        idPrice: p.id,
        name: p.nom,
        price: p.price,
        category: p.category,
        imageUrl: p.imageUrl,
      ))
          .toList();

      final categories = products
          .map((p) => p.category)
          .toSet()
          .map((name) => _CategoryItem(name: name))
          .toList();

      setState(() {
        _products = products;
        _categoryList = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage =
        (e is AppException || e is NoInternetConnectionException)
            ? e.toString()
            : "Erreur lors du chargement des produits";
      });
    }
  }

  List<_ProductItem> get _filteredProducts {
    if (_searchQuery.isEmpty) return _products;
    final query = _searchQuery.toLowerCase();
    return _products
        .where((p) =>
    p.name.toLowerCase().contains(query) ||
        p.category.toLowerCase().contains(query))
        .toList();
  }

  int get _selectionCount => _products.where((p) => p.isSelected).length;

  void _onProductToggled(_ProductItem product, bool selected) {
    setState(() {
      product.isSelected = selected;
      _errSelection = null;
      final productsInCat =
      _products.where((p) => p.category == product.category).toList();
      final allSelected = productsInCat.every((p) => p.isSelected);
      final catIndex =
      _categoryList.indexWhere((c) => c.name == product.category);
      if (catIndex != -1) _categoryList[catIndex].isSelected = allSelected;
    });
  }

  void _onCategoryToggled(_CategoryItem cat, bool selected) {
    setState(() {
      cat.isSelected = selected;
      for (var p in _products.where((p) => p.category == cat.name)) {
        p.isSelected = selected;
      }
      _errSelection = null;
    });
  }

  void _toggleAllStore() {
    final bool isAllSelected = _products.every((p) => p.isSelected);
    setState(() {
      final bool target = !isAllSelected;
      for (var p in _products) p.isSelected = target;
      for (var c in _categoryList) c.isSelected = target;
      _errSelection = null;
    });
  }

  Future<void> _pickDate({required bool isDebut}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate:
      isDebut ? (_dateDebut ?? now) : (_dateFin ?? _dateDebut ?? now),
      firstDate: isDebut ? now : (_dateDebut ?? now),
      lastDate: DateTime(now.year + 5),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        if (isDebut) {
          _dateDebut = picked;
          _errDateDebut = null;
        } else {
          _dateFin = picked;
          _errDateFin = null;
        }
      });
    }
  }

  bool _validate() {
    setState(() {
      _errNom =
      _nomCampagneController.text.trim().isEmpty ? "Nom requis" : null;
      _errDiscount =
      (_discount <= 0 || _discount > 100) ? "Entre 1 et 100 %" : null;
      _errSelection = _selectionCount == 0
          ? "Sélectionnez au moins un produit"
          : null;
      _errDateDebut = _dateDebut == null ? "Date requise" : null;
      _errDateFin = _dateFin == null ? "Date requise" : null;
    });
    return _errNom == null &&
        _errDiscount == null &&
        _errSelection == null &&
        _errDateDebut == null &&
        _errDateFin == null;
  }

  Future<void> _submit() async {
    if (!_validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final dto = AddPromotionDTO(
        nom: _nomCampagneController.text.trim(),
        taux: _discount,
        dateDebut: _dateDebut!,
        dateFin: _dateFin!,
        idsPrices: _products
            .where((p) => p.isSelected)
            .map((p) => p.idPrice)
            .toList(),
      );
      await _promotionService.addPromotion(dto);
      if (!mounted) return;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        title: "Succès",
        desc: "Promotion activée sur $_selectionCount produit(s).",
        btnOkOnPress: () => Navigator.pop(context , true),
      ).show();
    } catch (e) {
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: "Erreur",
        desc: e.toString(),
        btnOkOnPress: () {},
      ).show();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }


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
              "Nouvelle Promotion",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 17,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              "Configurez votre campagne",
              style: TextStyle(color: Colors.white60, fontSize: 11),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildTabBar(),
          _buildFormHeader(),
          Expanded(child: _buildMainContent()),
          _buildBottomAction(),
        ],
      ),
    );
  }

  // ── Tab bar ────────────────────────────────────────────────────────────────
  Widget _buildTabBar() {
    const tabs = [
      (icon: Icons.inventory_2_outlined, label: "PRODUITS"),
      (icon: Icons.category_outlined, label: "CATÉGORIES"),
      (icon: Icons.storefront_outlined, label: "TOUT"),
    ];

    return Container(
      color: AppColors.primary,
      child: Row(
        children: List.generate(
          tabs.length,
              (i) {
            final bool active = _currentPage == i;
            return Expanded(
              child: InkWell(
                onTap: () => _pageController.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeInOut,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            tabs[i].icon,
                            size: 14,
                            color: active ? Colors.white : Colors.white38,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            tabs[i].label,
                            style: TextStyle(
                              color: active ? Colors.white : Colors.white38,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 3,
                      width: active ? 48 : 0,
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── Header formulaire ──────────────────────────────────────────────────────
  Widget _buildFormHeader() {
    return Container(
      color: AppColors.cardBg,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Nom de campagne ──────────────────────────────────────
          _buildInput(
            controller: _nomCampagneController,
            label: "Nom de la campagne",
            icon: Icons.campaign_outlined,
            error: _errNom,
          ),
          const SizedBox(height: 10),

          // ── Remise + Dates ───────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildInput(
                  controller: _discountController,
                  label: "Remise %",
                  icon: Icons.percent_rounded,
                  error: _errDiscount,
                  keyboardType: TextInputType.number,
                  onChanged: (v) =>
                      setState(() => _discount = double.tryParse(v) ?? 0),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    _buildDateTile(
                      label: "Début",
                      date: _dateDebut,
                      hasError: _errDateDebut != null,
                      onTap: () => _pickDate(isDebut: true),
                    ),
                    const SizedBox(height: 6),
                    _buildDateTile(
                      label: "Fin",
                      date: _dateFin,
                      hasError: _errDateFin != null,
                      onTap: () => _pickDate(isDebut: false),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Erreur sélection ─────────────────────────────────────
          if (_errSelection != null)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.closedLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        color: AppColors.statusClosed, size: 15),
                    const SizedBox(width: 8),
                    Text(
                      _errSelection!,
                      style: const TextStyle(
                        color: AppColors.closedDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // ── Barre de recherche ───────────────────────────────────
          if (_currentPage != 2) ...[
            const SizedBox(height: 10),
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (v) => setState(() => _searchQuery = v),
                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: "Rechercher un produit ou catégorie...",
                  hintStyle:
                  const TextStyle(fontSize: 12, color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search_rounded,
                      size: 18, color: AppColors.textMuted),
                  border: InputBorder.none,
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Champ texte custom ─────────────────────────────────────────────────────
  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? error,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle:
        const TextStyle(fontSize: 13, color: AppColors.textMuted),
        prefixIcon: Icon(icon, size: 18, color: AppColors.primary),
        errorText: error,
        errorStyle: const TextStyle(fontSize: 11),
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        filled: true,
        fillColor: AppColors.surface,
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
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
    );
  }

  // ── Tuile date ─────────────────────────────────────────────────────────────
  Widget _buildDateTile({
    required String label,
    required DateTime? date,
    required bool hasError,
    required VoidCallback onTap,
  }) {
    final bool filled = date != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: filled
              ? AppColors.primary.withOpacity(0.05)
              : AppColors.surface,
          border: Border.all(
            color: hasError
                ? AppColors.accent
                : filled
                ? AppColors.primary.withOpacity(0.3)
                : Colors.grey.shade200,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 14,
              color: filled ? AppColors.primary : AppColors.textMuted,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                        fontSize: 10, color: AppColors.textMuted),
                  ),
                  Text(
                    date == null
                        ? "--/--/--"
                        : "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: filled
                          ? AppColors.primary
                          : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Contenu principal ──────────────────────────────────────────────────────
  Widget _buildMainContent() {
    if (_isLoading) return _buildLoadingState();
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: AppColors.closedLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.error_outline_rounded,
                    color: AppColors.accent, size: 34),
              ),
              const SizedBox(height: 14),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: AppColors.textMuted, fontSize: 14),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadProducts,
                icon: const Icon(Icons.refresh_rounded,
                    color: Colors.white, size: 16),
                label: const Text("Réessayer",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      );
    }
    return PageView(
      controller: _pageController,
      onPageChanged: (i) => setState(() => _currentPage = i),
      children: [
        _buildProductList(),
        _buildCategoryList(),
        _buildStoreView(),
      ],
    );
  }

  // ── Liste produits ─────────────────────────────────────────────────────────
  Widget _buildProductList() {
    final list = _filteredProducts;
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.local_offer_outlined,
                  size: 32, color: AppColors.primary),
            ),
            const SizedBox(height: 14),
            const Text(
              "Tous vos produits sont en promotion",
              style: TextStyle(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: 14),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: list.length,
      itemBuilder: (context, i) {
        final p = list[i];
        return _buildProductRow(p);
      },
    );
  }

  Widget _buildProductRow(_ProductItem p) {
    return GestureDetector(
      onTap: () => _onProductToggled(p, !p.isSelected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: p.isSelected
              ? AppColors.primary.withOpacity(0.05)
              : AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: p.isSelected
                ? AppColors.primary.withOpacity(0.3)
                : Colors.grey.shade100,
            width: p.isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 52,
                    height: 52,
                    color: AppColors.surface,
                    child: p.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                      imageUrl: _getThumbnailUrl(p.imageUrl),
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey,
                          size: 20),
                    )
                        : const Icon(Icons.inventory_2_outlined,
                        color: AppColors.primary, size: 22),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),

            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: p.isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          p.category,
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "${p.price.toInt()} FCFA",
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.priceGreen,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Checkbox custom
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: p.isSelected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: p.isSelected
                      ? AppColors.primary
                      : Colors.grey.shade300,
                  width: 1.5,
                ),
              ),
              child: p.isSelected
                  ? const Icon(Icons.check_rounded,
                  color: Colors.white, size: 15)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // ── Liste catégories ───────────────────────────────────────────────────────
  Widget _buildCategoryList() {
    if (_categoryList.isEmpty) {
      return const Center(
        child: Text("Aucune catégorie disponible",
            style: TextStyle(color: AppColors.textMuted)),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _categoryList.length,
      itemBuilder: (context, i) {
        final c = _categoryList[i];
        final int count =
            _products.where((p) => p.category == c.name).length;
        final int selectedInCat = _products
            .where((p) => p.category == c.name && p.isSelected)
            .length;

        return GestureDetector(
          onTap: () => _onCategoryToggled(c, !c.isSelected),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.only(bottom: 10),
            padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: c.isSelected
                  ? AppColors.primary.withOpacity(0.05)
                  : AppColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: c.isSelected
                    ? AppColors.primary.withOpacity(0.3)
                    : Colors.grey.shade100,
                width: c.isSelected ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: c.isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.category_outlined,
                    size: 20,
                    color: c.isSelected
                        ? AppColors.primary
                        : Colors.grey.shade400,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: c.isSelected
                              ? AppColors.primary
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      // Barre de progression sélection
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: count == 0
                                    ? 0
                                    : selectedInCat / count,
                                minHeight: 4,
                                backgroundColor: Colors.grey.shade100,
                                color: AppColors.priceGreen,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "$selectedInCat/$count",
                            style: TextStyle(
                              fontSize: 11,
                              color: selectedInCat > 0
                                  ? AppColors.priceGreen
                                  : AppColors.textMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color:
                    c.isSelected ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: c.isSelected
                          ? AppColors.primary
                          : Colors.grey.shade300,
                      width: 1.5,
                    ),
                  ),
                  child: c.isSelected
                      ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 15)
                      : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Vue boutique entière ───────────────────────────────────────────────────
  Widget _buildStoreView() {
    final bool isAllSelected =
        _products.isNotEmpty && _products.every((p) => p.isSelected);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icône animée
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: isAllSelected
                  ? AppColors.primary.withOpacity(0.08)
                  : AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: isAllSelected
                    ? AppColors.primary.withOpacity(0.3)
                    : Colors.grey.shade200,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.storefront_rounded,
              size: 42,
              color: isAllSelected ? AppColors.primary : Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            "OFFRE GÉNÉRALE",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Appliquer la promotion à l'ensemble des ${_products.length} produits de votre quincaillerie.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 10),

          // Badge compteur sélection
          if (_selectionCount > 0)
            Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.greenLight,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.statusOpen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "$_selectionCount produit${_selectionCount > 1 ? 's' : ''} sélectionné${_selectionCount > 1 ? 's' : ''}",
                    style: const TextStyle(
                      color: AppColors.greenDark,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 28),

          // Bouton toggle boutique entière
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _toggleAllStore,
              icon: Icon(
                isAllSelected
                    ? Icons.remove_circle_outline_rounded
                    : Icons.add_circle_outline_rounded,
                color: Colors.white,
                size: 18,
              ),
              label: Text(
                isAllSelected
                    ? "DÉSELECTIONNER TOUT"
                    : "SÉLECTIONNER TOUTE LA BOUTIQUE",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  letterSpacing: 0.3,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                isAllSelected ? AppColors.accent : AppColors.primary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Barre action bas ───────────────────────────────────────────────────────
  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -5)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Résumé compact
          if (_selectionCount > 0)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$_selectionCount produit${_selectionCount > 1 ? 's' : ''} sélectionné${_selectionCount > 1 ? 's' : ''}",
                    style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500),
                  ),
                  if (_discount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.closedLight,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        "-${_discount.toStringAsFixed(0)}% de remise",
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: _isSubmitting
                  ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.local_offer_rounded,
                  color: Colors.white, size: 18),
              label: Text(
                _isSubmitting
                    ? "Activation en cours..."
                    : "ACTIVER POUR $_selectionCount PRODUIT(S)",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 14,
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
        ],
      ),
    );
  }

  // ── Loading skeleton ───────────────────────────────────────────────────────
  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        height: 72,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 11,
                    width: 110,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Container(
                    height: 9,
                    width: 70,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}