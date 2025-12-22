import 'package:flutter/material.dart';
import 'package:sistema_gym/objetos/disciplina.dart';

class FormEditDisciplina extends StatefulWidget {
  const FormEditDisciplina({super.key, required this.disciplina});

  final Disciplina disciplina;

  @override
  _FormEditDisciplinaState createState() => _FormEditDisciplinaState();
}
class _FormEditDisciplinaState extends State<FormEditDisciplina>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Aquí procesas los datos, por ejemplo:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Disciplina editada con éxito', style: TextStyle(color: Colors.white)),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context, widget.disciplina); // Cierra el modal después de guardar
    } else {
      if (widget.disciplina.getNombre().isEmpty) {
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
            Text(
              'Editar Disciplina',
            ),
            const SizedBox(height: 20),
            // Campo para el nombre de la disciplina
            TextFormField(
              initialValue: widget.disciplina.getNombre(),
              decoration: const InputDecoration(
                labelText: 'Nombre de la disciplina',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Por favor, ingrese un nombre' : null,
              onSaved: (value) {
                widget.disciplina.setNombre(value!);
              },
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    _submitForm();
                  },
                  child: const Text('Guardar Cambios'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Cierra el modal sin guardar cambios
                  },
                  child: const Text('Cancelar'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}