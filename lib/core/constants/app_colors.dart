import 'package:flutter/material.dart';

/// Paleta de cores do aplicativo Adote Um Pet.
///
/// A cor primária (coral/pêssego) transmite calor e afeto,
/// enquanto a cor secundária (azul-verde) evoca confiança e saúde.
abstract final class AppColors {
  // Cor primária — Coral/Pêssego
  static const Color primary = Color(0xFFFF8A65);
  static const Color primaryLight = Color(0xFFFFBB93);
  static const Color primaryDark = Color(0xFFC75B39);

  // Cor secundária — Azul/Verde Água
  static const Color secondary = Color(0xFF4DB6AC);
  static const Color secondaryLight = Color(0xFF82E9DE);
  static const Color secondaryDark = Color(0xFF00867D);

  // Fundos e superfícies
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Textos
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Status
  static const Color success = Color(0xFF66BB6A);
  static const Color warning = Color(0xFFFFA726);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF42A5F5);

  // Divisores e bordas
  static const Color divider = Color(0xFFEEEEEE);
  static const Color border = Color(0xFFE0E0E0);

  // Overlay e sombras
  static const Color shadow = Color(0x1A000000);
  static const Color overlay = Color(0x80000000);
}
