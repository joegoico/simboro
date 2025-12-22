import '../config/api_config.dart';
import 'api_service.dart';
import '../objetos/alumno.dart';
import 'package:logging/logging.dart';

class AlumnosService  {
  final ApiService apiService = ApiService();
  final String endpoint = ApiConfig.alumnos;
  final _logger = Logger('AlumnosService');

  
  // Obtener alumnos por institución
 Future<List<Alumno>> getAlumnosByInstitucionId(int institucionId) async {
  try {
    // Realiza el GET request utilizando el ApiService
    final response = await ApiService.get('/institucion/$institucionId/alumnos');

    if (response == null) {
      throw Exception('La respuesta del servidor es nula');
    }

    // Verifica que la respuesta sea de tipo lista
    if (response is! List) {
      throw Exception('La respuesta del servidor no es una lista');
    }

    // Convierte la respuesta en una lista de objetos Alumno
    return response.map((json) => Alumno.fromJson(json)).toList();
  } catch (e) {
    // Loggea el error utilizando tu herramienta de logging
    print('Error al obtener alumnos: $e');
    rethrow;
  }
}

  // Crear un nuevo alumno
  Future<Alumno> crearAlumno(Alumno alumno) async {
    try {
      final data = alumno.toJson();
      _logger.info('Enviando datos para crear alumno: $data');
      
      final response = await ApiService.post(endpoint,body: data);
      _logger.info('Respuesta al crear alumno: $response');
      
      return Alumno.fromJson(response);
    } catch (e) {
      _logger.severe('Error al crear alumno: $e');
      rethrow;
    }
  }

  // Actualizar un alumno existente
  Future<Alumno> actualizarAlumno(Alumno alumno) async {
    try {
      final data = alumno.toJson();
      final response = await ApiService.put('$endpoint/${alumno.getId()}', body: data);
      return Alumno.fromJson(response);
    } catch (e) {
      _logger.severe('Error al actualizar alumno: $e');
      rethrow;
    }
  }

  // Eliminar un alumno
  Future<void> eliminarAlumno(int id) async {
    try {
      await ApiService.delete('$endpoint/$id');
    } catch (e) {
      _logger.severe('Error al eliminar alumno: $e');
      rethrow;
    }
  }
} 