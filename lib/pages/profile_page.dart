import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:p04_mobile/pages/authPages/client/RegisterPage.dart';
import 'package:p04_mobile/widgets/MainNavigation.dart';
import '../modele/UserInfos.dart';
import '../service/ApiService.dart';

class ProfilePage extends StatelessWidget {
  static const ApiService _apiService = ApiService();

  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasData) {
          User firebaseUser = snapshot.data!;
          // On appelle le FutureBuilder ici pour récupérer les infos MySQL
          return _buildProfileDataFetcher(context, firebaseUser);
        }

        return _buildGuestView(context);
      },
    );
  }

  // Ce widget fait le pont entre Firebase et ton API Spring Boot
  Widget _buildProfileDataFetcher(BuildContext context, User firebaseUser) {
    return FutureBuilder<UserInfos?>(
      future: _apiService.getUserInfo(), // Ton appel API avec le Token
      builder: (context, apiSnapshot) {
        // --- CHARGEMENT ---
        if (apiSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: Colors.amber)),
          );
        }

        // --- ERREUR (Serveur éteint, 404, etc.) ---
        if (apiSnapshot.hasError || apiSnapshot.data == null) {
          return _buildErrorView(context, firebaseUser);
        }

        // --- SUCCÈS ---
        final mySqlUser = apiSnapshot.data!;
        return _buildProfileView(context, firebaseUser, mySqlUser);
      },
    );
  }

  Widget _buildProfileView(BuildContext context, User firebaseUser, UserInfos mySqlUser) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background for contrast
      appBar: AppBar(
        title: const Text('Mon Profil', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.amber),
            onPressed: () {
              // Navigate to Settings or show a BottomSheet
              //_showSettingsMenu(context);
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER SECTION ---
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
              ),
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  Stack(
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
                  ),
                  const SizedBox(height: 16),
                  Text(
                    mySqlUser.name.toUpperCase(),
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber[700],
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      "CLIENT",
                      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- INFO & ACTIONS CARDS ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildInfoCard(
                    title: "Informations de contact",
                    children: [
                      _buildProfileItem(Icons.email_outlined, "Email", firebaseUser.email ?? 'Non renseigné'),
                      _buildProfileItem(Icons.phone_android_outlined, "Téléphone", mySqlUser.phone),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInfoCard(
                    title: "Actions Compte",
                    children: [
                      _buildActionTile(Icons.edit_outlined, "Modifier mon profil", () {
                        // Navigate to Edit Profile Page
                      }),
                      _buildActionTile(Icons.history_outlined, "Mes commandes", () {}),
                      _buildActionTile(Icons.logout, "Déconnexion", (){FirebaseAuth.instance.signOut(); Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainNavigation())); }, isDanger: true),
                    ],
                  ),
                  //const SizedBox(height: 30),
                  //Text("UID: ${firebaseUser.uid}", style: TextStyle(color: Colors.grey[400], fontSize: 10)),
                  //const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// --- HELPER WIDGETS FOR CLEAN DESIGN ---

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

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.amber[700]),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
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


  Widget _buildErrorView(BuildContext context, User firebaseUser) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profil"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône triste ou de réseau
              Icon(Icons.wifi_off_rounded, size: 80, color: Colors.amber[700]),
              const SizedBox(height: 24),

              const Text(
                "Oups ! Problème de connexion",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              const Text(
                "Nous n'avons pas pu récupérer vos informations. Vérifiez votre connexion internet et réessayez.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 32),

              // BOUTON RÉESSAYER
              ElevatedButton.icon(
                onPressed: () {
                  // Cette astuce force Flutter à redessiner le widget
                  // et donc à relancer l'appel API du FutureBuilder
                  (context as Element).markNeedsBuild();
                },
                icon: const Icon(Icons.refresh),
                label: const Text("RÉESSAYER"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700],
                  foregroundColor: Colors.black,
                  minimumSize: const Size(200, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


// Garde ton _buildGuestView actuel ici...
  Widget _buildGuestView(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_circle_outlined, size: 80, color: Colors.grey),
            const Text("Veuillez vous connecter pour voir votre profil"),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // On ouvre la RegisterPage comme une NOUVELLE page (Route)
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterPage(
                        page: ProfilePage(),
                        label: "Rejoindre la Quincaillerie"
                    ))
                );
              },
              child: const Text("Se connecter / S'inscrire"),
            ),
          ],
        ),
      ),
    );
  }
}
