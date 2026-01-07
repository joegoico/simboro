import 'package:sistema_gym/services/api_service.dart';
import 'package:sistema_gym/config/api_config.dart';
import 'package:sistema_gym/objetos/precio.dart';
import 'package:logging/logging.dart';

/// Servicio encargado de administrar los esquemas de costos de las disciplinas.
///
/// Permite definir múltiples precios para una misma actividad, facilitando
/// la gestión de diferentes categorías de socios o frecuencias de asistencia.
class PreciosService {
  final _logger = Logger('PreciosService');
  final String endpoint = ApiConfig.precios;

  /// Recupera el listado de precios configurados para una [disciplinaId] específica.
  ///
  /// Utiliza una ruta jerárquica para obtener todas las opciones arancelarias
  /// de una actividad deportiva. Lanza una excepción en caso de error de red.
  Future<List<Precio>> getPreciosByDisciplinaId(int disciplinaId) async {
    try {
      final response = await ApiService.get(
        '/disciplina/$disciplinaId/precios',
      );
      // Mapeo masivo utilizando el factory listFromJson del modelo Precio
      return Precio.listFromJson(response);
    } catch (e) {
      _logger.severe(
        'Fallo al obtener tarifas para la disciplina $disciplinaId: $e',
      );
      rethrow;
    }
  }

  /// Obtiene el detalle de un [precioId] individual.
  ///
  /// Útil para procesos de facturación o validación de aranceles específicos.
  Future<Precio> getPrecioById(int precioId) async {
    try {
      final response = await ApiService.get('$endpoint/$precioId');
      return Precio.fromJson(response);
    } catch (e) {
      _logger.severe('Error al recuperar el precio individual $precioId: $e');
      rethrow;
    }
  }

  /// Registra una nueva opción de [precio] en el catálogo.
  ///
  /// Los datos se envían en formato JSON al endpoint base de gestión de tarifas.
  Future<Precio> createPrecio(Precio precio) async {
    try {
      final data = precio.toJson();
      _logger.info('Registrando nueva tarifa en el sistema');

      final response = await ApiService.post(endpoint, body: data);
      return Precio.fromJson(response);
    } catch (e) {
      _logger.severe('Error crítico al crear nueva tarifa: $e');
      rethrow;
    }
  }

  /// Actualiza los valores o condiciones de un [precio] existente.
  ///
  /// Utiliza el método `getId()` del objeto para determinar la ruta del recurso.
  Future<Precio> updatePrecio(Precio precio) async {
    try {
      final data = precio.toJson();
      final response = await ApiService.put(
        '$endpoint/${precio.getId()}',
        body: data,
      );
      return Precio.fromJson(response);
    } catch (e) {
      _logger.severe('Error al actualizar la tarifa ${precio.getId()}: $e');
      rethrow;
    }
  }

  /// Elimina una configuración de precio mediante su [precioId].
  ///
  /// Esta acción quita la opción de arancel del catálogo de la disciplina.
  Future<void> deletePrecio(int precioId) async {
    try {
      await ApiService.delete('$endpoint/$precioId');
      _logger.info('Tarifa $precioId eliminada correctamente.');
    } catch (e) {
      _logger.severe('Fallo al intentar eliminar la tarifa $precioId: $e');
      rethrow;
    }
  }
}
