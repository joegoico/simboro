
import 'package:flutter/material.dart';
import 'package:sistema_gym/objetos/alumno.dart';

// Callback type when an Alumno is selected from the search results
typedef OnAlumnoSelected = void Function(Alumno alumno);

class AlumnosSearchBar extends StatefulWidget {
  final List<Alumno> allAlumnos; // The complete list of students to search from
  final OnAlumnoSelected? onAlumnoSelected;
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
  final SearchController _searchController = SearchController();
  List<Alumno> _filteredAlumnos = [];

  @override
  void initState() {
    super.initState();
    _filteredAlumnos = [];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performFiltering(String query) {
    if (query.isEmpty) {
      if (mounted) {
        setState(() {
          _filteredAlumnos = []; // Clear suggestions if query is empty
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _filteredAlumnos = widget.allAlumnos
            .where((alumno) =>
        (alumno.getNombre()).toLowerCase().contains(query.toLowerCase()) ||
            (alumno.getApellido()).toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }

    // Ensure the suggestions view is open when there's a query and results
    if (query.isNotEmpty && !_searchController.isOpen && mounted) {
      _searchController.openView();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SearchAnchor(
      viewBarPadding: EdgeInsets.only(left: 7, right: 7),
      searchController: _searchController,
      builder: (BuildContext context, SearchController controller) {
        return SearchBar(
          controller: controller,
          backgroundColor: WidgetStatePropertyAll(theme.colorScheme.surfaceContainerHigh),
          hintText: widget.hintText,
          hintStyle: WidgetStatePropertyAll(
              TextStyle(
                  color: theme.colorScheme.onSurfaceVariant)),
          textStyle: WidgetStatePropertyAll(
              TextStyle(color: theme.colorScheme.onSurface)),
          padding: const WidgetStatePropertyAll<EdgeInsets>(
              EdgeInsets.symmetric(horizontal: 16.0)),
          onTap: () {
            if (!controller.isOpen) {
              controller.openView();
            }
            // Perform initial filtering if there's already text (e.g., from previous selection)
            if (controller.text.isNotEmpty) {
              _performFiltering(controller.text);
            }
          },
          onChanged: (query) {
            _performFiltering(query);
          },
          leading: Icon(
              Icons.search, color: theme.colorScheme.onSurfaceVariant),
          trailing: [
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                if (value.text.isNotEmpty) {
                  return IconButton(
                    icon: Icon(
                        Icons.clear, color: theme.colorScheme.onSurfaceVariant),
                    onPressed: () {
                      controller.clear();
                      _performFiltering(''); // Clear results
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

        return List<Widget>.generate(
          _filteredAlumnos.length,
              (int index) {
            final Alumno alumno = _filteredAlumnos[index];
            final String displayText = '${alumno.getNombre()} ${alumno.getApellido()}';
            return ListTile(
              title: Text(displayText,
                  style: TextStyle(color: theme.colorScheme.onSurface)),
              onTap: () {
                // Set the text in the SearchBar to the selected item
                controller.closeView(displayText);
                // Call the callback with the selected Alumno object
                widget.onAlumnoSelected!(alumno);
                // Unfocus to hide keyboard
                FocusScope.of(context).unfocus();
              },
            );
          },
        );
      },
      // Optional: Customize the view when suggestions are open
      viewSurfaceTintColor: theme.colorScheme.surface,
      viewElevation: 4.0,
    );
  }
}