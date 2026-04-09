import 'package:brixel/ui/pages/ConversationPage.dart';
import 'package:brixel/ui/pages/pageVendeur/DashbordVendeur.dart';
import 'package:brixel/ui/pages/pageVendeur/StockPage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/authPages/client/LoginPage.dart';
import '../pages/authPages/client/RegisterPage.dart';
import '../pages/HomePage.dart';
import '../../provider/UserProvider.dart';
// Importe tes pages vendeurs ici
// import '../pages/vendeur/DashboardPage.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});


  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  late ColorScheme colorScheme;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final provider = context.read<UserProvider>();

    if (provider.isAuthenticated && (provider.role == null || provider.role!.isEmpty)) {
      provider.refreshUser();
    }
  }


  @override
  Widget build(BuildContext context) {

    colorScheme = Theme.of(context).colorScheme;

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
        const StockPage(),
        const Center(child: Text("Commandes Reçues")),
        ConversationPage(),
      ];

      navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.inventory), label: 'Stock'),
        BottomNavigationBarItem(icon: Icon(Icons.receipt_long), label: 'ventes'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Discussions'),
      ];
    } else if(role == "CLIENT"){
      // --- CONFIGURATION CLIENT / GUEST ---
      pages = [
        const HomePage(),
        const Center(child: Text("Favoris")),
        //const LoginPage(),
        const Center(child: Text("Quincaillerie")),
        //const RegisterPage(page: HomePage(), label: ""),
        ConversationPage(),

      ];

      navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
        //BottomNavigationBarItem(icon: Icon(Icons.propane_tank_outlined), label: 'Projet'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Favoris'),
        BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Quincaillerie'),
        //BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Discussion'),
      ];
    }else{
      pages = [
        const HomePage(),
        const Center(child: Text("Favoris")), // Ou LoginPage() selon ton besoin
        //const LoginPage(),
        const Center(child: Text("Quincaillerie")),
        //const RegisterPage(page: HomePage(), label: ""),
        const Center(child: Text("Discussion")),
      ];

      navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoris'),
        BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Quincaillerie'),
        BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Discussions'),
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
        selectedItemColor: colorScheme.secondary,
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