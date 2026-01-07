import 'package:sistema_gym/objetos/disciplina.dart';
import 'package:sistema_gym/services/disciplinas_service.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

/// Pantalla dedicada al registro de nuevas disciplinas deportivas.
///
/// Gestiona la captura de datos del formulario, la validación de entrada
/// y la comunicación asíncrona con el servicio de persistencia.
class CreateDisciplineScreen extends StatefulWidget {
  const CreateDisciplineScreen({super.key});

  @override
  _CreateDisciplineScreenState createState() => _CreateDisciplineScreenState();
}

class _CreateDisciplineScreenState extends State<CreateDisciplineScreen> {
  // Clave global para identificar el formulario y gestionar su estado de validación.
  final _formKey = GlobalKey<FormState>();

  // Controlador para recuperar el texto del input de nombre.
  final _nameController = TextEditingController();

  // Instancia del servicio para realizar la petición POST al backend.
  final disciplinasService = DisciplinasService();

  /// Procesa el envío del formulario.
  ///
  /// 1. Valida que los campos no estén vacíos.
  /// 2. Instancia el objeto de dominio [Disciplina].
  /// 3. Llama al servicio de forma asíncrona.
  /// 4. Gestiona el ciclo de vida del widget ([mounted]) antes de usar el contexto.
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      String name = _nameController.text;

      try {
        final Disciplina newDiscipline = Disciplina(nombre: name);

        // Llamada asíncrona al backend (espera respuesta)
        await disciplinasService.createDisciplina(newDiscipline);
      } catch (e) {
        // Safety Check: Verificamos si el widget sigue en el árbol de widgets.
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear la disciplina: $e')),
        );
        return;
      }

      // Safety Check post-éxito
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Disciplina creada exitosamente')),
      );

      // Navegación declarativa usando GoRouter para volver o ir a la lista.
      context.go(
        '/crearDisciplina',
      ); // Nota: Verificar si esta ruta es la lista o se recarga a sí misma.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Crear Disciplina')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Input: Nombre de la Disciplina
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre de la Disciplina',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa el nombre de la disciplina';
                  }
                  return null;
                },
              ),

              // Input: Descripción (Nota: Actualmente solo valida, falta asignar controlador)
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

              // Botón de Acción
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
