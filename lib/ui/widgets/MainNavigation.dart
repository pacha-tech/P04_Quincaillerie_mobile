
import 'package:brixel/ui/pages/ConversationPage.dart';
import 'package:brixel/ui/pages/pageVendeur/DashbordVendeur.dart';
import 'package:brixel/ui/pages/pageVendeur/StockPage.dart';
import 'package:brixel/ui/theme/AppColors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/HomePage.dart';
import '../../provider/UserProvider.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<UserProvider>();
    if (provider.isAuthenticated &&
        (provider.role == null || provider.role!.isEmpty)) {
      provider.refreshUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final String role = userProvider.role ?? "GUEST";

    // ── Loader pendant récupération du rôle ────────────────────────
    if (userProvider.status == AuthStatus.unknown) {
      return const Scaffold(
        backgroundColor: AppColors.surface,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    List<Widget> pages = [];
    List<_NavItem> navItems = [];

    if (role == "VENDEUR" || role == "ADMIN_STORE") {
      pages = [
        const DashboardVendeur(),
        const StockPage(),
        const Center(child: Text("Commandes Reçues")),
        ConversationPage(),
      ];
      navItems = const [
        _NavItem(icon: Icons.dashboard_outlined,    activeIcon: Icons.dashboard_rounded,    label: 'Dashboard'),
        _NavItem(icon: Icons.inventory_2_outlined,  activeIcon: Icons.inventory_2_rounded,  label: 'Stock'),
        _NavItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long_rounded, label: 'Ventes'),
        _NavItem(icon: Icons.chat_bubble_outline,   activeIcon: Icons.chat_bubble_rounded,  label: 'Messages'),
      ];
    } else if (role == "CLIENT") {
      pages = [
        const HomePage(),
        const Center(child: Text("Favoris")),
        const Center(child: Text("Quincaillerie")),
        ConversationPage(),
      ];
      navItems = const [
        _NavItem(icon: Icons.home_outlined,            activeIcon: Icons.home_rounded,         label: 'Accueil'),
        _NavItem(icon: Icons.favorite_border_rounded,  activeIcon: Icons.favorite_rounded,     label: 'Favoris'),
        _NavItem(icon: Icons.store_outlined,           activeIcon: Icons.store_rounded,         label: 'Boutiques'),
        _NavItem(icon: Icons.chat_bubble_outline,      activeIcon: Icons.chat_bubble_rounded,  label: 'Messages'),
      ];
    } else {
      pages = [
        const HomePage(),
        const Center(child: Text("Favoris")),
        const Center(child: Text("Quincaillerie")),
        const Center(child: Text("Discussion")),
      ];
      navItems = const [
        _NavItem(icon: Icons.home_outlined,            activeIcon: Icons.home_rounded,         label: 'Accueil'),
        _NavItem(icon: Icons.favorite_border_rounded,  activeIcon: Icons.favorite_rounded,     label: 'Favoris'),
        _NavItem(icon: Icons.store_outlined,           activeIcon: Icons.store_rounded,         label: 'Boutiques'),
        _NavItem(icon: Icons.chat_bubble_outline,      activeIcon: Icons.chat_bubble_rounded,  label: 'Messages'),
      ];
    }

    final int safeIndex =
    _selectedIndex < pages.length ? _selectedIndex : 0;

    return Scaffold(
      body: pages[safeIndex],
      bottomNavigationBar: _buildBottomNav(navItems, safeIndex),
    );
  }

  // ── Bottom nav custom ──────────────────────────────────────────────────────
  Widget _buildBottomNav(List<_NavItem> items, int currentIndex) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              items.length,
                  (index) => _buildNavItem(
                item: items[index],
                index: index,
                isSelected: currentIndex == index,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required _NavItem item,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? item.activeIcon : item.icon,
              size: 22,
              color: isSelected ? AppColors.primary : Colors.grey.shade400,
            ),
            // Label animé — visible uniquement quand l'item est actif
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeInOut,
              child: isSelected
                  ? Padding(
                padding: const EdgeInsets.only(left: 6),
                child: Text(
                  item.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Modèle item ────────────────────────────────────────────────────────────
class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}