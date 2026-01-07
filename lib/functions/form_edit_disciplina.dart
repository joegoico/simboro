import 'package:flutter/material.dart';
import 'package:sistema_gym/objetos/disciplina.dart';

/// Formulario para la edición del nombre y metadatos de una [Disciplina].
///
/// Actúa como un componente de edición rápida que garantiza que no existan
/// disciplinas sin nombre en el sistema, manteniendo la integridad del catálogo.
class FormEditDisciplina extends StatefulWidget {
  const FormEditDisciplina({super.key, required this.disciplina});

  /// La instancia de la disciplina que se está modificando.
  final Disciplina disciplina;

  @override
  _FormEditDisciplinaState createState() => _FormEditDisciplinaState();
}

class _FormEditDisciplinaState extends State<FormEditDisciplina> {
  /// Llave maestra para el control de validación y guardado del formulario.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Orquestador del guardado de datos.
  ///
  /// Realiza una validación preventiva. Si es exitosa, persiste los cambios
  /// en la instancia local del objeto y notifica al usuario.
  /// En caso de error, muestra un [SnackBar] informativo sobre el campo faltante.
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Feedback positivo tras la edición exitosa.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Disciplina editada con éxito',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Retornamos el objeto para que la vista padre actualice su estado sin reconectar a la API.
      Navigator.pop(context, widget.disciplina);
    } else {
      // Manejo de errores específicos de validación visual.
      if (widget.disciplina.getNombre().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Por favor, escriba un nombre para la disciplina"),
          ),
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
            const Text(
              'Editar Disciplina',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Campo de texto con validación reactiva.
            TextFormField(
              initialValue: widget.disciplina.getNombre(),
              decoration: const InputDecoration(
                labelText: 'Nombre de la disciplina',
                border: OutlineInputBorder(),
              ),
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Por favor, ingrese un nombre'
                          : null,
              onSaved: (value) {
                widget.disciplina.setNombre(value!);
              },
            ),
            const SizedBox(height: 20),

            // Fila de acciones estandarizada.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Guardar Cambios'),
                ),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
