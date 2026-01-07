/// Representa un egreso de caja o gasto operativo de la institución.
///
/// Esta clase encapsula la información necesaria para la auditoría financiera,
/// incluyendo el soporte para descripciones opcionales y la serialización
/// compatible con estándares REST (ISO 8601).
class Gasto {
  int _id;
  String _titulo;
  double _monto;
  DateTime _fecha;
  String? _descripcion;

  /// Constructor principal.
  /// Utiliza parámetros nombrados obligatorios para garantizar la integridad del objeto.
  Gasto({
    required int id,
    required String titulo,
    required double monto,
    required DateTime fecha,
    String? descripcion,
  }) : _id = id,
       _titulo = titulo,
       _monto = monto,
       _fecha = fecha,
       _descripcion = descripcion;

  // --- Getters y Setters con Encapsulación ---

  int getId() => _id;
  void setId(int id) => _id = id;

  String getTitulo() => _titulo;
  void setTitulo(String titulo) => _titulo = titulo;

  double getMonto() => _monto;
  void setMonto(double monto) => _monto = monto;

  DateTime getFecha() => _fecha;
  void setFecha(DateTime fecha) => _fecha = fecha;

  String getDescripcion() => _descripcion ?? '';
  void setDescripcion(String descripcion) => _descripcion = descripcion;

  // --- Persistencia y Transferencia de Datos ---

  /// Convierte la instancia en un mapa de datos para envío al servidor.
  ///
  /// La fecha se exporta en formato ISO 8601 para asegurar la compatibilidad
  /// con el backend en Python (FastAPI/Flask) y la base de datos SQL.
  Map<String, dynamic> toJson() {
    return {
      'titulo': _titulo,
      'monto': _monto,
      'fecha': _fecha.toIso8601String(),
      // Nota: Es recomendable incluir el ID y descripción si el backend lo requiere
      'id': _id,
      'descripcion': _descripcion,
    };
  }

  /// Factory para reconstruir un objeto Gasto desde una respuesta JSON.
  static Gasto fromJson(Map<String, dynamic> json) {
    return Gasto(
      id: json['id'],
      titulo: json['titulo'],
      monto: json['monto'].toDouble(), // Asegura la conversión a punto flotante
      fecha: DateTime.parse(json['fecha']),
      descripcion: json['descripcion'],
    );
  }

  // --- Utilidades de Estado ---

  /// Crea una instancia idéntica del objeto actual.
  ///
  /// Patrón de diseño Prototype: Esencial en Flutter para manejar estados temporales
  /// en formularios de edición. Permite modificar una copia del gasto y solo
  /// sobreescribir el original si el usuario confirma la acción.
  Gasto copy() {
    return Gasto(
      id: _id,
      titulo: _titulo,
      monto: _monto,
      fecha: _fecha,
      descripcion: _descripcion,
    );
  }
}
