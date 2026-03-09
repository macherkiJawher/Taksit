import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../screens/auth/login_screen.dart';

class LogoutHelper {
  static void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Déconnexion"),
        content: const Text("Êtes-vous sûr de vouloir vous déconnecter ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () async {
              await AuthService.logout();
              if (context.mounted) {
                // Nettoyer la stack et aller au login
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false, // Supprimer tous les écrans de la stack
                );
              }
            },
            child: const Text("Déconnexion"),
          ),
        ],
      ),
    );
  }
}
