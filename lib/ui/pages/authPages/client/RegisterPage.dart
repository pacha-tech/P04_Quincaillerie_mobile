import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:brixel/Exception/NoInternetConnectionException.dart';
import 'package:flutter/material.dart';
import '../../../../Exception/AppException.dart';
import '../../../../data/dto/user/RegisterCustomerDTO.dart';
import 'package:provider/provider.dart';
import '../../../../provider/UserProvider.dart';
import '../../../../service/UserService.dart';
import '../../../widgets/MainNavigation.dart';
import 'LoginPage.dart';

class RegisterPage extends StatefulWidget {
  final String label;
  const RegisterPage({super.key, required this.label});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>(); // Clé pour la validation du formulaire
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  late ColorScheme colorScheme;
  final UserService _userService = UserService();

  bool _obscurePassword = true;
  bool _isLoading = false;

  // Style d'input conservé à l'identique, mais appliqué à TextFormField
  InputDecoration _inputStyle(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: colorScheme.primary),
      suffixIcon: suffix,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      errorBorder: OutlineInputBorder( // Ajout du style pour l'erreur
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 1),
      ),
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
    colorScheme = Theme.of(context).colorScheme;
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
        child: Form( // Ajout du widget Form
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: colorScheme.primary,
                      child: const Icon(Icons.person, size: 60, color: Colors.white),
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
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
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

              // Changement de TextField en TextFormField pour la validation
              TextFormField(
                controller: nameController,
                decoration: _inputStyle("Nom", Icons.person_outline),
                validator: (value) => (value == null || value.isEmpty) ? "Le nom est obligatoire" : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputStyle("Email", Icons.email_outlined),
                validator: (value) {
                  if (value == null || value.isEmpty) return "L'email est obligatoire";
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) return "Email invalide";
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputStyle("Téléphone", Icons.phone_android_outlined),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Le numéro est obligatoire";
                  }

                  final phoneRegex = RegExp(r'^6[0-9]{8}$');
                  if (!phoneRegex.hasMatch(value)) {
                    return "Format invalide (ex: 6XXXXXXXX)";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
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
                validator: (value) {
                  if (value == null || value.isEmpty) return "Le mot de passe est obligatoire";
                  if (value.length < 6) return "Minimum 6 caractères";
                  return null;
                },
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                onPressed: _isLoading ? null : () async {

                  if (!_formKey.currentState!.validate()) return;

                  setState(() => _isLoading = true);

                  final dto = RegisterCustomerDTO(
                    email: emailController.text.trim(),
                    password: passwordController.text,
                    name: nameController.text.trim(),
                    phone: phoneController.text.trim(),
                    role: "CLIENT",
                    imageUrl: "",
                  );

                  try {
                    await _userService.registerCustomer(dto);
                    if (!mounted) return;

                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.success,
                      animType: AnimType.bottomSlide,
                      title: "Bienvenue ${nameController.text} !",
                      desc: 'Votre compte client est prêt.',
                      btnOkText: "C'est parti !",
                      btnOkColor: Colors.yellow[700],
                      buttonsTextStyle: const TextStyle(color: Colors.black),
                      btnOkOnPress: () {
                        context.read<UserProvider>().refreshClaimsAfterLogin();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const MainNavigation()),
                              (route) => false,
                        );
                      },
                      dismissOnTouchOutside: false,
                      dismissOnBackKeyPress: false,
                    ).show();
                  } on NoInternetConnectionException catch (e) {
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.error,
                      title: 'Erreur',
                      desc: e.message,
                      btnOkText: "Ok",
                      btnOkColor: Colors.green,
                      btnOkOnPress: () {

                      },
                    ).show();

                  } on AppException catch (e){
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.error,
                      title: 'Oups !',
                      desc: e.message,
                      btnOkColor: Colors.red,
                    ).show();
                  } catch(e) {
                    AwesomeDialog(
                      context: context,
                      dialogType: DialogType.error,
                      title: 'Erreur',
                      desc: "Une Erreur c'est produite",
                      btnOkColor: Colors.red,
                    ).show();
                  }
                  finally {
                    if (mounted) setState(() => _isLoading = false);
                  }
                },
                child: _isLoading ?
                const SizedBox(
                  height: 20, width: 20,
                  child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                )
                    : const Text("S'INSCRIRE", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),

              if (!_isLoading)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Déjà un compte ?"),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage())),
                      child: Text("Connectez-vous", style: TextStyle(color: Colors.amber[800], fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}