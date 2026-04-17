
import 'package:flutter/material.dart';
import 'package:brixel/ui/theme/AppColors.dart';
import '../client/LoginPage.dart';
import 'RegisterVendeur2.dart';

class RegisterVendeur1 extends StatefulWidget {
  const RegisterVendeur1({super.key});

  @override
  State<RegisterVendeur1> createState() => _RegisterVendeur1State();
}

class _RegisterVendeur1State extends State<RegisterVendeur1> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _submitted = false; // ← active la validation en temps réel après 1er submit

  final _nomController       = TextEditingController();
  final _emailController     = TextEditingController();
  final _telephoneController = TextEditingController();
  final _passwordController  = TextEditingController();

  @override
  void dispose() {
    _nomController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────────────────────
  String? _validateNom(String? v) {
    if (v == null || v.trim().isEmpty) return "Veuillez entrer votre nom";
    if (v.trim().length < 2) return "Nom trop court";
    return null;
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return "Veuillez entrer votre email";
    if (!RegExp(r'^[\w\-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v.trim())) {
      return "Adresse email invalide";
    }
    return null;
  }

  String? _validateTelephone(String? v) {
    if (v == null || v.isEmpty) return "Veuillez entrer votre numéro";
    if (!RegExp(r'^6[0-9]{8}$').hasMatch(v)) {
      return "Format invalide (ex: 6XXXXXXXX)";
    }
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return "Veuillez entrer un mot de passe";
    if (v.length < 6) return "Au moins 6 caractères requis";
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
        builder: (_) => RegisterVendeur2(
          nom:       _nomController.text.trim(),
          email:     _emailController.text.trim(),
          telephone: _telephoneController.text.trim(),
          password:  _passwordController.text.trim(),
        ),
      ),
    );

    if (mounted) setState(() => _isLoading = false);
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.white, size: 20),
          onPressed: _isLoading ? null : () => Navigator.pop(context),
        ),
        title: const Column(
          children: [
            Text("Devenir vendeur",
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    letterSpacing: 0.3)),
            Text("sur Brixel",
                style: TextStyle(fontSize: 12, color: Colors.white60)),
          ],
        ),
        centerTitle: true,
      ),
      body: SafeArea(
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

                // ── Header ──────────────────────────────────────────────────
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4))
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
                        child: const Icon(Icons.storefront_rounded,
                            size: 32, color: AppColors.primary),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Rejoignez Brixel",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Première marketplace de quincaillerie au Cameroun",
                        style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                            height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Indicateur d'étapes ───────────────────────────────────
                _buildStepBar(),
                const SizedBox(height: 24),

                // ── Section label ──────────────────────────────────────────
                _sectionLabel("INFORMATIONS PERSONNELLES"),
                const SizedBox(height: 12),

                // ── Formulaire ─────────────────────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildField(
                        controller: _nomController,
                        label: "Nom complet",
                        icon: Icons.person_outline_rounded,
                        validator: _validateNom,
                        capitalization: TextCapitalization.words,
                        isFirst: true,
                      ),
                      _divider(),
                      _buildField(
                        controller: _emailController,
                        label: "Adresse email",
                        icon: Icons.email_outlined,
                        validator: _validateEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      _divider(),
                      _buildField(
                        controller: _telephoneController,
                        label: "Numéro de téléphone",
                        icon: Icons.phone_outlined,
                        validator: _validateTelephone,
                        keyboardType: TextInputType.phone,
                        hint: "6XX XXX XXX",
                      ),
                      _divider(),
                      _buildPasswordField(),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Bouton continuer ───────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      disabledBackgroundColor:
                      AppColors.primary.withOpacity(0.5),
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
                            strokeWidth: 2.5, color: Colors.white))
                        : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Continuer",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 18),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ── Lien login ─────────────────────────────────────────────
                if (!_isLoading)
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Déjà un compte ?",
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 13)),
                        TextButton(
                          onPressed: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginPage()),
                          ),
                          style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8)),
                          child: const Text("Connectez-vous",
                              style: TextStyle(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13)),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Indicateur d'étapes ───────────────────────────────────────────────────
  Widget _buildStepBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stepCircle("1", true),
        _stepLine(false),
        _stepCircle("2", false),
        _stepLine(false),
        _stepCircle("3", false),
        _stepLine(false),
        _stepCircle("4", false),
      ],
    );
  }

  Widget _stepCircle(String number, bool isActive) {
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
              offset: const Offset(0, 3))
        ]
            : [],
      ),
      child: Center(
        child: Text(
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

  // ── Champ texte générique ─────────────────────────────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization capitalization = TextCapitalization.none,
    String? hint,
    bool isFirst = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextFormField(
        controller: controller,
        enabled: !_isLoading,
        keyboardType: keyboardType,
        textCapitalization: capitalization,
        validator: validator,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
          hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
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

  // ── Champ mot de passe ────────────────────────────────────────────────────
  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextFormField(
        controller: _passwordController,
        enabled: !_isLoading,
        obscureText: _obscurePassword,
        validator: _validatePassword,
        style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary),
        decoration: InputDecoration(
          labelText: "Mot de passe",
          labelStyle: TextStyle(fontSize: 13, color: Colors.grey[500]),
          prefixIcon:
          Icon(Icons.lock_outline_rounded, size: 20, color: Colors.grey[400]),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              size: 20,
              color: Colors.grey[400],
            ),
            onPressed: _isLoading
                ? null
                : () => setState(() => _obscurePassword = !_obscurePassword),
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
        ),
      ),
    );
  }

  Widget _divider() => Divider(
      height: 1, thickness: 0.5, color: Colors.grey[100],
      indent: 16, endIndent: 16);

  Widget _sectionLabel(String label) => Text(label,
      style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: Colors.grey.shade500,
          letterSpacing: 1.4));
}