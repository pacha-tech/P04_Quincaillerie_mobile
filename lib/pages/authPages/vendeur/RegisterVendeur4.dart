import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

import '../../../service/AuthService.dart';
import '../../../widgets/MainNavigation.dart';

class RegisterVendeur4 extends StatefulWidget {
  // Infos page 1
  final String nom;
  final String email;
  final String telephone;
  final String password;

  // Infos page 2
  final String storeName;
  final String region;
  final String ville;
  final String quartier;
  final String precision;
  final String description;

  // Position de la page 3
  final double latitude;
  final double longitude;

  const RegisterVendeur4({
    super.key,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.password,
    required this.storeName,
    required this.region,
    required this.ville,
    required this.quartier,
    required this.precision,
    required this.description,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<RegisterVendeur4> createState() => _RegisterVendeur4State();
}

class _RegisterVendeur4State extends State<RegisterVendeur4> {
  final _formKey = GlobalKey<FormState>();

  final _nuiController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  bool _acceptTerms = false;
  bool _wantTips = false;

  @override
  void dispose() {
    _nuiController.dispose();
    super.dispose();
  }

  String? _requiredCheckboxValidator(bool value, String message) {
    return value ? null : message;
  }

  Future<void> _submit() async {
    // Validation formulaire + CGU
    if (!_formKey.currentState!.validate() || !_acceptTerms) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Vous devez accepter les conditions générales"),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      //await Future.delayed(const Duration(seconds: 2));

      /*
      await _authService.registerCustomer(
          widget.email,
          widget.password,
          widget.nom,
          widget.telephone,
          "VENDEUR"
      );

      await _authService.registerQuincaillerie(
          widget.storeName,
          widget.region,
          widget.ville,
          widget.quartier,
          widget.precision,
          widget.description,
          widget.latitude,
          widget.longitude,
          widget.telephone
      );
      */

       await _authService.registerSeller(
         widget.password,
         widget.nom,
         widget.email,
         widget.telephone,
         "VENDEUR",
         "",
         widget.storeName,
         widget.region,
         widget.ville,
         widget.quartier,
         widget.precision,
         "",
         widget.description,
         widget.latitude,
         widget.longitude
       );

       if (!mounted) return;

       // Afficher le dialogue et ATTENDRE que l'utilisateur clique sur OK
       await AwesomeDialog(
         context: context,
         dialogType: DialogType.success,
         animType: AnimType.bottomSlide,
         title: "Quincaillerie ${widget.storeName} créée avec succès !",
         desc: 'Votre compte quincaillerie est prêt.',
         btnOkText: "C'est parti !",
         btnOkColor: Colors.yellow[700],
         buttonsTextStyle: const TextStyle(color: Colors.black),
         btnOkOnPress: () {}, // Rien ici, on gère après
         dismissOnTouchOutside: false,
         dismissOnBackKeyPress: false,
       ).show();


       if (mounted) {
         Navigator.pushAndRemoveUntil(
           context,
           MaterialPageRoute(builder: (context) => const MainNavigation()),
               (route) => false,
         );
       }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur lors de l'inscription : $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Document & Validation",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A2C1F),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 35),

                    // Indicateur d'étapes (toutes terminées)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildStepIndicator("1", true),
                        _buildStepConnector(true),
                        _buildStepIndicator("2", true),
                        _buildStepConnector(true),
                        _buildStepIndicator("3", true),
                        _buildStepConnector(true),
                        _buildStepIndicator("4", true),
                      ],
                    ),
                    const SizedBox(height: 50),

                    Text(
                      "Dernière étape avant validation",
                      style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 40),

                    // Champ NUI (optionnel)
                    TextFormField(
                      controller: _nuiController,
                      enabled: !_isLoading,
                      decoration: const InputDecoration(
                        labelText: "NUI (Optionnel)",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge_outlined),
                        hintText: "Numéro d’identification unique",
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 40),

                    // Cases à cocher
                    CheckboxListTile(
                      value: _acceptTerms,
                      onChanged: _isLoading ? null : (value) => setState(() => _acceptTerms = value ?? false),
                      title: const Text(
                        "J'accepte les conditions générales d'utilisation et la politique de confidentialité",
                        style: TextStyle(fontSize: 15),
                      ),
                      subtitle: const Text(
                        "* Obligatoire pour continuer",
                        style: TextStyle(fontSize: 12, color: Colors.red),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: const Color(0xFFF9A825),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 12),

                    CheckboxListTile(
                      value: _wantTips,
                      onChanged: _isLoading ? null : (value) => setState(() => _wantTips = value ?? false),
                      title: const Text(
                        "Je souhaite recevoir des conseils et astuces pour développer mes ventes",
                        style: TextStyle(fontSize: 15),
                      ),
                      controlAffinity: ListTileControlAffinity.leading,
                      activeColor: const Color(0xFFF9A825),
                      contentPadding: EdgeInsets.zero,
                    ),
                    const SizedBox(height: 48),

                    // Boutons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                color: _isLoading ? Colors.grey : const Color(0xFFF9A825),
                                width: 2,
                              ),
                              foregroundColor: _isLoading ? Colors.grey : const Color(0xFF1F0404),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: const Text("Précédent", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: (_isLoading || !_acceptTerms) ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF9A825),
                              foregroundColor: Colors.black87,
                              disabledBackgroundColor: const Color(0xFFFBF5DE),
                              disabledForegroundColor: Colors.black54,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                              ),
                            )
                                : const Text(
                              "Soumettre",
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

          ],
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