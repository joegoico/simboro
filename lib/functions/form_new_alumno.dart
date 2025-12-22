import 'package:flutter/material.dart';
import 'package:sistema_gym/objetos/alumno.dart';
import 'package:sistema_gym/objetos/disciplina.dart';
import 'package:provider/provider.dart';
import 'package:sistema_gym/providers/disciplinas_provider.dart';

class NuevoAlumnoForm extends StatefulWidget {
  const NuevoAlumnoForm({super.key});

  @override
  _NuevoAlumnoFormState createState() => _NuevoAlumnoFormState();
}

class _NuevoAlumnoFormState extends State<NuevoAlumnoForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); 

  String _nombre="";
  String _apellido="";
  String _correoElectronico="";
  int? _disciplina;




  void _submitForm(){
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
              Text('Alumno guardado con éxito', style: TextStyle(color: Colors.white)),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      ); // Guarda los datos del formulario
      final Alumno nuevoAlumno = Alumno(
        nombre: _nombre,
        apellido: _apellido,
        correoElectronico: _correoElectronico,
        idDisciplina: _disciplina!, 
        idInstitucion: 1,
      );                    
      Navigator.pop(context, nuevoAlumno); // Cierra el modal
    }
  }

  @override
  Widget build(BuildContext context) {
    final DisciplinasProvider disciplinasProvider = Provider.of<DisciplinasProvider>(context);
    final List<Disciplina> disciplinas = disciplinasProvider.disciplinas;
    // Formato de la fecha
        
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Se ajusta al contenido, pero se podrá desplazar
                  children: [
                    const Text(
                      'Nuevo Alumno',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w300),
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El nombre es obligatorio';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _nombre = value?.trim() ?? '';
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Apellido',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El apellido es obligatorio';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _apellido = value?.trim() ?? '';
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Correo Electrónico',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El correo electrónico es obligatorio';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Ingrese un correo válido';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _correoElectronico = value?.trim() ?? '';
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<Disciplina>(
                      decoration: const InputDecoration(
                        labelText: 'Disciplina',
                        border: OutlineInputBorder(),
                      ),
                      items: disciplinas.map((disciplina) {
                        return DropdownMenuItem<Disciplina>(
                          value: disciplina,
                          child: Text(disciplina.getNombre()),
                        );
                      }).toList(),
                      onChanged: (Disciplina? newValue) {
                        setState(() {
                          _disciplina = newValue!.getId();
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'La disciplina es obligatoria';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _disciplina = value!.getId();
                      },
                    ),                    
                    const SizedBox(height: 10),
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: _submitForm,
                            child:  Text('Guardar',style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child:  Text('Cancelar',style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer),),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
  }
}