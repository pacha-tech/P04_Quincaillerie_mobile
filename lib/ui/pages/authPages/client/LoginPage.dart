
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:brixel/Exception/NoInternetConnectionException.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../provider/UserProvider.dart';
import '../../../../service/UserService.dart';
import '../../../theme/AppColors.dart';
import '../../../widgets/MainNavigation.dart';
import 'RegisterPage.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey            = GlobalKey<FormState>();
  final _emailController    = TextEditingController();
  final _passwordController = TextEditingController();
  final UserService _userService = UserService();

  bool _obscurePassword = true;
  bool _isLoading       = false;


  InputDecoration _inputDecoration(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
          color: _isLoading ? Colors.grey[400] : Colors.grey[600],
          fontSize: 14),
      prefixIcon: Icon(icon,
          color: _isLoading ? Colors.grey[400] : AppColors.primary,
          size: 20),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.statusClosed, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide:
        const BorderSide(color: AppColors.statusClosed, width: 1.5),
      ),
      filled: true,
      fillColor: _isLoading ? Colors.grey[100] : const Color(0xFFF8F9FB),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  // ── Connexion ─────────────────────────────────────────────────────────────
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await _userService.login(
          _emailController.text.trim(), _passwordController.text);
      if (!mounted) return;

      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: "Heureux de vous revoir !",
        desc: "Votre compte est prêt.",
        btnOkText: "C'est parti !",
        btnOkColor: AppColors.priceGreen,
        btnOkOnPress: () {
          context.read<UserProvider>().refreshClaimsAfterLogin();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const MainNavigation()),
                (route) => false,
          );
        },
        dismissOnTouchOutside: false,
        dismissOnBackKeyPress: false,
      ).show();
    } on NoInternetConnectionException catch (e) {
      if (!mounted) return;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning,
        title: "Pas de connexion",
        desc: e.message,
        btnOkText: "Ok",
        btnOkColor: AppColors.primary,
        btnOkOnPress: () {},
      ).show();
    } catch (_) {
      if (!mounted) return;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: "Erreur de connexion",
        desc: "Email ou mot de passe incorrect.",
        btnOkColor: AppColors.statusClosed,
        btnOkOnPress: () {},
      ).show();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text("Connexion",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: !_isLoading,
        leading: _isLoading
            ? const SizedBox()
            : IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: PopScope(
        canPop: !_isLoading,
        child: Stack(
          children: [
            // ── Formulaire ───────────────────────────────────────────────
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 36),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Icône centrale ───────────────────────────────────
                    Center(
                      child: Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.08),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.primary.withOpacity(0.15),
                              width: 2),
                        ),
                        child: const Icon(Icons.lock_open_rounded,
                            size: 46, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Titres ───────────────────────────────────────────
                    const Text(
                      "Bon retour !",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Connectez-vous pour accéder à votre compte",
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 36),

                    // ── Champs — bloqués pendant le chargement ───────────
                    AbsorbPointer(
                      absorbing: _isLoading,
                      child: Column(
                        children: [
                          // Email
                          TextFormField(
                            controller: _emailController,
                            enabled: !_isLoading,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration(
                                "Email", Icons.email_outlined),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return "L'email est obligatoire";
                              }
                              if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(v)) {
                                return "Email invalide";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Mot de passe
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            enabled: !_isLoading,
                            decoration: _inputDecoration(
                              "Mot de passe",
                              Icons.lock_outline_rounded,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.grey[400],
                                  size: 20,
                                ),
                                onPressed: _isLoading
                                    ? null
                                    : () => setState(() =>
                                _obscurePassword =
                                !_obscurePassword),
                              ),
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return "Le mot de passe est obligatoire";
                              if (v.length < 6)
                                return "Minimum 6 caractères";
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    // ── Mot de passe oublié ──────────────────────────────
                    if (!_isLoading)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            // Mot de passe oublié
                          },
                          style: TextButton.styleFrom(
                              visualDensity: VisualDensity.compact),
                          child: const Text(
                            "Mot de passe oublié ?",
                            style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),

                    // ── Bouton connexion ─────────────────────────────────
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          disabledBackgroundColor:
                          AppColors.primary.withOpacity(0.6),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                            : const Text(
                          "SE CONNECTER",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8),
                        ),
                      ),
                    ),

                    // ── Lien inscription ─────────────────────────────────
                    if (!_isLoading) ...[
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Nouveau ici ?",
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 13)),
                          TextButton(
                            onPressed: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const RegisterPage(
                                  label:
                                  "Rejoignez notre Marketplace pour les produits de quincaillerie",
                                ),
                              ),
                            ),
                            style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact),
                            child: const Text(
                              "Créer un compte",
                              style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Overlay blocage total pendant le chargement ───────────────
            if (_isLoading)
              Container(color: Colors.black.withOpacity(0.06)),
          ],
        ),
      ),
    );
  }
}
