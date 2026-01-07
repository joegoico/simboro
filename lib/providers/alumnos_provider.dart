// modelo_alumnos.dart
import 'package:flutter/foundation.dart';
import 'package:sistema_gym/objetos/alumno.dart';
import 'package:sistema_gym/objetos/pago.dart';
import 'package:sistema_gym/services/alumnos_service.dart';
import 'package:logging/logging.dart';

/// Clase encargada de gestionar el estado global de los alumnos.
///
/// Implementa [ChangeNotifier] para notificar a la UI sobre cambios en los datos.
/// Actúa como un puente entre la capa de presentación y [AlumnosService].
class AlumnosModel extends ChangeNotifier {
  /// Lista interna de alumnos (Single Source of Truth en el cliente).
  final List<Alumno> _alumnos = [];

  /// Inyección del servicio de persistencia.
  final AlumnosService _alumnosService = AlumnosService();

  /// Estado de carga para feedback visual en la UI.
  bool _isLoading = false;

  final _logger = Logger('AlumnosModel');

  /// Expone la lista de alumnos de forma segura.
  ///
  /// El uso de [List.unmodifiable] es una excelente práctica de ingeniería:
  /// impide que los widgets modifiquen la lista directamente, obligándolos
  /// a usar los métodos del Provider.
  List<Alumno> get alumnos => List.unmodifiable(_alumnos);

  bool get isLoading => _isLoading;

  /// Recupera el padrón de alumnos desde el backend.
  ///
  /// Gestiona el ciclo de vida del estado de carga ([_isLoading]) y
  /// dispara [notifyListeners] para refrescar la vista.
  Future<void> cargarAlumnos(int institucionId) async {
    _isLoading = true;
    notifyListeners(); // Inicia estado de carga en la UI

    try {
      final alumnosFromServer = await _alumnosService.getAlumnosByInstitucionId(
        institucionId,
      );
      _alumnos.clear();
      _alumnos.addAll(alumnosFromServer);
    } catch (e) {
      _logger.warning('Error al cargar alumnos: $e');
    } finally {
      _isLoading = false;
      notifyListeners(); // Finaliza carga y actualiza lista
    }
  }

  /// Registra un nuevo alumno y actualiza la colección en memoria.
  Future<void> agregarAlumno(Alumno nuevoAlumno) async {
    try {
      final alumnoCreado = await _alumnosService.crearAlumno(nuevoAlumno);
      _alumnos.add(alumnoCreado);
      notifyListeners();
    } catch (e) {
      _logger.warning('Fallo en la creación del alumno: $e');
      rethrow;
    }
  }

  /// Elimina un alumno del sistema tras confirmar la persistencia en el backend.
  Future<void> eliminarAlumno(Alumno alumno) async {
    try {
      await _alumnosService.eliminarAlumno(alumno.getId());
      _alumnos.remove(alumno);
      notifyListeners();
    } catch (e) {
      _logger.warning('Error al eliminar alumno ${alumno.getId()}: $e');
      rethrow;
    }
  }

  /// Actualiza los datos de un alumno existente.
  ///
  /// Sincroniza la respuesta exitosa del servidor con el índice correspondiente
  /// en la lista local para evitar inconsistencias visuales.
  Future<void> editarAlumno(Alumno alumno, Alumno nuevoAlumno) async {
    try {
      final alumnoActualizado = await _alumnosService.actualizarAlumno(
        nuevoAlumno,
      );
      final index = _alumnos.indexWhere(
        (a) => a.getId() == nuevoAlumno.getId(),
      );
      if (index != -1) {
        _alumnos[index] = alumnoActualizado;
        notifyListeners();
      }
    } catch (e) {
      _logger.warning('Error al actualizar datos del alumno: $e');
      rethrow;
    }
  }

  /// Método de conveniencia para actualizar un pago dentro de la ficha de un alumno.
  ///
  /// Permite que cambios en el módulo de pagos se reflejen en el módulo de alumnos
  /// sin necesidad de recargar toda la base de datos.
  void updatePago(Alumno alumno, Pago pagoActualizado) {
    final index = _alumnos.indexWhere((a) => a.getId() == alumno.getId());
    if (index != -1) {
      _alumnos[index].actualizarPagos(pagoActualizado);
      notifyListeners(); // Notifica para refrescar badges de deuda o historial
    }
  }
}
