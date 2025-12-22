import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_gym/objetos/precio.dart';
import 'package:sistema_gym/objetos/disciplina.dart';
import 'package:sistema_gym/functions/form_new_precio.dart';
import 'package:sistema_gym/functions/form_edit_precio.dart';
import 'package:sistema_gym/providers/disciplinas_provider.dart';
import 'package:sistema_gym/custom_widgets/custom_floating_button.dart';
import 'package:sistema_gym/services/precios_service.dart';

class PreciosPage extends StatefulWidget {
  final Disciplina disciplina;
  const PreciosPage({super.key, required this.disciplina});

  @override
  State<PreciosPage> createState() => _PreciosPageState();
}

class _PreciosPageState extends State<PreciosPage> {
  final preciosService = PreciosService();
  
  List<Precio> precios = [];
  
  @override
  void initState() {
    super.initState();
    preciosService.getPreciosByDisciplinaId(widget.disciplina.getId()).then((precios) {
      setState(() {
        this.precios = precios;
      });
    });
  }
      
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
        widget.disciplina.agregarPrecio(nuevoPrecio);
      });
    }
  }

  void _showEditForm(BuildContext context, Precio precio) async{
    final result = await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) {
          return FormEditPrecio(precio: precio);

        });
    if (result != null && result is Precio) {
      Provider.of<DisciplinasProvider>(context, listen: false).updatePrecio(widget.disciplina, result);
    }
  }

    Future<bool?> showDeletePrecioDialog(BuildContext context, Precio precio) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text(
            '¿Estás seguro de eliminar el precio?',
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
    

    return Scaffold(
        body: Consumer<DisciplinasProvider>(
            builder: (context, disciplinasProvider, child){
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
                                icon:  Icon(Icons.edit,color: Theme.of(context).colorScheme.scrim),
                                onPressed: () {
                                  _showEditForm(context, precio);
                                },
                              ),
                              IconButton(
                                icon:  Icon(Icons.delete,color: Theme.of(context).colorScheme.scrim),
                                onPressed: () async {
                                  final confirmacion = await showDeletePrecioDialog(context, precio);
                                  if (confirmacion == true) {
                                    setState(() {
                                      widget.disciplina.eliminarPrecio(precio);
                                    });
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content:Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.check_circle, color: Colors.green),
                                          SizedBox(width: 8),
                                          Text('Precio eliminado con éxito'),
                                        ],
                                      )
                                      ),
                                    );
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

            }
        ),
        floatingActionButton: FloatingCircleButton(onPressed: () => _showNuevoPrecioForm(context)),
    );
  }
}