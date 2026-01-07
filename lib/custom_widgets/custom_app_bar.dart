import 'package:flutter/material.dart';

/// Un encabezado de aplicación personalizado que implementa [PreferredSizeWidget].
///
/// Este widget centraliza la apariencia de las barras superiores en toda la app,
/// asegurando que el esquema de colores y las elevaciones sean consistentes
/// con el [ThemeData] definido.
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Determina si se debe reservar espacio o mostrar una barra de búsqueda.
  /// (Funcionalidad proyectada para futuras iteraciones).
  final bool showSearchBar;

  /// El texto que se mostrará en el centro o inicio de la barra.
  final String title;

  /// Widget opcional para el área de control izquierda (ej: botón de menú o atrás).
  final Widget? customLeading;

  const CustomAppBar({
    super.key,
    required this.showSearchBar,
    required this.title,
    required this.customLeading,
  });

  @override
  Widget build(BuildContext context) {
    // Acceso al contexto de tema para garantizar adaptabilidad (Modo oscuro/claro)
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: theme.colorScheme.primary,
      shadowColor: theme.colorScheme.shadow,
      elevation: 2, // Sutil separación visual del contenido
      title: Text(title, style: TextStyle(color: theme.colorScheme.onPrimary)),
      leading: customLeading,

      // Nota de diseño: El parámetro 'bottom' puede extenderse aquí
      // si showSearchBar se activa en el futuro.
    );
  }

  /// Define la altura estándar de la barra para el framework de Flutter.
  ///
  /// Utiliza [kToolbarHeight] para mantener las dimensiones recomendadas
  /// por las guías de Material Design.
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
