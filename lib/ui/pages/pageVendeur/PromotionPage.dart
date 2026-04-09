/*
import 'package:brixel/Exception/NoInternetConnectionException.dart';
import 'package:flutter/material.dart';
import 'package:brixel/service/PromotionService.dart';
import '../../../Exception/ProductNotFoundException.dart';
import '../../../data/modele/Promotion.dart';
import '../../../main.dart';
import 'AddPromotionPage.dart';

class PromotionPage extends StatefulWidget {
  const PromotionPage({super.key});

  @override
  State<PromotionPage> createState() => _PromotionPageState();
}

class _PromotionPageState extends State<PromotionPage> with RouteAware {
  final PromotionService _promotionService = PromotionService();

  List<Promotion> _allPromotions = [];
  bool _isLoading = true;
  String? _errorMessage;
  late ColorScheme colorScheme;

  int _selectedFilterIndex = 0;

  @override
  void initState() {
    super.initState();
    _fetchPromotions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final modalRoute = ModalRoute.of(context);
    if (modalRoute != null) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void didPopNext() {

    setState(() {
      _fetchPromotions();
    });
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  Future<void> _fetchPromotions() async {
    try {
      final data = await _promotionService.getAllPromotion();
      if (mounted) {
        setState(() {
          _allPromotions = data;
          _isLoading = false;
        });
      }
    } on NoInternetConnectionException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    } on ProductNotFoundException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Erreur de chargement des promotions.";
          _isLoading = false;
        });
      }
    }
  }

  String _formatTaux(dynamic taux) {
    double value = double.tryParse(taux.toString()) ?? 0.0;
    return value % 1 == 0 ? value.toInt().toString() : value.toString();
  }

  @override
  Widget build(BuildContext context) {
    colorScheme = Theme.of(context).colorScheme;

    final filteredPromotions = _allPromotions.where((p) {
      if (_selectedFilterIndex == 0) return p.estActif;
      if (_selectedFilterIndex == 2) return !p.estActif;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          "Mes Promotions",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        centerTitle: true,
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchPromotions();
            },
            icon: const Icon(Icons.refresh_rounded),
          )
        ],
      ),
      body: Column(
        children: [
          _buildFilterBar(),
          Expanded(
            child: _buildContent(filteredPromotions),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPromotionPage()),
          );
        },
        backgroundColor: colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
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
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (val) => setState(() => _selectedFilterIndex = index),
      selectedColor: colorScheme.secondary,
      backgroundColor: const Color(0xFFF0F2F5),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black54,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide.none,
      elevation: isSelected ? 4 : 0,
      pressElevation: 0,
    );
  }

  Widget _buildContent(List<Promotion> promos) {
    if (_isLoading) {
      return Center(
          child: CircularProgressIndicator(color: colorScheme.secondary));
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Colors.redAccent, size: 60),
            const SizedBox(height: 16),
            Text(_errorMessage!,
                style: const TextStyle(color: Colors.grey)),
            TextButton(
                onPressed: _fetchPromotions,
                child: const Text("Réessayer"))
          ],
        ),
      );
    }

    if (promos.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
      itemCount: promos.length,
      itemBuilder: (context, index) => _buildPromotionCard(promos[index]),
    );
  }

  Widget _buildPromotionCard(Promotion promo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Column(
          children: [
            // ── Partie haute : taux + infos + menu ──
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  // Cercle taux
                  Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: promo.estActif
                            ? [colorScheme.primary, colorScheme.secondary]
                            : [Colors.grey.shade400, Colors.grey.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "-${_formatTaux(promo.taux)}%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Infos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                promo.nom,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: Color(0xFF2D3436),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert,
                                  color: Colors.grey),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  // Action modifier
                                } else if (value == 'cancel') {
                                  // Action annuler
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem<String>(
                                  value: 'edit',
                                  child: ListTile(
                                    leading: Icon(Icons.edit_outlined,
                                        size: 20),
                                    title: Text('Modifier'),
                                    contentPadding: EdgeInsets.zero,
                                    horizontalTitleGap: 0,
                                  ),
                                ),
                                if (promo.estActif)
                                  const PopupMenuItem<String>(
                                    value: 'cancel',
                                    child: ListTile(
                                      leading: Icon(Icons.cancel_outlined,
                                          size: 20,
                                          color: Colors.redAccent),
                                      title: Text('Annuler',
                                          style: TextStyle(
                                              color: Colors.redAccent)),
                                      contentPadding: EdgeInsets.zero,
                                      horizontalTitleGap: 0,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_month_outlined,
                                    size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  "${promo.dateDebut} — ${promo.dateFin}",
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 13,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ],
                            ),
                            _buildStatusBadge(promo.estActif),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Séparateur ──
            Divider(height: 1, color: Colors.grey.withOpacity(0.12)),

            // ── Partie basse : nbreProduits ──
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: promo.estActif
                          ? colorScheme.primary.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      size: 16,
                      color: promo.estActif
                          ? colorScheme.primary
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 8),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "${promo.nbreProduits ?? 0} ",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                            color: promo.estActif
                                ? colorScheme.primary
                                : Colors.grey,
                          ),
                        ),
                        TextSpan(
                          text: (promo.nbreProduits ?? 0) > 1
                              ? "produits concernés"
                              : "produit concerné",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
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

  Widget _buildStatusBadge(bool estActif) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: estActif
            ? const Color(0xFFE3F2FD)
            : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            estActif ? Icons.bolt_rounded : Icons.check_circle_rounded,
            size: 14,
            color: estActif ? Colors.blueAccent : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            estActif ? "ACTIF" : "TERMINÉ",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: estActif ? Colors.blueAccent : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10)
              ],
            ),
            child: Icon(Icons.local_offer_outlined,
                size: 60, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 20),
          const Text(
            "Aucune promotion trouvée",
            style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            "Créez votre première promotion pour booster vos ventes !",
            style: TextStyle(color: Colors.grey, fontSize: 13),
            textAlign: TextAlign.center,
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
import '../../../main.dart';
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