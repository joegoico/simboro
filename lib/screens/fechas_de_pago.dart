import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_gym/objetos/alumno.dart';
import 'package:sistema_gym/objetos/pago.dart';
import 'package:intl/intl.dart';
import 'package:sistema_gym/providers/alumnos_provider.dart';
import 'package:sistema_gym/providers/finanzas_provider.dart';
import 'package:sistema_gym/functions/form_edit_pago.dart';

class FechasDePago extends StatefulWidget {
  final Alumno alumno;
  const FechasDePago({super.key, required this.alumno});

  @override
  State<FechasDePago> createState() => _FechasDePagoState();
}

class _FechasDePagoState extends State<FechasDePago> {

  Future<bool?> showDeletePagoDialog(BuildContext context, Pago pago) async{
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

  void _showEditPagoForm(BuildContext context, Pago pago) async{
    final pagoOriginal = pago.copy();
    final disciplina = await widget.alumno.getDisciplina();
    final result = await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return FormEditPago(pago: pago.copy(), precios: disciplina.getPrecios());
        }
        );
    if (result != null && result is Pago) {
      setState(() {
        Provider.of<FinanzasProvider>(context,listen: false,).editarPago(pagoOriginal,result);
        Provider.of<AlumnosModel>(context,listen: false,).updatePago(widget.alumno,result);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Pago> fechasDePago = widget.alumno.getPagosRealizados();
    return Scaffold(
      body: fechasDePago.isEmpty
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
                // Obtenemos el nombre del mes en español.
                String mes = DateFormat('MMMM', 'es_ES').format(pago.getFechaDePago());
                // Convertimos la primera letra a mayúscula.
                mes = '${mes[0].toUpperCase()}${mes.substring(1)}';

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Column(
                    children: [
                      // Aquí se muestran los datos del pago
                      ListTile(
                        title: Text(mes),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Fecha de pago: ${DateFormat('dd/MM/yyyy').format(pago.getFechaDePago())}',
                            ),
                            Text(
                              '${pago.getMonto()} ARS',
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon:  Icon(Icons.edit,color: Theme.of(context).colorScheme.scrim),
                            onPressed: () {
                              _showEditPagoForm(context, pago);
                            },
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon:  Icon(Icons.delete,color: Theme.of(context).colorScheme.scrim),
                            onPressed: () async{
                              final confirmacion = await showDeletePagoDialog(context, pago);
                              if (confirmacion!) {
                                setState(() {
                                  Provider.of<FinanzasProvider>(context, listen: false).eliminarPago(pago);
                                  widget.alumno.eliminarFechaDePago(pago);
                                });
                              }
                              // Aquí puedes agregar la lógica para eliminar el pago.
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