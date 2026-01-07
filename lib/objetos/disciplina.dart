import 'package:sistema_gym/objetos/precio.dart';

/// Representa una actividad deportiva o servicio ofrecido por el gimnasio.
///
/// Esta clase gestiona la relación "Uno a Muchos" con los esquemas de [Precio],
/// permitiendo que una misma disciplina posea múltiples aranceles según la
/// frecuencia o categoría.
class Disciplina {
  int? _id;
  String _nombre;

  /// Lista interna de precios asociados. Se inicializa como una lista mutable.
  List<Precio> _precios;

  Disciplina({int? id, required String nombre, List<Precio>? precios})
    : _id = id,
      _nombre = nombre,
      _precios = precios ?? [];

  // --- Gestión de Atributos ---

  void setNombre(String nombre) => _nombre = nombre;
  void setId(int id) => _id = id;

  String getNombre() => _nombre;
  List<Precio> getPrecios() => _precios;
  int getId() => _id!;

  // --- Lógica de Negocio sobre la Colección ---

  /// Añade una nueva tarifa al catálogo interno de la disciplina.
  void agregarPrecio(Precio precio) {
    _precios.add(precio);
  }

  /// Remueve una tarifa específica de la colección.
  void eliminarPrecio(Precio precio) {
    _precios.remove(precio);
  }

  /// Busca y actualiza una instancia de [Precio] dentro de la lista local.
  ///
  /// Utiliza el [id] del precio para encontrar la coincidencia, permitiendo
  /// reflejar cambios realizados en formularios de edición.
  void updatePrecio(Precio precio) {
    final index = _precios.indexWhere((p) => p.getId() == precio.getId());
    if (index != -1) {
      _precios[index] = precio;
    }
  }

  // --- Serialización y Mapeo de Datos ---

  /// Construye una instancia de Disciplina procesando datos anidados.
  ///
  /// Implementa un mapeo recursivo donde el campo 'precios' del JSON
  /// es transformado en una lista de objetos de tipo [Precio].
  factory Disciplina.fromJson(Map<String, dynamic> json) {
    return Disciplina(
      id: json['id_disciplina'],
      nombre: json['nombre'],
      // Mapeo anidado: clave para el rendimiento de la API
      precios:
          (json['precios'] as List<dynamic>?)
              ?.map((precio) => Precio.fromJson(precio))
              .toList(),
    );
  }

  /// Serializa el objeto a JSON, incluyendo su lista de precios.
  Map<String, dynamic> toJson() {
    return {
      'nombre': _nombre,
      'precios': _precios.map((precio) => precio.toJson()).toList(),
    };
  }

  /// Procesa una respuesta masiva de la API para generar el catálogo completo.
  static List<Disciplina> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => Disciplina.fromJson(json)).toList();
  }
}
