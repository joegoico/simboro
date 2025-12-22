import 'package:flutter/material.dart';
import 'package:sistema_gym/custom_widgets/custom_search_bar.dart';
import 'package:sistema_gym/providers/deudores_provider.dart';
import 'package:provider/provider.dart';

class Deudores extends StatefulWidget {
  const Deudores({super.key});

  @override
  State<Deudores> createState() => _DeudoresState();
}

class _DeudoresState extends State<Deudores>  {

  Future<bool?> showDeleteDeudaDialog(BuildContext context, String mes) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text(
            '¿Estás seguro de eliminar la deuda del mes de $mes?',
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
    final allDeudores = Provider.of<DeudoresProvider>(context).deudores;
    final theme = Theme.of(context);
    return Stack(
      children: [
        AlumnosSearchBar(allAlumnos: allDeudores),
        allDeudores.isEmpty?
          const Center(
            child: Text(
              "No hay deudores registrados",
              style: TextStyle(fontSize: 18),
            ),
          )

          :ListView.builder(
            itemCount: allDeudores.length,
            itemBuilder: (context, index) {
              final deudor = allDeudores[index];
              return
                Card(
                  color: theme.colorScheme.surfaceContainerLow,
                  shadowColor: theme.colorScheme.shadow,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child:
                    ExpansionTile(
                      shape: RoundedRectangleBorder(),
                      title:
                        Text(
                          "${deudor.getNombre()} ${deudor.getApellido()}",
                          style:  TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: theme.colorScheme.onSurface),
                        ),
                      subtitle: Text(
                        "Monto adeudado: \$${deudor.getMontoAdeudado.toStringAsFixed(2)}",
                        style:  TextStyle(fontSize: 16, color: theme.colorScheme.onSurfaceVariant),
                        ),
                      trailing: Text(
                        "Dias adeudados: ${deudor.getCantDiasAdeudados}",
                        style:  TextStyle(fontSize: 16, color: theme.colorScheme.onSurfaceVariant),
                      ),
                      children: deudor.getMesesAdeudados.map((String mes) {
                        return ListTile(
                          leading: IconButton(
                              onPressed: () =>
                                showDeleteDeudaDialog(context, mes).then((value) {
                                   if (value == true) {
                                     deudor.eliminarMes(mes,0.0);
                                   }
                                 }),
                              icon: Icon(Icons.delete_forever)),
                          title: Text(mes, style:  TextStyle(fontSize: 16, color: theme.colorScheme.onSurfaceVariant)),
                        );
                      },
                    ).toList(),
                  ),
                );
            }
          )
      ],
    );
  }

}