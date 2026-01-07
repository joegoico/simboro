/// Representa la entidad legal o comercial que utiliza el sistema.
///
/// Actúa como el contenedor principal de todos los recursos (alumnos, pagos,
/// disciplinas). En una arquitectura distribuida, el ID de la institución
/// garantiza el aislamiento de datos entre diferentes clientes.
class Institucion {
  int? _idInstitucion;
  String _nombre;

  /// Constructor de la entidad.
  ///
  /// [idInstitucion] es opcional para permitir la creación de nuevas instancias
  /// que aún no han sido persistidas en la base de datos (donde el ID es autoincremental).
  Institucion({int? idInstitucion, required String nombre})
    : _idInstitucion = idInstitucion,
      _nombre = nombre;

  // --- Accesores (Getters y Setters) ---

  /// Retorna el identificador único.
  /// Se asume que para operaciones de consulta el ID ya existe.
  int getId() => _idInstitucion!;

  void setId(int idInstitucion) => _idInstitucion = idInstitucion;

  String getNombre() => _nombre;

  void setNombre(String nombre) => _nombre = nombre;

  // --- Serialización y Mapeo ---

  /// Crea una instancia de Institucion a partir de un mapa de valores (JSON).
  ///
  /// Utiliza el mapeo estándar de claves provenientes del backend en Python.
  factory Institucion.fromJson(Map<String, dynamic> json) {
    return Institucion(
      idInstitucion: json['id_institucion'],
      nombre: json['nombre'],
    );
  }

  /// Transforma la instancia en un mapa para persistencia o envío vía API.
  ///
  /// Nótese que no se envía el ID si el backend se encarga de la
  /// asignación de claves primarias.
  Map<String, dynamic> toJson() {
    return {'nombre': _nombre};
  }
}
