import 'package:flutter/material.dart';

import '../client/LoginPage.dart';
import 'RegisterVendeur2.dart';

class RegisterVendeur1 extends StatefulWidget {
  const RegisterVendeur1({super.key});


  @override
  State<RegisterVendeur1> createState() => _BecomeSellerPageState();
}

class _BecomeSellerPageState extends State<RegisterVendeur1> {
  final _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool _obscurePassword = true;

  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _passwordController = TextEditingController();
  late ColorScheme colorScheme;


  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _passwordController.dispose(); // ← ajouté
    super.dispose();
  }


  Widget _buildStepIndicator(String number, bool isActive) {
    colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isActive ? colorScheme.primary : Colors.grey[300],
        shape: BoxShape.circle
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

                Text(
                  "Informations Personnelles",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 35),

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

                // Indicateur d'étapes (inchangé)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStepIndicator("1", true),
                    _buildStepConnector(false),
                    _buildStepIndicator("2", false),
                    _buildStepConnector(false),
                    _buildStepIndicator("3", false),
                    _buildStepConnector(false),
                    _buildStepIndicator("4", false),
                  ],
                ),

                const SizedBox(height: 30),

                TextFormField(
                  controller: _nomController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: "Nom",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Veuillez entrer votre nom";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                TextFormField(
                  controller: _emailController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Veuillez entrer votre email";
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return "Email invalide";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                TextFormField(
                  controller: _telephoneController,
                  enabled: !isLoading,
                  decoration: const InputDecoration(
                    labelText: "Téléphone",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone_outlined),
                    hintText: "6XX XXX XXX",
                  ),
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "veuillez entrer votre numero de telephone";
                    }

                    final phoneRegex = RegExp(r'^6[0-9]{8}$');
                    if (!phoneRegex.hasMatch(value)) {
                      return "Format invalide (ex: 6XXXXXXXX)";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 15),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  enabled: !isLoading,
                  decoration: InputDecoration(
                    labelText: "Mot de passe",
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey[700],
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Veuillez entrer un mot de passe";
                    }
                    if (value.length < 6) {
                      return "Le mot de passe doit contenir au moins 6 caractères";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          isLoading = true;
                        });

                        await Future.delayed(const Duration(milliseconds: 500));

                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterVendeur2(
                              nom: _nomController.text.trim(),
                              email: _emailController.text.trim(),
                              telephone: _telephoneController.text.trim(),
                              password: _passwordController.text.trim(),
                            ),
                          ),
                        );
                        setState(() {
                          isLoading = false;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
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

                const SizedBox(height: 15),

                if(!isLoading)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Deja un compte ?"),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(context , MaterialPageRoute(builder: (context) => const LoginPage())),
                        child: Text("Connectez vous", style: TextStyle(color: Colors.amber[800], fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}