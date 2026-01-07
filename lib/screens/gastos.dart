import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_gym/functions/form_new_gasto.dart';
import 'package:sistema_gym/objetos/gasto.dart';
import 'package:sistema_gym/providers/gastos_provider.dart';
import 'package:sistema_gym/functions/form_edit_gastos.dart';
import 'package:intl/intl.dart';
import 'package:sistema_gym/custom_widgets/custom_floating_button.dart';

/// Pantalla de gestión operativa de egresos.
///
/// Permite visualizar los gastos agrupados por mes mediante listas expandibles,
/// así como registrar nuevos movimientos o auditar/editar los existentes.
class Gastos extends StatefulWidget {
  const Gastos({super.key});

  @override
  State<Gastos> createState() => _GastosState();
}

class _GastosState extends State<Gastos> {
  // --- Lógica de Modales (CRUD) ---

  /// Abre el formulario de edición aplicando el patrón Prototype.
  ///
  /// Se crea una copia profunda ([copy]) del gasto para aislar el estado del formulario
  /// del estado de la lista hasta que se confirme la operación.
  void _showEditGastoForm(BuildContext context, Gasto gasto) async {
    final gastoOriginal = gasto.copy();

    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return FormEditGastos(gasto: gasto.copy());
      },
    );

    if (result != null && result is Gasto) {
      setState(() {
        // Actualización atómica en el Provider
        Provider.of<GastosProvider>(
          context,
          listen: false,
        ).editarGasto(gastoOriginal, result);
      });
    }
  }

  /// Despliega el formulario para registrar una nueva salida de dinero.
  void _showNuevoGastoForm(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) => const AgregarGastoForm(),
    );

    if (result != null && result is Gasto) {
      setState(() {
        Provider.of<GastosProvider>(
          context,
          listen: false,
        ).agregarGasto(result);
      });
    }
  }

  /// Diálogo de seguridad para eliminación de registros.
  Future<bool?> showDeleteGastoDialog(BuildContext context, Gasto gasto) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text(
            '¿Estás seguro de eliminar el gasto "${gasto.getTitulo()}"?',
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
    // Consumo del mapa agrupado del Provider { "Enero": [Gasto1, Gasto2], ... }
    final gastosProvider = Provider.of<GastosProvider>(context).gastosPorMes;

    // --- Algoritmo de Ordenamiento Dinámico ---
    // Extrae las claves (Nombres de Meses) y las ordena basándose en la fecha
    // del primer objeto contenido en la lista, evitando mapeos de strings complejos.
    // Complejidad aproximada: O(k * log k) donde k es la cantidad de meses.
    final List<String> mesesOrdenados =
        gastosProvider.keys.toList()..sort((a, b) {
          final int mesA =
              gastosProvider[a]!.isNotEmpty
                  ? gastosProvider[a]!.first.getFecha().month
                  : 0;
          final int mesB =
              gastosProvider[b]!.isNotEmpty
                  ? gastosProvider[b]!.first.getFecha().month
                  : 0;
          return mesA.compareTo(mesB);
        });

    return Stack(
      children: [
        // Estado Vacío
        mesesOrdenados.isEmpty
            ? const Center(
              child: Text(
                "No hay gastos registrados",
                style: TextStyle(fontSize: 18),
              ),
            )
            // Lista Agrupada (Expandable List)
            : ListView.builder(
              itemCount: mesesOrdenados.length,
              // Padding inferior para que el último ítem no quede tapado por el botón flotante
              padding: const EdgeInsets.only(bottom: 80),
              itemBuilder: (context, index) {
                final mes = mesesOrdenados[index];
                final List<Gasto> gastosDelMes = gastosProvider[mes]!;

                return Card(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  shadowColor: Theme.of(context).colorScheme.shadow,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ExpansionTile(
                    title: Text(
                      mes,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Mapeo de Objetos de Dominio a Widgets de UI
                    children:
                        gastosDelMes.map((Gasto gasto) {
                          String fechaFormateada = DateFormat(
                            'dd/MM/yyyy',
                          ).format(gasto.getFecha());

                          return ListTile(
                            // Botón de Edición (Leading)
                            leading: IconButton(
                              onPressed:
                                  () => _showEditGastoForm(context, gasto),
                              icon: const Icon(Icons.edit),
                            ),
                            title: Text(gasto.getTitulo()),
                            subtitle: Text(
                              "Fecha: $fechaFormateada • Monto: \$${gasto.getMonto().toStringAsFixed(2)}",
                            ),
                            // Botón de Eliminación (Trailing)
                            trailing: IconButton(
                              onPressed:
                                  () => showDeleteGastoDialog(
                                    context,
                                    gasto,
                                  ).then((value) {
                                    if (value == true) {
                                      setState(() {
                                        Provider.of<GastosProvider>(
                                          context,
                                          listen: false,
                                        ).eliminarGasto(gasto);
                                      });
                                    }
                                  }),
                              icon: const Icon(Icons.delete_forever),
                            ),
                          );
                        }).toList(),
                  ),
                );
              },
            ),

        // Botón de Acción Flotante (FAB) Personalizado
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingCircleButton(
            onPressed: () => _showNuevoGastoForm(context),
          ),
        ),
      ],
    );
  }
}
