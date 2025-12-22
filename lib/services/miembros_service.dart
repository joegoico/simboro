import 'dart:convert';
import 'package:sistema_gym/services/api_service.dart';
import 'package:sistema_gym/objetos/miembro.dart';
import 'package:logging/logging.dart';

class MiembrosService extends ApiService {
  static const String _endpoint = '/miembros';
  final Logger logger = Logger('MiembrosService');

  // Obtener miembros por institución
  Future<List<Miembro>> getMiembrosByInstitucion(int institucionId) async {
    try {
      final response = await ApiService.get('$_endpoint/$institucionId');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Miembro.fromJson(item)).toList();
      } else if (response.statusCode == 401) {
        await ApiService.refreshToken();
        return getMiembrosByInstitucion(institucionId); // Reintentar
      }
      return [];
    } catch (e) {
      logger.severe('Error obteniendo miembros: $e');
      return [];
    }
  }

  // En tu MiembroService de Flutter

  Future<Miembro?> getMiembroById(String id) async {
    try {
      print('entro al getMiembroById');
      // ApiService.get ahora debe manejar los errores y lanzar excepciones.
      // Ya no esperamos un http.Response, sino el body decodificado o una excepción.
      final data = await ApiService.get('$_endpoint/$id');
      print('despues del await');

      // Si ApiService.get no lanzó una excepción y devolvió datos, los procesamos.
      if (data != null) {
        logger.info('Miembro obtenido: $data');
        return Miembro.fromJson(data);
      }
      // Si devuelve null (porque el body estaba vacío), lo tratamos como "no encontrado".
      return null;
    } on Exception catch (e) {
      print('Error en getMiembroById: $e');
      // ¡AQUÍ ESTÁ LA MAGIA!
      // Si ApiService lanza una excepción por un 404, la capturamos.
      // Suponiendo que tu _handleError convierte un 404 en una excepción reconocible.
      if (e.toString().contains('404')) {
        // O una comprobación más elegante
        logger.warning('Miembro no encontrado (404 recibido del backend).');
        return null; // Devolvemos null, que es lo que espera _redirectTo.
      }

      // Si es otro error, lo registramos y devolvemos null.
      logger.severe('Error obteniendo miembro por ID: $e');
      return null;
    }
  }

  Future<Miembro?> createMiembro(Miembro miembro) async {
    try {
      final response = await ApiService.post(
        _endpoint,
        body: (miembro.toJson()),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return Miembro.fromJson(data);
      } else if (response.statusCode == 401) {
        await ApiService.refreshToken();
        return createMiembro(miembro); // Reintentar
      }
      return null;
    } catch (e) {
      logger.severe('Error creando miembro: $e');
      return null;
    }
  }

  Future<Miembro?> updateMiembro(Miembro miembro) async {
    try {
      final response = await ApiService.put(
        '$_endpoint/${miembro.userId}',
        body: (miembro.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Miembro.fromJson(data);
      } else if (response.statusCode == 401) {
        await ApiService.refreshToken();
        return updateMiembro(miembro); // Reintentar
      }
      return null;
    } catch (e) {
      logger.severe('Error actualizando miembro: $e');
      return null;
    }
  }

  Future<bool> deleteMiembro(String id) async {
    try {
      final response = await ApiService.delete('$_endpoint/$id');

      if (response.statusCode == 204) {
        logger.info('Miembro eliminado exitosamente');
        return true; // Miembro eliminado exitosamente
      } else if (response.statusCode == 401) {
        await ApiService.refreshToken();
        return deleteMiembro(id); // Reintentar
      }
      return false; // Error al eliminar
    } catch (e) {
      logger.severe('Error eliminando miembro: $e');
      return false;
    }
  }

  // Otros métodos para crear, actualizar, eliminar miembros...
}
