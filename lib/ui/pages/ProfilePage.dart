
/*
import 'package:brixel/Exception/NoInternetConnectionException.dart';
import 'package:brixel/service/UserService.dart';
import 'package:brixel/ui/widgets/ErrorWidgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/UserProvider.dart';
import '../../Exception/AppException.dart';
import '../../data/modele/UserInfos.dart';
import '../widgets/MainNavigation.dart';
import 'authPages/client/RegisterPage.dart';

class ProfilePage extends StatelessWidget {
  static final UserService _userService = UserService();
  const ProfilePage({super.key});


  @override
  Widget build(BuildContext context) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    final userProvider = context.watch<UserProvider>();


    if (userProvider.isUnknown) {
      return _buildSkeletonView();
    }


    if (!userProvider.isAuthenticated || userProvider.currentUser == null || userProvider.role == null || userProvider.role!.isEmpty) {
      return _buildGuestView(context);
    }

    final firebaseUser = userProvider.currentUser!;
    final String role = userProvider.role!;

    return FutureBuilder<UserInfos?>(
      future: /*Future.delayed(Duration(seconds: 5)),*/
      _userService.getUserInfo(),
      builder: (context, apiSnapshot) {
        if (apiSnapshot.connectionState == ConnectionState.waiting) {
          return _buildProfileView(context, firebaseUser, null, role, isLoading: true,
          );
        }

        if (apiSnapshot.hasError || apiSnapshot.data == null) {
          final error = apiSnapshot.error;
          if(error is NoInternetConnectionException ){
            return Scaffold(
                backgroundColor: colorScheme.surface,
              appBar: AppBar(
                title: const Text('Mon Profil', style: TextStyle(fontWeight: FontWeight.bold)),
                centerTitle: true,
                elevation: 0,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
                body: ErrorWidgets(message: error.message, iconData: Icons.wifi_off, onRetry: () async { await _userService.getUserInfo();})
            );
          } else if(error is AppException){
            return Scaffold(
                backgroundColor: colorScheme.surface,
              appBar: AppBar(
                title: const Text('Mon Profil', style: TextStyle(fontWeight: FontWeight.bold)),
                centerTitle: true,
                elevation: 0,
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
                body: ErrorWidgets(message: error.message, iconData: Icons.error_outline_rounded, onRetry: () async {await _userService.getUserInfo();})
            );
          } else {
            return Scaffold(
                backgroundColor: colorScheme.surface,
                appBar: AppBar(
                  title: const Text('Mon Profil', style: TextStyle(fontWeight: FontWeight.bold)),
                  centerTitle: true,
                  elevation: 0,
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                ),
                body: ErrorWidgets(message: "Erreur interne", iconData: Icons.error_outline_rounded, onRetry: () async {await _userService.getUserInfo();})
            );
          }
        }

        final mySqlUser = apiSnapshot.data!;
        return _buildProfileView(context, firebaseUser, mySqlUser, role);
      },
    );
  }


  Widget _buildProfileView(BuildContext context, User firebaseUser, UserInfos? mySqlUser,
      String role, {
        bool isLoading = false,
      }) {
    ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Mon Profil', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  _buildAvatarSection(),
                  const SizedBox(height: 16),
                  isLoading
                      ? _buildLoadingBar(width: 180, height: 24)
                      : Text(
                    mySqlUser?.name.toUpperCase() ?? "Utilisateur",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildRoleBadge(role, isLoading),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Contenu principal
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildInfoCard(
                    title: "Informations de contact",
                    children: [
                      _buildProfileItem(Icons.email_outlined, "Email", firebaseUser.email ?? 'Non renseigné'),
                      _buildProfileItem(
                        Icons.phone_android_outlined,
                        "Téléphone",
                        isLoading ? "Chargement..." : (mySqlUser?.phone ?? "Non renseigné"),
                        isGreyed: isLoading,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInfoCard(
                    title: "Actions Compte",
                    children: [
                      _buildActionTile(Icons.edit_outlined, "Modifier mon profil", () {}),
                      _buildActionTile(Icons.history_outlined, "Mes commandes", () {}),
                      _buildActionTile(
                        Icons.logout,
                        "Déconnexion",
                            () => _handleSignOut(context),
                        isDanger: true,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildGuestView(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Mon Profil', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 55,
                backgroundColor: Colors.amber[100],
                child: Icon(Icons.person, size: 70, color: colorScheme.primary),
              ),
              const SizedBox(height: 24),

              // Message
              const Text(
                "Connectez-vous pour accéder à votre profil",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                "Découvrez votre historique, vos commandes et personnalisez votre expérience.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              const SizedBox(height: 40),

              // Boutons
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterPage(label: "Rejoindre la Quincaillerie"),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                ),
                child: const Text("SE CONNECTER / S'INSCRIRE", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Retour à l'accueil", style: TextStyle(color: colorScheme.primary, fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSkeletonView() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: CircularProgressIndicator(color: Colors.amber[700])),
    );
  }



  Widget _buildAvatarSection() {
    return Stack(
      children: [
        CircleAvatar(
          radius: 55,
          backgroundColor: Colors.amber[100],
          child: const Icon(Icons.person, size: 70, color: Colors.brown),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: CircleAvatar(
            radius: 18,
            backgroundColor: Colors.amber[700],
            child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleBadge(String role, bool isLoading) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isLoading ? Colors.grey[300] : Colors.amber[700],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        role.toUpperCase(),
        style: TextStyle(
          color: isLoading ? Colors.grey[600] : Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildLoadingBar({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildInfoCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 15),
          ...children,
        ],
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value, {bool isGreyed = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: isGreyed ? Colors.grey : Colors.amber[700]),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: isGreyed ? Colors.grey : Colors.black87)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String label, VoidCallback onTap, {bool isDanger = false}) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: isDanger ? Colors.redAccent : Colors.amber[700]),
      title: Text(label, style: TextStyle(color: isDanger ? Colors.redAccent : Colors.black87, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: onTap,
    );
  }

  void _handleSignOut(BuildContext context) async {
    await context.read<UserProvider>().signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigation()),
            (route) => false,
      );
    }
  }
}
 */

import 'package:brixel/Exception/NoInternetConnectionException.dart';
import 'package:brixel/service/UserService.dart';
import 'package:brixel/ui/theme/AppColors.dart';
import 'package:brixel/ui/widgets/ErrorWidgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/UserProvider.dart';
import '../../Exception/AppException.dart';
import '../../data/modele/UserInfos.dart';
import '../widgets/MainNavigation.dart';
import 'authPages/client/RegisterPage.dart';

class ProfilePage extends StatelessWidget {
  static final UserService _userService = UserService();
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    if (userProvider.isUnknown) return _buildSkeletonView();

    if (!userProvider.isAuthenticated ||
        userProvider.currentUser == null ||
        userProvider.role == null ||
        userProvider.role!.isEmpty) {
      return _buildGuestView(context);
    }

    final firebaseUser = userProvider.currentUser!;
    final String role = userProvider.role!;

    return FutureBuilder<UserInfos?>(
      future: _userService.getUserInfo(),
      builder: (context, snapshot) {
        // ── Erreurs ───────────────────────────────────────────────
        if (snapshot.hasError || (snapshot.connectionState == ConnectionState.done && snapshot.data == null)) {
          final error = snapshot.error;
          IconData icon = Icons.error_outline_rounded;
          String msg = "Erreur interne";
          if (error is NoInternetConnectionException) {
            icon = Icons.wifi_off;
            msg = error.message;
          } else if (error is AppException) {
            msg = error.message;
          }
          return _errorScaffold(context, msg, icon);
        }

        final bool isLoading = snapshot.connectionState == ConnectionState.waiting;
        final UserInfos? mySqlUser = snapshot.data;

        return _buildProfileView(
          context: context,
          firebaseUser: firebaseUser,
          mySqlUser: mySqlUser,
          role: role,
          isLoading: isLoading,
        );
      },
    );
  }

  // ── Scaffold erreur ────────────────────────────────────────────────────────
  Widget _errorScaffold(BuildContext context, String msg, IconData icon) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(context),
      body: ErrorWidgets(
        message: msg,
        iconData: icon,
        onRetry: () async => _userService.getUserInfo(),
      ),
    );
  }

  // ── AppBar partagée ────────────────────────────────────────────────────────
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      //leading: const SizedBox.shrink(),

      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        onPressed: () => Navigator.pop(context),
      ),

      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Mon Profil",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 17,
              letterSpacing: 0.3,
            ),
          ),
          Text(
            "Gérez vos informations",
            style: TextStyle(color: Colors.white60, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ── Vue profil ─────────────────────────────────────────────────────────────
  Widget _buildProfileView({
    required BuildContext context,
    required User firebaseUser,
    required UserInfos? mySqlUser,
    required String role,
    bool isLoading = false,
  }) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ── Header hero ───────────────────────────────────────
            _buildHeroHeader(
              name: mySqlUser?.name ?? "Utilisateur",
              role: role,
              isLoading: isLoading,
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // ── Banner résumé ─────────────────────────────
                  _buildSummaryBanner(
                    email: firebaseUser.email ?? "Non renseigné",
                    phone: isLoading
                        ? "Chargement..."
                        : (mySqlUser?.phone ?? "Non renseigné"),
                    isLoading: isLoading,
                  ),
                  const SizedBox(height: 16),

                  // ── Infos de contact ──────────────────────────
                  _buildSectionHeader(
                      "Informations de contact", Icons.contact_mail_outlined),
                  const SizedBox(height: 10),
                  _buildInfoCard(children: [
                    _buildProfileItem(
                      icon: Icons.email_outlined,
                      label: "Email",
                      value: firebaseUser.email ?? "Non renseigné",
                      color: AppColors.infoVille,
                    ),
                    _buildDivider(),
                    _buildProfileItem(
                      icon: Icons.phone_android_outlined,
                      label: "Téléphone",
                      value: isLoading
                          ? "Chargement..."
                          : (mySqlUser?.phone ?? "Non renseigné"),
                      color: AppColors.infoPhone,
                      isGreyed: isLoading,
                    ),
                  ]),

                  const SizedBox(height: 20),

                  // ── Actions compte ────────────────────────────
                  _buildSectionHeader("Mon compte", Icons.manage_accounts_outlined),
                  const SizedBox(height: 10),
                  _buildInfoCard(children: [
                    _buildActionTile(
                      icon: Icons.edit_outlined,
                      label: "Modifier mon profil",
                      color: AppColors.primary,
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildActionTile(
                      icon: Icons.history_rounded,
                      label: "Mes commandes",
                      color: AppColors.infoVille,
                      onTap: () {},
                    ),
                    _buildDivider(),
                    _buildActionTile(
                      icon: Icons.logout_rounded,
                      label: "Déconnexion",
                      color: AppColors.accent,
                      onTap: () => _handleSignOut(context),
                      isDanger: true,
                    ),
                  ]),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero header ────────────────────────────────────────────────────────────
  Widget _buildHeroHeader({
    required String name,
    required String role,
    required bool isLoading,
  }) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Colors.white.withOpacity(0.25), width: 2),
                ),
                child: const Icon(Icons.person_rounded,
                    size: 42, color: Colors.white70),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt_rounded,
                      size: 13, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Nom
          isLoading
              ? _buildSkeleton(width: 160, height: 20)
              : Text(
            name.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),

          // Badge rôle — style _buildStatusBadge
          isLoading
              ? _buildSkeleton(width: 80, height: 24)
              : Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                  color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.statusOpen,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  role.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Banner résumé (pattern établi dans tout le projet) ─────────────────────
  Widget _buildSummaryBanner({
    required String email,
    required String phone,
    required bool isLoading,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildBannerStat(
            icon: Icons.verified_outlined,
            label: "Statut",
            value: "Vérifié",
            color: AppColors.priceGreen,
          ),
          _buildStatDivider(),
          _buildBannerStat(
            icon: Icons.shopping_bag_outlined,
            label: "Commandes",
            value: isLoading ? "—" : "0",
            color: AppColors.infoVille,
          ),
          _buildStatDivider(),
          _buildBannerStat(
            icon: Icons.favorite_outline_rounded,
            label: "Favoris",
            value: isLoading ? "—" : "0",
            color: AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildBannerStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w900, color: color),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() => Container(
    width: 0.5,
    height: 36,
    color: Colors.grey.shade200,
  );

  // ── En-tête section (identique StockPage, DashboardVendeur) ───────────────
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.primary),
        const SizedBox(width: 6),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 11,
            color: AppColors.primary,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  // ── Card infos ─────────────────────────────────────────────────────────────
  Widget _buildInfoCard({required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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

  Widget _buildDivider() => Divider(
    height: 1,
    color: Colors.grey.shade100,
    indent: 44,
  );

  // ── Ligne info ─────────────────────────────────────────────────────────────
  Widget _buildProfileItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isGreyed = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: (isGreyed ? Colors.grey : color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon,
                size: 17,
                color: isGreyed ? Colors.grey.shade400 : color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textMuted),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isGreyed
                        ? Colors.grey.shade400
                        : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Ligne action ───────────────────────────────────────────────────────────
  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isDanger = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 17, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDanger ? AppColors.accent : AppColors.textPrimary,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 11, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }

  // ── Vue invité ─────────────────────────────────────────────────────────────
  Widget _buildGuestView(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: _buildAppBar(context),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person_outline_rounded,
                    size: 44, color: AppColors.primary),
              ),
              const SizedBox(height: 20),
              const Text(
                "Accédez à votre profil",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Connectez-vous pour accéder à votre historique, commandes et préférences.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade500, height: 1.5),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RegisterPage(
                          label: "Rejoindre la Quincaillerie"),
                    ),
                  ),
                  icon: const Icon(Icons.login_rounded,
                      color: Colors.white, size: 18),
                  label: const Text(
                    "SE CONNECTER / S'INSCRIRE",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        letterSpacing: 0.4),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                  ),
                  child: const Text(
                    "Retour à l'accueil",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Skeleton loader ────────────────────────────────────────────────────────
  Widget _buildSkeletonView() {
    return const Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );
  }

  Widget _buildSkeleton({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  // ── Sign out ───────────────────────────────────────────────────────────────
  void _handleSignOut(BuildContext context) async {
    await context.read<UserProvider>().signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainNavigation()),
            (route) => false,
      );
    }
  }
}