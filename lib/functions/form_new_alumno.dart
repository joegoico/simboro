import 'package:flutter/material.dart';
import 'package:sistema_gym/objetos/alumno.dart';
import 'package:sistema_gym/objetos/disciplina.dart';
import 'package:provider/provider.dart';
import 'package:sistema_gym/providers/disciplinas_provider.dart';

/// Formulario para el registro de nuevos alumnos en la institución.
///
/// Gestiona la captura de datos personales, validación de formato de correo
/// y asignación inicial de disciplina. Al finalizar con éxito, instancia
/// un objeto [Alumno] y lo retorna a la vista llamante.
class NuevoAlumnoForm extends StatefulWidget {
  const NuevoAlumnoForm({super.key});

  @override
  _NuevoAlumnoFormState createState() => _NuevoAlumnoFormState();
}

class _NuevoAlumnoFormState extends State<NuevoAlumnoForm> {
  /// Llave global para orquestar la validación y el salvado de estado del formulario.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Variables de estado local para la captura de datos
  String _nombre = "";
  String _apellido = "";
  String _correoElectronico = "";
  int? _disciplina;

  /// Valida el formulario y crea la instancia del modelo [Alumno].
  ///
  /// Si el formulario es válido:
  /// 1. Ejecuta [save] para persistir los valores en las variables locales.
  /// 2. Muestra un feedback visual de éxito.
  /// 3. Crea el objeto [Alumno] (inyectando por defecto idInstitucion: 1).
  /// 4. Cierra el modal devolviendo el nuevo objeto.
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Alumno guardado con éxito',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Instanciación del modelo de dominio
      final Alumno nuevoAlumno = Alumno(
        nombre: _nombre,
        apellido: _apellido,
        correoElectronico: _correoElectronico,
        idDisciplina: _disciplina!,
        idInstitucion:
            1, // Nota: Este ID debería venir de un AuthProvider en el futuro
      );

      Navigator.pop(context, nuevoAlumno);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Consumo de datos globales para poblar el selector de disciplinas
    final DisciplinasProvider disciplinasProvider =
        Provider.of<DisciplinasProvider>(context);
    final List<Disciplina> disciplinas = disciplinasProvider.disciplinas;

    return Padding(
      padding: EdgeInsets.only(
        // Ajuste dinámico para evitar que el teclado oculte el formulario
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Nuevo Alumno',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
              ),
              const SizedBox(height: 10),

              // Campo: Nombre
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'El nombre es obligatorio'
                            : null,
                onSaved: (value) => _nombre = value?.trim() ?? '',
              ),
              const SizedBox(height: 10),

              // Campo: Apellido
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Apellido',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'El apellido es obligatorio'
                            : null,
                onSaved: (value) => _apellido = value?.trim() ?? '',
              ),
              const SizedBox(height: 10),

              // Campo: Correo Electrónico con Validación por Regex
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'El correo electrónico es obligatorio';
                  // RFC 5322 compatible regex para validación de emails
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return 'Ingrese un correo válido';
                  }
                  return null;
                },
                onSaved: (value) => _correoElectronico = value?.trim() ?? '',
              ),
              const SizedBox(height: 10),

              // Selector: Disciplina Obligatoria
              DropdownButtonFormField<Disciplina>(
                decoration: const InputDecoration(
                  labelText: 'Disciplina',
                  border: OutlineInputBorder(),
                ),
                items:
                    disciplinas.map((disciplina) {
                      return DropdownMenuItem<Disciplina>(
                        value: disciplina,
                        child: Text(disciplina.getNombre()),
                      );
                    }).toList(),
                onChanged: (Disciplina? newValue) {
                  if (newValue != null)
                    setState(() => _disciplina = newValue.getId());
                },
                validator:
                    (value) =>
                        (value == null) ? 'La disciplina es obligatoria' : null,
                onSaved: (value) => _disciplina = value?.getId(),
              ),
              const SizedBox(height: 10),

              // Campo opcional: Notas/Descripción
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Descripción (Opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),

              // Botonera de acciones con estilos del tema
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                      onPressed: _submitForm,
                      child: const Text('Guardar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.secondaryContainer,
                        foregroundColor:
                            Theme.of(context).colorScheme.onSecondaryContainer,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
