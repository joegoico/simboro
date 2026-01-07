/// Representa a un usuario administrativo o staff dentro de una institución.
///
/// Este modelo vincula la identidad global del usuario ([userId]) con una
/// [institucionId] específica, asignándole un [rol] que determina sus
/// permisos dentro de la plataforma.
class Miembro {
  /// Identificador único proveniente del proveedor de autenticación (ej. Supabase Auth).
  final String userId;

  /// Vínculo con la entidad Institución.
  final int institucionId;

  /// Define el nivel de acceso (ej. 'admin', 'trainer', 'editor').
  final String rol;

  /// Fecha de creación del registro en el sistema.
  final DateTime? createdAt;

  // Atributos de perfil (opcionales, provenientes de metadatos de usuario)
  final String? fullName;
  final String? avatarUrl;
  final String? email;

  Miembro({
    required this.userId,
    required this.institucionId,
    required this.rol,
    this.createdAt,
    this.fullName,
    this.avatarUrl,
    this.email,
  });

  /// Factory para hidratar el objeto desde una respuesta de la API.
  ///
  /// Nota: Maneja la conversión de cadenas ISO 8601 a objetos [DateTime]
  /// de forma segura para evitar excepciones por nulos.
  factory Miembro.fromJson(Map<String, dynamic> json) {
    return Miembro(
      userId: json['user_id'],
      // Nota técnica: Se respeta la nomenclatura de la base de datos 'indtitucion'
      institucionId: json['institucion_id_indtitucion'],
      rol: json['rol'],
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'])
              : null,
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      email: json['email'],
    );
  }

  /// Serializa la instancia a JSON para operaciones de creación o actualización.
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'institucion_id_indtitucion': institucionId,
      'rol': rol,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'email': email,
    };
  }
}
