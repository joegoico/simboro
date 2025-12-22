import 'package:flutter/material.dart';
import 'package:sistema_gym/objetos/alumno.dart';
import 'package:sistema_gym/providers/disciplinas_provider.dart';
import 'package:provider/provider.dart';
import 'package:sistema_gym/objetos/disciplina.dart';

class FormEditAlumnos extends StatefulWidget {
  const FormEditAlumnos({super.key, required this.alumno});
  final Alumno alumno;

  @override
  State<FormEditAlumnos> createState() => _FormEditAlumnosState();
}

class _FormEditAlumnosState extends State<FormEditAlumnos> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Disciplina? _selectedDisciplina;

  @override
  void initState() {
    super.initState();
    _loadDisciplina();
  }

  Future<void> _loadDisciplina() async {
    final disciplina = await widget.alumno.getDisciplina();
    setState(() {
      _selectedDisciplina = disciplina;
    });
  }

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
              Text('Alumno editado con éxito', style: TextStyle(color: Colors.white)),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context, widget.alumno); // Cierra el modal después de guardar
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final DisciplinasProvider disciplinasProvider = Provider.of<DisciplinasProvider>(context);
    final List<Disciplina> disciplinas = disciplinasProvider.disciplinas;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(
              'Editar Alumno',
            ),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: widget.alumno.getNombre(),
              decoration: const InputDecoration(
                labelText: 'Nombre del alumno',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Por favor, ingrese un nombre' : null,
              onSaved: (value) {
                widget.alumno.setNombre(value!);
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: widget.alumno.getApellido(),
              decoration: const InputDecoration(
                labelText: 'Apellido del alumno',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Por favor, ingrese un apellido' : null,
              onSaved: (value) {
                widget.alumno.setApellido(value!);
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: widget.alumno.getCorreoElectronico(),
              decoration: const InputDecoration(
                labelText: 'Correo electrónico del alumno',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Por favor, ingrese un correo electrónico' : null,
              onSaved: (value) {
                widget.alumno.setCorreoElectronico(value!);
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<Disciplina>(
              decoration: const InputDecoration(
                labelText: 'Disciplina',
                border: OutlineInputBorder(),
              ),
              value: _selectedDisciplina,
              items: disciplinas.map((disciplina) {
                return DropdownMenuItem<Disciplina>(
                  value: disciplina,
                  child: Text(disciplina.getNombre()),
                );
              }).toList(),
              onChanged: (Disciplina? newValue) {
                setState(() {
                  _selectedDisciplina = newValue;
                  if (newValue != null) {
                    widget.alumno.setDisciplina(newValue.getId());
                  }
                });
              },
            ),                   
            const SizedBox(height: 16),           
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Aquí puedes manejar la lógica para editar el gasto
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
            ,
          ],
        ),
      ),
    ) ;
  }
}

