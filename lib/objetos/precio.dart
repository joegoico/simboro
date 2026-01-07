/// Define el costo y la frecuencia de una disciplina deportiva.
///
/// Esta entidad permite parametrizar los planes de cobro. Cada instancia
/// representa una opción específica (ej. "3 días por semana") dentro de
/// una actividad mayor.
class Precio {
  int? _id;
  int _cantDias;
  double _precio;
  int _disciplinaId;

  /// Constructor del modelo de tarifas.
  ///
  /// Utiliza inicialización por lista (initializer list) para asignar
  /// valores a los atributos privados.
  Precio({
    int? id,
    required int cantDias,
    required double precio,
    required int disciplinaId,
  }) : _id = id,
       _cantDias = cantDias,
       _precio = precio,
       _disciplinaId = disciplinaId;

  // --- Accesores y Mutadores ---

  void setCantDias(int cantDias) => _cantDias = cantDias;
  void setPrecio(double precio) => _precio = precio;

  int getId() => _id!;
  int getCantDias() => _cantDias;
  double getPrecio() => _precio;

  // --- Serialización y Mapeo ---

  /// Transforma una respuesta masiva del backend en una colección de precios.
  static List<Precio> listFromJson(List<dynamic> json) {
    return json.map((precio) => Precio.fromJson(precio)).toList();
  }

  /// Factory para hidratar el objeto desde un JSON.
  ///
  /// Mapea los nombres de las columnas de la base de datos SQL (`id_precio`, `cant_dias`)
  /// a las propiedades de la clase Dart.
  factory Precio.fromJson(Map<String, dynamic> json) {
    return Precio(
      id: json['id_precio'],
      cantDias: json['cant_dias'],
      precio: json['precio'],
      disciplinaId: json['disciplina_id'],
    );
  }

  /// Serializa el objeto para su persistencia o actualización vía API.
  Map<String, dynamic> toJson() {
    return {
      'cant_dias': _cantDias,
      'precio': _precio,
      'disciplina_id': _disciplinaId,
    };
  }
}
