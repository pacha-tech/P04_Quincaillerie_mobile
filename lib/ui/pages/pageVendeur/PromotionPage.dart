
/*
import 'package:brixel/Exception/NoInternetConnectionException.dart';
import 'package:flutter/material.dart';
import 'package:brixel/service/PromotionService.dart';
import '../../../Exception/ProductNotFoundException.dart';
import '../../../data/modele/Promotion.dart';
import '../../theme/AppColors.dart';
import 'AddPromotionPage.dart';

class PromotionPage extends StatefulWidget {
  const PromotionPage({super.key});

  @override
  State<PromotionPage> createState() => _PromotionPageState();
}

class _PromotionPageState extends State<PromotionPage> {
  final PromotionService _promotionService = PromotionService();

  List<Promotion> _allPromotions = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchPromotions();
  }

  Future<void> _fetchPromotions() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final data = await _promotionService.getAllPromotion();
      if (mounted) setState(() { _allPromotions = data; _isLoading = false; });
    } on NoInternetConnectionException catch (e) {
      if (mounted) setState(() { _errorMessage = e.message; _isLoading = false; });
    } on ProductNotFoundException catch (e) {
      if (mounted) setState(() { _errorMessage = e.message; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _errorMessage = "Erreur de chargement des promotions."; _isLoading = false; });
    }
  }

  String _formatTaux(dynamic taux) {
    final double value = double.tryParse(taux.toString()) ?? 0.0;
    return value % 1 == 0 ? value.toInt().toString() : value.toString();
  }

  List<Promotion> get _filtered => _allPromotions.where((p) {
    if (_selectedFilterIndex == 0) return p.estActif;
    if (_selectedFilterIndex == 2) return !p.estActif;
    return true;
  }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text("Mes Promotions",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _fetchPromotions,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildContent()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          /*
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPromotionPage()),
          );
          if (mounted) {
            _fetchPromotions();
          }
           */

          final hasChanged = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPromotionPage()),
          );
          if (hasChanged == true) {
            _fetchPromotions();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ── Barre de filtres ──────────────────────────────────────────────────────
  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 4)),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            _filterChip("En cours", 0),
            const SizedBox(width: 8),
            _filterChip("Tout", 1),
            const SizedBox(width: 8),
            _filterChip("Terminé", 2),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, int index) {
    final bool isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilterIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF0F2F5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [BoxShadow(
              color: AppColors.primary.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 3))]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ── Contenu ───────────────────────────────────────────────────────────────
  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                    color: AppColors.closedLight, shape: BoxShape.circle),
                child: const Icon(Icons.error_outline_rounded,
                    color: AppColors.statusClosed, size: 40),
              ),
              const SizedBox(height: 16),
              Text(_errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchPromotions,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text("Réessayer"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final promos = _filtered;
    if (promos.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: promos.length,
      itemBuilder: (_, i) => _buildPromotionCard(promos[i]),
    );
  }

  // ── Carte promotion ───────────────────────────────────────────────────────
  Widget _buildPromotionCard(Promotion promo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // ── Haut ─────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Badge taux — rectangle arrondi cohérent avec les autres cartes
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: promo.estActif
                          ? AppColors.primary
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        "-${_formatTaux(promo.taux)}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nom + badge + menu
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                promo.nom,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _buildStatusBadge(promo.estActif),
                            _buildMenu(promo),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Dates
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 12, color: Colors.grey[400]),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                "${promo.dateDebut} — ${promo.dateFin}",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Séparateur ────────────────────────────────────────────────
            Divider(height: 1, color: Colors.grey.withOpacity(0.1)),

            // ── Bas : nbreProduits ────────────────────────────────────────
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: promo.estActif
                          ? AppColors.primary.withOpacity(0.08)
                          : Colors.grey.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.inventory_2_outlined,
                        size: 15,
                        color: promo.estActif
                            ? AppColors.primary
                            : Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${promo.nbreProduits ?? 0} ",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: promo.estActif
                                ? AppColors.primary
                                : Colors.grey,
                          ),
                        ),
                        TextSpan(
                          text: (promo.nbreProduits ?? 0) > 1
                              ? "produits concernés"
                              : "produit concerné",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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

  // ── Badge statut ──────────────────────────────────────────────────────────
  Widget _buildStatusBadge(bool estActif) {
    return Container(
      margin: const EdgeInsets.only(right: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: estActif ? AppColors.greenLight : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: estActif ? AppColors.statusOpen : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            estActif ? "ACTIF" : "TERMINÉ",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: estActif ? AppColors.greenDark : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ── Menu 3 points ─────────────────────────────────────────────────────────
  Widget _buildMenu(Promotion promo) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'edit') {
          // Action modifier
        } else if (value == 'cancel') {
          // Action annuler
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem<String>(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit_outlined, size: 18),
            title: Text('Modifier', style: TextStyle(fontSize: 14)),
            contentPadding: EdgeInsets.zero,
            horizontalTitleGap: 8,
            dense: true,
          ),
        ),
        if (promo.estActif)
          const PopupMenuItem<String>(
            value: 'cancel',
            child: ListTile(
              leading: Icon(Icons.cancel_outlined,
                  size: 18, color: AppColors.statusClosed),
              title: Text('Annuler',
                  style: TextStyle(
                      color: AppColors.statusClosed, fontSize: 14)),
              contentPadding: EdgeInsets.zero,
              horizontalTitleGap: 8,
              dense: true,
            ),
          ),
      ],
    );
  }

  // ── État vide ─────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_offer_outlined,
                size: 52, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          const Text("Aucune promotion trouvée",
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16)),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              "Créez votre première promotion pour booster vos ventes !",
              style: TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
 */

