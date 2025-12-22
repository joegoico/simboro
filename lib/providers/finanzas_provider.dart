import 'package:flutter/material.dart';
import 'package:sistema_gym/objetos/pago.dart';
import 'package:intl/intl.dart';
import 'package:sistema_gym/objetos/gasto.dart';

class FinanzasProvider extends ChangeNotifier {

  final Map<String, double> _pagosPorMes = {};
  final Map<String, double> _gastosPorMes = {};

  Map<String, double> get pagosPorMes => Map.unmodifiable(_pagosPorMes);

  void agregarPago(Pago nuevoPago) {
    String mesKey = DateFormat('MMMM', 'es_ES').format(nuevoPago.getFechaDePago());
    mesKey = '${mesKey[0].toUpperCase()}${mesKey.substring(1)}';

    if (_pagosPorMes.containsKey(mesKey)) {
      _pagosPorMes[mesKey]=_pagosPorMes[mesKey]! + nuevoPago.getMonto();
    } else {
      _pagosPorMes[mesKey] = nuevoPago.getMonto();
    }
    notifyListeners();
  }
  void agregarGasto(Gasto nuevoGasto) {
    String mes = DateFormat('MMMM', 'es_ES').format(nuevoGasto.getFecha());
    if (_gastosPorMes.containsKey(mes)) {
      _gastosPorMes[mes] = _gastosPorMes[mes]! + nuevoGasto.getMonto();
    } else {
      _gastosPorMes[mes] = nuevoGasto.getMonto();
    }
    notifyListeners();
  }

  void eliminarPago(Pago pago) {
    String mesKey = DateFormat('MMMM', 'es_ES').format(pago.getFechaDePago());
    mesKey = '${mesKey[0].toUpperCase()}${mesKey.substring(1)}';
    if (_pagosPorMes.containsKey(mesKey)) {
      _pagosPorMes[mesKey] = _pagosPorMes[mesKey]! - pago.getMonto();
      notifyListeners();
    }
  }

  void eliminarGasto(Gasto gasto) {
    String mesKey = DateFormat('MMMM', 'es_ES').format(gasto.getFecha());
    if (_gastosPorMes.containsKey(mesKey)) {
      _gastosPorMes[mesKey] = _gastosPorMes[mesKey]! - gasto.getMonto();
      notifyListeners();
    }
  }

  String _getMesKey(Pago pago) {
    String key = DateFormat('MMMM', 'es_ES').format(pago.getFechaDePago());
    key = '${key[0].toUpperCase()}${key.substring(1)}';
    return key;
  }

  double _calculoDeMontos(Pago oldPay, Pago newPay){
    // Si el mes no cambió, simplemente actualizamos la diferencia en ese mes.
    if (_getMesKey(oldPay) == _getMesKey(newPay)) {
      if (_pagosPorMes.containsKey(_getMesKey(oldPay))) {
        return  _pagosPorMes[_getMesKey(oldPay)]! - oldPay.getMonto() + newPay.getMonto();
      }
    } else {
      // Si el mes cambió:
      // Restar el monto del pago original del mes antiguo.
      if (_pagosPorMes.containsKey(_getMesKey(oldPay))) {
        _pagosPorMes[_getMesKey(oldPay)]= _pagosPorMes[_getMesKey(oldPay)]! - oldPay.getMonto();
      }

      // Sumar el monto del nuevo pago al mes nuevo.
      if (_pagosPorMes.containsKey(_getMesKey(newPay))) {
        return _pagosPorMes[_getMesKey(newPay)]! + newPay.getMonto();
      } else {
        // En caso de que no exista aún la clave para el mes nuevo
        return newPay.getMonto();
      }
    }
    return 0;

  }

  void editarPago(Pago pago, Pago nuevoPago) {
    // Obtener la clave del mes del pago original.
    if(_getMesKey(pago)==_getMesKey(nuevoPago)){
      _pagosPorMes[_getMesKey(pago)] = _calculoDeMontos(pago, nuevoPago);
    }else{
      _pagosPorMes[_getMesKey(nuevoPago)] = _calculoDeMontos(pago, nuevoPago);
    }
    notifyListeners();
  }
}