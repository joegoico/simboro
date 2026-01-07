import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_gym/objetos/alumno.dart';
import 'package:sistema_gym/objetos/pago.dart';
import 'package:intl/intl.dart';
import 'package:sistema_gym/providers/alumnos_provider.dart';
import 'package:sistema_gym/providers/finanzas_provider.dart';
import 'package:sistema_gym/functions/form_edit_pago.dart';

/// Pantalla de detalle que lista el historial de pagos de un alumno específico.
///
/// Permite visualizar, editar y eliminar transacciones individuales.
/// Mantiene la sincronización entre el historial personal del alumno y
/// el balance global de finanzas.
class FechasDePago extends StatefulWidget {
  final Alumno alumno;

  /// Inyección de dependencia: La pantalla requiere una instancia de [Alumno]
  /// para saber de quién cargar los datos.
  const FechasDePago({super.key, required this.alumno});

  @override
  State<FechasDePago> createState() => _FechasDePagoState();
}

class _FechasDePagoState extends State<FechasDePago> {
  /// Diálogo de confirmación para la eliminación de registros contables.
  Future<bool?> showDeletePagoDialog(BuildContext context, Pago pago) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text(
            '¿Estás seguro de eliminar el pago de ${pago.getMonto()}?',
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

  /// Gestiona el flujo de edición de un pago.
  ///
  /// 1. Clona el objeto original (Patrón Prototype) para seguridad en memoria.
  /// 2. Recupera asíncronamente la [Disciplina] para obtener los precios vigentes.
  /// 3. Abre el formulario modal.
  /// 4. Si hay cambios, actualiza DOS fuentes de verdad: [FinanzasProvider] (Global)
  ///    y [AlumnosModel] (Personal).
  void _showEditPagoForm(BuildContext context, Pago pago) async {
    // Copia de seguridad del estado anterior para el cálculo de diferencias en Finanzas.
    final pagoOriginal = pago.copy();

    // Lazy Loading: Obtenemos los precios solo cuando se necesitan.
    final disciplina = await widget.alumno.getDisciplina();

    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      // Pasamos una copia al formulario para no mutar el objeto de la lista directamente.
      builder: (BuildContext context) {
        return FormEditPago(
          pago: pago.copy(),
          precios: disciplina.getPrecios(),
        );
      },
    );

    if (result != null && result is Pago) {
      setState(() {
        // Actualización atómica de los dos estados afectados
        Provider.of<FinanzasProvider>(
          context,
          listen: false,
        ).editarPago(pagoOriginal, result);
        Provider.of<AlumnosModel>(
          context,
          listen: false,
        ).updatePago(widget.alumno, result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Acceso directo a la lista en memoria del objeto Alumno
    final List<Pago> fechasDePago = widget.alumno.getPagosRealizados();

    return Scaffold(
      // Estado vacío
      body:
          fechasDePago.isEmpty
              ? const Center(
                child: Text(
                  "No hay pagos realizados",
                  style: TextStyle(fontSize: 18),
                ),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(10),
                itemCount: fechasDePago.length,
                itemBuilder: (context, index) {
                  final pago = fechasDePago[index];

                  // Formateo de fecha localizada (i18n)
                  String mes = DateFormat(
                    'MMMM',
                    'es_ES',
                  ).format(pago.getFechaDePago());
                  mes = '${mes[0].toUpperCase()}${mes.substring(1)}';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      children: [
                        ListTile(
                          title: Text(mes),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Fecha de pago: ${DateFormat('dd/MM/yyyy').format(pago.getFechaDePago())}',
                              ),
                              Text('${pago.getMonto()} ARS'),
                            ],
                          ),
                        ),
                        // Barra de acciones
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              icon: Icon(
                                Icons.edit,
                                color: Theme.of(context).colorScheme.scrim,
                              ),
                              onPressed: () => _showEditPagoForm(context, pago),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Theme.of(context).colorScheme.scrim,
                              ),
                              onPressed: () async {
                                final confirmacion = await showDeletePagoDialog(
                                  context,
                                  pago,
                                );
                                if (confirmacion == true) {
                                  setState(() {
                                    // Eliminación en cascada: Global y Local
                                    Provider.of<FinanzasProvider>(
                                      context,
                                      listen: false,
                                    ).eliminarPago(pago);
                                    widget.alumno.eliminarFechaDePago(pago);
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
