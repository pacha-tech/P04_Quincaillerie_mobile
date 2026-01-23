import 'package:flutter/material.dart';

class HelpAndLegalPage extends StatefulWidget {
  final String? initialSection;

  const HelpAndLegalPage({super.key, this.initialSection});

  @override
  State<HelpAndLegalPage> createState() => _HelpAndLegalPageState();
}

class _HelpAndLegalPageState extends State<HelpAndLegalPage> {
  final GlobalKey _aboutKey    = GlobalKey();
  final GlobalKey _termsKey    = GlobalKey();
  final GlobalKey _deliveryKey = GlobalKey();
  final GlobalKey _returnsKey  = GlobalKey();
  final GlobalKey _helpKey     = GlobalKey();

  // Pour savoir quelle section est "active" (soulignement)
  String? _activeSection;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollTo(widget.initialSection);
      if (widget.initialSection != null) {
        setState(() => _activeSection = widget.initialSection);
      }
    });
  }

  void _scrollTo(String? section) {
    if (section == null) return;

    GlobalKey? key;
    switch (section) {
      case 'about':    key = _aboutKey;    break;
      case 'terms':    key = _termsKey;    break;
      case 'delivery': key = _deliveryKey; break;
      case 'returns':  key = _returnsKey;  break;
      case 'help':     key = _helpKey;     break;
      default: return;
    }

    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
        alignment: 0.0,
      );
      setState(() => _activeSection = section);
    }
  }

  Widget _buildMenuItem(String label, String section) {
    final bool isActive = _activeSection == section;
    return GestureDetector(
      onTap: () => _scrollTo(section),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isActive ? const Color(0xFF795548) : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xFF795548) : Colors.grey[700],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _section(GlobalKey key, String title, String content, String sectionId) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4A2C1F),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          content,
          style: const TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(height: 48),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Aide & Informations légales"),
        backgroundColor: const Color(0xFF795548),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Menu sommaire fixe (horizontal scrollable si besoin)
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildMenuItem("À propos", "about"),
                  _buildMenuItem("Conditions", "terms"),
                  _buildMenuItem("Livraison", "delivery"),
                  _buildMenuItem("Retours", "returns"),
                  _buildMenuItem("Aide", "help"),
                ],
              ),
            ),
          ),

          // Contenu scrollable
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _section(_aboutKey, "À propos de QuincaMarket",
                      "QuincaMarket est la première marketplace dédiée à la quincaillerie et aux matériaux de construction au Cameroun. Nous connectons les quincailleries locales avec des artisans, entrepreneurs et particuliers à travers tout le pays, en facilitant l'accès à des outils de qualité à des prix compétitifs.",
                      'about'),

                  _section(_termsKey, "Conditions générales d'utilisation",
                      "En utilisant la plateforme QuincaMarket, vous acceptez les présentes conditions générales. Les ventes sont régies par la législation camerounaise. Les vendeurs sont responsables de la description exacte des produits. Tout litige sera soumis aux tribunaux compétents de Douala. Nous nous réservons le droit de suspendre un compte en cas de fraude ou non-respect des règles.",
                      'terms'),

                  _section(_deliveryKey, "Livraison",
                      "Nous proposons la livraison dans toutes les régions du Cameroun via des partenaires fiables (motos, camions, services postaux). Délais moyens : 2-5 jours ouvrables selon la zone. Frais de livraison calculés automatiquement au panier selon le poids, le volume et la destination. Possibilité de livraison express dans certaines villes (supplément). Suivi disponible via votre compte.",
                      'delivery'),

                  _section(_returnsKey, "Retour et remboursement",
                      "Vous disposez de 7 jours calendaires après réception pour initier un retour (produit non utilisé, emballage intact, étiquettes présentes). Le retour est à votre charge sauf en cas d'erreur du vendeur ou produit défectueux. Remboursement intégral (hors frais de retour) sous 10-14 jours après réception et vérification du produit par le vendeur. Contactez le vendeur directement via la messagerie pour lancer la procédure.",
                      'returns'),

                  _section(_helpKey, "Centre d’aide – Questions fréquentes",
                      "• Comment suivre ma commande ? → Via votre compte → Mes commandes\n"
                          "• Que faire si le produit est défectueux ? → Contactez le vendeur dans les 48h + photos\n"
                          "• Comment contacter un vendeur ? → Via la messagerie de la fiche produit\n"
                          "• Problème de paiement ? → Vérifiez Orange Money / MTN MoMo\n"
                          "• Autre question ? Écrivez-nous à market@gmail.com ou appelez +237 6XX XXX XXX",
                      'help'),

                  const SizedBox(height: 80), // espace final
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}