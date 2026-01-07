import 'package:flutter/material.dart';

/// Proveedor encargado de la personalización visual de la interfaz.
///
/// Utiliza el patrón Observer para notificar a la raíz de la aplicación
/// ([MaterialApp]) sobre cambios en la preferencia de brillo del usuario.
class AppThemeNotifier extends ChangeNotifier {
  /// Estado interno de la preferencia de tema.
  bool _isDarkTheme = false;

  /// Expone el estado actual como un booleano para controles de tipo Switch.
  bool get isDarkTheme => _isDarkTheme;

  /// Retorna el [ThemeMode] correspondiente para ser inyectado
  /// directamente en el widget principal de Flutter.
  ThemeMode get currentThemeMode =>
      _isDarkTheme ? ThemeMode.dark : ThemeMode.light;

  /// Modifica la preferencia visual y propaga el cambio a todos los listeners.
  ///
  /// [isDark] determina si se debe activar el Modo Oscuro.
  void toggleTheme(bool isDark) {
    _isDarkTheme = isDark;
    notifyListeners();
  }
}
