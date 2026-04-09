import 'package:brixel/data/modele/QuincaillerieDetail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../theme/AppColors.dart';


class QuincaillerieInfoSheet extends StatelessWidget {
  final QuincaillerieDetail store;

  const QuincaillerieInfoSheet({super.key, required this.store});

  static void show(BuildContext context, QuincaillerieDetail store) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuincaillerieInfoSheet(store: store),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.92,
      minChildSize: 0.4,
      builder: (_, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                controller: scrollController,
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 20),
                    _buildRatingBar(),
                    const SizedBox(height: 20),
                    if (store.description != null &&
                        store.description!.isNotEmpty) ...[
                      _buildSectionTitle("À propos"),
                      const SizedBox(height: 8),
                      Text(
                        store.description!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textMuted,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    _buildSectionTitle("Coordonnées & Localisation"),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.phone_rounded,    "Téléphone", store.telephone, AppColors.infoPhone),
                    _buildInfoRow(Icons.location_city_rounded, "Ville", store.ville,  AppColors.infoVille),
                    _buildInfoRow(Icons.map_rounded,      "Quartier",  store.quartier, AppColors.infoQuartier),
                    _buildInfoRow(Icons.place_rounded,    "Précision", store.precision,AppColors.infoPrecision),
                    _buildInfoRow(Icons.public_rounded,   "Région",    store.region,   AppColors.infoRegion),
                    const SizedBox(height: 24),
                    _buildCallButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CachedNetworkImage(
            imageUrl: store.photoUrl,
            width: 72,
            height: 72,
            fit: BoxFit.cover,
            errorWidget: (_, __, ___) => Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.store_rounded,
                  color: AppColors.accent, size: 32),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                store.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              _buildStatusBadge(store.status),
            ],
          ),
        ),
      ],
    );
  }

  // ── Rating ────────────────────────────────────────────────────────────────
  Widget _buildRatingBar() {
    final double rating = store.averageRating.toDouble();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.starBgWarm,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ...List.generate(5, (i) => Icon(
            i < rating.floor()
                ? Icons.star_rounded
                : (i < rating
                ? Icons.star_half_rounded
                : Icons.star_outline_rounded),
            color: AppColors.starYellow,
            size: 22,
          )),
          const SizedBox(width: 8),
          Text(
            store.averageRating.toStringAsFixed(1),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: AppColors.starTextBrown,
            ),
          ),
        ],
      ),
    );
  }

  // ── Ligne info ────────────────────────────────────────────────────────────
  Widget _buildInfoRow(
      IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  // ── Badge statut ──────────────────────────────────────────────────────────
  Widget _buildStatusBadge(String status) {
    final bool isOpen =
        status.toLowerCase() == 'ouvert' || status.toLowerCase() == 'open';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen ? AppColors.greenLight : AppColors.closedLight,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isOpen ? AppColors.statusOpen : AppColors.statusClosed,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            isOpen ? "Ouvert" : "Fermé",
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: isOpen ? AppColors.greenDark : AppColors.closedDark,
            ),
          ),
        ],
      ),
    );
  }

  // ── Titre section ─────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: Colors.grey,
        letterSpacing: 1.1,
      ),
    );
  }

  // ── Bouton appel ──────────────────────────────────────────────────────────
  Widget _buildCallButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        icon: const Icon(Icons.call_rounded, size: 18),
        label: Text("Appeler ${store.telephone}"),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.callGreen,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
      ),
    );
  }
}