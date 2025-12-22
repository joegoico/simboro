import 'package:flutter/material.dart';
import 'package:sistema_gym/objetos/pago.dart';
import 'package:sistema_gym/objetos/precio.dart';

class FormEditPago extends StatefulWidget{
  const FormEditPago({super.key, required this.pago, required this.precios});
  final Pago pago;
  final List <Precio> precios;

  @override
  State<FormEditPago> createState() => _FormEditPagoState();

}

class _FormEditPagoState extends State<FormEditPago>{
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _fechaController;
  Precio? precioSeleccionado;

  @override
  void initState() {
    super.initState();
    // Puedes formatear la fecha como prefieras; aquí se muestra en formato dd/MM/yyyy.
    _fechaController = TextEditingController(
        text: "${widget.pago.getFechaDePago().day.toString().padLeft(2, '0')}/${widget.pago.getFechaDePago().month.toString().padLeft(2, '0')}/${widget.pago.getFechaDePago().year}"
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
      initialDate: widget.pago.getFechaDePago(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (newSelectedDate != null) {
      setState(() {
        widget.pago.setFechaDePago(newSelectedDate); // Actualiza el objeto Gasto con la nueva fecha
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
              Text('Pago editado con éxito', style: TextStyle(color: Colors.white)),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context, widget.pago); // Cierra el modal después de guardar
    }
  }

  @override
  Widget build(BuildContext context){
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Text(
              'Editar Pago',
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _fechaController,
              decoration: const InputDecoration(
                labelText: 'Fecha del pago',
                border:  OutlineInputBorder(),
              ),
              readOnly: true, // Esto evita que el usuario escriba manualmente
              onTap: _selectDate, // Función que usará el date picker
              validator: (value) =>
              value == null || value.isEmpty ? 'Por favor, ingrese una fecha' : null,
              // No necesitas onSaved aquí, ya que actualizas directamente en el objeto.
            ),
            const SizedBox(height: 20),
            DropdownButton<Precio>(
              value: precioSeleccionado,
              hint: const Text("Selecciona un precio"),
              // Genera la lista de items a partir de widget.precios
              items: widget.precios.map((Precio precio) {
                return DropdownMenuItem<Precio>(
                  value: precio,
                  child: Text(
                    "\$${precio.getPrecio().toStringAsFixed(2)} (${precio.getCantDias()} días)",
                    style: const TextStyle(color: Colors.black),
                  ),
                );
              }).toList(),
              onChanged: (Precio? nuevoPrecio) {
                widget.pago.setMonto(nuevoPrecio!.getPrecio());
              },
            ),
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
      )
    );
  }

}