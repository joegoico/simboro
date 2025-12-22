import 'package:sistema_gym/objetos/disciplina.dart';
import 'package:sistema_gym/services/disciplinas_service.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class CreateDisciplineScreen extends StatefulWidget {
  const CreateDisciplineScreen({super.key});

  @override
  _CreateDisciplineScreenState createState() => _CreateDisciplineScreenState();
}

class _CreateDisciplineScreenState extends State<CreateDisciplineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final disciplinasService = DisciplinasService();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text;

      try {
        final Disciplina newDiscipline = Disciplina(nombre: name);
        await disciplinasService.createDisciplina(newDiscipline);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear la disciplina: $e')),
        );
        return;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disciplina creada exitosamente')),
      );
      context.go('/crearDisciplina'); // Redirigir a la lista de disciplinas
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Disciplina'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre de la Disciplina'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre de la disciplina';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la descripción';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Guardar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}