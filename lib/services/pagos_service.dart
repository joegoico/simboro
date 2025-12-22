import 'package:sistema_gym/objetos/pago.dart';
import 'package:sistema_gym/services/api_service.dart';
import 'package:sistema_gym/config/api_config.dart';
import 'package:logging/logging.dart';

class PagosService  {
  final _logger = Logger('PagosService');
  final String endpoint = ApiConfig.pagos;

  Future<List<Pago>> getPagosByAlumnoId(int alumnoId) async {
    try {
      final response = await ApiService.get('/alumno/$alumnoId/pagos');
      return Pago.listFromJson(response);
    } catch (e) {
      _logger.severe('Error al obtener los pagos del alumno: $e');
      rethrow;
    }
  }
  
  Future<Pago> crearPago(Pago pago) async {
    try {
      final data = pago.toJson();
      final response = await ApiService.post(endpoint, body: data);
      return Pago.fromJson(response);
    } catch (e) {
      _logger.severe('Error al crear el pago: $e');
      rethrow;
    }
  }

  Future<Pago> actualizarPago(Pago pago) async {
    try {
      final data = pago.toJson();
      final response = await ApiService.put('$endpoint/${pago.getId()}', body: data);
      return Pago.fromJson(response);
    } catch (e) {
      _logger.severe('Error al actualizar el pago: $e');
      rethrow;
    }
  }

  Future<void> eliminarPago(Pago pago) async {
    try {
      await ApiService.delete('$endpoint/${pago.getId()}');
    } catch (e) {
      _logger.severe('Error al eliminar el pago: $e');
      rethrow;
    }
  }
}