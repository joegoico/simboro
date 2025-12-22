// modelo_alumnos.dart
import 'package:flutter/foundation.dart';
import 'package:sistema_gym/objetos/alumno.dart';
import 'package:sistema_gym/objetos/pago.dart';
import 'package:sistema_gym/services/alumnos_service.dart';
import 'package:logging/logging.dart';

class AlumnosModel extends ChangeNotifier {
  final List<Alumno> _alumnos = [];
  final AlumnosService _alumnosService = AlumnosService();
  bool _isLoading = false;
  final _logger = Logger('AlumnosModel');

  List<Alumno> get alumnos => List.unmodifiable(_alumnos);
  bool get isLoading => _isLoading;

  // Cargar alumnos desde el backend
  Future<void> cargarAlumnos(int institucionId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final alumnosFromServer = await _alumnosService.getAlumnosByInstitucionId(institucionId);
      _alumnos.clear();
      _alumnos.addAll(alumnosFromServer);
    } catch (e) {
      _logger.warning('Error al cargar alumnos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> agregarAlumno(Alumno nuevoAlumno) async {
    try {
      final alumnoCreado = await _alumnosService.crearAlumno(nuevoAlumno);
      _alumnos.add(alumnoCreado);
      notifyListeners();
    } catch (e) {
      _logger.warning('Error al agregar alumno: $e');
      rethrow;
    }
  }

  Future<void> eliminarAlumno(Alumno alumno) async {
    try {
      await _alumnosService.eliminarAlumno(alumno.getId());
      _alumnos.remove(alumno);
      notifyListeners();
    } catch (e) {
      _logger.warning('Error al eliminar alumno: $e');
      rethrow;
    }
  }

  Future<void> editarAlumno(Alumno alumno, Alumno nuevoAlumno) async {
    try {
      final alumnoActualizado = await _alumnosService.actualizarAlumno(nuevoAlumno);
      final index = _alumnos.indexWhere((a) => a.getId() == nuevoAlumno.getId());
      if (index != -1) {
        _alumnos[index] = alumnoActualizado;
        notifyListeners();
      }
    } catch (e) {
      _logger.warning('Error al editar alumno: $e');
      rethrow;
    }
  }

  void updatePago(Alumno alumno, Pago pagoActualizado) {
    final index = _alumnos.indexWhere((a) => a.getId() == alumno.getId());
    if (index != -1) {
      _alumnos[index].actualizarPagos(pagoActualizado);
      notifyListeners();
    }
  }

// Agrega otros métodos, como eliminar o editar, si los necesitas
}