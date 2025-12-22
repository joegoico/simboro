// services/institucion_service.dart
import 'dart:convert';
import 'api_service.dart';
import '../objetos/institucion.dart';
import 'package:sistema_gym/services/api_service.dart';
import 'package:logging/logging.dart';

class InstitucionService extends ApiService {
  static const String _endpoint = '/institucion/';
  static final Logger logger = Logger('InstitucionService');

  // Obtener una institución por ID
  Future<Institucion?> getInstitucion(int id) async {
    try {
      final response = await ApiService.get('$_endpoint/$id');

      if (response.statusCode == 200) {
        return Institucion.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        await ApiService.refreshToken();
        return getInstitucion(id); // Reintentar
      }
      return null;
    } catch (e) {
      logger.severe('Error obteniendo institución: $e');
      return null;
    }
  }

  // Crear una nueva institución
  Future<Institucion?> createInstitucion(Institucion institucion) async {
    try {
      final jsonInst = institucion.toJson();
      logger.info('Creando institución: $jsonInst');

      // ApiService.post ahora se encargará de los 401 y reintentos.
      // Si falla permanentemente, lanzará una excepción que capturamos abajo.
      final responseBody = await ApiService.post(_endpoint, body: jsonInst);

      if (responseBody != null) {
        return Institucion.fromJson(responseBody);
      }

      logger.warning(
        'La creación de la institución no devolvió un cuerpo de respuesta.',
      );
      return null;
    } catch (e) {
      logger.severe('Error final creando institución: $e');
      // Aquí puedes relanzar el error o devolver null, dependiendo de tu manejo de UI.
      return null;
    }
  }

  // Actualizar una institución
  Future<Institucion?> updateInstitucion(
    int id,
    Institucion institucion,
  ) async {
    try {
      final json_inst = institucion.toJson();
      final response = await ApiService.put('$_endpoint/$id', body: json_inst);

      if (response.statusCode == 200) {
        return Institucion.fromJson(json.decode(response.body));
      } else if (response.statusCode == 401) {
        await ApiService.refreshToken();
        return updateInstitucion(id, institucion);
      }
      logger.severe('Error actualizando institución: ${response.body}');
      return null;
    } catch (e) {
      logger.severe('Error actualizando institución: $e');
      return null;
    }
  }

  // Eliminar una institución
  Future<bool> deleteInstitucion(int id) async {
    try {
      final response = await ApiService.delete('$_endpoint/$id');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else if (response.statusCode == 401) {
        await ApiService.refreshToken();
        return deleteInstitucion(id);
      }
      logger.severe('Error eliminando institución: ${response.body}');
      return false;
    } catch (e) {
      logger.severe('Error eliminando institución: $e');
      return false;
    }
  }
}
