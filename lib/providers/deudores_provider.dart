import 'package:flutter/cupertino.dart';
import 'package:sistema_gym/objetos/deudor.dart';

/// Clase encargada de administrar el estado de los alumnos con deudas pendientes.
///
/// Proporciona una interfaz reactiva para que la UI pueda visualizar y
/// modificar el estado de morosidad sin necesidad de recargar todo el padrón.
class DeudoresProvider extends ChangeNotifier {
  /// Lista interna de deudores.
  List<Deudor> _deudores = [];

  /// Expone los deudores actuales para su consumo en la UI.
  List<Deudor> get deudores => _deudores;

  /// Registra un nuevo alumno en la lista de morosidad.
  ///
  /// Dispara [notifyListeners] para que las pantallas de reportes o
  /// notificaciones se actualicen instantáneamente.
  void agregarDeudor(Deudor deudor) {
    _deudores.add(deudor);
    notifyListeners();
  }

  /// Remueve a un alumno de la lista de deudores (ej: tras saldar el total).
  void eliminarDeudor(Deudor deudor) {
    _deudores.remove(deudor);
    notifyListeners();
  }

  /// Procesa el pago parcial o total de un periodo específico.
  ///
  /// Este método es un gran ejemplo de **delegación de responsabilidades**:
  /// 1. Llama al método [eliminarMes] del objeto [Deudor] (Lógica de dominio).
  /// 2. Notifica a la UI del cambio de estado (Gestión de estado).
  void eliminarDeuda(Deudor deudor, String mes, double monto) {
    // La mutación ocurre dentro del modelo, garantizando la integridad.
    deudor.eliminarMes(mes, monto);

    // Si tras eliminar el mes el deudor ya no tiene meses pendientes,
    // se podría evaluar automatizar su salida de la lista aquí.
    notifyListeners();
  }
}
