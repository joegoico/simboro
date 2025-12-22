class Miembro {
  final String userId;
  final int institucionId;
  final String rol;
  final DateTime? createdAt;

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

  factory Miembro.fromJson(Map<String, dynamic> json) {
    return Miembro(
      userId: json['user_id'],
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
