import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  const CustomBottomNavigationBar({Key? key}) : super(key: key);

  // Definimos las rutas, íconos y etiquetas de la barra.
  static const List<String> navRoutes = [
    '/alumnos',
    '/deudores',
  ];

  static const List<IconData> navIcons = [
    Icons.people_alt_rounded,
    Icons.money_off_rounded,
  ];

  static const List<String> navLabels = [
    'Alumnos',
    'Deudores',
  ];

  @override
  Widget build(BuildContext context) {
    // Obtenemos la localización actual


    // Determinamos si la ruta actual está en la lista de la navegación.
    int? selectedIndex;
    for (int i = 0; i < navRoutes.length; i++) {
      if (GoRouterState.of(context).matchedLocation.startsWith(navRoutes[i])) {
        selectedIndex = i;
        break;
      }
    }
    
    // Si la ruta actual no está en navRoutes, isInNavPages será false,
    // y ninguno de los íconos se resaltará.
    final bool isInNavPages = selectedIndex != null;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 1,
            blurRadius: 3,)]

      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(navRoutes.length, (index) {
          // Si estamos en alguna de las páginas de la barra, resalta el que esté seleccionado.
          final bool isSelected =
              isInNavPages && selectedIndex == index;
          final iconColor = isSelected ? Theme.of(context).colorScheme.tertiary : Colors.grey;

          return InkWell(
            onTap: () {
              // Navega a la ruta correspondiente.
              context.go(navRoutes[index], extra: navLabels[index]);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  navIcons[index],
                  color: iconColor,
                ),
                const SizedBox(height: 4),
                Text(
                  navLabels[index],
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 12,
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