import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_gym/objetos/institucion.dart';
import 'package:sistema_gym/services/institucion_service.dart';
import 'package:sistema_gym/services/miembros_service.dart';

class CreateInstitutionScreen extends StatefulWidget {
  // 1. Añade el campo para recibir los datos del usuario.
  //    Lo hacemos opcional por si se llega a esta pantalla de otra forma.
  final Map<String, dynamic>? user;

  // 2. Actualiza el constructor.
  const CreateInstitutionScreen({super.key, required this.user});

  @override
  _CreateInstitutionScreenState createState() =>
      _CreateInstitutionScreenState();
}

class _CreateInstitutionScreenState extends State<CreateInstitutionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final institucionService = InstitucionService();

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // Aquí enviarías los datos al backend
      String name = _nameController.text;

      try {
        final Institucion newInstitution = Institucion(nombre: name);
        await institucionService.createInstitucion(newInstitution);
      } catch (e) {
        // Manejar errores de creación
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear la institución: $e')),
        );
        return;
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Institución creada exitosamente')),
      );
      context.go('/crearDisciplina'); // Redirigir a la lista de instituciones
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crear Institución')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre de la Institución',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre de la institución';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Dirección'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la dirección';
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
