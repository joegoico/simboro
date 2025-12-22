import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_gym/base_scaffold.dart';

class ShellScaffoldWrapper extends StatelessWidget {
  final GoRouterState state;
  final Widget child;

  const ShellScaffoldWrapper({
    Key? key,
    required this.state,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Determina si se requiere botón "back" en función de la ruta.
    final bool requiereBack = (state.matchedLocation == '/pagos' ||
        state.matchedLocation == '/precios');

    // Configura el título según la ruta.
    late final String title;
    if (state.matchedLocation == '/pagos') {
      title = 'Pagos';
    } else if (state.matchedLocation == '/precios') {
      title = 'Precios';
    } else {
      title = state.extra is String ? state.extra as String : 'Le Groupe Gym';
    }

    // Si se requiere botón de back, no mostramos el Drawer.
    final bool showDrawer = !requiereBack;
    // Se muestra la barra de búsqueda solo para ciertas rutas.
    final bool showSearchBar =
    (state.matchedLocation == '/alumnos' || state.matchedLocation == '/deudores');

    // Si se requiere botón de volver, creamos un widget leading custom.
    final Widget? leadingWidget = requiereBack
        ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              // Dependiendo de la ruta actual, se redirige a otra.
              if (GoRouterState.of(context).matchedLocation.startsWith('/pagos')) {
                context.go('/alumnos');
              } else if (GoRouterState.of(context).matchedLocation.startsWith('/precios')) {
                context.go('/disciplinas');
              }
            }
          },
        )
        : null;

    // Retornamos el BaseScaffold con los parámetros configurados.
    return BaseScaffold(
      title: title,
      showDrawer: showDrawer,
      leading: leadingWidget,
      showSearchBar: showSearchBar,
      child: child,
    );
  }
}