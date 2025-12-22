import 'package:flutter/material.dart';
import 'package:sistema_gym/objetos/precio.dart';

class FormEditPrecio extends StatefulWidget {
  const FormEditPrecio({super.key, required this.precio});
  final Precio precio;

  @override
  State<FormEditPrecio> createState() => _FormEditPrecioState();

}

class _FormEditPrecioState extends State<FormEditPrecio> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  int? _selectedDays;

  void _submitForm() {
    if(_formKey.currentState!.validate()){
      _formKey.currentState!.save();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 10),
                Text('Precio editado con éxito', style: TextStyle(color: Colors.white)),
              ]
            ),
          backgroundColor: Colors.green,
        )
      );
      Navigator.pop(context,widget.precio);
    }
  }

  @override
  Widget build (BuildContext context){
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(
              'Editar Precio',
              style: TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
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
              onSaved: (value) => widget.precio.setCantDias(value!),
              validator: (value) {
                if (value == null) {
                  return 'Seleccione la cantidad de días';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Monto (ARS)',
                border: OutlineInputBorder(),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onSaved: (value) {
                widget.precio.setPrecio(double.parse(value!));
              }),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: _submitForm,
                    child:  Text('Guardar cambios',style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),),
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
      )
    );
  }
}