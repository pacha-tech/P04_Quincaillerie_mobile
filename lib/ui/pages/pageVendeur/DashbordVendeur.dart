
import 'package:brixel/ui/pages/ProfilePage.dart';
import 'package:brixel/ui/pages/pageVendeur/AddProductPage.dart';
import 'package:brixel/ui/pages/pageVendeur/ProfileQuincailleriePage.dart';
import 'package:brixel/ui/pages/pageVendeur/PromotionPage.dart';
import 'package:brixel/ui/pages/pageVendeur/UpdateStockPage.dart';
import 'package:brixel/ui/theme/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/UserProvider.dart';
import '../../widgets/MainNavigation.dart';

class DashboardVendeur extends StatelessWidget {
  const DashboardVendeur({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      drawer: _buildDrawer(context),
      body: CustomScrollView(
        slivers: [
          // ── SliverAppBar ──────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 70,
            pinned: true,
            elevation: 0,
            backgroundColor: AppColors.primary,
            leading: Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu_rounded, color: Colors.white70, size: 22),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 52, bottom: 16),
              title: const Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Dashboard",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 17,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              background: Container(
                color: AppColors.primary,
                child: Stack(
                  children: [
                    Positioned(
                      right: -10,
                      top: -20,
                      child: Icon(
                        Icons.storefront_rounded,
                        size: 110,
                        color: Colors.white.withOpacity(0.04),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.account_circle_outlined,
                    color: Colors.white70, size: 24),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                ),
              ),
              const SizedBox(width: 4),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Stats du jour ───────────────────────────────────────
                  _buildSectionHeader("Aujourd'hui", Icons.today_rounded),
                  const SizedBox(height: 12),
                  _buildSummaryBanner(),
                  const SizedBox(height: 10),
                  SizedBox(
                    height: 116,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildStatCard(
                          label: "Ventes",
                          value: "145 000 F",
                          icon: Icons.payments_outlined,
                          color: AppColors.priceGreen,
                          trend: "+12%",
                          trendUp: true,
                        ),
                        _buildStatCard(
                          label: "Commandes",
                          value: "12",
                          icon: Icons.shopping_bag_outlined,
                          color: AppColors.infoVille,
                          trend: "+3",
                          trendUp: true,
                        ),
                        _buildStatCard(
                          label: "Stock Bas",
                          value: "04",
                          icon: Icons.warning_amber_rounded,
                          color: AppColors.accent,
                          trend: "Alertes",
                          trendUp: false,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 26),

                  // ── Actions rapides ─────────────────────────────────────
                  _buildSectionHeader("Actions rapides", Icons.bolt_rounded),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          label: "Ajouter\nun produit",
                          icon: Icons.add_circle_outline_rounded,
                          color: AppColors.primary,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AddProductPage()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionCard(
                          label: "Mettre à\njour le stock",
                          icon: Icons.inventory_2_outlined,
                          color: AppColors.priceGreen,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const UpdateStockPage()),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          label: "Nouvelle\npromotion",
                          icon: Icons.local_offer_rounded,
                          color: AppColors.accent,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => PromotionPage()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionCard(
                          label: "Ma\nboutique",
                          icon: Icons.storefront_rounded,
                          color: AppColors.infoVille,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ProfileQuincailleriePage()),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  // ── Activité récente ────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _buildSectionHeader(
                            "Activité récente", Icons.history_rounded),
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: const [
                              Text(
                                "Voir tout",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(width: 3),
                              Icon(Icons.arrow_forward_ios_rounded,
                                  size: 9, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildActivityList(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Banner résumé du jour ──────────────────────────────────────────────────
  Widget _buildSummaryBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildBannerStat(
            icon: Icons.trending_up_rounded,
            label: "CA du mois",
            value: "2,3M F",
            color: AppColors.priceGreen,
          ),
          _buildDivider(),
          _buildBannerStat(
            icon: Icons.star_rounded,
            label: "Note moy.",
            value: "4.7 ★",
            color: AppColors.starYellow,
          ),
          _buildDivider(),
          _buildBannerStat(
            icon: Icons.inventory_2_outlined,
            label: "Produits",
            value: "38",
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildBannerStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w900, color: color),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => Container(
    width: 0.5,
    height: 36,
    color: Colors.grey.shade200,
  );

  // ── En-tête de section ─────────────────────────────────────────────────────
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  // ── Carte stat ─────────────────────────────────────────────────────────────
  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required String trend,
    required bool trendUp,
  }) {
    return Container(
      width: 148,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: trendUp
                      ? AppColors.greenLight
                      : AppColors.closedLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: trendUp ? AppColors.greenDark : AppColors.closedDark,
                  ),
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
              Text(
                label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Carte action ───────────────────────────────────────────────────────────
  Widget _buildActionCard({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white38, size: 12),
          ],
        ),
      ),
    );
  }

  // ── Liste activité ─────────────────────────────────────────────────────────
  Widget _buildActivityList() {
    return Column(
      children: [
        _activityItem(
          title: "Vente · Marteau 500g",
          subtitle: "Il y a 5 min",
          value: "+3 500 F",
          icon: Icons.payments_outlined,
          color: AppColors.priceGreen,
        ),
        _activityItem(
          title: "Stock · Pointes 10cm",
          subtitle: "Stock épuisé",
          value: "Alerte",
          icon: Icons.warning_amber_rounded,
          color: AppColors.accent,
        ),
        _activityItem(
          title: "Commande #1240",
          subtitle: "En attente de confirmation",
          value: "12 000 F",
          icon: Icons.shopping_bag_outlined,
          color: AppColors.infoVille,
        ),
      ],
    );
  }

  Widget _activityItem({
    required String title,
    required String subtitle,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: color,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Drawer ─────────────────────────────────────────────────────────────────
  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.surface,
      width: 260,
      child: Column(
        children: [
          // ── Header drawer ─────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
            color: AppColors.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: Colors.white.withOpacity(0.2), width: 1.5),
                  ),
                  child: const Icon(Icons.store_rounded,
                      color: Colors.white, size: 28),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Armel Vendeur",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "quincaillerie.armel@brixel.com",
                  style: TextStyle(color: Colors.white54, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                // Badge statut ouvert
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                      const SizedBox(width: 5),
                      const Text(
                        "Boutique ouverte",
                        style: TextStyle(
                          color: AppColors.greenDark,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Liens navigation ──────────────────────────────────────
          _drawerItem(
            context,
            icon: Icons.local_offer_rounded,
            label: "Promotions",
            color: AppColors.accent,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => PromotionPage()),
            ),
          ),
          _drawerItem(
            context,
            icon: Icons.storefront_rounded,
            label: "Ma boutique",
            color: AppColors.primary,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ProfileQuincailleriePage()),
            ),
          ),
          _drawerItem(
            context,
            icon: Icons.inventory_2_outlined,
            label: "Mon stock",
            color: AppColors.priceGreen,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddProductPage()),
            ),
          ),
          _drawerItem(
            context,
            icon: Icons.account_circle_outlined,
            label: "Mon profil",
            color: AppColors.infoVille,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfilePage()),
            ),
          ),

          const Spacer(),

          // ── Séparateur + déconnexion ──────────────────────────────
          const Divider(height: 1, color: Colors.black12),
          _drawerItem(
            context,
            icon: Icons.logout_rounded,
            label: "Déconnexion",
            color: AppColors.accent,
            onTap: () => _handleSignOut(context),
            isDestructive: true,
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _drawerItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
        required VoidCallback onTap,
        bool isDestructive = false,
      }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: isDestructive
                ? AppColors.closedLight
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDestructive ? AppColors.accent : AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 11,
                color: Colors.grey.shade300,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSignOut(BuildContext context) async {
    await context.read<UserProvider>().signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
            (route) => false,
      );
    }
  }
}