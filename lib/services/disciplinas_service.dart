import '../config/api_config.dart';
import 'api_service.dart';
import '../objetos/disciplina.dart';
import 'package:logging/logging.dart';
import 'dart:convert';

/// Servicio para administrar las disciplinas o actividades deportivas del club.
///
/// Permite gestionar el catálogo de deportes, sus costos y la asociación
/// jerárquica con la institución correspondiente.
class DisciplinasService extends ApiService {
  final _logger = Logger('DisciplinasService');
  final String endpoint = ApiConfig.disciplina;

  /// Obtiene el listado completo de disciplinas asociadas a una [institucionId].
  ///
  /// Realiza una validación manual del estado de la respuesta y verifica
  /// que el cuerpo sea una lista válida antes de proceder con el mapeo
  /// a través de [Disciplina.listFromJson].
  Future<List<Disciplina>> getDisciplinasByInstitucionId(
    int institucionId,
  ) async {
    try {
      final response = await ApiService.get(
        '/institucion/$institucionId/disciplina',
      );

      // En este método específico se valida el código de estado para asegurar
      // la integridad de la lista antes de parsear.
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // Verificación de tipo: previene errores de ejecución si el back cambia el formato
        if (jsonResponse is! List) {
          _logger.severe(
            'Error de formato: Se esperaba List y se recibió ${jsonResponse.runtimeType}',
          );
          throw Exception('La respuesta del servidor no es una lista');
        }

        return Disciplina.listFromJson(jsonResponse);
      }
      throw Exception('Error del servidor: ${response.statusCode}');
    } catch (e) {
      _logger.severe(
        'Fallo al recuperar disciplinas para institución $institucionId: $e',
      );
      rethrow;
    }
  }

  /// Recupera los detalles de una disciplina específica mediante su [id].
  ///
  /// Retorna un objeto [Disciplina] procesado por la lógica centralizada de [ApiService].
  Future<Disciplina> getDisciplinaById(int id) async {
    try {
      final response = await ApiService.get('$endpoint/$id');
      // La respuesta ya viene decodificada por el interceptor del ApiService
      return Disciplina.fromJson(response);
    } catch (e) {
      _logger.severe('Error al consultar disciplina individual $id: $e');
      rethrow;
    }
  }

  /// Registra una nueva [disciplina] en el sistema.
  ///
  /// Transforma el objeto a JSON y registra la respuesta para trazabilidad
  /// en los logs del sistema.
  Future<Disciplina> createDisciplina(Disciplina disciplina) async {
    try {
      final data = disciplina.toJson();
      _logger.info(
        'Solicitando creación de nueva disciplina: ${disciplina.getNombre()}',
      );

      final response = await ApiService.post(endpoint, body: data);

      return Disciplina.fromJson(response);
    } catch (e) {
      _logger.severe('Fallo en la creación de disciplina: $e');
      rethrow;
    }
  }

  /// Actualiza la información de una [disciplina] existente.
  ///
  /// Obtiene el ID dinámicamente del objeto para construir la ruta del recurso.
  Future<Disciplina> actualizarDisciplina(Disciplina disciplina) async {
    try {
      final data = disciplina.toJson();
      // Concatenación de ID para cumplir con el estándar REST (PUT /endpoint/id)
      final response = await ApiService.put(
        '$endpoint/${disciplina.getId()}',
        body: data,
      );

      return Disciplina.fromJson(response);
    } catch (e) {
      _logger.severe(
        'Error en actualización de disciplina ${disciplina.getId()}: $e',
      );
      rethrow;
    }
  }

  /// Elimina una disciplina del catálogo mediante su [id].
  ///
  /// Si la operación no lanza una excepción, se considera que el borrado
  /// fue exitoso en la base de datos.
  Future<void> eliminarDisciplina(int id) async {
    try {
      await ApiService.delete('$endpoint/$id');
      _logger.info('Disciplina $id eliminada exitosamente');
    } catch (e) {
      _logger.severe('Error al intentar eliminar la disciplina $id: $e');
      rethrow;
    }
  }
}
