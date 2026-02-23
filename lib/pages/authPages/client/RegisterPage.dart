import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import '../../../service/AuthService.dart';
import '../../../widgets/MainNavigation.dart';
import 'LoginPage.dart';

class RegisterPage extends StatefulWidget {
  final Widget page;
  final String label;
  const RegisterPage({super.key , required this.page , required this.label});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final AuthService _authService = AuthService();


  bool _obscurePassword = true;
  bool _isLoading = false;

  InputDecoration _inputStyle(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.amber[700]),
      suffixIcon: suffix, // Ajout du bouton pour l'œil
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
        title: const Text("Créer un compte", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- ZONE PHOTO ---
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[300],
                    child: Icon(Icons.person, size: 60, color: Colors.grey[600]),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.amber[700],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),  //doit etre modfier en un iconButton
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            Text(
              widget.label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            const Text(
              "Remplissez vos informations pour commencer",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            TextField(
                controller: nameController,
                decoration: _inputStyle("Nom", Icons.person_outline)
            ),
            const SizedBox(height: 16),

            TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputStyle("Email", Icons.email_outlined)
            ),
            const SizedBox(height: 16),

            TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputStyle("Téléphone", Icons.phone_android_outlined)
            ),
            const SizedBox(height: 16),

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
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                )
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.yellow[700],
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 2,
              ),
              onPressed: _isLoading ? null : () async {
                setState(() {
                  _isLoading = true;
                });
                try {
                  await _authService.registerCustomer(
                      emailController.text,
                      passwordController.text,
                      nameController.text,
                      phoneController.text,
                      "CLIENT"
                  );
                  if (!mounted) return;
                  print("DEBUT DE L'AFFICHAGE DU MESSAGE DE SUCCES");
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.success,
                    animType: AnimType.bottomSlide, // Surgit du bas
                    title: "Bienvenue ${nameController.text} !",
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
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Erreur: $e"), backgroundColor: Colors.red)
                  );
                  print("ERREUR FIREBASE: $e");
                  AwesomeDialog(
                    context: context,
                    dialogType: DialogType.error,
                    title: 'Oups !',
                    desc: 'Erreur : $e',
                    btnOkColor: Colors.red,
                  ).show();
                }finally{
                  setState(() {
                    _isLoading = false;
                  });
                }
              },
              child: _isLoading ?
               const SizedBox(
                 height: 20,
                 width: 20,
                 child: CircularProgressIndicator(
                   color: Colors.black, // Couleur contrastée avec le jaune
                   strokeWidth: 2,
                 ),
               )
               :const Text("S'INSCRIRE", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            if(!_isLoading)
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
    );
  }
}
