import 'package:flutter/material.dart';

// 1. On crée une extension de thème
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color success;
  const AppColorsExtension({required this.success});

  @override
  ThemeExtension<AppColorsExtension> copyWith({Color? success}) =>
      AppColorsExtension(success: success ?? this.success);

  @override
  ThemeExtension<AppColorsExtension> lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(success: Color.lerp(success, other.success, t)!);
  }
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFFA000),
        secondary: const Color(0xFFFFA000),
        primary: Colors.brown,
        surface: Colors.grey[50]!,
        error: Colors.redAccent,
      ),
      // 2. On ajoute l'extension ici
      extensions: [
        const AppColorsExtension(success: Colors.green),
      ],
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFA000),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}