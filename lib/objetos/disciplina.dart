import 'package:sistema_gym/objetos/precio.dart';

class Disciplina {
  int? _id;
  String _nombre;
  List<Precio> _precios;

  Disciplina({
    int? id,
    required String nombre,
    List<Precio>? precios, // Parámetro opcional y nullable
  }) :_id = id,
       _nombre = nombre,
       _precios = precios ?? []; // Si no se pasa un valor, se asigna una lista mutable nueva 
   // Si no se pasa un valor, se asigna una lista mutable nueva
  void setNombre(String nombre) {
    _nombre = nombre;
  }
  void agregarPrecio(Precio precio) {
    _precios.add(precio);
  }
  void eliminarPrecio(Precio precio) {
    _precios.remove(precio);
  }
  String getNombre() {
    return _nombre;
  }
  List<Precio> getPrecios() {
    return _precios;
  }
  Precio getPrecio(int index) {
    return _precios[index];
  }
  int getId() {
    return _id!;
  }
  void setId(int id) {
    _id = id;
  }

  void updatePrecio(Precio precio) {
    final index = _precios.indexWhere((p) => p.getId() == precio.getId());
    if (index != -1) {
      _precios[index] = precio;
    }
  }
  factory Disciplina.fromJson(Map<String, dynamic> json) {
    return Disciplina(
      id: json['id_disciplina'],
      nombre: json['nombre'],
      precios: json['precios'].map((precio) => Precio.fromJson(precio)).toList(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'nombre': _nombre,
      'precios': _precios.map((precio) => precio.toJson()).toList(),
    };
  }
  static List<Disciplina> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((json) => Disciplina.fromJson(json)).toList();
  }
}
