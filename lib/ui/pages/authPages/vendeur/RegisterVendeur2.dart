
/*
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
  late ColorScheme colorScheme;
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
    colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text("Devenir vendeur sur Brixel"),
        backgroundColor: colorScheme.primary,
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
                SizedBox(height: 20),
                Text(
                  "Informations sur votre boutique",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: colorScheme.secondary),
                ),
                const SizedBox(height: 20),

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
                          side: BorderSide(color: colorScheme.primary, width: 2),
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
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
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
    colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isActive ? colorScheme.primary : Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          number,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Container(
      width: 40,
      height: 3,
      color: isActive ? colorScheme.primary : Colors.grey[300],
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }
}
 */

import 'package:flutter/material.dart';
import 'package:brixel/ui/theme/AppColors.dart';
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
  bool _isLoading = false;
  bool _submitted = false;

  final _nomBoutiqueController = TextEditingController();
  final _precisionController   = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedRegion;
  String? _selectedVille;
  String? _selectedQuartier;

  // ── Données géographiques ────────────────────────────────────────────────
  final Map<String, Map<String, List<String>>> _locations = {
    "Centre": {
      "Yaoundé":   ["Bastos", "Mvan", "Ngoa-Ekelle", "Essos", "Efoulan", "Messa", "Carrefour EMANA", "Obili"],
      "Mbalmayo":  ["Nkolfoulou", "Ngat", "Centre-ville"],
      "Bafia":     ["Quartier Administratif", "Marché Central"],
    },
    "Littoral": {
      "Douala":     ["Bonanjo", "Akwa", "Bonapriso", "Deido", "New Bell", "Bali", "Makepe"],
      "Edéa":       ["Quartier Nkolo", "Centre-ville"],
      "Nkongsamba": ["Quartier Haoussa", "Marché central"],
    },
    "Ouest": {
      "Bafoussam": ["Djeleng", "Marché A", "Tchatchoua"],
      "Dschang":   ["Carrefour TSF", "Fiala-Foreke"],
      "Mbouda":    ["Quartier Marché"],
    },
    "Nord-Ouest":    {"Bamenda":     ["Commercial Avenue", "Up Station"]},
    "Sud-Ouest":     {"Buea":        ["Molyko", "Mile 17"]},
    "Adamaoua":      {"Ngaoundéré":  ["Quartier Sabongari"]},
    "Est":           {"Bertoua":     ["Quartier Domayo"]},
    "Extrême-Nord":  {"Maroua":      ["Domayo"]},
    "Nord":          {"Garoua":      ["Quartier Pitoa"]},
    "Sud":           {"Ebolowa":     ["Quartier Grand Marché"]},
  };

  @override
  void dispose() {
    _nomBoutiqueController.dispose();
    _precisionController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  List<String> get _villesDisponibles =>
      _selectedRegion == null ? [] : (_locations[_selectedRegion!]?.keys.toList() ?? []);

  List<String> get _quartiersDisponibles =>
      (_selectedRegion == null || _selectedVille == null)
          ? []
          : (_locations[_selectedRegion!]?[_selectedVille!] ?? []);

  // ── Validation ────────────────────────────────────────────────────────────
  String? _validateNomBoutique(String? v) {
    if (v == null || v.trim().isEmpty) return "Veuillez entrer le nom de votre boutique";
    if (v.trim().length < 2) return "Nom trop court";
    return null;
  }

  String? _validatePrecision(String? v) {
    if (v == null || v.trim().isEmpty) return "Précisez la localisation de votre boutique";
    return null;
  }

  // ── Soumission ────────────────────────────────────────────────────────────
  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 400));

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterVendeur3(
          nom:         widget.nom,
          email:       widget.email,
          telephone:   widget.telephone,
          password:    widget.password,
          storeName:   _nomBoutiqueController.text.trim(),
          region:      _selectedRegion ?? '',
          ville:       _selectedVille ?? '',
          quartier:    _selectedQuartier ?? '',
          precision:   _precisionController.text.trim(),
          description: _descriptionController.text.trim(),
        ),
      ),
    );

    if (mounted) setState(() => _isLoading = false);
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
        title: const Column(
          children: [
            Text(
              "Devenir vendeur",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              "sur Brixel",
              style: TextStyle(fontSize: 12, color: Colors.white60),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: AbsorbPointer(
        absorbing: _isLoading,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Form(
              key: _formKey,
              autovalidateMode: _submitted
                  ? AutovalidateMode.onUserInteraction
                  : AutovalidateMode.disabled,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Header card ────────────────────────────────────────
                  _buildHeaderCard(),
                  const SizedBox(height: 20),

                  // ── Stepper ────────────────────────────────────────────
                  _buildStepBar(),
                  const SizedBox(height: 24),

                  // ── Nom boutique ───────────────────────────────────────
                  _sectionLabel("INFORMATIONS DE LA BOUTIQUE"),
                  const SizedBox(height: 12),

                  _buildCardGroup(children: [
                    _buildField(
                      controller: _nomBoutiqueController,
                      label: "Nom de la boutique",
                      icon: Icons.storefront_outlined,
                      validator: _validateNomBoutique,
                      capitalization: TextCapitalization.words,
                      isFirst: true,
                    ),
                    _divider(),
                    _buildField(
                      controller: _descriptionController,
                      label: "Description de la boutique",
                      hint: "Vos spécialités, points forts...",
                      icon: Icons.description_outlined,
                      maxLines: 3,
                      capitalization: TextCapitalization.sentences,
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // ── Localisation ───────────────────────────────────────
                  _sectionLabel("LOCALISATION"),
                  const SizedBox(height: 12),

                  _buildCardGroup(children: [
                    _buildDropdown(
                      label: "Région",
                      icon: Icons.map_outlined,
                      value: _selectedRegion,
                      items: _locations.keys.toList(),
                      validator: (v) => v == null ? "Sélectionnez une région" : null,
                      onChanged: (v) => setState(() {
                        _selectedRegion  = v;
                        _selectedVille   = null;
                        _selectedQuartier = null;
                      }),
                      isFirst: true,
                    ),
                    _divider(),
                    _buildDropdown(
                      label: "Ville",
                      icon: Icons.location_city_outlined,
                      value: _selectedVille,
                      items: _villesDisponibles,
                      validator: (v) => v == null ? "Sélectionnez une ville" : null,
                      onChanged: _villesDisponibles.isEmpty
                          ? null
                          : (v) => setState(() {
                        _selectedVille    = v;
                        _selectedQuartier = null;
                      }),
                      enabled: _villesDisponibles.isNotEmpty,
                    ),
                    _divider(),
                    _buildDropdown(
                      label: "Quartier",
                      icon: Icons.location_on_outlined,
                      value: _selectedQuartier,
                      items: _quartiersDisponibles,
                      validator: (v) => v == null ? "Sélectionnez un quartier" : null,
                      onChanged: _quartiersDisponibles.isEmpty
                          ? null
                          : (v) => setState(() => _selectedQuartier = v),
                      enabled: _quartiersDisponibles.isNotEmpty,
                    ),
                    _divider(),
                    _buildField(
                      controller: _precisionController,
                      label: "Précision / Repères",
                      hint: "Ex : près de la station Total...",
                      icon: Icons.assistant_navigation,
                      validator: _validatePrecision,
                      capitalization: TextCapitalization.sentences,
                    ),
                  ]),

                  const SizedBox(height: 28),

                  // ── Boutons ────────────────────────────────────────────
                  _buildActions(),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Header card (identique RegisterVendeur1) ───────────────────────────────
  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.store_mall_directory_rounded,
                size: 32, color: AppColors.primary),
          ),
          const SizedBox(height: 12),
          const Text(
            "Votre boutique",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Décrivez votre commerce pour que les clients vous trouvent facilement",
            style: TextStyle(fontSize: 13, color: Colors.grey[500], height: 1.4),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Stepper (identique RegisterVendeur1, étape 2 active) ──────────────────
  Widget _buildStepBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stepCircle("1", true, done: true),
        _stepLine(true),
        _stepCircle("2", true),
        _stepLine(false),
        _stepCircle("3", false),
        _stepLine(false),
        _stepCircle("4", false),
      ],
    );
  }

  Widget _stepCircle(String number, bool isActive, {bool done = false}) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.grey[200],
        shape: BoxShape.circle,
        boxShadow: isActive
            ? [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ]
            : [],
      ),
      child: Center(
        child: done
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 18)
            : Text(
          number,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: isActive ? Colors.white : Colors.grey[400],
          ),
        ),
      ),
    );
  }

  Widget _stepLine(bool isActive) {
    return Container(
      width: 36,
      height: 3,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : Colors.grey[200],
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  // ── Groupe de champs en card (identique RegisterVendeur1) ──────────────────
  Widget _buildCardGroup({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  // ── Champ texte (copie exacte RegisterVendeur1) ───────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization capitalization = TextCapitalization.none,
    String? hint,
    int maxLines = 1,
    bool isFirst = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextFormField(
        controller: controller,
        enabled: !_isLoading,
        keyboardType: keyboardType,
        textCapitalization: capitalization,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
          hintStyle: TextStyle(fontSize: 12, color: Colors.grey[400]),
          prefixIcon: Icon(icon, size: 20, color: Colors.grey[400]),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
          errorStyle: const TextStyle(
              fontSize: 11, color: AppColors.accent, height: 0.8),
        ),
      ),
    );
  }

  // ── Dropdown (même style que les champs texte, sans bordure) ─────────────
  Widget _buildDropdown({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required String? Function(String?) validator,
    required void Function(String?)? onChanged,
    bool enabled = true,
    bool isFirst = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        validator: validator,
        onChanged: (!_isLoading && enabled) ? onChanged : null,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: enabled ? AppColors.primary.withOpacity(0.5) : Colors.grey[300],
          size: 20,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            fontSize: 13,
            color: enabled ? Colors.grey[500] : Colors.grey[300],
          ),
          prefixIcon: Icon(
            icon,
            size: 20,
            color: enabled ? Colors.grey[400] : Colors.grey[300],
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          focusedErrorBorder: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
          errorStyle: const TextStyle(
              fontSize: 11, color: AppColors.accent, height: 0.8),
          // Feedback visuel : champ verrouillé si pas encore disponible
          suffixIcon: !enabled
              ? Icon(Icons.lock_outline_rounded,
              size: 14, color: Colors.grey[300])
              : null,
        ),
        items: items
            .map((item) => DropdownMenuItem(
          value: item,
          child: Text(item,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary)),
        ))
            .toList(),
      ),
    );
  }

  // ── Boutons (identique RegisterVendeur1) ───────────────────────────────────
  Widget _buildActions() {
    return Column(
      children: [
        // Bouton principal Continuer
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
            child: _isLoading
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                  strokeWidth: 2.5, color: Colors.white),
            )
                : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Continuer",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Bouton Précédent
        if (!_isLoading)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: const Text(
                "Précédent",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _divider() => Divider(
    height: 1,
    thickness: 0.5,
    color: Colors.grey[100],
    indent: 16,
    endIndent: 16,
  );

  Widget _sectionLabel(String label) => Text(
    label,
    style: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      color: Colors.grey.shade500,
      letterSpacing: 1.4,
    ),
  );
}