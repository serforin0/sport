import 'package:flutter/material.dart';

/// Tokens de marca HubSport (guía de observaciones §5).
class AppColors {
  AppColors._();

  /// Fondo principal (slate).
  static const Color background = Color(0xFF0F172A);

  /// Superficie / cards.
  static const Color surface = Color(0xFF1E293B);

  /// Azul marca e interacción (CTAs, links, barra).
  static const Color brand = Color(0xFF3B82F6);

  /// Azul claro wordmark "SPORT" / acentos de perfil.
  static const Color brandLight = Color(0xFF64A6FF);
  static const Color brandCyan = Color(0xFF2CB5FF);

  /// Dorado: solo números de rendimiento.
  static const Color performanceGold = Color(0xFFEAB308);

  /// Verde: solo estados (verificado, en vivo).
  static const Color statusGreen = Color(0xFF22C55E);

  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xB3FFFFFF); // white70
  static const Color textMuted = Color(0x61FFFFFF); // white38
}
