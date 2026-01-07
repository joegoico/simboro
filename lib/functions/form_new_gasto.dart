import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Asegúrate de tener la dependencia intl en pubspec.yaml
import 'package:sistema_gym/objetos/gasto.dart';

/// Formulario para la creación de nuevos registros de gastos (egresos).
///
/// Captura datos transaccionales como título, monto y fecha, permitiendo
/// además una descripción opcional para auditorías contables.
/// Utiliza [DateFormat] para la presentación de fechas en formato regional.
class AgregarGastoForm extends StatefulWidget {
  const AgregarGastoForm({super.key});

  @override
  AgregarGastoFormState createState() => AgregarGastoFormState();
}

class AgregarGastoFormState extends State<AgregarGastoForm> {
  /// Llave global para el control de validación y estado del formulario.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Variables de estado para la captura de datos
  String _titulo = "";
  double? _monto;
  DateTime? _fecha;
  int? _id;
  String? _descripcion;

  /// Controlador para gestionar el campo de texto de la fecha de forma reactiva.
  final TextEditingController _fechaController = TextEditingController();

  @override
  void dispose() {
    // Liberación de recursos para prevenir fugas de memoria.
    _fechaController.dispose();
    super.dispose();
  }

  /// Despliega el selector de fecha nativo y actualiza el estado visual.
  ///
  /// Utiliza [DateFormat] de la librería 'intl' para asegurar un formato
  /// legible (dd/MM/yyyy) en el [TextFormField].
  Future<void> _selectDate(BuildContext context) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = _fecha ?? now;
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != _fecha) {
      setState(() {
        _fecha = pickedDate;
        _fechaController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  /// Valida la integridad de los datos y construye el objeto [Gasto].
  ///
  /// El proceso asegura que:
  /// 1. El título no esté vacío.
  /// 2. El monto sea un valor numérico válido.
  /// 3. La fecha haya sido seleccionada.
  ///
  /// Si la validación es exitosa, cierra el modal y retorna la instancia de [Gasto].
  void _submitForm() {
    if (_formKey.currentState!.validate() && _fecha != null) {
      _formKey.currentState!.save();

      // Notificación de éxito al usuario.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Gasto registrado con éxito',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Instanciación del modelo de datos para persistencia.
      final Gasto nuevoGasto = Gasto(
        titulo: _titulo,
        monto: _monto!,
        fecha: _fecha!,
        id: _id!, // ID manual provisorio hasta integración con backend.
        descripcion: _descripcion,
      );

      Navigator.pop(context, nuevoGasto);
    } else {
      // Validación manual para campos no gestionados directamente por el validador del campo.
      if (_fecha == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Por favor, seleccione la fecha")),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Agregar Gasto",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Campo: Título
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Título del gasto",
                border: OutlineInputBorder(),
              ),
              validator:
                  (value) =>
                      (value == null || value.isEmpty)
                          ? "El título es obligatorio"
                          : null,
              onSaved: (value) => _titulo = value!,
            ),
            const SizedBox(height: 16),

            // Campo: Monto (ARS)
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Monto (ARS)",
                border: OutlineInputBorder(),
                prefixText: "\$ ",
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty)
                  return "El monto es obligatorio";
                if (double.tryParse(value) == null)
                  return "Ingrese un monto válido";
                return null;
              },
              onSaved: (value) => _monto = double.tryParse(value!),
            ),
            const SizedBox(height: 16),

            // Campo: Fecha (Interacción mediante DatePicker)
            TextFormField(
              controller: _fechaController,
              decoration: const InputDecoration(
                labelText: "Fecha",
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.calendar_today),
              ),
              readOnly: true,
              onTap: () => _selectDate(context),
              validator:
                  (value) =>
                      (value == null || value.isEmpty)
                          ? "La fecha es obligatoria"
                          : null,
            ),
            const SizedBox(height: 16),

            // Campo: ID Provisorio (Simulación de clave primaria)
            TextFormField(
              decoration: const InputDecoration(
                labelText: "ID de registro (Provisorio)",
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              validator:
                  (value) =>
                      (value == null || value.isEmpty)
                          ? "El ID es obligatorio"
                          : null,
              onSaved: (value) => _id = int.tryParse(value!),
            ),
            const SizedBox(height: 16),

            // Campo: Descripción
            TextFormField(
              decoration: const InputDecoration(
                labelText: "Descripción (opcional)",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              onSaved: (value) => _descripcion = value,
            ),
            const SizedBox(height: 24),

            // Botonera con diseño adaptativo
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
