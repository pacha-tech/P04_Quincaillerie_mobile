import 'package:flutter/material.dart';
import '../theme/AppColors.dart';

class ErrorWidgets extends StatelessWidget {
  final String? message;
  final IconData iconData;
  final VoidCallback onRetry;

  const ErrorWidgets({
    super.key,
    required this.message,
    required this.iconData,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ── Icône ────────────────────────────────────────────────────
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: AppColors.accent, size: 38),
            ),
            const SizedBox(height: 20),

            // ── Titre ─────────────────────────────────────────────────────
            const Text(
              "Une erreur est survenue",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.primary,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 8),

            // ── Message ───────────────────────────────────────────────────
            Text(
              message ?? "Impossible de charger les données.\nVérifiez votre connexion et réessayez.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 28),

            // ── Bouton réessayer ──────────────────────────────────────────
            SizedBox(
              height: 46,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, size: 18, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      "Réessayer",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}