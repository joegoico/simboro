import 'package:flutter/material.dart';
import 'package:sistema_gym/objetos/disciplina.dart';

class NuevaDisciplinaForm extends StatefulWidget {
  const NuevaDisciplinaForm({super.key});

  @override
  _NuevaDisciplinaFormState createState() => _NuevaDisciplinaFormState();
}
class _NuevaDisciplinaFormState extends State<NuevaDisciplinaForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Variables del formulario
  String? _nombreDisciplina;
  
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Aquí procesas los datos, por ejemplo:
      if (_nombreDisciplina != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const  SnackBar(
            backgroundColor: Colors.green,
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Disciplina registrada con éxito', style: TextStyle(color: Colors.white)),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
        final Disciplina nuevaDisciplina = Disciplina(
          nombre: _nombreDisciplina!,
        );
        Navigator.pop(context,nuevaDisciplina); // Cierra el modal después de guardar
      }
      // Aquí puedes limpiar el formulario o navegar hacia atrás
    } else {
      if (_nombreDisciplina == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Por favor, escriba un nombre para la disciplina")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text( 'Agregar Disciplina'),
            const SizedBox(height: 16),
            // Campo para el nombre de la disciplina
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nombre de la Disciplina',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el nombre de la disciplina';
                }
                return null;
              },            
              onSaved: (value) {
                _nombreDisciplina = value!;
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: _submitForm,
                    child:  Text('Guardar',style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child:  Text('Cancelar',style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer),),
                  ),
                ),
              ],
            ),
          ]
        ),
      ),
    );
  }
}