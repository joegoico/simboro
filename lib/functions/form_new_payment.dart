import 'package:flutter/material.dart';
import 'package:sistema_gym/objetos/alumno.dart';
import 'package:sistema_gym/objetos/disciplina.dart';
import 'package:sistema_gym/providers/disciplinas_provider.dart';
import 'package:sistema_gym/objetos/pago.dart';
import 'package:sistema_gym/objetos/precio.dart';
import 'package:sistema_gym/providers/alumnos_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sistema_gym/providers/finanzas_provider.dart';

/// Formulario de alta de pagos con lógica de selección en cascada.
///
/// Este componente coordina tres entidades del sistema:
/// 1. [Alumnos]: Para vincular el cobro a una persona.
/// 2. [Disciplinas/Precios]: Para determinar el monto basado en la actividad.
/// 3. [Finanzas]: Para registrar el ingreso en el balance global.
class FormNewPayment extends StatefulWidget {
  const FormNewPayment({super.key});

  @override
  State<FormNewPayment> createState() => _FormNewPaymentState();
}

class _FormNewPaymentState extends State<FormNewPayment> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fechaController = TextEditingController();

  // Variables de estado para la selección vinculada
  DateTime? _fechaPago;
  Disciplina? _selectedDiscipline;
  Alumno? _selectedAlumno;
  Precio? _selectedPrice;
  bool applyDiscount = false;

  /// Gestiona la selección de fecha y actualiza el controlador visual.
  Future<void> _selectDate(BuildContext context) async {
    DateTime? newSelectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (newSelectedDate != null) {
      setState(() {
        _fechaPago = newSelectedDate;
        _fechaController.text = DateFormat(
          'dd/MM/yyyy',
        ).format(newSelectedDate);
      });
    }
  }

  /// Ejecuta la lógica de negocio para persistir el pago.
  ///
  /// Realiza tres acciones atómicas:
  /// 1. Crea la instancia de [Pago].
  /// 2. Actualiza el historial del [Alumno] seleccionado.
  /// 3. Notifica al [FinanzasProvider] para actualizar los reportes globales.
  void _submitForm() {
    // Validación de seguridad: Campos obligatorios y fecha seleccionada
    if (_formKey.currentState!.validate() &&
        _fechaPago != null &&
        _selectedAlumno != null &&
        _selectedPrice != null) {
      _formKey.currentState!.save();

      final Pago nuevoPago = Pago(
        monto: _selectedPrice!.getPrecio(),
        fechaDePago: _fechaPago!,
        descuento: applyDiscount,
      );

      // Inyección de datos en los modelos correspondientes
      _selectedAlumno!.agregarFechaDePago(nuevoPago);
      Provider.of<FinanzasProvider>(
        context,
        listen: false,
      ).agregarPago(nuevoPago);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Text('Pago registrado y procesado con éxito'),
        ),
      );

      Navigator.pop(context, nuevoPago);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Inyección de dependencias mediante Provider (Patrón Observer)
    final disciplinasProvider =
        Provider.of<DisciplinasProvider>(context).disciplinas;
    final alumnosProvider = Provider.of<AlumnosModel>(context).alumnos;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Nuevo Pago',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              // Campo de Fecha: Read-only para integridad de datos
              TextFormField(
                controller: _fechaController,
                decoration: const InputDecoration(
                  labelText: 'Fecha de pago',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.calendar_month_rounded),
                ),
                readOnly: true,
                onTap: () => _selectDate(context),
                validator:
                    (value) =>
                        (value == null || value.isEmpty)
                            ? 'Ingrese la fecha'
                            : null,
              ),
              const SizedBox(height: 10),

              // Selector de Alumno
              DropdownButtonFormField<Alumno>(
                decoration: const InputDecoration(
                  labelText: 'Alumno',
                  border: OutlineInputBorder(),
                ),
                items:
                    alumnosProvider
                        .map(
                          (alumno) => DropdownMenuItem(
                            value: alumno,
                            child: Text(
                              '${alumno.getNombre()} ${alumno.getApellido()}',
                            ),
                          ),
                        )
                        .toList(),
                onChanged:
                    (newValue) => setState(() => _selectedAlumno = newValue),
                validator:
                    (value) => value == null ? 'Seleccione un alumno' : null,
              ),
              const SizedBox(height: 10),

              // Selector de Disciplina: Disparador de la cascada de precios
              DropdownButtonFormField<Disciplina>(
                value: _selectedDiscipline,
                decoration: const InputDecoration(
                  labelText: 'Disciplina',
                  border: OutlineInputBorder(),
                ),
                items:
                    disciplinasProvider
                        .map(
                          (disciplina) => DropdownMenuItem(
                            value: disciplina,
                            child: Text(disciplina.getNombre()),
                          ),
                        )
                        .toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedDiscipline = newValue;
                    _selectedPrice = null; // Reset de la cascada
                  });
                },
                validator:
                    (value) =>
                        value == null ? 'Seleccione la disciplina' : null,
              ),
              const SizedBox(height: 10),

              // Selector de Precio (Dependiente de la disciplina seleccionada)
              DropdownButtonFormField<Precio>(
                value: _selectedPrice,
                decoration: const InputDecoration(
                  labelText: 'Plan / Precio',
                  border: OutlineInputBorder(),
                ),
                // Lógica de filtrado dinámico
                items:
                    _selectedDiscipline
                        ?.getPrecios()
                        .map(
                          (precio) => DropdownMenuItem(
                            value: precio,
                            child: Text(
                              '\$${precio.getPrecio().toStringAsFixed(2)} - ${precio.getCantDias()} días',
                            ),
                          ),
                        )
                        .toList(),
                onChanged:
                    (newValue) => setState(() => _selectedPrice = newValue),
                validator:
                    (value) =>
                        value == null ? 'Seleccione un plan de precio' : null,
              ),

              // Toggle de Descuento
              SwitchListTile(
                title: const Text('¿Aplicar Descuento?'),
                value: applyDiscount,
                onChanged: (value) => setState(() => applyDiscount = value),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.onPrimary,
                      ),
                      onPressed: _submitForm,
                      child: const Text('Guardar Pago'),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
