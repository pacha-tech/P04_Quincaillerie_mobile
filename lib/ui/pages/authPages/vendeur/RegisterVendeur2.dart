import 'package:flutter/material.dart';

import 'RegisterVendeur3.dart';

class RegisterVendeur2 extends StatefulWidget {
  final String nom;
  final String email;
  final String telephone;
  final String password;

  const RegisterVendeur2({
    super.key,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.password,
  });

  @override
  State<RegisterVendeur2> createState() => _RegisterVendeur2State();
}

class _RegisterVendeur2State extends State<RegisterVendeur2> {
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;

  final _nomBoutiqueController = TextEditingController();
  final _precisionController = TextEditingController(); // anciennement quartier → précision
  final _descriptionController = TextEditingController();

  String? _selectedRegion;
  String? _selectedVille;
  String? _selectedQuartier;

  // Données en cascade (région → villes → quartiers)
  final Map<String, Map<String, List<String>>> _locations = {
    "Centre": {
      "Yaoundé": [
        "Bastos",
        "Mvan",
        "Ngoa-Ekelle",
        "Essos",
        "Efoulan",
        "Messa",
        "Carrefour EMANA",
        "Obili",
      ],
      "Mbalmayo": ["Nkolfoulou", "Ngat", "Centre-ville"],
      "Bafia": ["Quartier Administratif", "Marché Central"],
    },
    "Littoral": {
      "Douala": [
        "Bonanjo",
        "Akwa",
        "Bonapriso",
        "Deido",
        "New Bell",
        "Bali",
        "Makepe",
      ],
      "Edéa": ["Quartier Nkolo", "Centre-ville"],
      "Nkongsamba": ["Quartier Haoussa", "Marché central"],
    },
    "Ouest": {
      "Bafoussam": ["Djeleng", "Marché A", "Tchatchoua"],
      "Dschang": ["Carrefour TSF", "Fiala-Foreke"],
      "Mbouda": ["Quartier Marché"],
    },
    // Ajoute les autres régions quand tu veux (pour l'instant minimal)
    "Nord-Ouest": {"Bamenda": ["Commercial Avenue", "Up Station"]},
    "Sud-Ouest": {"Buea": ["Molyko", "Mile 17"]},
    "Adamaoua": {"Ngaoundéré": ["Quartier Sabongari"]},
    "Est": {"Bertoua": ["Quartier Domayo"]},
    "Extrême-Nord": {"Maroua": ["Domayo"]},
    "Nord": {"Garoua": ["Quartier Pitoa"]},
    "Sud": {"Ebolowa": ["Quartier Grand Marché"]},
  };

  @override
  void dispose() {
    _nomBoutiqueController.dispose();
    _precisionController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<String> get _villesDisponibles {
    if (_selectedRegion == null) return [];
    return _locations[_selectedRegion!]?.keys.toList() ?? [];
  }

  List<String> get _quartiersDisponibles {
    if (_selectedRegion == null || _selectedVille == null) return [];
    return _locations[_selectedRegion!]?[_selectedVille!] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text("Devenir vendeur sur Brixel"),
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
                /*
                const Text(
                  "Vendez sur Brixel",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A2C1F),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                */

                Text(
                  "Rejoignez la première marketplace de quincaillerie au Cameroun\net développez votre activité",
                  style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.4),
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
                    _buildStepConnector(false),
                    _buildStepIndicator("4", false),
                  ],
                ),
                const SizedBox(height: 35),

                const Text(
                  "Informations sur votre boutique",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Color(0xFF4A2C1F)),
                ),
                const SizedBox(height: 8),
                Text(
                  "Décrivez votre commerce pour que les clients vous trouvent facilement",
                  style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),

                TextFormField(
                  controller: _nomBoutiqueController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: "Nom de la boutique",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.storefront_outlined),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => v?.trim().isEmpty ?? true ? "Veuillez entrer le nom de votre boutique" : null,
                ),
                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  value: _selectedRegion,
                  decoration: const InputDecoration(
                    labelText: "Région",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.map_outlined),
                  ),
                  items: _locations.keys.map((region) {
                    return DropdownMenuItem(value: region, child: Text(region));
                  }).toList(),
                  onChanged: isLoading ? null : (value) {
                    setState(() {
                      _selectedRegion = value;
                      _selectedVille = null;     // reset ville
                      _selectedQuartier = null;  // reset quartier
                    });
                  },
                  validator: (v) => v == null ? "Veuillez sélectionner une région" : null,
                ),
                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  value: _selectedVille,
                  decoration: const InputDecoration(
                    labelText: "Ville",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_city_outlined),
                  ),
                  items: _villesDisponibles.map((ville) {
                    return DropdownMenuItem(value: ville, child: Text(ville));
                  }).toList(),
                  onChanged: isLoading ? null : (value) {
                    setState(() {
                      _selectedVille = value;
                      _selectedQuartier = null; // reset quartier
                    });
                  },
                  validator: (v) => v == null ? "Veuillez sélectionner une ville" : null,
                ),
                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  value: _selectedQuartier,
                  decoration: const InputDecoration(
                    labelText: "Quartier",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_searching_outlined),
                    hintText: "Sélectionnez votre quartier",
                  ),
                  items: _quartiersDisponibles.map((q) {
                    return DropdownMenuItem(value: q, child: Text(q));
                  }).toList(),
                  onChanged:isLoading ? null : (value) => setState(() => _selectedQuartier = value),
                  validator: (v) => v == null ? "Veuillez sélectionner un quartier" : null,
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: _precisionController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: "Précision / Repères",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.info_outline),
                    hintText: "Ex : près de la station Total, en face du supermarché...",
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  validator: (v) => v?.trim().isEmpty ?? true ? "Veuillez precisez la localisation de votre boutique" : null,
                ),
                const SizedBox(height: 20),

                // Description
                TextFormField(
                  controller: _descriptionController,
                  enabled: !isLoading,
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
                ),
                const SizedBox(height: 30),

                // Boutons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isLoading ? null : () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFF9A825), width: 2),
                          foregroundColor: const Color(0xFF1F0404),
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                        child: const Text("Précédent", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() {
                              isLoading = true;
                            });

                            await Future.delayed(const Duration(milliseconds: 500));

                            await Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RegisterVendeur3(
                                nom: widget.nom,
                                email: widget.email,
                                telephone: widget.telephone,
                                password: widget.password,
                                storeName: _nomBoutiqueController.text.trim(),
                                region: _selectedRegion ?? '',
                                ville: _selectedVille ?? '',
                                quartier: _selectedQuartier ?? '',
                                precision: _precisionController.text.trim(),
                                description: _descriptionController.text.trim(),
                              )),
                            );
                            setState(() {
                              setState(() {
                                isLoading = false;
                              });
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF9A825),
                          foregroundColor: Colors.black87,
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: isLoading ?
                        SizedBox(
                          width: 25,
                          height: 25,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black87,
                          )
                        ):
                        const Text(
                          "Continuer",
                          style: TextStyle(
                            fontSize: 18,
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
      width: 40,
      height: 3,
      color: isActive ? const Color(0xFFF9A825) : Colors.grey[300],
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}