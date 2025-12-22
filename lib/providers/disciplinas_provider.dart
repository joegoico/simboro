// modelo_alumnos.dart
import 'package:flutter/foundation.dart';
import 'package:sistema_gym/objetos/disciplina.dart'; // Tu modelo Alumno
import 'package:sistema_gym/objetos/precio.dart';
import 'package:sistema_gym/services/disciplinas_service.dart';
import 'package:sistema_gym/services/precios_service.dart';
import 'package:logging/logging.dart';

class DisciplinasProvider extends ChangeNotifier {
  final List<Disciplina> disciplina = [];
  final DisciplinasService _disciplinasService = DisciplinasService();
  final PreciosService _preciosService = PreciosService();
  final _logger = Logger('DisciplinasProvider');
  bool _isLoading = false;

  List<Disciplina> get disciplinas => List.unmodifiable(disciplina);
  bool get isLoading => _isLoading;

  Future<void> cargarDisciplinas(int institucionId) async {
    _isLoading = true;
    try {  
      final disciplinasFromServer = await _disciplinasService.getDisciplinasByInstitucionId(institucionId);
      disciplina.clear();
      disciplina.addAll(disciplinasFromServer);

    } catch (e) {
      _logger.severe('Error al cargar disciplinas: $e');
      //rethrow;
    }
    finally{
      _isLoading = false;
      notifyListeners();
    }
  }
  

  Future<void> agregarDisciplina(Disciplina nuevaDisciplina) async {
    try {
      final disciplinaCreada = await _disciplinasService.createDisciplina(nuevaDisciplina);
      disciplina.add(disciplinaCreada);
      notifyListeners();
    } catch (e) {
      _logger.severe('Error al agregar disciplina: $e');
      rethrow;
    }
  }

  Future<void> eliminarDisciplina(Disciplina disci) async {
    try {
      await _disciplinasService.eliminarDisciplina(disci.getId());
      disciplina.remove(disci);
      notifyListeners();
    } catch (e) {
      _logger.severe('Error al eliminar disciplina: $e');
      rethrow;
    }
  }
  Future<void> editarDisciplina(Disciplina disci, Disciplina nuevaDisciplina ) async {
    try {
      final disciplinaEditada = await _disciplinasService.actualizarDisciplina(nuevaDisciplina);
      final index = disciplinas.indexWhere((d) => d.getId() == nuevaDisciplina.getId());
      if (index != -1) {
        disciplinas[index] = disciplinaEditada;
        notifyListeners();
      }
    } catch (e) {
      _logger.severe('Error al editar disciplina: $e');
      rethrow;
    }
  }
  void updatePrecio(Disciplina d, Precio nuevoPrecio) {
    final indexDisciplina = disciplinas.indexWhere((d) => d.getId() == d.getId());
    if (indexDisciplina != -1) {
      _preciosService.updatePrecio(nuevoPrecio);
      disciplina[indexDisciplina].updatePrecio(nuevoPrecio);
      notifyListeners();
    }
  }
  // Agrega otros métodos, como eliminar o editar, si los necesitas
}