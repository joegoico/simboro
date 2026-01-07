import 'package:sistema_gym/objetos/alumno.dart';

/// Representa a un alumno con obligaciones financieras pendientes.
///
/// Extiende de [Alumno] para reutilizar la gestión de datos personales y
/// servicios, añadiendo lógica específica para el control de meses de mora,
/// montos adeudados y días de retraso.
class Deudor extends Alumno {
  int? idDeudor;

  /// Listado de nombres de los meses en los que el alumno no registró pagos.
  List<String> mesesAdeudados;

  /// Sumatoria total de la deuda acumulada.
  double montoAdeudado;

  /// Cantidad de días transcurridos desde el primer vencimiento impago.
  int cantDiasAdeudados;

  Deudor({
    this.idDeudor,
    this.mesesAdeudados = const [],
    required this.montoAdeudado,
    required this.cantDiasAdeudados,
    required String nombre,
    required String apellido,
    required String correoElectronico,
    required int idDisciplina,
    required int idInstitucion,
  }) : super(
         nombre: nombre,
         apellido: apellido,
         correoElectronico: correoElectronico,
         idDisciplina: idDisciplina,
         idInstitucion: idInstitucion,
       );

  // --- Getters ---
  List<String> get getMesesAdeudados => mesesAdeudados;
  double get getMontoAdeudado => montoAdeudado;
  int get getCantDiasAdeudados => cantDiasAdeudados;

  // --- Setters y Lógica de Negocio ---

  /// Actualiza la lista completa de meses adeudados garantizando la limpieza del estado anterior.
  set setMesesAdeudados(List<String> mesesAdeudados) {
    this.mesesAdeudados = List.from(mesesAdeudados);
  }

  void setMontoAdeudado(double montoAdeudado) {
    this.montoAdeudado = montoAdeudado;
  }

  void setCantDiasAdeudados(int cantDiasAdeudados) {
    this.cantDiasAdeudados = cantDiasAdeudados;
  }

  /// Añade un nuevo periodo de mora a la lista del deudor.
  void agregarMes(String mes) {
    mesesAdeudados.add(mes);
  }

  /// Elimina un mes de la deuda y actualiza el balance económico.
  ///
  /// Se utiliza cuando el deudor salda parcialmente su deuda por un mes específico.
  void eliminarMes(String mes, double monto) {
    if (mesesAdeudados.contains(mes)) {
      mesesAdeudados.remove(mes);
      actualizarMontoAdeudado(monto);
    }
  }

  /// Ajusta el balance de la deuda basándose en un monto entregado.
  ///
  /// $$montoAdeudado_{nuevo} = montoAdeudado_{actual} - monto$$
  void actualizarMontoAdeudado(double monto) {
    montoAdeudado -= monto;
  }
}
