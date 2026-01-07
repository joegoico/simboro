import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Barra de navegación inferior personalizada integrada con [GoRouter].
///
/// A diferencia de los componentes estándar, este widget sincroniza su estado
/// visual (ícono seleccionado) basándose en la ubicación actual de la ruta
/// en el stack de navegación, permitiendo una navegación consistente.
class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({super.key});

  /// Lista de rutas base para la navegación.
  static const List<String> navRoutes = ['/alumnos', '/deudores'];

  /// Íconos representativos para cada sección.
  static const List<IconData> navIcons = [
    Icons.people_alt_rounded,
    Icons.money_off_rounded,
  ];

  /// Etiquetas descriptivas para los ítems de navegación.
  static const List<String> navLabels = ['Alumnos', 'Deudores'];

  @override
  Widget build(BuildContext context) {
    // Lógica de detección de ruta:
    // Comparamos la ubicación actual de GoRouter con nuestras rutas definidas.
    int? selectedIndex;
    final String currentLocation = GoRouterState.of(context).matchedLocation;

    for (int i = 0; i < navRoutes.length; i++) {
      // Usamos 'startsWith' para que el ícono permanezca resaltado
      // incluso si estamos en una sub-ruta (ej: /alumnos/detalle/1).
      if (currentLocation.startsWith(navRoutes[i])) {
        selectedIndex = i;
        break;
      }
    }

    final bool isInNavPages = selectedIndex != null;
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 3,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(navRoutes.length, (index) {
          final bool isSelected = isInNavPages && selectedIndex == index;

          // Color adaptativo: 'tertiary' para el activo, 'grey' para el inactivo.
          final iconColor =
              isSelected ? theme.colorScheme.tertiary : Colors.grey;

          return InkWell(
            onTap: () {
              // Navegación declarativa: pasamos el label como 'extra'
              // para potenciales usos en el encabezado de la página destino.
              context.go(navRoutes[index], extra: navLabels[index]);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(navIcons[index], color: iconColor),
                const SizedBox(height: 4),
                Text(
                  navLabels[index],
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
