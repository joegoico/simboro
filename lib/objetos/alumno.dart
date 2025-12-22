import 'package:sistema_gym/objetos/pago.dart';
import 'package:sistema_gym/objetos/disciplina.dart';
import 'package:sistema_gym/services/disciplinas_service.dart';
import 'package:sistema_gym/services/pagos_service.dart';
import 'package:logging/logging.dart';
class Alumno {
  int? _id;
  String _nombre;
  String _apellido;
  String _correoElectronico;
  int _idDisciplina;
  int _idInstitucion;
  final List<Pago> _pagosRealizados = [];

  final PagosService _pagosService = PagosService();
  final _logger = Logger('Alumno');

  Alumno({
    int? id,
    required String nombre,
    required String apellido,
    required String correoElectronico,
    required int idDisciplina,
    required int idInstitucion,
  })  : _id = id,
        _nombre = nombre,
        _apellido = apellido,
        _correoElectronico = correoElectronico,
        _idDisciplina = idDisciplina,
        _idInstitucion = idInstitucion;
  void setId(int id) {
    _id = id;
  }
  void setDisciplina(int idDisciplina) {
    _idDisciplina = idDisciplina;
  }        
  void setNombre(String nombre) {
    _nombre = nombre;
  }
  void setApellido(String apellido) {
    _apellido = apellido;
  }
  void setCorreoElectronico(String correoElectronico) {
    _correoElectronico = correoElectronico;
  }
  void setInstitucion(int idInstitucion) {
    _idInstitucion = idInstitucion;
  } 
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

  void agregarFechaDePago(Pago fechaDePago) {
    try {
      _pagosService.crearPago(fechaDePago);
      insertPagoOrdered(_pagosRealizados, fechaDePago);
    } catch (e) {
      _logger.severe('Error al agregar el pago: $e');
    }
  }

  void eliminarFechaDePago(Pago fechaDePago) {
    try {
      _pagosService.eliminarPago(fechaDePago);
      _pagosRealizados.remove(fechaDePago);
    } catch (e) {
      _logger.severe('Error al eliminar el pago: $e');
    }
  }

  String getNombre() {
    return _nombre;
  }
  String getApellido() {
    return _apellido;
  }
  String getCorreoElectronico() {
    return _correoElectronico;
  }

  List<Pago> getPagosRealizados() {
    return _pagosRealizados;
  }
  int getId() {
    return _id!;
  }
  Future<Disciplina> getDisciplina() async {
    return await DisciplinasService().getDisciplinaById(_idDisciplina);
  }

  void insertPagoOrdered(List<Pago> pagos, Pago newPago) {
  // Si la lista está vacía, simplemente agrega el nuevo pago.
    if (pagos.isEmpty) {
        pagos.add(newPago);
      return;
    }
    
    // Encuentra el índice en que el nuevo pago debe insertarse.
    // Compara las fechas y si newPago es anterior a un pago existente, se inserta justo antes.
    int indexToInsert = pagos.indexWhere((pago) => newPago.getFechaDePago().isBefore(pago.getFechaDePago()));
    
    if (indexToInsert == -1) {
      // Si no se encontró ningún elemento cuyo pago sea posterior a newPago, se agrega al final.
        pagos.add(newPago);
    } else {
        pagos.insert(indexToInsert, newPago);
    }
  }

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

  Map<String, dynamic> toJson() {
    return {
      'nombre': _nombre,
      'apellido': _apellido,
      'correo_electronico': _correoElectronico,
      'DISCIPLINA_id_disciplina': _idDisciplina,
      'INSTITUCION_id_institucion': _idInstitucion,
    };
  }

  static List<Alumno> listFromJson(List<dynamic> jsonList) {
    return jsonList
      .map((e) => Alumno.fromJson(e as Map<String, dynamic>))
      .toList();
  }
}

