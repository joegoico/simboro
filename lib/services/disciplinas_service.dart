import '../config/api_config.dart';
import 'api_service.dart';
import '../objetos/disciplina.dart';
import 'package:logging/logging.dart';
import 'dart:convert';

class DisciplinasService extends ApiService {
  final _logger = Logger('DisciplinasService');
  final String endpoint = ApiConfig.disciplina;
  
  // Obtener disciplinas por institución
  Future<List<Disciplina>> getDisciplinasByInstitucionId(int institucionId) async {
    try {
      //_logger.info('Obteniendo disciplinas para la institución ID: $institucionId');
      final response = await ApiService.get('/institucion/$institucionId/disciplina');
      
      _logger.info('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse is! List) {
          _logger.severe('Respuesta inesperada del servidor: $jsonResponse');
          throw Exception('La respuesta del servidor no es una lista');
        }
        _logger.info('Respuesta del servidor para la institución $institucionId: $jsonResponse');
        return Disciplina.listFromJson(jsonResponse);
      }
      throw Exception('Error ${response.statusCode}: ${response.body}');
    } catch (e) {
      _logger.severe('Error al obtener disciplinas de la institución $institucionId: $e');
      rethrow;
    }
  } 

  // Obtener disciplina por ID
  Future<Disciplina> getDisciplinaById(int id) async {
    try {
      final response = await ApiService.get('$endpoint/$id');
      return Disciplina.fromJson(response);
    } catch (e) {
      _logger.severe('Error al obtener disciplina por ID: $e');
      rethrow;
    }
  }
  

  // Crear una nueva disciplina
  Future<Disciplina> createDisciplina(Disciplina disciplina) async {
    try {
      final data = disciplina.toJson();
      _logger.info('Enviando datos para crear disciplina: $data');
      
      final response = await ApiService.post(endpoint, body: data);
      _logger.info('Respuesta al crear disciplina: $response');
      
      return Disciplina.fromJson(response);
    } catch (e) {
      _logger.severe('Error al crear disciplina: $e');
      rethrow;
    }
  }

  // Actualizar una disciplina existente
  Future<Disciplina> actualizarDisciplina(Disciplina disciplina) async {
    try {
      final data = disciplina.toJson();
      final response = await ApiService.put('$endpoint/${disciplina.getId()}', body: data);
      return Disciplina.fromJson(response);
    } catch (e) {
      _logger.severe('Error al actualizar disciplina: $e');
      rethrow;
    }
  }

  // Eliminar una disciplina
  Future<void> eliminarDisciplina(int id) async {
    try {
      await ApiService.delete('$endpoint/$id');
    } catch (e) {
      _logger.severe('Error al eliminar disciplina: $e');
      rethrow;
    }
  }
} 