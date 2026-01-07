/// Representa una transacción de ingreso monetario vinculada a una suscripción.
///
/// Esta clase encapsula los datos de cobro y proporciona utilidades para la
/// manipulación de estados y la comunicación con el backend mediante JSON.
class Pago {
  int? _id;
  DateTime _fechaDePago;
  double _monto;
  bool _descuento;

  /// Constructor principal.
  ///
  /// El [_id] es opcional para permitir la creación de pagos nuevos
  /// que aún no han sido procesados por la base de datos.
  Pago({
    int? id,
    required DateTime fechaDePago,
    required double monto,
    required bool descuento,
  }) : _id = id,
       _fechaDePago = fechaDePago,
       _monto = monto,
       _descuento = descuento;

  // --- Accesores y Mutadores ---

  void setFechaDePago(DateTime fechaDePago) => _fechaDePago = fechaDePago;
  void setMonto(double monto) => _monto = monto;
  void setDescuento(bool descuento) => _descuento = descuento;

  int getId() => _id ?? 0;
  DateTime getFechaDePago() => _fechaDePago;
  double getMonto() => _monto;
  bool getDescuento() => _descuento;

  /// Implementación del Patrón Prototype (Clonación).
  ///
  /// Permite crear una copia independiente del objeto. Vital para
  /// flujos de edición "undo/redo" o para comparar estados antes de persistir.
  Pago copy() {
    return Pago(
      id: _id,
      fechaDePago: _fechaDePago,
      monto: _monto,
      descuento: _descuento,
    );
  }

  // --- Serialización y Mapeo de Datos ---

  /// Factory para instanciar un Pago desde un mapa de datos.
  ///
  /// Utiliza [DateTime.parse] para reconstruir el objeto temporal
  /// a partir de una cadena ISO 8601.
  factory Pago.fromJson(Map<String, dynamic> json) {
    return Pago(
      id: json['id'],
      fechaDePago: DateTime.parse(json['fechaDePago']),
      monto: json['monto'],
      descuento: json['descuento'],
    );
  }

  /// Método utilitario para convertir listas de JSON en colecciones de objetos.
  static List<Pago> listFromJson(List<dynamic> json) {
    return json.map((e) => Pago.fromJson(e)).toList();
  }

  /// Serializa la instancia a un formato compatible con APIs REST.
  ///
  /// El monto se mantiene como double y la fecha se normaliza a string.
  Map<String, dynamic> toJson() {
    return {
      'fechaDePago': _fechaDePago.toIso8601String(),
      'monto': _monto,
      'descuento': _descuento,
    };
  }
}
