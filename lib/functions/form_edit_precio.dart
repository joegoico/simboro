import 'package:flutter/material.dart';
import 'package:sistema_gym/objetos/precio.dart';

/// Formulario para la actualización de tarifas específicas de una disciplina.
///
/// Permite modificar el costo monetario y la frecuencia semanal (cantidad de días)
/// asociada a un plan de entrenamiento [Precio].
class FormEditPrecio extends StatefulWidget {
  const FormEditPrecio({super.key, required this.precio});

  /// La instancia del modelo Precio que se desea editar.
  final Precio precio;

  @override
  State<FormEditPrecio> createState() => _FormEditPrecioState();
}

class _FormEditPrecioState extends State<FormEditPrecio> {
  /// Llave global para el control de validación y estado del formulario.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Almacena el valor seleccionado para la frecuencia semanal.
  int? _selectedDays;

  @override
  void initState() {
    super.initState();
    // Inicializamos con el valor actual del objeto para persistencia visual.
    _selectedDays = widget.precio.getCantDias();
  }

  /// Ejecuta la validación y persiste los cambios.
  ///
  /// Si los datos son válidos, actualiza el objeto [precio] y lo devuelve
  /// a la pantalla anterior para actualizar la UI.
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text(
                'Precio editado con éxito',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );

      // Retorno del objeto actualizado mediante el Navigator.
      Navigator.pop(context, widget.precio);
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
              'Editar Precio',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Selector de Frecuencia: Limitado de 1 a 7 días.
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Cantidad de Días (por semana)',
                border: OutlineInputBorder(),
              ),
              // Generamos las opciones dinámicamente para mayor limpieza.
              items:
                  List.generate(7, (index) => index + 1)
                      .map(
                        (day) => DropdownMenuItem<int>(
                          value: day,
                          child: Text('$day día${day > 1 ? "s" : ""}'),
                        ),
                      )
                      .toList(),
              value: _selectedDays,
              onChanged: (int? newValue) {
                setState(() => _selectedDays = newValue);
              },
              onSaved: (value) => widget.precio.setCantDias(value!),
              validator:
                  (value) =>
                      value == null ? 'Seleccione la cantidad de días' : null,
            ),
            const SizedBox(height: 16),

            // Campo de Monto: Configurado para teclado numérico decimal.
            TextFormField(
              initialValue: widget.precio.getPrecio().toString(),
              decoration: const InputDecoration(
                labelText: 'Monto (ARS)',
                border: OutlineInputBorder(),
                prefixText: '\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Ingrese un monto';
                if (double.tryParse(value) == null)
                  return 'Ingrese un número válido';
                return null;
              },
              onSaved: (value) => widget.precio.setPrecio(double.parse(value!)),
            ),
            const SizedBox(height: 24),

            // Botonera con integración de colores de Material 3.
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                    ),
                    onPressed: _submitForm,
                    child: const Text('Guardar cambios'),
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
          ],
        ),
      ),
    );
  }
}
