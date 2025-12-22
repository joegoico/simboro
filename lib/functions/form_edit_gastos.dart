import 'package:flutter/material.dart';
import 'package:sistema_gym/objetos/gasto.dart';

class FormEditGastos extends StatefulWidget{
  const FormEditGastos({super.key, required this.gasto});
  final Gasto gasto;

  @override
  State<FormEditGastos> createState() => _FormEditGastosState();
}

class _FormEditGastosState extends State<FormEditGastos>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController _fechaController;

  @override
  void initState() {
    super.initState();
    // Puedes formatear la fecha como prefieras; aquí se muestra en formato dd/MM/yyyy.
    _fechaController = TextEditingController(
      text: "${widget.gasto.getFecha().day.toString().padLeft(2, '0')}/${widget.gasto.getFecha().month.toString().padLeft(2, '0')}/${widget.gasto.getFecha().year}"
    );
  }
    
  @override
  void dispose() {
    _fechaController.dispose();
    super.dispose();
  }
  Future<void> _selectDate() async {
    DateTime? newSelectedDate = await showDatePicker(
      context: context,
      initialDate: widget.gasto.getFecha(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (newSelectedDate != null) {
      setState(() {
        widget.gasto.setFecha(newSelectedDate); // Actualiza el objeto Gasto con la nueva fecha
        // Actualiza el controlador con la nueva fecha formateada
        _fechaController.text =
            "${newSelectedDate.day.toString().padLeft(2, '0')}/${newSelectedDate.month.toString().padLeft(2, '0')}/${newSelectedDate.year}";
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      // Aquí procesas los datos, por ejemplo:
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Gasto editado con éxito', style: TextStyle(color: Colors.white)),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context, widget.gasto); // Cierra el modal después de guardar
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
            Text(
              'Editar Gasto',
            ),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: widget.gasto.getTitulo(),
              decoration: const InputDecoration(
                labelText: 'Nombre del gasto',
                border:  OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.isEmpty ? 'Por favor, ingrese un nombre' : null,
              onSaved: (value) {
                widget.gasto.setTitulo(value!);
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              initialValue: widget.gasto.getMonto().toString(),
              decoration: const InputDecoration(
                labelText: 'Monto del gasto',
                border:  OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator: (value) => value == null || value.isEmpty ? 'Por favor, ingrese un monto' : null,
              onSaved: (value) {
                widget.gasto.setMonto(double.parse(value!));
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _fechaController,
              decoration: const InputDecoration(
                labelText: 'Fecha del gasto',
                border:  OutlineInputBorder(),
              ),
              readOnly: true, // Esto evita que el usuario escriba manualmente
              onTap: _selectDate, // Función que usará el date picker
              validator: (value) =>
                value == null || value.isEmpty ? 'Por favor, ingrese una fecha' : null,
              // No necesitas onSaved aquí, ya que actualizas directamente en el objeto.
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Aquí puedes manejar la lógica para editar el gasto
                    _submitForm();
                  },
                  child: const Text('Guardar Cambios'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Cierra el modal sin guardar cambios
                  },
                  child: const Text('Cancelar'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}