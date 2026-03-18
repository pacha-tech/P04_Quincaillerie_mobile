

/*
import 'package:flutter/material.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:provider/provider.dart';
// Remplacez ces imports par les chemins réels de votre projet
// import 'package:votre_projet/providers/user_provider.dart';
// import 'package:votre_projet/pages/main_navigation.dart';

class DialogHelper {
  /// Affiche une boîte de dialogue de succès personnalisée
  /// après la création d'un compte ou une connexion.
  static void showSuccessRegistration(BuildContext context, String userName) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.bottomSlide,
      title: "Bienvenue $userName !",
      desc: 'Votre compte client est prêt.',
      btnOkText: "C'est parti !",
      btnOkColor: Colors.yellow[700],
      buttonsTextStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      btnOkOnPress: () {
        // 1. Rafraîchir les permissions de l'utilisateur
        // context.read<UserProvider>().refreshClaimsAfterLogin();

        // 2. Naviguer vers l'interface principale et vider la pile de navigation
        /*
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigation()),
          (route) => false,
        );
        */
      },
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
    ).show();
  }
}

class AwesomeDialog extends StatelessWidget {
  final String type;
  final String title;
  final String description;
  final String btn
  const AwesomeDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

 */
