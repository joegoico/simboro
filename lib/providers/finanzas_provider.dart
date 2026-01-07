import 'package:flutter/material.dart';
import 'package:sistema_gym/objetos/pago.dart';
import 'package:intl/intl.dart';
import 'package:sistema_gym/objetos/gasto.dart';

/// Proveedor encargado de la lógica analítica y financiera.
///
/// Gestiona la agregación de ingresos ([Pago]) y egresos ([Gasto]) agrupados
/// por periodos mensuales, permitiendo una visualización ejecutiva del balance.
class FinanzasProvider extends ChangeNotifier {
  /// Acumuladores de totales indexados por nombre de mes (ej. "Enero").
  final Map<String, double> _pagosPorMes = {};
  final Map<String, double> _gastosPorMes = {};

  /// Expone los datos agregados de forma inmutable.
  Map<String, double> get pagosPorMes => Map.unmodifiable(_pagosPorMes);
  Map<String, double> get gastosPorMes => Map.unmodifiable(_gastosPorMes);

  /// Registra un ingreso y actualiza el acumulador mensual correspondiente.
  ///
  /// Realiza una normalización de la clave (mes) para asegurar consistencia
  /// visual (Capitalización) y localización al español.
  void agregarPago(Pago nuevoPago) {
    String mesKey = _getMesKeyFromDate(nuevoPago.getFechaDePago());

    _pagosPorMes[mesKey] = (_pagosPorMes[mesKey] ?? 0) + nuevoPago.getMonto();
    notifyListeners();
  }

  /// Registra un egreso en el acumulador de gastos mensual.
  void agregarGasto(Gasto nuevoGasto) {
    String mes = DateFormat('MMMM', 'es_ES').format(nuevoGasto.getFecha());
    _gastosPorMes[mes] = (_gastosPorMes[mes] ?? 0) + nuevoGasto.getMonto();
    notifyListeners();
  }

  /// Reversa un pago del acumulador mensual.
  void eliminarPago(Pago pago) {
    String mesKey = _getMesKeyFromDate(pago.getFechaDePago());
    if (_pagosPorMes.containsKey(mesKey)) {
      _pagosPorMes[mesKey] = _pagosPorMes[mesKey]! - pago.getMonto();
      notifyListeners();
    }
  }

  /// Gestiona la edición de pagos, contemplando cambios de monto o de periodo.
  ///
  /// Si el pago cambia de mes, el sistema realiza una transferencia de
  /// fondos entre claves del mapa para mantener la integridad del balance.
  void editarPago(Pago pago, Pago nuevoPago) {
    String oldKey = _getMesKeyFromDate(pago);
    String newKey = _getMesKeyFromDate(nuevoPago);

    if (oldKey == newKey) {
      // Caso A: Cambio de monto en el mismo mes
      _pagosPorMes[oldKey] =
          _pagosPorMes[oldKey]! - pago.getMonto() + nuevoPago.getMonto();
    } else {
      // Caso B: El pago se movió a otro mes (Transferencia)
      _pagosPorMes[oldKey] = (_pagosPorMes[oldKey] ?? 0) - pago.getMonto();
      _pagosPorMes[newKey] = (_pagosPorMes[newKey] ?? 0) + nuevoPago.getMonto();
    }
    notifyListeners();
  }

  /// Helper para estandarizar la generación de claves de mapa.
  String _getMesKeyFromDate(dynamic objeto) {
    DateTime fecha = (objeto is Pago) ? objeto.getFechaDePago() : objeto;
    String key = DateFormat('MMMM', 'es_ES').format(fecha);
    return '${key[0].toUpperCase()}${key.substring(1)}';
  }
}
