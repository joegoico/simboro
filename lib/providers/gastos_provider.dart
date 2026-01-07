import 'package:flutter/foundation.dart';
import 'package:sistema_gym/objetos/gasto.dart';
import 'package:intl/intl.dart';

/// Proveedor encargado de gestionar la colección detallada de egresos.
///
/// A diferencia del motor contable, este provider organiza los objetos [Gasto]
/// en un mapa indexado por mes, manteniendo cada lista interna ordenada
/// cronológicamente para optimizar la visualización en la UI.
class GastosProvider extends ChangeNotifier {
  /// Almacén de gastos agrupados. Clave: Nombre del mes, Valor: Lista de Gastos.
  final Map<String, List<Gasto>> _gastosPorMes = {};

  /// Expone una vista inmutable del mapa de gastos.
  Map<String, List<Gasto>> get gastosPorMes => Map.unmodifiable(_gastosPorMes);

  /// Registra un nuevo gasto en el sistema.
  ///
  /// Si el mes ya existe en el mapa, delega la inserción a [insertGastoOrdered]
  /// para mantener la secuencia temporal. Si no, crea una nueva entrada.
  void agregarGasto(Gasto nuevoGasto) {
    String mesKey = _getMesKey(nuevoGasto);

    if (_gastosPorMes.containsKey(mesKey)) {
      insertGastoOrdered(nuevoGasto, mesKey);
    } else {
      _gastosPorMes[mesKey] = [nuevoGasto];
    }
    notifyListeners();
  }

  /// Elimina un gasto específico basado en su identificador único.
  ///
  /// Si tras la eliminación la lista del mes queda vacía, remueve la clave
  /// del mapa para optimizar el uso de memoria y limpiar la UI.
  void eliminarGasto(Gasto gasto) {
    String mesKey = _getMesKey(gasto);
    if (_gastosPorMes.containsKey(mesKey)) {
      _gastosPorMes[mesKey]!.removeWhere((g) => g.getId() == gasto.getId());

      if (_gastosPorMes[mesKey]!.isEmpty) {
        _gastosPorMes.remove(mesKey);
      }
      notifyListeners();
    }
  }

  /// Gestiona la actualización de datos de un gasto existente.
  ///
  /// Contempla el cambio de mes (traslado entre listas) o la simple
  /// actualización de valores dentro del mismo periodo mensual.
  void editarGasto(Gasto oldGasto, Gasto newGasto) {
    String oldKey = _getMesKey(oldGasto);
    String newKey = _getMesKey(newGasto);

    if (oldKey == newKey) {
      // Caso: Actualización en el mismo mes
      int index = _gastosPorMes[oldKey]!.indexWhere(
        (g) => g.getId() == oldGasto.getId(),
      );
      if (index != -1) {
        _gastosPorMes[oldKey]![index] = newGasto;
      }
    } else {
      // Caso: El gasto cambió de fecha a otro mes
      eliminarGasto(oldGasto);
      agregarGasto(newGasto);
    }
    notifyListeners();
  }

  /// Implementación de inserción ordenada (Binary-like search insertion).
  ///
  /// Mantiene la lista de gastos organizada por fecha. La complejidad
  /// temporal es $O(n)$ en el peor de los casos, lo cual es ideal para
  /// listas de tamaño moderado en dispositivos móviles.
  void insertGastoOrdered(Gasto newGasto, String mesKey) {
    List<Gasto> listaDelMes = _gastosPorMes[mesKey]!;

    if (listaDelMes.isEmpty) {
      listaDelMes.add(newGasto);
      return;
    }

    // Encuentra la posición correcta basada en la cronología
    int indexToInsert = listaDelMes.indexWhere(
      (g) => newGasto.getFecha().isBefore(g.getFecha()),
    );

    if (indexToInsert == -1) {
      listaDelMes.add(newGasto);
    } else {
      listaDelMes.insert(indexToInsert, newGasto);
    }
  }

  /// Estandariza la generación de claves para el mapa.
  String _getMesKey(Gasto gasto) {
    String key = DateFormat('MMMM', 'es_ES').format(gasto.getFecha());
    return '${key[0].toUpperCase()}${key.substring(1)}';
  }
}
