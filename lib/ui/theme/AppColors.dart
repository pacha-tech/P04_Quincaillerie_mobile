import 'package:flutter/material.dart';

/// Palette centralisée — importez ce fichier partout dans l'app
/// Usage : AppColors.primary, AppColors.accent, etc.
class AppColors {
  AppColors._();

  // ── Couleurs principales ────────────────────────────────────────────────────
  /// Fond sombre navbar / appbar
  static const Color primary    = Color(0xFF1A1A2E);


  ///Couleurs secondaire
  static const Color secondary  = Color(0xFF3D3E50);

  /// Rouge vif — promotions, badges, accents
  static const Color accent     = Color(0xFFE94560);
  /// Fond général des pages
  static const Color surface    = Color(0xFFF8F9FB);
  /// Fond des cartes
  static const Color cardBg     = Colors.white;

  // ── Prix & disponibilité ───────────────────────────────────────────────────
  /// Vert — prix, stock disponible, succès
  static const Color priceGreen = Color(0xFF00897B);
  /// Vert foncé texte sur fond clair
  static const Color greenDark  = Color(0xFF2E7D32);
  /// Vert fond badge "Ouvert"
  static const Color greenLight = Color(0xFFE8F5E9);
  /// Vert bouton appel
  static const Color callGreen  = Color(0xFF00897B);

  // ── Statuts ────────────────────────────────────────────────────────────────
  /// Vert point "Ouvert"
  static const Color statusOpen   = Color(0xFF43A047);
  /// Rouge point "Fermé"
  static const Color statusClosed = Color(0xFFE53935);
  /// Rouge fond badge "Fermé"
  static const Color closedLight  = Color(0xFFFFEBEE);
  /// Rouge texte badge "Fermé"
  static const Color closedDark   = Color(0xFFC62828);

  // ── Étoiles / notation ────────────────────────────────────────────────────
  /// Jaune étoiles
  static const Color starYellow  = Color(0xFFFFB300);
  /// Fond container notation
  static const Color starBgWarm  = Color(0xFFFFF8E1);
  /// Texte note
  static const Color starTextBrown = Color(0xFF7B5800);

  // ── Icônes infos ──────────────────────────────────────────────────────────
  static const Color infoPhone    = Color(0xFF00897B);
  static const Color infoVille    = Color(0xFF1E88E5);
  static const Color infoQuartier = Color(0xFF5E35B1);
  static const Color infoPrecision= Color(0xFFE53935);
  static const Color infoRegion   = Color(0xFF43A047);

  // ── Textes ────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1A1A2E);
  static const Color textSecondary = Color(0xFF2D2D2D);
  static const Color textMuted     = Color(0xFF444444);

  // ── Notifications ─────────────────────────────────────────────────────────
  static const Color notifSuccess = Colors.green;
  static const Color notifWarning = Colors.orange;
  static const Color notifError   = Colors.red;
}