import 'package:flutter/material.dart';
import 'package:sistema_gym/objetos/precio.dart';

class NuevoPrecioForm extends StatefulWidget {
  final int disciplinaId;
  const NuevoPrecioForm({super.key, required this.disciplinaId});

  @override
  _NuevoPrecioFormState createState() => _NuevoPrecioFormState();
}

class _NuevoPrecioFormState extends State<NuevoPrecioForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Variables del formulario
  int? _selectedDays;
  double? _monto;

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Guarda los valores ingresados en los campos
      _formKey.currentState!.save();
      // Aquí se pueden utilizar los datos recogidos (en este ejemplo, se muestra mediante un SnackBar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Nuevo precio registrado con éxito', style: TextStyle(color: Colors.white)),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );
      final nuevoPrecio = Precio(cantDias: _selectedDays!, precio: _monto!, disciplinaId: widget.disciplinaId);
      Navigator.pop(context,nuevoPrecio); // Cierra el modal después de guardar
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
            // Selección de cantidad de días (desplegable del 1 al 7)
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Cantidad de Días',
                border: OutlineInputBorder(),
              ),
              items: List.generate(7, (index) => index + 1)
                  .map((day) => DropdownMenuItem<int>(
                        value: day,
                        child: Text(day.toString()),
                      ))
                  .toList(),
              value: _selectedDays,
              onChanged: (int? newValue) {
                setState(() {
                  _selectedDays = newValue;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Seleccione la cantidad de días';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // Campo para ingresar el monto a cobrar (en pesos argentinos)
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Monto (ARS)',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onSaved: (value) {
                _monto = double.tryParse(value ?? '');
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese el monto';
                }
                if (double.tryParse(value) == null) {
                  return 'Ingrese un monto válido';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            // Botón para guardar los datos
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
            
          ],
        ),
      ),
    );
  }
}