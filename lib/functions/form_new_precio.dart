import 'package:flutter/material.dart';
import 'package:sistema_gym/objetos/precio.dart';

/// Formulario para la creación de nuevas tarifas vinculadas a una disciplina.
///
/// Permite definir el costo y la frecuencia semanal de una actividad.
/// Recibe un [disciplinaId] obligatorio para asegurar la relación jerárquica
/// en la base de datos.
class NuevoPrecioForm extends StatefulWidget {
  /// Identificador de la disciplina a la cual pertenecerá este precio.
  final int disciplinaId;

  const NuevoPrecioForm({super.key, required this.disciplinaId});

  @override
  _NuevoPrecioFormState createState() => _NuevoPrecioFormState();
}

class _NuevoPrecioFormState extends State<NuevoPrecioForm> {
  /// Llave global para el control de validación y estado del formulario.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Variables de estado local para la captura de datos
  int? _selectedDays;
  double? _monto;

  /// Orquestador del guardado de la nueva tarifa.
  ///
  /// 1. Ejecuta la validación de todos los campos del [Form].
  /// 2. Persiste los valores mediante [save].
  /// 3. Instancia el objeto [Precio] inyectando el [disciplinaId] del widget.
  /// 4. Notifica el éxito y cierra el modal devolviendo el nuevo objeto.
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // Feedback visual de operación exitosa
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Nuevo precio registrado con éxito'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Creación del objeto de dominio con los datos recolectados
      final nuevoPrecio = Precio(
        cantDias: _selectedDays!,
        precio: _monto!,
        disciplinaId: widget.disciplinaId,
      );

      // Retorno del objeto para actualización de la UI o persistencia en API
      Navigator.pop(context, nuevoPrecio);
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
          children: [
            // Selección de frecuencia semanal (Dropdown para restringir el dominio de datos)
            DropdownButtonFormField<int>(
              decoration: const InputDecoration(
                labelText: 'Cantidad de Días por semana',
                border: OutlineInputBorder(),
              ),
              // Generación dinámica de opciones del 1 al 7
              items:
                  List.generate(7, (index) => index + 1)
                      .map(
                        (day) => DropdownMenuItem<int>(
                          value: day,
                          child: Text(day.toString()),
                        ),
                      )
                      .toList(),
              value: _selectedDays,
              onChanged:
                  (int? newValue) => setState(() => _selectedDays = newValue),
              validator:
                  (value) =>
                      value == null ? 'Seleccione la cantidad de días' : null,
            ),
            const SizedBox(height: 16),

            // Campo de Monto: Entrada numérica con soporte decimal
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Monto (ARS)',
                border: OutlineInputBorder(),
                prefixText: '\$ ',
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onSaved: (value) => _monto = double.tryParse(value ?? ''),
              validator: (value) {
                if (value == null || value.isEmpty) return 'Ingrese el monto';
                if (double.tryParse(value) == null)
                  return 'Ingrese un monto válido';
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Acciones del formulario con jerarquía visual (Primary vs Secondary)
            Row(
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
