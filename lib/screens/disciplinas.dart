import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_gym/functions/form_new_disciplina.dart';
import 'package:sistema_gym/objetos/disciplina.dart';
import 'package:sistema_gym/functions/form_edit_disciplina.dart';
import 'package:sistema_gym/providers/disciplinas_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_gym/custom_widgets/custom_floating_button.dart';

/// Pantalla principal para la gestión del catálogo de disciplinas.
///
/// Permite visualizar la lista de actividades disponibles, agregar nuevas,
/// editar las existentes y navegar a la configuración de precios.
class DiscplinasPage extends StatefulWidget {
  const DiscplinasPage({super.key, required this.title});
  final String title;

  @override
  State<DiscplinasPage> createState() => _DiscplinasPageState();
}

class _DiscplinasPageState extends State<DiscplinasPage> {
  @override
  void initState() {
    super.initState();
    // Patrón de Inicialización Diferida:
    // Se utiliza addPostFrameCallback para garantizar que el contexto esté
    // completamente montado antes de intentar modificar el estado del Provider.
    // Esto evita el error "setState() or markNeedsBuild() called during build".
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final disciplinasProvider = Provider.of<DisciplinasProvider>(
        context,
        listen: false,
      );

      // Carga condicional para optimizar el uso de red.
      if (disciplinasProvider.disciplinas.isEmpty) {
        // debugPrint es preferible a print en producción
        debugPrint("Cargando disciplinas desde el servidor...");
        disciplinasProvider.cargarDisciplinas(
          1,
        ); // ID institución hardcodeado por ahora
      }
    });
  }

  // --- Gestión de Modales (Formularios) ---

  /// Despliega el formulario de creación en una hoja inferior modal.
  Future<void> _showNuevaDisciplinaForm(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) => const NuevaDisciplinaForm(),
    );

    // Actualización de UI tras el cierre del modal
    if (result != null && result is Disciplina) {
      // Nota: Provider ya notifica a los listeners, por lo que este setState
      // es redundante si solo se usa para refrescar la lista, pero útil si hay
      // estado local que dependa de esto.
      setState(() {
        Provider.of<DisciplinasProvider>(
          context,
          listen: false,
        ).agregarDisciplina(result);
      });
    }
  }

  /// Despliega el formulario de edición pasando la instancia actual.
  Future<void> _showEditDisciplinaForm(
    BuildContext context,
    Disciplina disciplina,
  ) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (BuildContext context) => FormEditDisciplina(disciplina: disciplina),
    );

    if (result != null && result is Disciplina) {
      setState(() {
        Provider.of<DisciplinasProvider>(
          context,
          listen: false,
        ).editarDisciplina(disciplina, result);
      });
    }
  }

  /// Diálogo de confirmación para operación destructiva.
  Future<bool?> showDeleteDisciplinaDialog(
    BuildContext context,
    Disciplina disciplina,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text(
            '¿Estás seguro de eliminar la disciplina "${disciplina.getNombre()}"?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Consumo del Provider: La UI reacciona a cambios en 'disciplinasProvider'.
    final disciplinasProvider = Provider.of<DisciplinasProvider>(context);
    final disciplinas = disciplinasProvider.disciplinas;
    final isLoading = disciplinasProvider.isLoading;

    return Stack(
      children: [
        // Estado de Carga
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        // Estado Vacío
        else if (disciplinas.isEmpty)
          const Center(
            child: Text(
              "No hay disciplinas agregadas",
              style: TextStyle(fontSize: 18),
            ),
          )
        // Lista de Datos
        else
          ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: disciplinas.length,
            itemBuilder: (context, index) {
              final disciplina = disciplinas[index];
              return Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                shadowColor: Theme.of(context).colorScheme.shadow,
                margin: const EdgeInsets.only(bottom: 8),
                child: Column(
                  children: [
                    ListTile(title: Text(disciplina.getNombre())),
                    // Barra de herramientas por ítem
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        // Acción: Eliminar
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Theme.of(context).colorScheme.scrim,
                          ),
                          onPressed: () async {
                            final confirmacion =
                                await showDeleteDisciplinaDialog(
                                  context,
                                  disciplina,
                                );
                            if (confirmacion == true) {
                              // Verificación explícita de true
                              // No necesitamos 'mounted' check aquí porque Provider.of
                              // fue obtenido en el build scope superior o se puede usar context seguro.
                              disciplinasProvider.eliminarDisciplina(
                                disciplina,
                              );

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Disciplina eliminada con éxito'),
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        // Acción: Editar Nombre
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Theme.of(context).colorScheme.scrim,
                          ),
                          onPressed: () {
                            _showEditDisciplinaForm(context, disciplina);
                          },
                        ),
                        // Acción: Navegar a Precios (Drill-down navigation)
                        IconButton(
                          icon: Icon(
                            Icons.monetization_on,
                            color: Theme.of(context).colorScheme.scrim,
                          ),
                          onPressed: () {
                            // Transferencia de objeto complejo a la siguiente ruta
                            context.go('/precios', extra: disciplina);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

        // Botón Flotante Personalizado
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingCircleButton(
            onPressed: () => _showNuevaDisciplinaForm(context),
          ),
        ),
      ],
    );
  }
}
