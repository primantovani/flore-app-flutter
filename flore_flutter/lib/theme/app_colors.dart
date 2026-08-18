import 'package:flutter/material.dart';

/// Paleta central da Florê. Antes espalhada como `Color(0xFF...)` duplicado
/// em main.dart e em cada tela — qualquer ajuste de marca exigia caçar
/// todas as ocorrências.
class AppColors {
  AppColors._();

  static const teal = Color(0xFF2a7d70);
  static const tealLight = Color(0xFF3d9e8f);
  static const tealDark = Color(0xFF1a5c52);
  static const orange = Color(0xFFd4541a);
  static const cream = Color(0xFFf7f5f2);
  static const dark = Color(0xFF1e1e1e);
  static const gray = Color(0xFF6b6b6b);
  static const grayLight = Color(0xFFaaaaaa);
  static const border = Color(0xFFe0e0e0);
  static const tealSurface = Color(0xFFe8f4f1);
  static const white = Colors.white;
}
