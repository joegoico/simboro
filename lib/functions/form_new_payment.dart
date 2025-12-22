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

class FormNewPayment extends StatefulWidget {
  const FormNewPayment({super.key}
);

  @override
  State<FormNewPayment> createState() => _FormNewPaymentState();
}

class _FormNewPaymentState extends State<FormNewPayment> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _fechaController = TextEditingController();
  DateTime? _fechaPago;
  Disciplina? _selectedDiscipline;
  Alumno? _selectedAlumno; // Almacena el alumno seleccionado
  Precio? _selectedPrice;
  bool applyDiscount = false; // Variable para aplicar descuento

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
      // Formatea la fecha para mostrarla en el TextFormField
      _fechaController.text =
          DateFormat('dd/MM/yyyy').format(newSelectedDate);

      });
    }
  }

  

  void _submitForm(){
    if (_formKey.currentState!.validate() && _fechaPago != null && _selectedAlumno != null) {
      _formKey.currentState!.save();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.green,
          content: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 10),
              Text('Pago registrado con éxito', style: TextStyle(color: Colors.white)),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      ); // Guarda 
      // Suponiendo que Pago es un objeto que representa el pago
      Pago nuevoPago = Pago(
        monto: _selectedPrice!.getPrecio(), // Cambia el monto según la lógica de descuento
        fechaDePago: _fechaPago!,
        descuento: applyDiscount,
      );
        // Si el usuario confirma, agrega el pago
        _selectedAlumno!.agregarFechaDePago(nuevoPago);
        Provider.of<FinanzasProvider>(context, listen: false).agregarPago(nuevoPago);
        Navigator.pop(context, nuevoPago);
    }
  }
  
  


  @override
  Widget build(BuildContext context) {
    final disciplinasProvider = Provider.of<DisciplinasProvider>(context).disciplinas; // Obtiene la lista de disciplinas del provider
    final alumnosProvider = Provider.of<AlumnosModel>(context).alumnos; // Obtiene la lista de alumnos del provider
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Form(
        child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text( 'Nuevo Pago', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    TextFormField(
                      controller: _fechaController,
                      decoration: const InputDecoration(
                        labelText: 'Fecha de pago',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_month_rounded),
                      ),
                      readOnly: true, // Esto evita que el usuario escriba manualmente
                      onTap: (){
                        _selectDate(context); // Llama a la función para seleccionar la fecha
                      }, // Función que usará el date picker
                      validator: (value) =>
                        value == null || value.isEmpty ? 'Por favor, ingrese una fecha' : null,
                      // No necesitas onSaved aquí, ya que actualizas directamente en el objeto.
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<Alumno>(
                      decoration: const InputDecoration(
                        labelText: 'Alumno',
                        border: OutlineInputBorder(),
                      ),
                      items: alumnosProvider.map((Alumno alumno) {
                        return DropdownMenuItem<Alumno>(
                          value: alumno,
                          child: Text(alumno.getNombre()),
                        );
                      }).toList(),
                      onChanged: (Alumno? newValue) {
                        setState(() {
                          _selectedAlumno = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 10),     
                    DropdownButtonFormField<Disciplina>(
                      value: _selectedDiscipline, // Asignar el valor de la disciplina del alumno
                      decoration: const InputDecoration(
                        labelText: 'Disciplina',
                        border: OutlineInputBorder()),
                      items: disciplinasProvider.map((Disciplina disciplina) {
                        return DropdownMenuItem<Disciplina>(
                          value: disciplina,
                          child: Text(disciplina.getNombre()),
                        );
                      }).toList(),
                      onChanged: (Disciplina? newValue) {
                        setState(() {
                          _selectedDiscipline = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<Precio>( // Asignar el valor del precio del alumno
                      decoration: const InputDecoration(
                        labelText: 'Precio',
                        border: OutlineInputBorder()),
                      items: _selectedDiscipline?.getPrecios().map((Precio precio) {
                        return DropdownMenuItem<Precio>(
                          value: precio,
                          child: Text(
                                '${precio.getPrecio().toStringAsFixed(2)} ARS - ${precio.getCantDias()} días'),
                        );
                      }).toList(),
                      onChanged: (Precio? newValue) {
                        setState(() {
                          _selectedPrice = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Switch(
                          value: applyDiscount,
                          onChanged: (bool? value) {
                            setState(() {
                              applyDiscount = value ?? false;
                            });
                          },
                        ),
                        const Text('Aplicar Descuento'),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                            ),
                            onPressed: _submitForm,
                            child:  Text('Guardar Pago',style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),),
                        )),
                        const SizedBox(width: 15,),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                            ),
                            onPressed: () {
                              Navigator.pop(context); // Cerrar el formulario sin guardar
                            },
                            child:  Text('Cancelar',style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer),),
                          ),)
                      ],
                    ),
                    const SizedBox(height: 10),                   
                  ],
                ),
              ),
            ),
        ),
      ),
    );
  }
}