import 'package:flutter/material.dart';

class BecomeSellerStep3Page extends StatefulWidget {
  // On peut passer les données des étapes précédentes si besoin plus tard
  const BecomeSellerStep3Page({super.key});

  @override
  State<BecomeSellerStep3Page> createState() => _BecomeSellerStep3PageState();
}

class _BecomeSellerStep3PageState extends State<BecomeSellerStep3Page> {
  final _formKey = GlobalKey<FormState>();

  final _nuiController = TextEditingController();

  bool _acceptTerms = false;
  bool _wantTips = false;

  @override
  void dispose() {
    _nuiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // même fond que les étapes précédentes
      appBar: AppBar(
        title: const Text("Devenir vendeur – Étape 3"),
        backgroundColor: const Color(0xFF795548),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Titre principal (cohérent avec étapes 1 et 2)
                const Text(
                  "Vendez sur QuincaMarket",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A2C1F),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),

                Text(
                  "Rejoignez la première marketplace de quincaillerie au Cameroun\net développez votre activité",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Barre de progression des étapes
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStepIndicator("1", true),   // terminée
                    _buildStepConnector(true),
                    _buildStepIndicator("2", true),   // terminée
                    _buildStepConnector(true),
                    _buildStepIndicator("3", true),   // actuelle
                  ],
                ),
                const SizedBox(height: 35),

                // Titre de l'étape
                const Text(
                  "Document & validation",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A2C1F),
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  "Dernière étape avant validation",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 40),

                // Champ NUI (optionnel)
                TextFormField(
                  controller: _nuiController,
                  decoration: const InputDecoration(
                    labelText: "NUI (Optionnel)",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge_outlined),
                    hintText: "Numéro d’identification unique",
                  ),
                  keyboardType: TextInputType.number,
                  // Pas de validator → reste optionnel
                ),
                const SizedBox(height: 40),

                // Cases à cocher
                CheckboxListTile(
                  value: _acceptTerms,
                  onChanged: (bool? value) {
                    setState(() {
                      _acceptTerms = value ?? false;
                    });
                  },
                  title: const Text(
                    "J'accepte les conditions de confidentialité et la politique de confidentialité",
                    style: TextStyle(fontSize: 15),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: const Color(0xFFF9A825),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 8),

                CheckboxListTile(
                  value: _wantTips,
                  onChanged: (bool? value) {
                    setState(() {
                      _wantTips = value ?? false;
                    });
                  },
                  title: const Text(
                    "Je souhaite recevoir des conseils pour développer mes ventes",
                    style: TextStyle(fontSize: 15),
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: const Color(0xFFF9A825),
                  contentPadding: EdgeInsets.zero,
                ),
                const SizedBox(height: 48),

                // Boutons Précédent + Soumettre
                Row(
                  children: [
                    // Bouton Précédent
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFF9A825), width: 2),
                          foregroundColor: const Color(0xFF1F0404),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "Précédent",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Bouton Soumettre
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _acceptTerms
                            ? () {
                          if (_formKey.currentState!.validate()) {
                            // Ici : envoyer la demande complète (API, Firebase, etc.)
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Demande envoyée ! Nous vous contacterons bientôt."),
                                backgroundColor: Colors.green,
                              ),
                            );

                            // Option : revenir à l'accueil ou afficher une page de confirmation
                            // Navigator.popUntil(context, (route) => route.isFirst);
                          }
                        }
                            : null, // désactivé si conditions non acceptées
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF9A825),
                          foregroundColor: Colors.black87,
                          disabledBackgroundColor: Color(0xFFFBF5DE),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "Soumettre",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(String number, bool isActive) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFF9A825) : Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          number,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.black87 : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Container(
      width: 50,
      height: 3,
      color: isActive ? const Color(0xFFF9A825) : Colors.grey[300],
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}