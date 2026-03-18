import 'package:flutter/material.dart';

class ErrorWidgets extends StatelessWidget {
  final String? message;
  final IconData iconData; // Utiliser IconData est plus flexible qu'un widget Icon complet
  final VoidCallback onRetry;

  const ErrorWidgets({
    super.key,
    required this.message,
    required this.iconData,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Prend le minimum de place verticale
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Conteneur circulaire pour l'icône afin de donner du relief
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                color: colorScheme.error,
                size: 64,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "Erreur",
              style: textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message ?? "Erreur",
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 20),
              label: const Text("Réessayer"),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}