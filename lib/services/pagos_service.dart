import 'package:sistema_gym/objetos/pago.dart';
import 'package:sistema_gym/services/api_service.dart';
import 'package:sistema_gym/config/api_config.dart';
import 'package:logging/logging.dart';

/// Servicio dedicado a la gestión de transacciones financieras y pagos.
///
/// Permite el seguimiento de las cuotas y aranceles abonados por los alumnos,
/// facilitando el control de ingresos de la institución.
class PagosService {
  final _logger = Logger('PagosService');
  final String endpoint = ApiConfig.pagos;

  /// Recupera el historial de pagos asociados a un [alumnoId].
  ///
  /// Utiliza un endpoint jerárquico para filtrar los registros directamente
  /// desde el servidor. Retorna una [List] de objetos [Pago].
  Future<List<Pago>> getPagosByAlumnoId(int alumnoId) async {
    try {
      final response = await ApiService.get('/alumno/$alumnoId/pagos');
      // Delegamos el mapeo masivo al método estático del modelo Pago
      return Pago.listFromJson(response);
    } catch (e) {
      _logger.severe(
        'Fallo al recuperar historial de pagos para el alumno $alumnoId: $e',
      );
      rethrow;
    }
  }

  /// Registra una nueva transacción de [pago] en el sistema.
  ///
  /// El objeto retornado incluye los metadatos generados por el backend,
  /// como la fecha de registro y el ID de transacción.
  Future<Pago> crearPago(Pago pago) async {
    try {
      final data = pago.toJson();
      final response = await ApiService.post(endpoint, body: data);
      return Pago.fromJson(response);
    } catch (e) {
      _logger.severe('Error crítico al registrar nuevo pago: $e');
      rethrow;
    }
  }

  /// Actualiza la información de un registro de [pago] existente.
  ///
  /// Útil para corregir errores en montos, fechas o conceptos de pago.
  /// El ID se obtiene dinámicamente mediante el método `getId()`.
  Future<Pago> actualizarPago(Pago pago) async {
    try {
      final data = pago.toJson();
      final response = await ApiService.put(
        '$endpoint/${pago.getId()}',
        body: data,
      );
      return Pago.fromJson(response);
    } catch (e) {
      _logger.severe('Error al intentar modificar el pago ${pago.getId()}: $e');
      rethrow;
    }
  }

  /// Elimina un registro de [pago] del historial mediante su identificador.
  ///
  /// Esta operación debe usarse con precaución ya que afecta directamente
  /// los balances contables de la institución.
  Future<void> eliminarPago(Pago pago) async {
    try {
      await ApiService.delete('$endpoint/${pago.getId()}');
      _logger.info('Pago ${pago.getId()} eliminado del registro contable.');
    } catch (e) {
      _logger.severe('Error al eliminar registro de pago ${pago.getId()}: $e');
      rethrow;
    }
  }
}
