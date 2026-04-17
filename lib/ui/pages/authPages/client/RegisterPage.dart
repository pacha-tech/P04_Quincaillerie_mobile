
import 'dart:io';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:brixel/Exception/NoInternetConnectionException.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../Exception/AppException.dart';
import '../../../../data/dto/user/RegisterCustomerDTO.dart';
import 'package:provider/provider.dart';
import '../../../../provider/UserProvider.dart';
import '../../../../service/UserService.dart';
import '../../../theme/AppColors.dart';
import '../../../widgets/MainNavigation.dart';
import 'LoginPage.dart';

class RegisterPage extends StatefulWidget {
  final String label;
  const RegisterPage({super.key, required this.label});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey          = GlobalKey<FormState>();
  final _nameController   = TextEditingController();
  final _emailController  = TextEditingController();
  final _phoneController  = TextEditingController();
  final _passwordController = TextEditingController();

  final UserService _userService = UserService();
  final ImagePicker _picker      = ImagePicker();

  bool _obscurePassword = true;
  bool _isLoading       = false;
  File? _pickedImage;

  // ── Image picker ──────────────────────────────────────────────────────────
  Future<void> _pickImage(ImageSource source) async {
    // Pas d'action si chargement en cours
    if (_isLoading) return;

    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 600,
      );
      if (file != null && mounted) {
        setState(() => _pickedImage = File(file.path));
      }
    } catch (_) {
      // Permission refusée ou autre erreur — on ignore silencieusement
    }
  }

  void _showImageSourceSheet() {
    if (_isLoading) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text("Choisir une photo",
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _imageSourceTile(
                    icon: Icons.camera_alt_rounded,
                    label: "Caméra",
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _imageSourceTile(
                    icon: Icons.photo_library_rounded,
                    label: "Galerie",
                    color: AppColors.priceGreen,
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageSourceTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(label,
                style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }

  // ── Style des champs ──────────────────────────────────────────────────────
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
        borderSide: const BorderSide(color: AppColors.statusClosed, width: 1.5),
      ),
      filled: true,
      fillColor: _isLoading ? Colors.grey[100] : const Color(0xFFF8F9FB),
      contentPadding:
      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  // ── Inscription ───────────────────────────────────────────────────────────
  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final dto = RegisterCustomerDTO(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      role: "CLIENT",
      imageUrl: _pickedImage?.path ?? "",
    );

    try {
      await _userService.registerCustomer(dto);
      if (!mounted) return;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.bottomSlide,
        title: "Bienvenue ${_nameController.text} !",
        desc: "Votre compte client est prêt.",
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
    } on AppException catch (e) {
      if (!mounted) return;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: "Oups !",
        desc: e.message,
        btnOkColor: AppColors.statusClosed,
        btnOkOnPress: () {},
      ).show();
    } catch (_) {
      if (!mounted) return;
      AwesomeDialog(
        context: context,
        dialogType: DialogType.error,
        title: "Erreur",
        desc: "Une erreur s'est produite, réessayez.",
        btnOkColor: AppColors.statusClosed,
        btnOkOnPress: () {},
      ).show();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ── BUILD ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        title: const Text("Créer un compte",
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        // Désactiver le retour pendant le chargement
        automaticallyImplyLeading: !_isLoading,
        leading: _isLoading
            ? const SizedBox()
            : IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      // Bloquer le retour système pendant le chargement
      body: PopScope(
        canPop: !_isLoading,
        child: Stack(
          children: [
            // ── Formulaire principal ─────────────────────────────────────
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24, vertical: 28),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Avatar avec picker ───────────────────────────────
                    Center(
                      child: GestureDetector(
                        onTap: _showImageSourceSheet,
                        child: Stack(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary.withOpacity(0.08),
                                border: Border.all(
                                    color: AppColors.primary.withOpacity(0.2),
                                    width: 2),
                                image: _pickedImage != null
                                    ? DecorationImage(
                                  image: FileImage(_pickedImage!),
                                  fit: BoxFit.cover,
                                )
                                    : null,
                              ),
                              child: _pickedImage == null
                                  ? const Icon(Icons.person_rounded,
                                  size: 50, color: AppColors.primary)
                                  : null,
                            ),
                            Positioned(
                              bottom: 2,
                              right: 2,
                              child: Container(
                                width: 30,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: _isLoading
                                      ? Colors.grey
                                      : AppColors.primary,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2),
                                ),
                                child: const Icon(Icons.camera_alt_rounded,
                                    color: Colors.white, size: 14),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Titre ────────────────────────────────────────────
                    Text(
                      widget.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Remplissez vos informations pour commencer",
                      textAlign: TextAlign.center,
                      style:
                      TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                    const SizedBox(height: 32),

                    // ── Champs ───────────────────────────────────────────
                    AbsorbPointer(
                      absorbing: _isLoading,
                      child: Column(
                        children: [
                          // Nom
                          TextFormField(
                            controller: _nameController,
                            decoration: _inputDecoration(
                                "Nom complet", Icons.person_outline_rounded),
                            textCapitalization:
                            TextCapitalization.words,
                            validator: (v) => (v == null || v.isEmpty)
                                ? "Le nom est obligatoire"
                                : null,
                          ),
                          const SizedBox(height: 14),

                          // Email
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: _inputDecoration(
                                "Email", Icons.email_outlined),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return "L'email est obligatoire";
                              if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(v))
                                return "Email invalide";
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Téléphone
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            decoration: _inputDecoration(
                                "Téléphone",
                                Icons.phone_android_outlined),
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return "Le numéro est obligatoire";
                              if (!RegExp(r'^6[0-9]{8}$').hasMatch(v))
                                return "Format invalide (ex: 6XXXXXXXX)";
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),

                          // Mot de passe
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
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
                    const SizedBox(height: 32),

                    // ── Bouton inscription ───────────────────────────────
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
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
                            : const Text("S'INSCRIRE",
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8)),
                      ),
                    ),

                    // ── Lien connexion ───────────────────────────────────
                    if (!_isLoading) ...[
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Déjà un compte ?",
                              style: TextStyle(
                                  color: Colors.grey, fontSize: 13)),
                          TextButton(
                            onPressed: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const LoginPage()),
                            ),
                            style: TextButton.styleFrom(
                                visualDensity: VisualDensity.compact),
                            child: const Text("Connectez-vous",
                                style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13)),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // ── Overlay de blocage total pendant le chargement ───────────
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.08),
                child: const Center(child: SizedBox()),
              ),
          ],
        ),
      ),
    );
  }
}