class Institucion {
  int? _idInstitucion;
  String _nombre;

  Institucion({
    int? idInstitucion,
    required String nombre,
  })  : _idInstitucion = idInstitucion,
        _nombre = nombre;

  int getId() {
    return _idInstitucion!;
  }
  String getNombre() {
    return _nombre;
  }
  void setId(int idInstitucion) {
    _idInstitucion = idInstitucion;
  }
  void setNombre(String nombre) {
    _nombre = nombre;
  }
  factory Institucion.fromJson(Map<String, dynamic> json) {
    return Institucion(
      idInstitucion: json['id_institucion'],
      nombre: json['nombre'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'nombre': _nombre,
    };
  }
  
  
}
