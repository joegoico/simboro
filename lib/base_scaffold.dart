import 'package:flutter/material.dart';
import 'custom_widgets/custom_navigation_bar.dart';
import 'custom_widgets/custom_app_bar.dart';
import 'custom_widgets/custom_drawer.dart';

/// Widget de envoltorio (Wrapper) para estandarizar el diseño de las pantallas.
///
/// Centraliza los componentes comunes como el [CustomAppBar], [CustomDrawer]
/// y el [CustomBottomNavigationBar], permitiendo configuraciones específicas
/// por pantalla mediante parámetros booleanos.
class BaseScaffold extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? customBottomNavigationBar;
  final bool showSearchBar;
  final bool showDrawer;
  final Widget? leading;

  const BaseScaffold({
    super.key,
    required this.title,
    required this.child,
    required this.showSearchBar,
    required this.showDrawer,
    this.customBottomNavigationBar,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      // Uso de colores semánticos de Material 3 para el fondo
      backgroundColor: theme.colorScheme.surfaceContainerHigh,

      // Cabecera común personalizada
      appBar: CustomAppBar(
        showSearchBar: showSearchBar,
        title: title,
        customLeading: leading,
      ),

      // Renderizado condicional del menú lateral
      drawer: showDrawer ? const CustomDrawer() : null,

      // El contenido principal de cada pantalla
      body: child,

      // Barra de navegación inferior global
      bottomNavigationBar: const CustomBottomNavigationBar(),
    );
  }
}
