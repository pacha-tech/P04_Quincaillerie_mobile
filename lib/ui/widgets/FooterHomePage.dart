
/*
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../pages/PromotionsPage.dart';
import '../pages/authPages/vendeur/RegisterVendeur1.dart';
import '../pages/CatalogPage.dart';
import '../pages/help_and_legal_page.dart';

class FooterHomePage extends StatelessWidget {
  final bool isloging;
  const FooterHomePage({super.key , required this.isloging});

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
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15), // Réduit de 20 à 15
      decoration: BoxDecoration(
        color: colorScheme.primary,
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
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterVendeur1())),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.secondary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 2), // Moins de padding interne
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                    child: const Text("Commencer à vendre", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  ),
                ),
                const Divider(color: Colors.white24, thickness: 0.5),

              ],
            ),



          const SizedBox(height: 8),

          const Text(
            "Brixel",
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
                      _contactRow(Icons.email, "brixel@gmail.com"),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white24),
          const SizedBox(height: 3),

          // Liens rapides compressés
          /*
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

           */
          const SizedBox(height: 3),
          const Text("© 2026 Brixel.", style: TextStyle(color: Colors.white54, fontSize: 11)),
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
 */

import 'package:flutter/material.dart';
import 'package:brixel/ui/theme/AppColors.dart';
import '../pages/PromotionsPage.dart';
import '../pages/authPages/vendeur/RegisterVendeur1.dart';
import '../pages/CatalogPage.dart';
import '../pages/help_and_legal_page.dart';

class FooterHomePage extends StatelessWidget {
  final bool isloging;
  const FooterHomePage({super.key, required this.isloging});

  void _goToHelpSection(BuildContext context, String section) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (_) => HelpAndLegalPage(initialSection: section)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      // Déborde légèrement pour coller aux bords de la ScrollView parente
      margin: const EdgeInsets.symmetric(horizontal: 0),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ── CTA vendeur ──────────────────────────────────────────
          if (!isloging) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.storefront_rounded,
                      color: Colors.white54, size: 28),
                  const SizedBox(height: 8),
                  const Text(
                    "Vous avez une quincaillerie ?",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Rejoignez Brixel au Cameroun. Inscription gratuite.",
                    style: TextStyle(
                        color: Colors.white54, fontSize: 12, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RegisterVendeur1()),
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white, size: 15),
                      label: const Text(
                        "Commencer à vendre",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accent,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildDivider(),
            const SizedBox(height: 20),
          ],

          // ── Logo & tagline ───────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: const Icon(Icons.construction_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              const Text(
                "Brixel",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            "La première marketplace de quincaillerie au Cameroun.",
            style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.4),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // ── Réseaux sociaux ──────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _socialIcon(Icons.facebook_rounded),
              const SizedBox(width: 20),
              _socialIcon(Icons.flutter_dash_outlined),
              const SizedBox(width: 20),
              _socialIcon(Icons.camera_alt_rounded),
            ],
          ),

          const SizedBox(height: 20),
          _buildDivider(),
          const SizedBox(height: 20),

          // ── Service client + Contact ─────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _footerSectionTitle("Service client"),
                    const SizedBox(height: 10),
                    _footerLink("Centre d'aide",
                            () => _goToHelpSection(context, 'help')),
                    _footerLink("Conditions générales",
                            () => _goToHelpSection(context, 'terms')),
                    _footerLink(
                        "Livraison",
                            () => _goToHelpSection(context, 'delivery')),
                    _footerLink(
                        "Retours", () => _goToHelpSection(context, 'returns')),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _footerSectionTitle("Contact"),
                    const SizedBox(height: 10),
                    _contactRow(Icons.location_on_rounded, "Douala, CMR"),
                    _contactRow(Icons.phone_rounded, "+237 6XX XXX XXX"),
                    _contactRow(Icons.email_rounded, "brixel@gmail.com"),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          _buildDivider(),
          const SizedBox(height: 14),

          // ── Liens rapides ────────────────────────────────────────
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 20,
            runSpacing: 6,
            children: [
              _quickLink("Accueil",
                      () => Navigator.popUntil(context, (r) => r.isFirst)),
              _quickLink(
                  "Catalogue",
                      () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const CatalogPage()))),
              _quickLink(
                  "Promotions",
                      () => Navigator.push(context,
                      MaterialPageRoute(
                          builder: (_) => const PromotionsPage()))),
              _quickLink(
                  "À propos", () => _goToHelpSection(context, 'about')),
            ],
          ),

          const SizedBox(height: 16),
          _buildDivider(),
          const SizedBox(height: 12),

          // ── Copyright ────────────────────────────────────────────
          const Text(
            "© 2026 Brixel · Tous droits réservés",
            style: TextStyle(color: Colors.white38, fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
  Widget _buildDivider() =>
      const Divider(color: Colors.white12, thickness: 0.5);

  Widget _footerSectionTitle(String text) => Text(
    text,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 13,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    ),
  );

  Widget _footerLink(String text, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: GestureDetector(
        onTap: onTap,
        child: Text(
          text,
          style: const TextStyle(color: Colors.white54, fontSize: 12, height: 1.3),
        ),
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Icon(icon, color: Colors.white38, size: 13),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickLink(String text, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white38,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Icon(icon, color: Colors.white54, size: 20),
    );
  }
}