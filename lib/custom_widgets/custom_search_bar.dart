import 'package:flutter/material.dart';
import 'package:sistema_gym/objetos/alumno.dart';

/// Callback personalizado que se dispara al seleccionar un [Alumno] del buscador.
typedef OnAlumnoSelected = void Function(Alumno alumno);

/// Un buscador especializado que permite filtrar y seleccionar alumnos de una lista local.
///
/// Implementa el patrón [SearchAnchor] de Material 3 para proporcionar una vista
/// de sugerencias integrada y animada.
class AlumnosSearchBar extends StatefulWidget {
  /// La fuente de datos completa sobre la cual se realizará la búsqueda.
  final List<Alumno> allAlumnos;

  /// Función que se ejecuta cuando el usuario confirma la selección.
  final OnAlumnoSelected? onAlumnoSelected;

  /// Texto de ayuda visual dentro del campo de entrada.
  final String hintText;

  const AlumnosSearchBar({
    super.key,
    required this.allAlumnos,
    this.onAlumnoSelected,
    this.hintText = "Buscar alumnos...",
  });

  @override
  State<AlumnosSearchBar> createState() => _AlumnosSearchBarState();
}

class _AlumnosSearchBarState extends State<AlumnosSearchBar> {
  /// Controlador que gestiona la apertura, cierre y texto de la vista de búsqueda.
  final SearchController _searchController = SearchController();

  /// Lista local que almacena los resultados filtrados en tiempo real.
  List<Alumno> _filteredAlumnos = [];

  @override
  void initState() {
    super.initState();
    _filteredAlumnos = [];
  }

  @override
  void dispose() {
    // Liberación de recursos para evitar fugas de memoria (Memory Leaks).
    _searchController.dispose();
    super.dispose();
  }

  /// Ejecuta el algoritmo de filtrado sobre la lista de alumnos.
  ///
  /// Realiza una comparación 'case-insensitive' (ignora mayúsculas/minúsculas)
  /// sobre los campos de nombre y apellido.
  void _performFiltering(String query) {
    if (query.isEmpty) {
      if (mounted) {
        setState(() => _filteredAlumnos = []);
      }
      return;
    }

    if (mounted) {
      setState(() {
        _filteredAlumnos =
            widget.allAlumnos
                .where(
                  (alumno) =>
                      (alumno.getNombre()).toLowerCase().contains(
                        query.toLowerCase(),
                      ) ||
                      (alumno.getApellido()).toLowerCase().contains(
                        query.toLowerCase(),
                      ),
                )
                .toList();
      });
    }

    // Abre automáticamente la vista de sugerencias si hay una consulta activa.
    if (query.isNotEmpty && !_searchController.isOpen && mounted) {
      _searchController.openView();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SearchAnchor(
      viewBarPadding: const EdgeInsets.only(left: 7, right: 7),
      searchController: _searchController,
      builder: (BuildContext context, SearchController controller) {
        return SearchBar(
          controller: controller,
          backgroundColor: WidgetStatePropertyAll(
            theme.colorScheme.surfaceContainerHigh,
          ),
          hintText: widget.hintText,
          // Sincronización de estilos con el sistema de temas.
          hintStyle: WidgetStatePropertyAll(
            TextStyle(color: theme.colorScheme.onSurfaceVariant),
          ),
          textStyle: WidgetStatePropertyAll(
            TextStyle(color: theme.colorScheme.onSurface),
          ),
          padding: const WidgetStatePropertyAll<EdgeInsets>(
            EdgeInsets.symmetric(horizontal: 16.0),
          ),
          onTap: () {
            if (!controller.isOpen) controller.openView();
            if (controller.text.isNotEmpty) _performFiltering(controller.text);
          },
          onChanged: (query) => _performFiltering(query),
          leading: Icon(
            Icons.search,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          trailing: [
            // Listener optimizado que muestra el botón de borrado solo si hay texto.
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                if (value.text.isNotEmpty) {
                  return IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () {
                      controller.clear();
                      _performFiltering('');
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        );
      },
      suggestionsBuilder: (BuildContext context, SearchController controller) {
        // Manejo de estado: Vista vacía.
        if (_filteredAlumnos.isEmpty && controller.text.isNotEmpty) {
          return [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'No se encontraron alumnos para "${controller.text}"',
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
            ),
          ];
        }

        // Generación dinámica de la lista de resultados.
        return List<Widget>.generate(_filteredAlumnos.length, (int index) {
          final Alumno alumno = _filteredAlumnos[index];
          final String displayText =
              '${alumno.getNombre()} ${alumno.getApellido()}';
          return ListTile(
            title: Text(
              displayText,
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
            onTap: () {
              controller.closeView(displayText);
              widget.onAlumnoSelected?.call(alumno);
              // Gestión de foco para ocultar el teclado virtual.
              FocusScope.of(context).unfocus();
            },
          );
        });
      },
      viewSurfaceTintColor: theme.colorScheme.surface,
      viewElevation: 4.0,
    );
  }
}
