import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_gym/objetos/precio.dart';
import 'package:sistema_gym/objetos/disciplina.dart';
import 'package:sistema_gym/functions/form_new_precio.dart';
import 'package:sistema_gym/functions/form_edit_precio.dart';
import 'package:sistema_gym/providers/disciplinas_provider.dart';
import 'package:sistema_gym/custom_widgets/custom_floating_button.dart';
import 'package:sistema_gym/services/precios_service.dart';

/// Pantalla detallada para la configuración de aranceles de una actividad.
///
/// Recibe una [disciplina] por constructor y permite gestionar sus diferentes
/// esquemas de precios según la cantidad de días semanales.
class PreciosPage extends StatefulWidget {
  final Disciplina disciplina;
  const PreciosPage({super.key, required this.disciplina});

  @override
  State<PreciosPage> createState() => _PreciosPageState();
}

class _PreciosPageState extends State<PreciosPage> {
  final preciosService = PreciosService();

  /// Estado local que almacena la lista de precios filtrada.
  List<Precio> precios = [];

  @override
  void initState() {
    super.initState();
    // Inicialización asíncrona: Recupera solo los precios pertenecientes
    // al ID de la disciplina inyectada.
    preciosService.getPreciosByDisciplinaId(widget.disciplina.getId()).then((
      precios,
    ) {
      if (mounted) {
        setState(() {
          this.precios = precios;
        });
      }
    });
  }

  /// Despliega el modal para registrar una nueva tarifa.
  void _showNuevoPrecioForm(BuildContext context) async {
    final nuevoPrecio = await showModalBottomSheet<Precio>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return NuevoPrecioForm(disciplinaId: widget.disciplina.getId());
      },
    );

    if (nuevoPrecio != null) {
      setState(() {
        // Actualización de la composición en el objeto de dominio.
        widget.disciplina.agregarPrecio(nuevoPrecio);
        // Se recomienda refrescar la lista 'precios' local aquí también.
      });
    }
  }

  /// Gestiona la edición de una tarifa existente.
  void _showEditForm(BuildContext context, Precio precio) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return FormEditPrecio(precio: precio);
      },
    );

    if (result != null && result is Precio) {
      // Notifica al Provider global para sincronizar el estado en toda la app.
      Provider.of<DisciplinasProvider>(
        context,
        listen: false,
      ).updatePrecio(widget.disciplina, result);
    }
  }

  /// Diálogo de confirmación para eliminar una categoría de precio.
  Future<bool?> showDeletePrecioDialog(BuildContext context, Precio precio) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: const Text('¿Estás seguro de eliminar este precio?'),
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
    return Scaffold(
      // El uso de Consumer garantiza que la lista se refresque si el
      // DisciplinasProvider emite cambios.
      body: Consumer<DisciplinasProvider>(
        builder: (context, disciplinasProvider, child) {
          if (precios.isEmpty) {
            return const Center(
              child: Text(
                "No hay precios agregados",
                style: TextStyle(fontSize: 18),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: precios.length,
            itemBuilder: (context, index) {
              final precio = precios[index];
              return Card(
                color: Theme.of(context).colorScheme.surface,
                shadowColor: Theme.of(context).colorScheme.shadow,
                margin: const EdgeInsets.only(bottom: 8),
                child: Column(
                  children: [
                    ListTile(
                      title: Text('${precio.getCantDias()} días'),
                      subtitle: Text('${precio.getPrecio()} ARS'),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: Theme.of(context).colorScheme.scrim,
                          ),
                          onPressed: () => _showEditForm(context, precio),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.delete,
                            color: Theme.of(context).colorScheme.scrim,
                          ),
                          onPressed: () async {
                            final confirmacion = await showDeletePrecioDialog(
                              context,
                              precio,
                            );
                            if (confirmacion == true) {
                              setState(() {
                                widget.disciplina.eliminarPrecio(precio);
                                precios.remove(
                                  precio,
                                ); // Sincronía con estado local
                              });
                              // ... feedback mediante SnackBar ...
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingCircleButton(
        onPressed: () => _showNuevoPrecioForm(context),
      ),
    );
  }
}
