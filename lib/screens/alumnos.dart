import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sistema_gym/functions/form_new_alumno.dart';
import 'package:sistema_gym/objetos/alumno.dart';
import 'package:sistema_gym/objetos/pago.dart';
import 'package:sistema_gym/providers/alumnos_provider.dart';
import 'package:sistema_gym/functions/form_edit_alumno.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_gym/functions/form_new_payment.dart';
import 'package:sistema_gym/custom_widgets/custom_search_bar.dart';

class Alumnos extends StatefulWidget {
  const Alumnos({super.key, required this.title});
  final String title;

  @override
  State<Alumnos> createState() => _AlumnosState();
}

class _AlumnosState extends State<Alumnos> {
  String query = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final alumnosModel = Provider.of<AlumnosModel>(context, listen: false);
      if (alumnosModel.alumnos.isEmpty) {
        alumnosModel.cargarAlumnos(1); // Solo carga si la lista está vacía
      }
    });
  }

  Future<void> _showNuevoAlumnoForm(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return const NuevoAlumnoForm();
      },
    );

    if (result != null && result is Alumno) {
      try {
        await Provider.of<AlumnosModel>(context, listen: false).agregarAlumno(result);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Alumno agregado con éxito'),
              ],
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text('Error al agregar alumno: $e'),
              ],
            ),
          ),
        );
      }
    }
  }

  Future<void> _showEditAlumnoForm(BuildContext context, Alumno alumno) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return FormEditAlumnos(alumno: alumno);
      },
    );

    if (result != null && result is Alumno) {
      try {
        await Provider.of<AlumnosModel>(context, listen: false).editarAlumno(alumno, result);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Alumno actualizado con éxito'),
              ],
            ),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text('Error al actualizar alumno: $e'),
              ],
            ),
          ),
        );
      }
    }
  }

  Future<void> _showRegistrarPagoForm(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return FormNewPayment();
      },
    );
    if (result != null && result is Pago) {
      setState(() {});
    }
  }

  Future<bool?> showDeleteAlumnoDialog(BuildContext context, Alumno alumno) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Eliminación'),
          content: Text(
            '¿Estás seguro de eliminar al alumno "${alumno.getNombre()} ${alumno.getApellido()}"? Esta acción borrará todos sus datos asociados.',
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
    final alumnosProvider = Provider.of<AlumnosModel>(context);
    final alumnos = alumnosProvider.alumnos;
    final isLoading = alumnosProvider.isLoading;

    return Stack(
      children: [
        if (isLoading)
          const Center(
            child: CircularProgressIndicator(),
          )
        else if (alumnos.isEmpty)
          const Center(
            child: Text(
              "No hay alumnos agregados",
              style: TextStyle(fontSize: 18),
            ),
          )
        else
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(5),
                child: AlumnosSearchBar(allAlumnos: alumnos),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: alumnos.length,
                  itemBuilder: (context, index) {
                    final alumno = alumnos[index];
                    return Card(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      shadowColor: Theme.of(context).colorScheme.shadow,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        children: [
                          ListTile(
                            title: Text('${alumno.getNombre()} ${alumno.getApellido()}'),
                            subtitle: Text(alumno.getCorreoElectronico()),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.calendar_month_sharp, color: Theme.of(context).colorScheme.scrim),
                                onPressed: () {
                                  context.go('/pagos', extra: alumno);
                                },
                              ),
                              IconButton(
                                onPressed: () => _showEditAlumnoForm(context, alumno),
                                icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.scrim),
                              ),
                              IconButton(
                                onPressed: () async {
                                  bool? confirmado = await showDeleteAlumnoDialog(context, alumno);
                                  if (confirmado == true) {
                                    try {
                                      if (!mounted) return;
                                      await Provider.of<AlumnosModel>(context, listen: false).eliminarAlumno(alumno);
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.check_circle, color: Colors.green),
                                              SizedBox(width: 8),
                                              Text('Alumno eliminado con éxito'),
                                            ],
                                          ),
                                        ),
                                      );
                                    } catch (e) {
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.error, color: Colors.red),
                                              SizedBox(width: 8),
                                              Text('Error al eliminar alumno: $e'),
                                            ],
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                },
                                icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.scrim),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        Positioned(
          right: 20,
          bottom: 20,
          child: PopupMenuButton<String>(
            color: Theme.of(context).colorScheme.primaryContainer,
            icon: Icon(
              Icons.add,
              size: 25.0,
              color: Theme.of(context).colorScheme.primary,
            ),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'nuevoAlumno',
                child: Row(
                  children: [
                    Icon(Icons.person_add, color: Theme.of(context).colorScheme.onPrimaryContainer),
                    SizedBox(width: 8),
                    Text("Agregar Alumno", style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'registrarPago',
                child: Row(
                  children: [
                    Icon(Icons.payment, color: Theme.of(context).colorScheme.onPrimaryContainer),
                    SizedBox(width: 8),
                    Text("Registrar Pago", style: TextStyle(color: Theme.of(context).colorScheme.onPrimaryContainer)),
                  ],
                ),
              ),
            ],
            onSelected: (String selectedValue) {
              if (selectedValue == 'nuevoAlumno') {
                _showNuevoAlumnoForm(context);
              } else if (selectedValue == 'registrarPago') {
                _showRegistrarPagoForm(context);
              }
            },
          ),
        ),
      ],
    );
  }
}