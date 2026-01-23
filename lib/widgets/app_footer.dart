import 'package:flutter/material.dart';
import '../pages/PromotionsPage.dart';
import '../pages/become_seller_page.dart';
import '../pages/catalog_page.dart';
import '../pages/help_and_legal_page.dart'; // ← À AJOUTER (crée ce fichier ensuite)

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  void _goToHelpSection(BuildContext context, String section) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HelpAndLegalPage(initialSection: section),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF795548),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Bloc "Vous avez une quincaillerie ?"
          const Text(
            "Vous avez une quincaillerie ?",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          const Text(
            "Rejoignez QuincaMarket et touchez des milliers de clients au Cameroun.\n"
                "Inscription gratuite, commissions transparentes.",
            style: TextStyle(color: Colors.white70, fontSize: 15, height: 1.3),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BecomeSellerPage()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF9A825),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text(
                "Commencer à vendre",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 20),
          const Divider(color: Colors.white24, thickness: 0),
          const SizedBox(height: 10),

          // 2. QuincaMarket + description
          const Text(
            "QuincaMarket",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "La première marketplace de quincaillerie au Cameroun. Trouvez tous vos outils et matériaux de construction.",
            style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.4),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 24),

          // Réseaux sociaux
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.facebook, color: Colors.white70, size: 32),
              SizedBox(width: 40),
              Icon(Icons.flutter_dash_outlined, color: Colors.white70, size: 32),
              SizedBox(width: 40),
              Icon(Icons.camera_alt, color: Colors.white70, size: 32),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: Colors.white24, thickness: 0),
          const SizedBox(height: 10),

          // SERVICE CLIENT + CONTACT
          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service client
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Service client",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: () => _goToHelpSection(context, 'help'),
                        child: const Text("Centre d’aide", style: TextStyle(color: Colors.white70)),
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () => _goToHelpSection(context, 'terms'),
                        child: const Text("Conditions générales", style: TextStyle(color: Colors.white70)),
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () => _goToHelpSection(context, 'delivery'),
                        child: const Text("Livraison", style: TextStyle(color: Colors.white70)),
                      ),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () => _goToHelpSection(context, 'returns'),
                        child: const Text("Retour et remboursement", style: TextStyle(color: Colors.white70)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 1),

                // Contact (non cliquable pour l'instant)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        "Contact",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.location_pin, color: Colors.white70, size: 18),
                          SizedBox(width: 8),
                          Text("Douala, Cameroun", style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.phone, color: Colors.white70, size: 18),
                          SizedBox(width: 8),
                          Text("+237 6XX XXX XXX", style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(Icons.email, color: Colors.white70, size: 18),
                          SizedBox(width: 8),
                          Text("market@gmail.com", style: TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Divider(color: Colors.white24, thickness: 0),
          const SizedBox(height: 10),

          // Liens rapides
          const Text(
            "Liens rapides",
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 24,
            runSpacing: 12,
            children: [
              InkWell(
                onTap: () {
                  // Accueil → retourne à la home (pop jusqu'à la racine ou push replacement)
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text("Acceuil", style: TextStyle(color: Colors.white70, fontSize: 14)),
              ),
              InkWell(
                onTap: () {
                  // Catalogue → tu as déjà la page CatalogPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CatalogPage()),
                  );
                },
                child: const Text("Catalogue", style: TextStyle(color: Colors.white70, fontSize: 14)),
              ),
              InkWell(
                onTap: () {
                  // Promotion → tu as déjà PromotionsPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PromotionsPage()),
                  );
                },
                child: const Text("Promotion", style: TextStyle(color: Colors.white70, fontSize: 14)),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const BecomeSellerPage()),
                  );
                },
                child: const Text("Devenir vendeur", style: TextStyle(color: Colors.white70, fontSize: 14)),
              ),
              InkWell(
                onTap: () => _goToHelpSection(context, 'about'),
                child: const Text("À propos", style: TextStyle(color: Colors.white70, fontSize: 14)),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: Colors.white24, thickness: 0),
          const SizedBox(height: 10),

          // Paiements sécurisés
          const Text(
            "Paiements sécurisés",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          const Text(
            "Orange Money    •    MTN MoMo",
            style: TextStyle(color: Colors.white70, fontSize: 15),
          ),

          const SizedBox(height: 40),

          // Copyright
          const Text(
            "© 2025 QuincaMarket. Tous droits réservés.",
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}