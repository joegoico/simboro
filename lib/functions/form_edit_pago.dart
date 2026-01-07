import 'package:flutter/material.dart';
import 'package:sistema_gym/objetos/pago.dart';
import 'package:sistema_gym/objetos/precio.dart';

/// Formulario para la edición de transacciones financieras.
///
/// Permite modificar la fecha de un cobro y actualizar su monto seleccionando
/// una tarifa del catálogo de [precios] disponibles.
class FormEditPago extends StatefulWidget {
  const FormEditPago({super.key, required this.pago, required this.precios});

  /// El registro de pago que se desea modificar.
  final Pago pago;

  /// Catálogo de tarifas vigentes de la disciplina para asignar al pago.
  final List<Precio> precios;

  @override
  State<FormEditPago> createState() => _FormEditPagoState();
}

class _FormEditPagoState extends State<FormEditPago> {
  /// Llave para la gestión de validación y estado del formulario.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Controlador para la representación visual de la fecha seleccionada.
  late TextEditingController _fechaController;

  /// Almacena la tarifa seleccionada del catálogo.
  Precio? precioSeleccionado;

  @override
  void initState() {
    super.initState();
    // Sincronización inicial del controlador con la fecha del objeto Pago.
    _fechaController = TextEditingController(
      text:
          "${widget.pago.getFechaDePago().day.toString().padLeft(2, '0')}/${widget.pago.getFechaDePago().month.toString().padLeft(2, '0')}/${widget.pago.getFechaDePago().year}",
    );
  }

  @override
  void dispose() {
    // Limpieza de recursos para evitar memory leaks.
    _fechaController.dispose();
    super.dispose();
  }

  /// Gestiona la selección de fecha mediante el componente nativo de la plataforma.
  ///
  /// Al confirmar, actualiza tanto el modelo [pago] como el controlador visual.
  Future<void> _selectDate() async {
    DateTime? newSelectedDate = await showDatePicker(
      context: context,
      initialDate: widget.pago.getFechaDePago(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (newSelectedDate != null) {
      setState(() {
        widget.pago.setFechaDePago(newSelectedDate);
        _fechaController.text =
            "${newSelectedDate.day.toString().padLeft(2, '0')}/${newSelectedDate.month.toString().padLeft(2, '0')}/${newSelectedDate.year}";
      });
    }
  }

  /// Valida el formulario y retorna el objeto [pago] actualizado.
  ///
  /// Muestra un [SnackBar] de éxito antes de cerrar el modal de edición.
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
                'Pago editado con éxito',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context, widget.pago);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            const Text(
              'Editar Pago',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Selector de Fecha (ReadOnly para garantizar formato correcto)
            TextFormField(
              controller: _fechaController,
              decoration: const InputDecoration(
                labelText: 'Fecha del pago',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: _selectDate,
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Por favor, ingrese una fecha'
                          : null,
            ),
            const SizedBox(height: 20),

            // Selector de Monto basado en el catálogo de Precios
            DropdownButtonFormField<Precio>(
              value: precioSeleccionado,
              decoration: const InputDecoration(
                labelText: "Selecciona una tarifa",
                border: OutlineInputBorder(),
              ),
              hint: const Text("Seleccionar precio"),
              items:
                  widget.precios.map((Precio precio) {
                    return DropdownMenuItem<Precio>(
                      value: precio,
                      child: Text(
                        "\$${precio.getPrecio().toStringAsFixed(2)} (${precio.getCantDias()} días)",
                      ),
                    );
                  }).toList(),
              onChanged: (Precio? nuevoPrecio) {
                if (nuevoPrecio != null) {
                  setState(() {
                    precioSeleccionado = nuevoPrecio;
                    widget.pago.setMonto(nuevoPrecio.getPrecio());
                  });
                }
              },
              validator:
                  (value) =>
                      value == null ? 'Por favor, seleccione un precio' : null,
            ),
            const SizedBox(height: 24),

            // Acciones del formulario con colores adaptativos del tema
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    onPressed: _submitForm,
                    child: const Text('Guardar'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.secondaryContainer,
                      foregroundColor: colorScheme.onSecondaryContainer,
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
