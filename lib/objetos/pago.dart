class Pago{
  int? _id;
  DateTime _fechaDePago;
  double _monto;
  bool _descuento;

  Pago({
    int? id,
    required DateTime fechaDePago,
    required double monto,
    required bool descuento,
  }) : _id = id, _fechaDePago = fechaDePago, _monto = monto, _descuento = descuento;
  void setFechaDePago(DateTime fechaDePago) {
    _fechaDePago = fechaDePago;
  }
  void setMonto(double monto) {
    _monto = monto;
  }
  void setDescuento(bool descuento) {
    _descuento = descuento;
  }
  int getId() {
    return _id ?? 0;
  }
  DateTime getFechaDePago() {
    return _fechaDePago;
  }
  double getMonto() {
    return _monto;
  }
  bool getDescuento() {
    return _descuento;
  }
  Pago copy(){
    return Pago(id: _id ?? 0, fechaDePago: _fechaDePago, monto: _monto, descuento: _descuento);
  }

  factory Pago.fromJson(Map<String, dynamic> json) {  
    return Pago(
      id: json['id'],
      fechaDePago: DateTime.parse(json['fechaDePago']),
      monto: json['monto'],
      descuento: json['descuento'],
    );
  }

  static List<Pago> listFromJson(List<dynamic> json) {
    return json.map((e) => Pago.fromJson(e)).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'fechaDePago': _fechaDePago.toIso8601String(),
      'monto': _monto,
      'descuento': _descuento,  
    };
  }
}
