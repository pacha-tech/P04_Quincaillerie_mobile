import 'package:brixel/pages/ProfilePage.dart';
import 'package:brixel/pages/pageVendeur/AddProductPage.dart';
import 'package:flutter/material.dart';

class DashboardVendeur extends StatelessWidget {
  const DashboardVendeur({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface, // On utilise la surface du thème
      drawer: _buildModernDrawer(context),
      body: CustomScrollView(
        slivers: [
          // --- APP BAR AVEC TES COULEURS ---
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            elevation: 0,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
              title: Text(
                "Dashboard Vendeur",
                style: TextStyle(
                  color: colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Petit motif décoratif en fond
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Icon(Icons.store, size: 150, color: colorScheme.onPrimary.withOpacity(0.1)),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage())),
                icon: const Icon(Icons.account_circle_outlined),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- RÉSUMÉ DES PERFORMANCES ---
                  _buildSectionTitle(context, "Aujourd'hui"),
                  const SizedBox(height: 15),

                  // Cartes de statistiques horizontales
                  SizedBox(
                    height: 130,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _buildStatCard(context, "Ventes", "145k F", Icons.payments_outlined, Colors.green),
                        _buildStatCard(context, "Commandes", "12", Icons.shopping_bag_outlined, colorScheme.primary),
                        _buildStatCard(context, "Stock Bas", "04", Icons.warning_amber_rounded, Colors.red),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- ACTIONS PRINCIPALES (Tes Couleurs : Marron/Orange) ---
                  _buildSectionTitle(context, "Actions rapides"),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      _buildActionCard(
                        context,
                        "Ajouter un\nproduit",
                        Icons.add_circle_outline,
                        colorScheme.primary, // Marron
                            () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddProductPage())),
                      ),
                      const SizedBox(width: 15),
                      _buildActionCard(
                        context,
                        "Nouvelle\nfacture",
                        Icons.receipt_long_outlined,
                        const Color(0xFFF9A825), // Ton orange spécifique
                            () {},
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // --- FLUX D'ACTIVITÉ ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle(context, "Activité récente"),
                      TextButton(
                        onPressed: () {},
                        child: Text("Voir tout", style: TextStyle(color: colorScheme.primary)),
                      ),
                    ],
                  ),
                  _buildActivityList(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- ÉLÉMENTS DE DESIGN ---

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary.withOpacity(0.8),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 28),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 10),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityList(BuildContext context) {
    return Column(
      children: [
        _activityItem("Vente : Marteau 500g", "Il y a 5 min", "3 500 F", Colors.green),
        _activityItem("Stock : Pointes 10cm", "Stock épuisé", "Alerte", Colors.red),
        _activityItem("Commande #1240", "En attente", "12 000 F", Colors.orange),
      ],
    );
  }

  Widget _activityItem(String title, String subtitle, String value, Color statusColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: statusColor.withOpacity(0.1),
            child: Icon(Icons.history, color: statusColor, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
              ],
            ),
          ),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: statusColor)),
        ],
      ),
    );
  }

  Widget _buildModernDrawer(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(color: colorScheme.primary),
            accountName: const Text("Armel Vendeur", style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: const Text("quincaillerie.armel@brixel.com"),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.store, color: Color(0xFFF9A825)),
            ),
          ),
          ListTile(
            leading: Icon(Icons.dashboard_outlined, color: colorScheme.primary),
            title: const Text("Dashboard"),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.inventory_2_outlined),
            title: const Text("Produits"),
            onTap: () {},
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Déconnexion", style: TextStyle(color: Colors.red)),
            onTap: () {},
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}