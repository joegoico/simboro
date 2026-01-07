import 'package:flutter/material.dart';
import 'package:sistema_gym/objetos/alumno.dart';
import 'package:sistema_gym/providers/disciplinas_provider.dart';
import 'package:provider/provider.dart';
import 'package:sistema_gym/objetos/disciplina.dart';

/// Formulario especializado para la edición de datos de un [Alumno].
///
/// Este componente permite modificar información básica y reasignar disciplinas.
/// Utiliza una [GlobalKey] para gestionar el estado del formulario y asegurar
/// que los datos sean válidos antes de persistirlos.
class FormEditAlumnos extends StatefulWidget {
  const FormEditAlumnos({super.key, required this.alumno});

  /// La instancia del alumno que se desea modificar.
  final Alumno alumno;

  @override
  State<FormEditAlumnos> createState() => _FormEditAlumnosState();
}

class _FormEditAlumnosState extends State<FormEditAlumnos> {
  /// Llave global que identifica de forma única el formulario y permite la validación.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Almacena la disciplina actualmente seleccionada en el dropdown.
  Disciplina? _selectedDisciplina;

  @override
  void initState() {
    super.initState();
    // Carga inicial de la disciplina para mostrarla en el formulario.
    _loadDisciplina();
  }

  /// Recupera de forma asíncrona la disciplina actual del alumno.
  ///
  /// Esto es necesario ya que la relación puede requerir una consulta
  /// adicional o el mapeo de un ID a un objeto [Disciplina].
  Future<void> _loadDisciplina() async {
    final disciplina = await widget.alumno.getDisciplina();
    if (mounted) {
      setState(() {
        _selectedDisciplina = disciplina;
      });
    }
  }

  /// Ejecuta el proceso de validación y guardado del formulario.
  ///
  /// Si la validación es exitosa:
  /// 1. Dispara los callbacks [onSaved] de cada campo.
  /// 2. Notifica al usuario mediante un [SnackBar].
  /// 3. Retorna el objeto [Alumno] actualizado a la pantalla anterior.
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Feedback visual siguiendo las guías de Material Design.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Alumno editado con éxito',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Se cierra el contexto del formulario devolviendo el objeto modificado.
      Navigator.pop(context, widget.alumno);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Consumo de DisciplinasProvider para poblar las opciones del Dropdown.
    final DisciplinasProvider disciplinasProvider =
        Provider.of<DisciplinasProvider>(context);
    final List<Disciplina> disciplinas = disciplinasProvider.disciplinas;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Text(
              'Editar Alumno',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Campo: Nombre
            TextFormField(
              initialValue: widget.alumno.getNombre(),
              decoration: const InputDecoration(
                labelText: 'Nombre del alumno',
                border: OutlineInputBorder(),
              ),
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Por favor, ingrese un nombre'
                          : null,
              onSaved: (value) => widget.alumno.setNombre(value!),
            ),
            const SizedBox(height: 20),

            // Campo: Apellido
            TextFormField(
              initialValue: widget.alumno.getApellido(),
              decoration: const InputDecoration(
                labelText: 'Apellido del alumno',
                border: OutlineInputBorder(),
              ),
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Por favor, ingrese un apellido'
                          : null,
              onSaved: (value) => widget.alumno.setApellido(value!),
            ),
            const SizedBox(height: 20),

            // Campo: Correo Electrónico
            TextFormField(
              initialValue: widget.alumno.getCorreoElectronico(),
              decoration: const InputDecoration(
                labelText: 'Correo electrónico del alumno',
                border: OutlineInputBorder(),
              ),
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Por favor, ingrese un correo electrónico'
                          : null,
              onSaved: (value) => widget.alumno.setCorreoElectronico(value!),
            ),
            const SizedBox(height: 20),

            // Selector Relacional: Disciplina
            DropdownButtonFormField<Disciplina>(
              decoration: const InputDecoration(
                labelText: 'Disciplina',
                border: OutlineInputBorder(),
              ),
              value: _selectedDisciplina,
              items:
                  disciplinas.map((disciplina) {
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
            const SizedBox(height: 24),

            // Botonera de acciones
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
