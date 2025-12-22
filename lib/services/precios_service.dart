import 'package:sistema_gym/services/api_service.dart';
import 'package:sistema_gym/config/api_config.dart';
import 'package:sistema_gym/objetos/precio.dart';
import 'package:logging/logging.dart';

class PreciosService {
  final _logger = Logger('PreciosService');
  final String endpoint = ApiConfig.precios;

  Future<List<Precio>> getPreciosByDisciplinaId(int disciplinaId) async {
    try {
      final response = await ApiService.get('/disciplina/$disciplinaId/precios');
      return Precio.listFromJson(response);
    } catch (e) {
      _logger.severe('Error al obtener precios por disciplina ID: $e');
      rethrow;
    }
  }

  Future<Precio> getPrecioById(int precioId) async {
    try {
      final response = await ApiService.get('$endpoint/$precioId');
      return Precio.fromJson(response);
    } catch (e) {
      _logger.severe('Error al obtener precio por ID: $e');
      rethrow;
    }
  }

  Future<Precio> createPrecio(Precio precio) async {
    try {
      final data = precio.toJson();
      final response = await ApiService.post(endpoint, body: data); 
      return Precio.fromJson(response);
    } catch (e) {
      _logger.severe('Error al crear precio: $e');
      rethrow;
    }
  }

  Future<Precio> updatePrecio(Precio precio) async {
    try {
      final data = precio.toJson();
      final response = await ApiService.put('$endpoint/${precio.getId()}', body: data);
      return Precio.fromJson(response);
    } catch (e) {
      _logger.severe('Error al actualizar precio: $e');
      rethrow;
    }
  }

  Future<void> deletePrecio(int precioId) async {
    try {
      await ApiService.delete('$endpoint/$precioId');
    } catch (e) {
      _logger.severe('Error al eliminar precio: $e');
      rethrow;
    }
  }
}