import 'package:brixel/Exception/NoInternetConnectionException.dart';
import 'package:flutter/material.dart';
import 'package:brixel/service/PromotionService.dart';
import '../../../Exception/ProductNotFoundException.dart';
import '../../../data/modele/Promotion.dart';
import '../../theme/AppColors.dart';
import '../../widgets/SkeletonPulsar.dart';
import 'AddPromotionPage.dart';

class PromotionPage extends StatefulWidget {
  const PromotionPage({super.key});

  @override
  State<PromotionPage> createState() => _PromotionPageState();
}

class _PromotionPageState extends State<PromotionPage> {
  final PromotionService _promotionService = PromotionService();

  List<Promotion> _allPromotions = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchPromotions();
  }

  Future<void> _fetchPromotions() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final data = await _promotionService.getAllPromotion();
      if (mounted) setState(() { _allPromotions = data; _isLoading = false; });
    } on NoInternetConnectionException catch (e) {
      if (mounted) setState(() { _errorMessage = e.message; _isLoading = false; });
    } on ProductNotFoundException catch (e) {
      if (mounted) setState(() { _errorMessage = e.message; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() { _errorMessage = "Erreur de chargement des promotions."; _isLoading = false; });
    }
  }

  String _formatTaux(dynamic taux) {
    final double value = double.tryParse(taux.toString()) ?? 0.0;
    return value % 1 == 0 ? value.toInt().toString() : value.toString();
  }

  List<Promotion> get _filtered => _allPromotions.where((p) {
    if (_selectedFilterIndex == 0) return p.estActif;
    if (_selectedFilterIndex == 2) return !p.estActif;
    return true;
  }).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text("Mes Promotions",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _fetchPromotions,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(child: _buildContent()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final hasChanged = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPromotionPage()),
          );
          if (hasChanged == true) {
            _fetchPromotions();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // ── Barre de filtres ──────────────────────────────────────────────────────
  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
              color: Color(0x08000000),
              blurRadius: 8,
              offset: Offset(0, 4)),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            _filterChip("En cours", 0),
            const SizedBox(width: 8),
            _filterChip("Tout", 1),
            const SizedBox(width: 8),
            _filterChip("Terminé", 2),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, int index) {
    final bool isSelected = _selectedFilterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilterIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : const Color(0xFFF0F2F5),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [BoxShadow(
              color: AppColors.primary.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 3))]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ── Contenu ───────────────────────────────────────────────────────────────
  Widget _buildContent() {
    if (_isLoading) {
      // Affichage du Skeleton animé
      return SkeletonPulsar(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: 6, // 6 fausses cartes pour remplir l'écran
          itemBuilder: (_, __) => _buildSkeletonCard(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                    color: AppColors.closedLight, shape: BoxShape.circle),
                child: const Icon(Icons.error_outline_rounded,
                    color: AppColors.statusClosed, size: 40),
              ),
              const SizedBox(height: 16),
              Text(_errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _fetchPromotions,
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text("Réessayer"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final promos = _filtered;
    if (promos.isEmpty) return _buildEmptyState();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: promos.length,
      itemBuilder: (_, i) => _buildPromotionCard(promos[i]),
    );
  }

  // ── SKELETON CARTE (Même design exact que _buildPromotionCard) ────────────
  Widget _buildSkeletonCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Haut
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Faux Badge taux
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Faux Nom + badge
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 15,
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              width: 50,
                              height: 18,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            const SizedBox(width: 24), // Espace du menu
                          ],
                        ),
                        const SizedBox(height: 10),
                        // Fausses Dates
                        Container(
                          width: 140,
                          height: 12,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Séparateur
            Divider(height: 1, color: Colors.grey.withOpacity(0.1)),

            // Bas : Faux nbreProduits
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Container(
                    width: 27,
                    height: 27,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 110,
                    height: 13,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
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

  // ── Carte promotion ───────────────────────────────────────────────────────
  Widget _buildPromotionCard(Promotion promo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            // Haut
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Badge taux
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: promo.estActif
                          ? AppColors.primary
                          : Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        "-${_formatTaux(promo.taux)}%",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nom + badge + menu
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                promo.nom,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _buildStatusBadge(promo.estActif),
                            _buildMenu(promo),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Dates
                        Row(
                          children: [
                            Icon(Icons.calendar_today_outlined,
                                size: 12, color: Colors.grey[400]),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                "${promo.dateDebut} — ${promo.dateFin}",
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Séparateur
            Divider(height: 1, color: Colors.grey.withOpacity(0.1)),

            // Bas : nbreProduits
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: promo.estActif
                          ? AppColors.primary.withOpacity(0.08)
                          : Colors.grey.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.inventory_2_outlined,
                        size: 15,
                        color: promo.estActif
                            ? AppColors.primary
                            : Colors.grey),
                  ),
                  const SizedBox(width: 8),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${promo.nbreProduits ?? 0} ",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: promo.estActif
                                ? AppColors.primary
                                : Colors.grey,
                          ),
                        ),
                        TextSpan(
                          text: (promo.nbreProduits ?? 0) > 1
                              ? "produits concernés"
                              : "produit concerné",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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

  // ── Badge statut ──────────────────────────────────────────────────────────
  Widget _buildStatusBadge(bool estActif) {
    return Container(
      margin: const EdgeInsets.only(right: 2),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: estActif ? AppColors.greenLight : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: estActif ? AppColors.statusOpen : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            estActif ? "ACTIF" : "TERMINÉ",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: estActif ? AppColors.greenDark : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  // ── Menu 3 points ─────────────────────────────────────────────────────────
  Widget _buildMenu(Promotion promo) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, color: Colors.grey, size: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (value) {
        if (value == 'edit') {
          // Action modifier
        } else if (value == 'cancel') {
          // Action annuler
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem<String>(
          value: 'edit',
          child: ListTile(
            leading: Icon(Icons.edit_outlined, size: 18),
            title: Text('Modifier', style: TextStyle(fontSize: 14)),
            contentPadding: EdgeInsets.zero,
            horizontalTitleGap: 8,
            dense: true,
          ),
        ),
        if (promo.estActif)
          const PopupMenuItem<String>(
            value: 'cancel',
            child: ListTile(
              leading: Icon(Icons.cancel_outlined,
                  size: 18, color: AppColors.statusClosed),
              title: Text('Annuler',
                  style: TextStyle(
                      color: AppColors.statusClosed, fontSize: 14)),
              contentPadding: EdgeInsets.zero,
              horizontalTitleGap: 8,
              dense: true,
            ),
          ),
      ],
    );
  }

  // ── État vide ─────────────────────────────────────────────────────────────
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.local_offer_outlined,
                size: 52, color: AppColors.primary),
          ),
          const SizedBox(height: 20),
          const Text("Aucune promotion trouvée",
              style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 16)),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              "Créez votre première promotion pour booster vos ventes !",
              style: TextStyle(color: Colors.grey, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}