// services/institucion_service.dart
import 'package:sistema_gym/services/api_service.dart';
import '../objetos/institucion.dart';
import 'package:logging/logging.dart';

/// Servicio encargado de la gestión de instituciones deportivas.
///
/// Actúa como intermediario entre la capa de UI y [ApiService],
/// transformando las respuestas JSON en objetos de tipo [Institucion].
class InstitucionService {
  // Quitamos la barra final para evitar doble barra // al concatenar IDs
  static const String _endpoint = '/institucion';
  static final Logger logger = Logger('InstitucionService');

  /// Recupera una institución específica por su [id].
  ///
  /// Retorna una instancia de [Institucion] si la operación es exitosa,
  /// o `null` si la institución no existe o ocurre un error de red.
  Future<Institucion?> getInstitucion(int id) async {
    try {
      final data = await ApiService.get('$_endpoint/$id');

      if (data != null) {
        return Institucion.fromJson(data);
      }
      return null;
    } catch (e) {
      logger.severe('Error obteniendo institución: $e');
      return null;
    }
  }

  /// Registra una nueva [institucion] en el sistema.
  ///
  /// Envía los datos al servidor y retorna el objeto creado (incluyendo su ID generado).
  /// Si la API no devuelve datos o falla, retorna `null`.
  Future<Institucion?> createInstitucion(Institucion institucion) async {
    try {
      final jsonInst = institucion.toJson();
      logger.info('Creando institución: $jsonInst');

      final data = await ApiService.post(_endpoint, body: jsonInst);

      if (data != null) {
        return Institucion.fromJson(data);
      }

      logger.warning('La API no devolvió datos al crear la institución.');
      return null;
    } catch (e) {
      logger.severe('Error creando institución: $e');
      return null;
    }
  }

  /// Actualiza los datos de una institución existente identificada por [id].
  ///
  /// Retorna el objeto [Institucion] actualizado si la operación fue exitosa.
  /// Si la API no devuelve datos o falla, retorna `null`.
  Future<Institucion?> updateInstitucion(
    int id,
    Institucion institucion,
  ) async {
    try {
      final jsonInst = institucion.toJson();

      final data = await ApiService.put('$_endpoint/$id', body: jsonInst);

      if (data != null) {
        return Institucion.fromJson(data);
      }
      return null;
    } catch (e) {
      logger.severe('Error actualizando institución: $e');
      return null;
    }
  }

  /// Elimina una institución del sistema mediante su [id].
  ///
  /// Retorna `true` si la eliminación fue confirmada por el servidor,
  /// o `false` en caso de error.
  Future<bool> deleteInstitucion(int id) async {
    try {
      await ApiService.delete('$_endpoint/$id');
      return true;
    } catch (e) {
      logger.severe('Error eliminando institución: $e');
      return false;
    }
  }
}
