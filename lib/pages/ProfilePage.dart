import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../modele/UserInfos.dart';
import '../../../service/ApiService.dart';
import '../../../widgets/MainNavigation.dart';
import '../provider/UserProvider.dart';
import 'authPages/client/RegisterPage.dart';

class ProfilePage extends StatelessWidget {
  static const ApiService _apiService = ApiService();

  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();

    // 1. État de chargement initial (Firebase)
    if (userProvider.isUnknown) {
      return _buildSkeletonView();
    }

    // 2. État "Invité" (Non connecté)
    if (userProvider.isUnauthenticated || userProvider.currentUser == null) {
      return _buildGuestView(context);
    }

    // 3. État "Connecté"
    final firebaseUser = userProvider.currentUser!;
    final userRole = userProvider.role;

    return FutureBuilder<UserInfos?>(
      future: _apiService.getUserInfo(),
      builder: (context, apiSnapshot) {
        // Au lieu de retourner un Scaffold vide, on affiche la structure avec des placeholders
        if (apiSnapshot.connectionState == ConnectionState.waiting) {
          return _buildProfileView(
            context,
            firebaseUser,
            null, // mySqlUser est null pendant le chargement
            userRole ?? "Chargement...",
            isLoading: true,
          );
        }

        if (apiSnapshot.hasError || apiSnapshot.data == null) {
          return _buildErrorView(context, firebaseUser);
        }

        final mySqlUser = apiSnapshot.data!;
        return _buildProfileView(context, firebaseUser, mySqlUser, userRole ?? "CLIENT");
      },
    );
  }

  // --- VUE PRINCIPALE (Gère aussi l'état de chargement partiel) ---
  Widget _buildProfileView(BuildContext context, User firebaseUser, UserInfos? mySqlUser, String role, {bool isLoading = false}) {
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
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  _buildAvatarSection(),
                  const SizedBox(height: 16),
                  // Placeholder pour le nom
                  isLoading
                      ? _buildLoadingBar(width: 150, height: 20)
                      : Text(mySqlUser?.name.toUpperCase() ?? "", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  // Badge du rôle
                  _buildRoleBadge(role, isLoading),
                ],
              ),
            ),
            const SizedBox(height: 20),
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
                          isLoading ? "Chargement..." : (mySqlUser?.phone ?? "N/A"),
                          isGreyed: isLoading
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInfoCard(
                    title: "Actions Compte",
                    children: [
                      _buildActionTile(Icons.edit_outlined, "Modifier mon profil", () {}),
                      _buildActionTile(Icons.history_outlined, "Mes commandes", () {}),
                      _buildActionTile(Icons.logout, "Déconnexion", () => _handleSignOut(context), isDanger: true),
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

  // --- COMPOSANTS DE CHARGEMENT (Placeholders) ---

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

  // --- AUTRES COMPOSANTS ---

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

  // Vue affichée quand le UserProvider ne sait pas encore si on est connecté ou non
  Widget _buildSkeletonView() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(child: CircularProgressIndicator(color: Colors.amber[700])),
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon Profil'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle_outlined, size: 100, color: Colors.grey),
            const Text("Connectez-vous pour accéder à votre profil"),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage(page: ProfilePage(), label: "Rejoindre la Quincaillerie"))),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber[700]),
              child: const Text("SE CONNECTER / S'INSCRIRE", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context, User firebaseUser) {
    return Scaffold(
      appBar: AppBar(title: const Text("Erreur")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const Text("Impossible de charger les infos MySQL"),
            TextButton(onPressed: () => (context as Element).markNeedsBuild(), child: const Text("Réessayer"))
          ],
        ),
      ),
    );
  }

  void _handleSignOut(BuildContext context) async {
    await context.read<UserProvider>().signOut();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MainNavigation()), (route) => false);
    }
  }
}