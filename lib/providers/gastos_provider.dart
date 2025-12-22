
import 'package:flutter/foundation.dart';
import 'package:sistema_gym/objetos/gasto.dart';
import 'package:intl/intl.dart';

// GastosProvider usando un Map, donde la clave es el mes (p.ej., "Mayo") y el valor una lista de gastos.
class GastosProvider extends ChangeNotifier {
  // Usamos Map<String, List<Gasto>> para agrupar los gastos por mes.
  final Map<String, List<Gasto>> _gastosPorMes = {};

  // Retorna el map completo como inmutable.
  Map<String, List<Gasto>> get gastosPorMes => Map.unmodifiable(_gastosPorMes);

  // Método para agregar un gasto.
  void agregarGasto(Gasto nuevoGasto) {
    // Obtener el nombre del mes formateado.
    String mesKey = DateFormat('MMMM', 'es_ES').format(nuevoGasto.getFecha());
    mesKey = '${mesKey[0].toUpperCase()}${mesKey.substring(1)}';

    if (_gastosPorMes.containsKey(mesKey)) {
      insertGastoOrdered(nuevoGasto, mesKey);
    } else {
      _gastosPorMes[mesKey] = [nuevoGasto];
    }
    notifyListeners();
  }

  void eliminarGasto(Gasto gasto) {
    String mesKey = _getMesKey(gasto);
    if (_gastosPorMes.containsKey(mesKey)) {
      // Se elimina buscando el gasto cuyo id coincida con el del gasto a eliminar.
      _gastosPorMes[mesKey]!.removeWhere((g) => g.getId() == gasto.getId());
      // Si la lista queda vacía, se elimina la clave.
      if (_gastosPorMes[mesKey]!.isEmpty) {
        _gastosPorMes.remove(mesKey);
      }
      notifyListeners();
    }
  }

  String _getMesKey(Gasto gasto) {
    String key = DateFormat('MMMM', 'es_ES').format(gasto.getFecha());
    key = '${key[0].toUpperCase()}${key.substring(1)}';
    return key;
  }

  void editarGasto(Gasto oldGasto, Gasto newGasto) {
    if(_getMesKey(oldGasto)==_getMesKey(newGasto)){
      int index = _gastosPorMes[_getMesKey(oldGasto)]!.indexWhere(
            (gasto) => gasto.getId() == oldGasto.getId(),
      );
      if (index != -1) {
        // Se actualiza el total restando el monto antiguo y sumando el nuevo,
        // usando el gasto que se encuentra en ese índice.
         _gastosPorMes[_getMesKey(oldGasto)]![index]=newGasto;
      }
    }else{
      if(_gastosPorMes.containsKey(_getMesKey(oldGasto))) {
        eliminarGasto(oldGasto);
      }
      if(_gastosPorMes.containsKey(_getMesKey(newGasto))){
        agregarGasto(newGasto);
      }
      else{
        agregarGasto(newGasto);
      }
    }
    notifyListeners();
  }
  void insertGastoOrdered( Gasto newGasto, String mesKey) {
    // Si la lista está vacía, simplemente agrega el nuevo gasto.
    if ( _gastosPorMes[mesKey]!.isEmpty) {
      _gastosPorMes[mesKey]!.add(newGasto);
      return;
    }
    
    // Encuentra el índice en que el nuevo gasto debe insertarse.
    // Compara las fechas y si newGasto es anterior a un gasto existente, se inserta justo antes.
    int indexToInsert =  _gastosPorMes[mesKey]!.indexWhere((gasto) => newGasto.getFecha().isBefore(gasto.getFecha()));
    
    if (indexToInsert == -1) {
       _gastosPorMes[mesKey]!.add(newGasto);
    } else {
       _gastosPorMes[mesKey]!.insert(indexToInsert, newGasto);
    }
  }
}