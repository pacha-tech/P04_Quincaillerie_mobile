import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/PromotionsPage.dart';
import '../pages/authPages/vendeur/become_seller_page.dart';
import '../pages/catalog_page.dart';
import '../pages/help_and_legal_page.dart';

class AppFooter extends StatelessWidget {
  final bool isloging;
  const AppFooter({super.key , required this.isloging});

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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15), // Réduit de 20 à 15
      decoration: const BoxDecoration(
        color: Color(0xFF795548),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if(!isloging)
            Column(
              children: [
                const Text(
                  "Vous avez une quincaillerie ?",
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold), // Réduit 20 -> 18
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4), // Réduit 5 -> 4
                const Text(
                  "Rejoignez QuincaMarket au Cameroun. Inscription gratuite.",
                  style: TextStyle(color: Colors.white70, fontSize: 14, height: 1.2), // Texte plus compact
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8), // Réduit 10 -> 8
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BecomeSellerPage())),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF9A825),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 2), // Moins de padding interne
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text("Commencer à vendre", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),

          const SizedBox(height: 12), // Réduit 20 -> 12
          const Divider(color: Colors.white24, thickness: 0.5),
          const SizedBox(height: 8),

          const Text(
            "QuincaMarket",
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            "La première marketplace de quincaillerie au Cameroun.",
            style: TextStyle(color: Colors.white70, fontSize: 13),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 15), // Réduit 24 -> 15

          // Réseaux sociaux - Rapprochement des icônes
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.facebook, color: Colors.white70, size: 28),
              SizedBox(width: 25), // Réduit 40 -> 25
              Icon(Icons.flutter_dash_outlined, color: Colors.white70, size: 28),
              SizedBox(width: 25),
              Icon(Icons.camera_alt, color: Colors.white70, size: 28),
            ],
          ),

          const SizedBox(height: 15),
          const Divider(color: Colors.white24, thickness: 0.5),

          // SERVICE CLIENT + CONTACT
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Service client", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8), // Réduit 16 -> 8
                      _footerLink("Centre d’aide", () => _goToHelpSection(context, 'help')),
                      _footerLink("Conditions générales", () => _goToHelpSection(context, 'terms')),
                      _footerLink("Livraison", () => _goToHelpSection(context, 'delivery')),
                      _footerLink("Retours", () => _goToHelpSection(context, 'returns')),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Contact", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      _contactRow(Icons.location_pin, "Douala, CMR"),
                      _contactRow(Icons.phone, "+237 6XX..."),
                      _contactRow(Icons.email, "market@gmail.com"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white24),
          const SizedBox(height: 8),

          // Liens rapides compressés
          const Text("Liens rapides", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 15, // Réduit 24 -> 15
            runSpacing: 5,  // Réduit 12 -> 5
            children: [
              _quickLink("Accueil", () => Navigator.popUntil(context, (route) => route.isFirst)),
              _quickLink("Catalogue", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CatalogPage()))),
              _quickLink("Promo", () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PromotionsPage()))),
              _quickLink("À propos", () => _goToHelpSection(context, 'about')),
            ],
          ),

          const SizedBox(height: 15),
          const Text("Paiements sécurisés", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          const Text("OM  •  MoMo", style: TextStyle(color: Colors.white70, fontSize: 13)),

          const SizedBox(height: 15), // Réduit 40 -> 15
          const Text("© 2026 QuincaMarket.", style: TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      ),
    );
  }

  // Petits helpers pour éviter les répétitions et réduire l'espace
  Widget _footerLink(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(onTap: onTap, child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12))),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12), overflow: TextOverflow.ellipsis)),
      ]),
    );
  }

  Widget _quickLink(String text, VoidCallback onTap) {
    return InkWell(onTap: onTap, child: Text(text, style: const TextStyle(color: Colors.white70, fontSize: 12)));
  }
}