import 'package:flutter/material.dart';
import 'package:sistema_gym/custom_widgets/custom_search_bar.dart';
import 'package:sistema_gym/providers/deudores_provider.dart';
import 'package:provider/provider.dart';

/// Pantalla para la gestión de cobranzas y visualización de morosidad.
///
/// Utiliza una estructura jerárquica ([ExpansionTile]) para mostrar a los
/// deudores y el desglose de sus meses impagos. Permite la eliminación
/// individual de periodos de deuda.
class Deudores extends StatefulWidget {
  const Deudores({super.key});

  @override
  State<Deudores> createState() => _DeudoresState();
}

class _DeudoresState extends State<Deudores> {
  /// Despliega un diálogo modal para confirmar la eliminación de una deuda.
  ///
  /// Retorna un [Future<bool?>] que permite al flujo principal esperar
  /// la decisión del usuario antes de ejecutar la acción destructiva.
  Future<bool?> showDeleteDeudaDialog(BuildContext context, String mes) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text('¿Estás seguro de eliminar la deuda del mes de $mes?'),
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
    // Consumo del Provider para obtener la lista actualizada de morosos.
    final allDeudores = Provider.of<DeudoresProvider>(context).deudores;
    final theme = Theme.of(context);

    return Stack(
      children: [
        // Barra de búsqueda polimórfica (Reutiliza el widget de Alumnos)
        // Nota: Al usar Stack, asegúrate de que el ListView tenga un padding superior
        // para no quedar oculto detrás de la barra.
        AlumnosSearchBar(allAlumnos: allDeudores),

        allDeudores.isEmpty
            ? const Center(
              child: Text(
                "No hay deudores registrados",
                style: TextStyle(fontSize: 18),
              ),
            )
            : ListView.builder(
              itemCount: allDeudores.length,
              // Añade padding superior para evitar solapamiento con la SearchBar
              padding: const EdgeInsets.only(top: 70),
              itemBuilder: (context, index) {
                final deudor = allDeudores[index];
                return Card(
                  // Uso de colores semánticos de Material 3
                  color: theme.colorScheme.surfaceContainerLow,
                  shadowColor: theme.colorScheme.shadow,
                  margin: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  child: ExpansionTile(
                    shape: const RoundedRectangleBorder(),
                    title: Text(
                      "${deudor.getNombre()} ${deudor.getApellido()}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      "Monto adeudado: \$${deudor.getMontoAdeudado.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    trailing: Text(
                      "Dias adeudados: ${deudor.getCantDiasAdeudados}",
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    // Generación dinámica de la lista de meses adeudados
                    children:
                        deudor.getMesesAdeudados.map((String mes) {
                          return ListTile(
                            leading: IconButton(
                              onPressed:
                                  () => showDeleteDeudaDialog(
                                    context,
                                    mes,
                                  ).then((value) {
                                    if (value == true) {
                                      // Eliminación lógica del mes.
                                      // Nota: El monto 0.0 debe revisarse según regla de negocio.
                                      deudor.eliminarMes(mes, 0.0);
                                      // Forzamos la reconstrucción para reflejar el cambio visualmente
                                      setState(() {});
                                    }
                                  }),
                              icon: const Icon(
                                Icons.delete_forever,
                                color: Colors.red,
                              ),
                            ),
                            title: Text(
                              mes,
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                );
              },
            ),
      ],
    );
  }
}
