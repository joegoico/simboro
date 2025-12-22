class Precio {
  int? _id;
  int _cantDias;
  double _precio;
  int _disciplinaId;


  Precio({
    int? id,
    required int cantDias,
    required double precio,
    required int disciplinaId,
  })  : _id = id,
        _cantDias = cantDias,
        _precio = precio,
        _disciplinaId = disciplinaId;

  void setCantDias(int cantDias) {
    _cantDias = cantDias;
  }

  void setPrecio(double precio) {
    _precio = precio;
  }

  int getId() {
    return _id!;
  }

  int getCantDias() {
    return _cantDias;
  }

  double getPrecio() {
    return _precio;
  }
  static List<Precio> listFromJson(List<dynamic> json) {
    return json.map((precio) => Precio.fromJson(precio)).toList();
  }
  factory Precio.fromJson(Map<String, dynamic> json) {
    return Precio(
      id: json['id_precio'],
      cantDias: json['cant_dias'],
      precio: json['precio'],
      disciplinaId: json['disciplina_id'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'cant_dias': _cantDias,
      'precio': _precio,
      'disciplina_id': _disciplinaId,
    };
  }
}