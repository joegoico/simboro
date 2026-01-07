// modelo_alumnos.dart
import 'package:flutter/foundation.dart';
import 'package:sistema_gym/objetos/disciplina.dart'; // Tu modelo Alumno
import 'package:sistema_gym/objetos/precio.dart';
import 'package:sistema_gym/services/disciplinas_service.dart';
import 'package:sistema_gym/services/precios_service.dart';
import 'package:logging/logging.dart';

/// Clase encargada de administrar el estado global de las actividades deportivas.
///
/// Centraliza las operaciones CRUD para las disciplinas y permite la
/// actualización reactiva de los precios asociados a cada una.
class DisciplinasProvider extends ChangeNotifier {
  /// Lista interna que almacena el catálogo de actividades.
  final List<Disciplina> disciplina = [];

  // Servicios de persistencia
  final DisciplinasService _disciplinasService = DisciplinasService();
  final PreciosService _preciosService = PreciosService();

  final _logger = Logger('DisciplinasProvider');
  bool _isLoading = false;

  /// Expone las disciplinas de forma segura para evitar mutaciones externas
  /// accidentales fuera del flujo del Provider.
  List<Disciplina> get disciplinas => List.unmodifiable(disciplina);

  bool get isLoading => _isLoading;

  /// Sincroniza el catálogo local con el servidor para una [institucionId].
  ///
  /// Implementa el patrón 'Loading State' para permitir que la UI
  /// renderice indicadores de progreso (shimmers/spinners).
  Future<void> cargarDisciplinas(int institucionId) async {
    _isLoading = true;
    try {
      final disciplinasFromServer = await _disciplinasService
          .getDisciplinasByInstitucionId(institucionId);
      disciplina.clear();
      disciplina.addAll(disciplinasFromServer);
    } catch (e) {
      _logger.severe('Error crítico al cargar catálogo de disciplinas: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Registra una nueva actividad deportiva y actualiza la UI.
  Future<void> agregarDisciplina(Disciplina nuevaDisciplina) async {
    try {
      final disciplinaCreada = await _disciplinasService.createDisciplina(
        nuevaDisciplina,
      );
      disciplina.add(disciplinaCreada);
      notifyListeners();
    } catch (e) {
      _logger.severe('Error al registrar nueva disciplina: $e');
      rethrow;
    }
  }

  /// Elimina una disciplina del catálogo local y remoto.
  Future<void> eliminarDisciplina(Disciplina disci) async {
    try {
      await _disciplinasService.eliminarDisciplina(disci.getId());
      disciplina.remove(disci);
      notifyListeners();
    } catch (e) {
      _logger.severe(
        'Fallo al intentar eliminar la disciplina ${disci.getId()}: $e',
      );
      rethrow;
    }
  }

  /// Actualiza los metadatos de una disciplina existente.
  Future<void> editarDisciplina(
    Disciplina disci,
    Disciplina nuevaDisciplina,
  ) async {
    try {
      final disciplinaEditada = await _disciplinasService.actualizarDisciplina(
        nuevaDisciplina,
      );
      final index = disciplina.indexWhere(
        (d) => d.getId() == nuevaDisciplina.getId(),
      );
      if (index != -1) {
        disciplina[index] = disciplinaEditada;
        notifyListeners();
      }
    } catch (e) {
      _logger.severe('Error al editar disciplina: $e');
      rethrow;
    }
  }

  /// Gestiona la actualización de una tarifa específica dentro de una disciplina.
  ///
  /// Este método es clave para mantener la **integridad referencial** en el cliente,
  /// ya que actualiza el precio en el servidor y sincroniza el objeto anidado
  /// dentro de la lista de disciplinas.
  void updatePrecio(Disciplina d, Precio nuevoPrecio) {
    // Buscamos la disciplina por ID para asegurar la concordancia
    final indexDisciplina = disciplina.indexWhere(
      (element) => element.getId() == d.getId(),
    );

    if (indexDisciplina != -1) {
      // Persistencia asíncrona (Fire and forget en este caso, o podría ser await)
      _preciosService.updatePrecio(nuevoPrecio);

      // Actualización del modelo de dominio anidado
      disciplina[indexDisciplina].updatePrecio(nuevoPrecio);
      notifyListeners();
    }
  }
}
