import 'package:flutter/material.dart';

import 'become_seller_step3.dart';

class BecomeSellerStep2Page extends StatefulWidget {
  final String nom;
  final String prenom;
  final String email;
  final String telephone;

  const BecomeSellerStep2Page({
    super.key,
    required this.nom,
    required this.prenom,
    required this.email,
    required this.telephone,
  });

  @override
  State<BecomeSellerStep2Page> createState() => _BecomeSellerStep2PageState();
}

class _BecomeSellerStep2PageState extends State<BecomeSellerStep2Page> {
  final _formKey = GlobalKey<FormState>();

  final _nomBoutiqueController = TextEditingController();
  final _villeController = TextEditingController();
  final _adresseController = TextEditingController();
  final _quartierController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedRegion;

  // Liste des régions du Cameroun (tu peux en ajouter ou modifier)
  final List<String> regions = [
    "Centre",
    "Littoral",
    "Ouest",
    "Nord-Ouest",
    "Sud-Ouest",
    "Adamaoua",
    "Est",
    "Extrême-Nord",
    "Nord",
    "Sud",
  ];

  @override
  void dispose() {
    _nomBoutiqueController.dispose();
    _villeController.dispose();
    _adresseController.dispose();
    _quartierController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Devenir vendeur – Étape 2"),
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
                // Titre principal (cohérent avec étape 1)
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

                // Indicateur d'étapes
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStepIndicator("1", true),
                    _buildStepConnector(true),
                    _buildStepIndicator("2", true),
                    _buildStepConnector(false),
                    _buildStepIndicator("3", false),
                  ],
                ),
                const SizedBox(height: 35),

                const Text(
                  "Informations sur votre boutique",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4A2C1F),
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  "Décrivez votre commerce pour que les clients vous trouvent facilement",
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),

                // Champs du formulaire
                TextFormField(
                  controller: _nomBoutiqueController,
                  decoration: const InputDecoration(
                    labelText: "Nom de la boutique",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.storefront_outlined),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Veuillez entrer le nom de votre boutique";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  value: _selectedRegion,
                  decoration: const InputDecoration(
                    labelText: "Région",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.map_outlined),
                  ),
                  items: regions.map((String region) {
                    return DropdownMenuItem<String>(
                      value: region,
                      child: Text(region),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() => _selectedRegion = newValue);
                  },
                  validator: (value) {
                    if (value == null) {
                      return "Veuillez sélectionner une région";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _villeController,
                  decoration: const InputDecoration(
                    labelText: "Ville",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_city_outlined),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Veuillez entrer la ville";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _adresseController,
                  decoration: const InputDecoration(
                    labelText: "Adresse complète",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.home_outlined),
                    hintText: "Rue, numéro, bâtiment...",
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Veuillez entrer l'adresse complète";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _quartierController,
                  decoration: const InputDecoration(
                    labelText: "Quartier / Repères",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_searching_outlined),
                    hintText: "Ex : Carrefour Mvan, près de la station Total...",
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: "Description de la boutique",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description_outlined),
                    hintText: "Décrivez votre activité, vos spécialités, vos points forts...",
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Veuillez décrire votre boutique";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                // Boutons Précédent + Continuer
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFF9A825), width: 2),
                          foregroundColor: const Color(0xFF1F0404),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text(
                          "Précédent",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Ici tu peux passer à l'étape 3
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BecomeSellerStep3Page(),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF9A825),
                          foregroundColor: Colors.black87,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          elevation: 2,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text(
                          "Continuer",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
      width: 60,
      height: 3,
      color: isActive ? const Color(0xFFF9A825) : Colors.grey[300],
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}