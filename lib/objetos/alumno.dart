import 'package:sistema_gym/objetos/pago.dart';
import 'package:sistema_gym/objetos/disciplina.dart';
import 'package:sistema_gym/services/disciplinas_service.dart';
import 'package:sistema_gym/services/pagos_service.dart';
import 'package:logging/logging.dart';

/// Representa a un alumno dentro del sistema Simboro.
///
/// Esta clase no solo actúa como un contenedor de datos (DTO), sino que
/// también gestiona la lógica de negocio relacionada con sus pagos y
/// la comunicación con los servicios de persistencia.
class Alumno {
  // Atributos privados para garantizar la encapsulación.
  int? _id;
  String _nombre;
  String _apellido;
  String _correoElectronico;
  int _idDisciplina;
  int _idInstitucion;

  /// Lista interna de pagos, mantenida de forma privada para controlar
  /// las mutaciones mediante métodos específicos.
  final List<Pago> _pagosRealizados = [];

  final PagosService _pagosService = PagosService();
  final _logger = Logger('Alumno');

  /// Constructor principal para la creación de instancias de Alumno.
  Alumno({
    int? id,
    required String nombre,
    required String apellido,
    required String correoElectronico,
    required int idDisciplina,
    required int idInstitucion,
  }) : _id = id,
       _nombre = nombre,
       _apellido = apellido,
       _correoElectronico = correoElectronico,
       _idDisciplina = idDisciplina,
       _idInstitucion = idInstitucion;

  // --- Setters con lógica de asignación simple ---

  void setId(int id) => _id = id;
  void setDisciplina(int idDisciplina) => _idDisciplina = idDisciplina;
  void setNombre(String nombre) => _nombre = nombre;
  void setApellido(String apellido) => _apellido = apellido;
  void setCorreoElectronico(String correoElectronico) =>
      _correoElectronico = correoElectronico;
  void setInstitucion(int idInstitucion) => _idInstitucion = idInstitucion;

  // --- Lógica de Negocio y Persistencia ---

  /// Actualiza un registro de pago existente tanto en el servidor como en memoria.
  void actualizarPagos(Pago pago) {
    final index = _pagosRealizados.indexWhere((p) => p.getId() == pago.getId());
    if (index != -1) {
      try {
        _pagosService.actualizarPago(pago);
        _pagosRealizados[index] = pago;
      } catch (e) {
        _logger.severe('Error al actualizar el pago: $e');
      }
    }
  }

  /// Registra un nuevo pago.
  ///
  /// Invoca al servicio de persistencia e inserta el pago en la lista local
  /// manteniendo el orden cronológico mediante [insertPagoOrdered].
  void agregarFechaDePago(Pago fechaDePago) {
    try {
      _pagosService.crearPago(fechaDePago);
      insertPagoOrdered(_pagosRealizados, fechaDePago);
    } catch (e) {
      _logger.severe('Error al agregar el pago: $e');
    }
  }

  /// Elimina un pago del historial del alumno y lo persiste en el servidor.
  void eliminarFechaDePago(Pago fechaDePago) {
    try {
      _pagosService.eliminarPago(fechaDePago);
      _pagosRealizados.remove(fechaDePago);
    } catch (e) {
      _logger.severe('Error al eliminar el pago: $e');
    }
  }

  // --- Getters ---

  String getNombre() => _nombre;
  String getApellido() => _apellido;
  String getCorreoElectronico() => _correoElectronico;
  List<Pago> getPagosRealizados() => _pagosRealizados;
  int getId() => _id!;

  /// Recupera de forma asíncrona el objeto completo de la [Disciplina]
  /// asociada mediante su identificador.
  Future<Disciplina> getDisciplina() async {
    return await DisciplinasService().getDisciplinaById(_idDisciplina);
  }

  /// Algoritmo de inserción ordenada por fecha.
  ///
  /// Asegura que la lista de pagos se mantenga organizada cronológicamente (O(n)),
  /// facilitando la visualización en la UI sin necesidad de ordenamientos extras.
  void insertPagoOrdered(List<Pago> pagos, Pago newPago) {
    if (pagos.isEmpty) {
      pagos.add(newPago);
      return;
    }

    int indexToInsert = pagos.indexWhere(
      (pago) => newPago.getFechaDePago().isBefore(pago.getFechaDePago()),
    );

    if (indexToInsert == -1) {
      pagos.add(newPago);
    } else {
      pagos.insert(indexToInsert, newPago);
    }
  }

  // --- Serialización JSON ---

  /// Factory para instanciar un Alumno desde un mapa de datos (API Response).
  factory Alumno.fromJson(Map<String, dynamic> json) {
    return Alumno(
      id: json['id_alumno'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      correoElectronico: json['correo_electronico'],
      idDisciplina: json['DISCIPLINA_id_disciplina'],
      idInstitucion: json['INSTITUCION_id_institucion'],
    );
  }

  /// Convierte la instancia actual en un mapa para su envío al backend.
  Map<String, dynamic> toJson() {
    return {
      'nombre': _nombre,
      'apellido': _apellido,
      'correo_electronico': _correoElectronico,
      'DISCIPLINA_id_disciplina': _idDisciplina,
      'INSTITUCION_id_institucion': _idInstitucion,
    };
  }

  /// Utilidad para procesar listas de alumnos provenientes de la API.
  static List<Alumno> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((e) => Alumno.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
