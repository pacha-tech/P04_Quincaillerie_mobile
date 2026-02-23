import 'package:brixel/pages/pageVendeur/DashbordVendeur.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/authPages/client/LoginPage.dart';
import '../pages/authPages/client/RegisterPage.dart';
import '../pages/homePage/HomePage.dart';
import '../provider/UserProvider.dart';
// Importe tes pages vendeurs ici
// import '../pages/vendeur/DashboardPage.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 1. On écoute le UserProvider
    final userProvider = Provider.of<UserProvider>(context);
    final String role = userProvider.role ?? "GUEST";

    // 2. On définit les pages selon le rôle
    List<Widget> pages = [];
    List<BottomNavigationBarItem> navItems = [];

    if (role == "VENDEUR" || role == "ADMIN_STORE") {
      // --- CONFIGURATION VENDEUR ---
      pages = [
        const DashboardVendeur(),
        const Center(child: Text("Gestion Stock")),
        const Center(child: Text("Commandes Reçues")),
        const Center(child: Text("Profil Boutique")),
      ];

      navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Stock'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'Ventes'),
        BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Boutique'),
      ];
    } else {
      // --- CONFIGURATION CLIENT / GUEST ---
      pages = [
        const HomePage(),
        const Center(child: Text("Recherche")), // Ou LoginPage() selon ton besoin
        //const LoginPage(),
        const Center(child: Text("Historique")),
        //const RegisterPage(page: HomePage(), label: ""),
        const Center(child: Text("Profil")),
      ];

      navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Chercher'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historique'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ];
    }

    // 3. Affichage d'un loader si le rôle est en cours de récupération
    if (userProvider.status == AuthStatus.unknown) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      // On s'assure que l'index ne dépasse pas la taille de la liste
      body: pages[_selectedIndex < pages.length ? _selectedIndex : 0],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: role == "VENDEUR" ? Colors.orange : Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex < navItems.length ? _selectedIndex : 0,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: navItems,
      ),
    );
  }
}