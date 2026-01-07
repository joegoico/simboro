import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_gym/base_scaffold.dart';

/// Envoltorio inteligente que configura la estructura visual base según la ruta activa.
///
/// Este componente centraliza la lógica de visualización del [BaseScaffold],
/// determinando dinámicamente el título, la visibilidad del menú lateral (Drawer)
/// y el comportamiento de la navegación hacia atrás.
class ShellScaffoldWrapper extends StatelessWidget {
  /// El estado actual de la ruta proporcionado por GoRouter.
  final GoRouterState state;

  /// El contenido específico de la pantalla que se renderizará dentro del Scaffold.
  final Widget child;

  const ShellScaffoldWrapper({
    super.key,
    required this.state,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Lógica de Navegación: Determinamos si el usuario está en una sub-pantalla
    // que requiere un botón de retroceso en lugar del menú lateral.
    final bool requiereBack =
        (state.matchedLocation == '/pagos' ||
            state.matchedLocation == '/precios');

    // 2. Gestión Dinámica de Títulos:
    // Prioriza rutas específicas y utiliza 'state.extra' como fallback para títulos dinámicos.
    late final String title;
    if (state.matchedLocation == '/pagos') {
      title = 'Pagos';
    } else if (state.matchedLocation == '/precios') {
      title = 'Precios';
    } else {
      title = state.extra is String ? state.extra as String : 'Le Groupe Gym';
    }

    // El Drawer solo se muestra en pantallas de nivel raíz (sin botón back).
    final bool showDrawer = !requiereBack;

    // Configuración de visibilidad del buscador según el contexto de la sección.
    final bool showSearchBar =
        (state.matchedLocation == '/alumnos' ||
            state.matchedLocation == '/deudores');

    // 3. Implementación del Leading Widget (Botón de Acción Izquierdo):
    // Maneja tanto el retroceso estándar como redirecciones manuales
    // en caso de navegación directa (Deep Linking).
    final Widget? leadingWidget =
        requiereBack
            ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                } else {
                  // Fallback de seguridad: asegura que el usuario no quede atrapado
                  // si entró directamente a una sub-ruta.
                  if (state.matchedLocation.startsWith('/pagos')) {
                    context.go('/alumnos');
                  } else if (state.matchedLocation.startsWith('/precios')) {
                    context.go('/disciplinas');
                  }
                }
              },
            )
            : null;

    // Retorno del Scaffold base con la configuración inyectada.
    return BaseScaffold(
      title: title,
      showDrawer: showDrawer,
      leading: leadingWidget,
      showSearchBar: showSearchBar,
      child: child,
    );
  }
}
