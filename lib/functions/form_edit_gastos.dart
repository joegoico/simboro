import 'package:flutter/material.dart';
import 'package:sistema_gym/objetos/gasto.dart';

/// Formulario para la edición y actualización de egresos institucionales.
///
/// Gestiona la modificación de títulos, montos y fechas de los objetos [Gasto].
/// Implementa un [DatePicker] para garantizar la integridad temporal de los datos.
class FormEditGastos extends StatefulWidget {
  const FormEditGastos({super.key, required this.gasto});

  /// La instancia del gasto que se desea editar.
  final Gasto gasto;

  @override
  State<FormEditGastos> createState() => _FormEditGastosState();
}

class _FormEditGastosState extends State<FormEditGastos> {
  /// Llave global para el manejo del estado y validación del formulario.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Controlador para gestionar la representación textual de la fecha.
  /// Se utiliza para sincronizar la selección del DatePicker con el campo visual.
  late TextEditingController _fechaController;

  @override
  void initState() {
    super.initState();
    // Inicialización del controlador con la fecha actual del objeto Gasto.
    // Se aplica un formato manual dd/MM/yyyy.
    _fechaController = TextEditingController(
      text:
          "${widget.gasto.getFecha().day.toString().padLeft(2, '0')}/${widget.gasto.getFecha().month.toString().padLeft(2, '0')}/${widget.gasto.getFecha().year}",
    );
  }

  @override
  void dispose() {
    // Liberación del controlador para prevenir fugas de memoria.
    _fechaController.dispose();
    super.dispose();
  }

  /// Despliega el selector de fecha nativo y actualiza el estado del widget.
  ///
  /// Al confirmar una nueva fecha:
  /// 1. Se actualiza el modelo [Gasto].
  /// 2. Se formatea la cadena de texto en el controlador visual.
  Future<void> _selectDate() async {
    DateTime? newSelectedDate = await showDatePicker(
      context: context,
      initialDate: widget.gasto.getFecha(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (newSelectedDate != null) {
      setState(() {
        widget.gasto.setFecha(newSelectedDate);
        _fechaController.text =
            "${newSelectedDate.day.toString().padLeft(2, '0')}/${newSelectedDate.month.toString().padLeft(2, '0')}/${newSelectedDate.year}";
      });
    }
  }

  /// Valida y persiste los cambios realizados en el formulario.
  ///
  /// Utiliza la validación de [FormState] para asegurar que el monto y el título
  /// cumplan con los requisitos mínimos de negocio antes de cerrar el modal.
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
                'Gasto editado con éxito',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Retorna el objeto Gasto actualizado a la vista de origen.
      Navigator.pop(context, widget.gasto);
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
              'Editar Gasto',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Campo: Título del Gasto
            TextFormField(
              initialValue: widget.gasto.getTitulo(),
              decoration: const InputDecoration(
                labelText: 'Nombre del gasto',
                border: OutlineInputBorder(),
              ),
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Por favor, ingrese un nombre'
                          : null,
              onSaved: (value) => widget.gasto.setTitulo(value!),
            ),
            const SizedBox(height: 20),

            // Campo: Monto (Optimizado para entrada numérica)
            TextFormField(
              initialValue: widget.gasto.getMonto().toString(),
              decoration: const InputDecoration(
                labelText: 'Monto del gasto',
                border: OutlineInputBorder(),
                prefixText: '\$ ',
              ),
              keyboardType: TextInputType.number,
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Por favor, ingrese un monto'
                          : null,
              onSaved: (value) => widget.gasto.setMonto(double.parse(value!)),
            ),
            const SizedBox(height: 20),

            // Campo de Fecha: ReadOnly con selector manual
            TextFormField(
              controller: _fechaController,
              decoration: const InputDecoration(
                labelText: 'Fecha del gasto',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true, // Protege la integridad del formato de fecha
              onTap: _selectDate,
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Por favor, ingrese una fecha'
                          : null,
            ),
            const SizedBox(height: 24),

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
