import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sistema_gym/objetos/institucion.dart';
import 'package:sistema_gym/services/institucion_service.dart';
import 'package:sistema_gym/services/miembros_service.dart';

/// Pantalla de creación de la entidad institucional.
///
/// Es el primer paso tras la autenticación para usuarios que aún no
/// pertenecen a una organización. Vincula al [user] actual con la
/// nueva [Institucion] que se creará en el backend.
class CreateInstitutionScreen extends StatefulWidget {
  /// Datos del usuario autenticado provenientes del flujo de Login.
  final Map<String, dynamic>? user;

  const CreateInstitutionScreen({super.key, required this.user});

  @override
  _CreateInstitutionScreenState createState() =>
      _CreateInstitutionScreenState();
}

class _CreateInstitutionScreenState extends State<CreateInstitutionScreen> {
  // Manejo de estado del formulario para validaciones sincrónicas.
  final _formKey = GlobalKey<FormState>();

  // Controlador para el campo de nombre institucional.
  final _nameController = TextEditingController();

  // Inyección del servicio de persistencia institucional.
  final institucionService = InstitucionService();

  /// Procesa el alta de la institución.
  ///
  /// 1. Valida los campos obligatorios.
  /// 2. Envía la petición de creación al backend.
  /// 3. Redirige al usuario al siguiente paso lógico (Configuración de Disciplinas).
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text;

      try {
        final Institucion newInstitution = Institucion(nombre: name);

        // Operación asíncrona de red (POST)
        await institucionService.createInstitucion(newInstitution);
      } catch (e) {
        // Manejo de excepciones con verificación de ciclo de vida (mounted)
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al crear la institución: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        return;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Institución creada exitosamente')),
      );

      // Navegación hacia la configuración del catálogo inicial.
      context.go('/crearDisciplina');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear Institución')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Campo: Nombre (Persistido)
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre de la Institución',
                  hintText: 'Ej: Gimnasio Central',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre de la institución';
                  }
                  return null;
                },
              ),

              // Campo: Dirección (Preparado para expansión del modelo)
              TextFormField(
                decoration: const InputDecoration(labelText: 'Dirección'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa la dirección';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Guardar y Continuar'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
