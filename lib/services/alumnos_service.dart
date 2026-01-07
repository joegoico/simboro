import '../config/api_config.dart';
import 'api_service.dart';
import '../objetos/alumno.dart';
import 'package:logging/logging.dart';

/// Servicio para la gestión de alumnos y su relación con las instituciones.
///
/// Provee métodos para realizar operaciones CRUD sobre la entidad [Alumno],
/// incluyendo el filtrado por institución.
class AlumnosService {
  final ApiService apiService = ApiService();
  final String endpoint = ApiConfig.alumnos;
  final _logger = Logger('AlumnosService');

  /// Recupera la lista de alumnos pertenecientes a una institución específica.
  ///
  /// [institucionId] es el identificador único de la institución.
  /// Lanza una [Exception] si la respuesta es nula o si el formato de datos
  /// recibido no es una [List].
  Future<List<Alumno>> getAlumnosByInstitucionId(int institucionId) async {
    try {
      // Realizamos la petición al endpoint anidado para mantener la semántica REST
      final response = await ApiService.get(
        '/institucion/$institucionId/alumnos',
      );

      if (response == null) {
        throw Exception('La respuesta del servidor es nula');
      }

      // Validación de seguridad: nos aseguramos de que el JSON sea efectivamente una lista
      if (response is! List) {
        throw Exception('Formato de datos inválido: Se esperaba una lista.');
      }

      // Mapeo dinámico de JSON a objetos de dominio Alumno
      return response.map((json) => Alumno.fromJson(json)).toList();
    } catch (e) {
      _logger.severe(
        'Error al obtener alumnos de la institución $institucionId: $e',
      );
      rethrow; // Re-lanzamos para que el ViewModel/Bloc pueda manejar el error
    }
  }

  /// Registra un [nuevoAlumno] en la base de datos.
  ///
  /// Retorna el [Alumno] creado con los datos validados por el backend.
  Future<Alumno> crearAlumno(Alumno alumno) async {
    try {
      final data = alumno.toJson();
      _logger.info('Iniciando creación de alumno: ${alumno.getNombre()}');

      final response = await ApiService.post(endpoint, body: data);

      return Alumno.fromJson(response);
    } catch (e) {
      _logger.severe('Error crítico al crear alumno: $e');
      rethrow;
    }
  }

  /// Actualiza la información de un [alumno] existente.
  ///
  /// Utiliza el ID interno del objeto para construir la URL del recurso.
  Future<Alumno> actualizarAlumno(Alumno alumno) async {
    try {
      final data = alumno.toJson();
      // Se concatena el ID del alumno al endpoint base
      final response = await ApiService.put(
        '$endpoint/${alumno.getId()}',
        body: data,
      );

      return Alumno.fromJson(response);
    } catch (e) {
      _logger.severe('Error al actualizar alumno ${alumno.getId()}: $e');
      rethrow;
    }
  }

  /// Elimina definitivamente un alumno mediante su [id].
  ///
  /// Si la operación falla en el servidor, se lanza una excepción.
  Future<void> eliminarAlumno(int id) async {
    try {
      await ApiService.delete('$endpoint/$id');
      _logger.info('Alumno $id eliminado correctamente');
    } catch (e) {
      _logger.severe('Error al eliminar alumno $id: $e');
      rethrow;
    }
  }
}
