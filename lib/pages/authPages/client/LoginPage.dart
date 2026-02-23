import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../../../widgets/MainNavigation.dart';
import '../../homePage/HomePage.dart';
import 'RegisterPage.dart';
import '../../../service/AuthService.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _isloading = false;

  // Même style que RegisterPage
  InputDecoration _inputStyle(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.amber[700]),
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.amber[700]!, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Connexion", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Logo ou Icône de bienvenue
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.yellow,
                child: Icon(Icons.lock_open_rounded, size: 50, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              "Bon retour !",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            const Text(
              "Connectez-vous pour accéder à votre compte",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),

            // Champ Email
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: _inputStyle("Email", Icons.email_outlined),
            ),
            const SizedBox(height: 16),

            // Champ Mot de passe avec Œil
            TextField(
              controller: passwordController,
              obscureText: _obscurePassword,
              decoration: _inputStyle(
                "Mot de passe",
                Icons.lock_outline,
                suffix: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey[600],
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
            ),

            // Mot de passe oublié (Optionnel)
            if(!_isloading)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // Logique mot de passe oublié ici
                  },
                  child: Text("Mot de passe oublié ?", style: TextStyle(color: Colors.amber[800])),
                ),
              ),
            const SizedBox(height: 24),

            // Bouton de connexion
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              onPressed: _isloading ? null : () async {
                setState(() {
                  _isloading = true;
                });
                try {
                  await _authService.login(emailController.text, passwordController.text);
                  if (!mounted) return;

                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.success,
                    animType: AnimType.bottomSlide, // Surgit du bas
                    title: "Heureux de vous revoir !",
                    desc: 'Votre compte client est prêt.',
                    btnOkText: "C'est parti !",
                    btnOkColor: Colors.yellow[700],
                    buttonsTextStyle: const TextStyle(color: Colors.black),
                    btnOkOnPress: () {
                      // Le dialogue se fermera automatiquement ici
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const MainNavigation()),
                            (route) => false,
                      );
                    },
                    dismissOnTouchOutside: false,
                    dismissOnBackKeyPress: false,
                    onDismissCallback: (type) {
                      //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainNavigation()));
                      //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => widget.page));
                      //Navigator.of(context).pop();
                    },
                  ).show();
                } catch (e) {
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.error,
                    title: 'Erreur de connexion',
                    desc: 'Email ou mot de passe incorrect.',
                    btnOkColor: Colors.red,
                    btnOkOnPress: () {},
                  ).show();
                }finally{
                  setState(() {
                    _isloading = false;
                  });
                }
              },
              child: _isloading
                  ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.black, // Couleur contrastée avec le jaune
                  strokeWidth: 2,
                ),
              ) : const Text("SE CONNECTER", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),

            const SizedBox(height: 24),

            // Lien vers Inscription
            if(!_isloading)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Nouveau ici ?"),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(context , MaterialPageRoute(builder: (context) => const RegisterPage(page: HomePage(), label: "Rejoinez notre AmrketPlace pour les produits de quincaillerie"))),
                    child: Text("Créer un compte", style: TextStyle(color: Colors.amber[800], fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
