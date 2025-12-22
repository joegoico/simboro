import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_gym/functions/form_new_gasto.dart';
import 'package:sistema_gym/objetos/gasto.dart';
import 'package:sistema_gym/providers/gastos_provider.dart';
import 'package:sistema_gym/functions/form_edit_gastos.dart';
import 'package:intl/intl.dart';
import 'package:sistema_gym/custom_widgets/custom_floating_button.dart';

class Gastos extends StatefulWidget {
  const Gastos({super.key});

  @override
  State<Gastos> createState() => _GastosState();
}
class _GastosState extends State<Gastos>   {

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
        Provider.of<GastosProvider>(context,listen: false,).editarGasto(gastoOriginal,result); // Agrega el nuevo gasto a la lista
      });
    }
  }
  void _showNuevoGastoForm(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return const AgregarGastoForm();
      },
    );
    if (result != null && result is Gasto) {
      setState(() {
        Provider.of<GastosProvider>(context,listen: false,).agregarGasto(result); // Agrega el nuevo gasto a la lista
      });
    }
  }

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
    // Obtiene la lista de gastos del provider
    final gastosProvider = Provider.of<GastosProvider>(context).gastosPorMes;

    final List<String> mesesOrdenados = gastosProvider.keys.toList()
      ..sort((a, b) {
        // Para ordenar, obtenemos el número del mes desde los gastos del map.
        // Si la lista está vacía, regresamos 0.
        final int mesA = gastosProvider[a]!.isNotEmpty ? gastosProvider[a]!.first.getFecha().month : 0;
        final int mesB = gastosProvider[b]!.isNotEmpty ? gastosProvider[b]!.first.getFecha().month : 0;
        return mesA.compareTo(mesB);
      });



    // Mantiene el estado de la pantalla al cambiar de pestaña
  return Stack(
    children: [

      mesesOrdenados.isEmpty
      ? const Center(
          child: Text(
          "No hay gastos registrados",
          style: TextStyle(fontSize: 18),
        ))
      : ListView.builder(
          itemCount: mesesOrdenados.length,
          itemBuilder: (context, index) {
            final mes = mesesOrdenados[index];
            final List<Gasto> gastosDelMes = gastosProvider[mes]!;

            return Card(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              shadowColor: Theme.of(context).colorScheme.shadow,
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: ExpansionTile(
                title: Text(
                  mes,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                children: gastosDelMes.map((Gasto gasto) {
                  String fechaFormateada = DateFormat('dd/MM/yyyy').format(gasto.getFecha());
                  return ListTile(
                    leading: IconButton(
                        onPressed:() => _showEditGastoForm(context, gasto),
                        icon: const Icon(Icons.edit),
                      ),
                    title: Text(gasto.getTitulo()),
                    subtitle: Text("Fecha: $fechaFormateada • Monto: \$${gasto.getMonto().toStringAsFixed(2)}"),
                    trailing:
                      IconButton(
                        onPressed:()  => showDeleteGastoDialog(context, gasto).then((value) {
                          if (value == true) {
                            setState(() {
                              Provider.of<GastosProvider>(context,listen: false,).eliminarGasto(gasto);
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
      Positioned(
        right: 20,
        bottom: 20,
        child: FloatingCircleButton(onPressed: () => _showNuevoGastoForm(context))
        ),
      ]
    );
  } // Mantiene el estado de la pantalla al cambiar de pestaña
}