import 'package:flutter/material.dart';
import 'package:sistema_gym/objetos/disciplina.dart';

/// Formulario para la creación de nuevas disciplinas deportivas.
///
/// Este componente permite al administrador dar de alta actividades en el sistema.
/// Al finalizar con éxito, instancia un objeto [Disciplina] y lo transfiere
/// de regreso a la vista anterior para su persistencia asíncrona.
class NuevaDisciplinaForm extends StatefulWidget {
  const NuevaDisciplinaForm({super.key});

  @override
  _NuevaDisciplinaFormState createState() => _NuevaDisciplinaFormState();
}

class _NuevaDisciplinaFormState extends State<NuevaDisciplinaForm> {
  /// Llave global necesaria para acceder al estado del formulario y ejecutar validaciones.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Variable de estado local para capturar el nombre ingresado.
  String? _nombreDisciplina;

  /// Orquestador del guardado de datos.
  ///
  /// 1. Verifica que los campos cumplan con las reglas del [validator].
  /// 2. Ejecuta [save] para mapear el texto del input a la variable local.
  /// 3. Crea una instancia de [Disciplina].
  /// 4. Notifica el éxito mediante un [SnackBar] y cierra el modal devolviendo el objeto.
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_nombreDisciplina != null) {
        // Feedback visual de operación exitosa
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text(
                  'Disciplina registrada con éxito',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );

        // Creación del objeto de dominio
        final Disciplina nuevaDisciplina = Disciplina(
          nombre: _nombreDisciplina!,
        );

        // Retorno del objeto a la capa superior (Service/Provider)
        Navigator.pop(context, nuevaDisciplina);
      }
    } else {
      // Manejo de error si la validación falla (aunque el validador ya muestra el error en el campo)
      if (_nombreDisciplina == null) {
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
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Text(
              'Agregar Disciplina',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Campo de Entrada: Nombre de la Disciplina
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nombre de la Disciplina',
                border: OutlineInputBorder(),
              ),
              // Regla de validación: Campo obligatorio
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa el nombre de la disciplina';
                }
                return null;
              },
              onSaved: (value) => _nombreDisciplina = value!,
            ),
            const SizedBox(height: 24),

            // Fila de acciones con botones adaptativos (Expanded)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                    onPressed: _submitForm,
                    child: const Text('Guardar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.secondaryContainer,
                      foregroundColor: theme.colorScheme.onSecondaryContainer,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
